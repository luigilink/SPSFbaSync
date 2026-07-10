function Export-SPSFbaSyncReport {
    <#
        .SYNOPSIS
        Renders a sync result set (or a results JSON file) into a self-contained HTML report.

        .DESCRIPTION
        Export-SPSFbaSyncReport takes the per-user sync result produced by SPSFbaSync -
        either passed directly with -Result, or read from a results JSON file with
        -InputFile - and writes a single self-contained HTML file (no external CSS/JS/CDN,
        so it opens offline on a SharePoint server).

        The report shows:
        - a metadata line (application, environment, generation time, version),
        - summary cards (total users processed, plus Updated / NoChange / Created /
          Errors counts), and
        - an interactive table: one row per processed user, with a status "pill" and the
          Login, UserName, Email and Notes columns. The table supports a search box and
          click-to-sort headers via Get-SPSReportHtmlScript.

        Returns the full path of the HTML file that was written.

        .PARAMETER Result
        The collection of per-user result objects (UserProfileInformation) gathered by
        SPSFbaSync. Mutually exclusive with -InputFile.

        .PARAMETER InputFile
        Path to a results JSON file previously produced by SPSFbaSync. Mutually exclusive
        with -Result. The file is expected to expose a UserProfileInformation array.

        .PARAMETER OutputPath
        Full path of the HTML file to write.

        .PARAMETER Application
        Application / customer short name, shown in the report metadata line.

        .PARAMETER Environment
        Logical environment name (e.g. PROD), shown in the report metadata line.

        .PARAMETER Version
        SPSFbaSync version string, shown in the report metadata line.

        .EXAMPLE
        Export-SPSFbaSyncReport -Result $rows -OutputPath 'D:\Tools\Reports\CONTOSO-PROD.html' -Application 'contoso' -Environment 'PROD' -Version '2.1.0'

        .EXAMPLE
        Export-SPSFbaSyncReport -InputFile 'D:\Tools\Results\CONTOSO-PROD.json' -OutputPath 'D:\Tools\Reports\CONTOSO-PROD.html'
    #>
    [CmdletBinding(DefaultParameterSetName = 'Result')]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'Result')]
        [System.Object]
        $Result,

        [Parameter(Mandatory = $true, ParameterSetName = 'InputFile')]
        [System.String]
        $InputFile,

        [Parameter(Mandatory = $true)]
        [System.String]
        $OutputPath,

        [Parameter()]
        [System.String]
        $Application = '',

        [Parameter()]
        [System.String]
        $Environment = '',

        [Parameter()]
        [System.String]
        $Version = ''
    )

    if ($PSCmdlet.ParameterSetName -eq 'InputFile') {
        if (-not (Test-Path -Path $InputFile)) {
            throw "Export-SPSFbaSyncReport: input file '$InputFile' not found."
        }
        $parsed = Get-Content -Path $InputFile -Raw | ConvertFrom-Json
        if ($null -ne $parsed.UserProfileInformation) {
            $Result = $parsed.UserProfileInformation
        }
        else {
            $Result = $parsed
        }
    }

    $rows = @($Result)

    # Categorise each status into a tone bucket for the pill styling.
    function Get-StatusTone {
        param([System.String] $Status)
        switch -Wildcard ($Status) {
            'Updated' { return 'ok' }
            '*Updated' { return 'ok' }
            'NoChange' { return 'neutral' }
            '*Skipped' { return 'neutral' }
            'MissingProfile' { return 'warn' }
            'Error' { return 'alert' }
            '*Warning' { return 'warn' }
            default { return 'neutral' }
        }
    }

    # Compute summary counts.
    $updatedCount = 0
    $noChangeCount = 0
    $errorCount = 0
    foreach ($row in $rows) {
        switch -Wildcard ("$($row.Status)") {
            'Updated' { $updatedCount++ }
            'UserInfoListUpdated' { $updatedCount++ }
            'NoChange' { $noChangeCount++ }
            'Error' { $errorCount++ }
            '*Warning' { $errorCount++ }
        }
    }

    # Build a status pill.
    function Get-Pill {
        param([System.String] $Value)
        $safe = ConvertTo-SPSHtmlEncoded -Value $Value
        switch (Get-StatusTone -Status $Value) {
            'ok' { return "<span class=`"pill pill-present`">$safe</span>" }
            'alert' { return "<span class=`"pill pill-absent`">$safe</span>" }
            'warn' { return "<span class=`"pill pill-warn`">$safe</span>" }
            default { return "<span class=`"pill pill-na`">$safe</span>" }
        }
    }

    $sb = [System.Text.StringBuilder]::new()

    [void]$sb.Append((Get-SPSReportHtmlHead -Title 'SPSFbaSync - Sync Report'))

    $encApp = ConvertTo-SPSHtmlEncoded -Value "$Application"
    $encEnv = ConvertTo-SPSHtmlEncoded -Value "$Environment"
    $encGen = ConvertTo-SPSHtmlEncoded -Value ((Get-Date).ToUniversalTime().ToString('yyyy-MM-dd HH:mm'))
    $encVersion = ConvertTo-SPSHtmlEncoded -Value "$Version"

    [void]$sb.Append("<h1>SPSFbaSync - Sync Report</h1>")
    [void]$sb.Append("<div class=`"meta`">Application: <strong>$encApp</strong> &middot; Environment: <strong>$encEnv</strong> &middot; Generated: <strong>$encGen</strong> (UTC) &middot; Version: <strong>$encVersion</strong></div>")

    # Summary cards.
    [void]$sb.Append("<div class=`"summary`"><div class=`"cards`">")
    [void]$sb.Append((Get-SPSReportCardHtml -Value $rows.Count -Label 'Users processed' -Sub 'rows in this run' -Tone 'accent'))
    [void]$sb.Append((Get-SPSReportCardHtml -Value $updatedCount -Label 'Updated' -Tone 'clean'))
    [void]$sb.Append((Get-SPSReportCardHtml -Value $noChangeCount -Label 'No change'))
    [void]$sb.Append((Get-SPSReportCardHtml -Value $errorCount -Label 'Errors' -Tone $(if ($errorCount -gt 0) { 'alert' } else { '' })))
    [void]$sb.Append("</div></div>")

    # Controls.
    [void]$sb.Append("<div class=`"controls`"><input id=`"report-search`" class=`"search`" type=`"text`" placeholder=`"Filter rows...`"><span id=`"report-info`" class=`"info`"></span></div>")

    if ($rows.Count -eq 0) {
        [void]$sb.Append("<p class=`"empty`">No users were processed in this run.</p>")
    }
    else {
        [void]$sb.Append("<table id=`"sps-report`"><thead><tr>")
        foreach ($col in @('Login', 'UserName', 'Email', 'Status', 'Notes')) {
            [void]$sb.Append("<th>$col</th>")
        }
        [void]$sb.Append("</tr></thead><tbody>")

        foreach ($row in $rows) {
            [void]$sb.Append("<tr>")
            [void]$sb.Append("<td>$(ConvertTo-SPSHtmlEncoded -Value "$($row.Login)")</td>")
            [void]$sb.Append("<td>$(ConvertTo-SPSHtmlEncoded -Value "$($row.UserName)")</td>")
            [void]$sb.Append("<td>$(ConvertTo-SPSHtmlEncoded -Value "$($row.Email)")</td>")
            [void]$sb.Append("<td>$(Get-Pill -Value "$($row.Status)")</td>")
            [void]$sb.Append("<td>$(ConvertTo-SPSHtmlEncoded -Value "$($row.Notes)")</td>")
            [void]$sb.Append("</tr>")
        }

        [void]$sb.Append("</tbody></table>")
    }

    [void]$sb.Append("<div class=`"footer`">Generated by SPSFbaSync &middot; <a href=`"https://github.com/luigilink/SPSFbaSync`">github.com/luigilink/SPSFbaSync</a></div>")
    [void]$sb.Append((Get-SPSReportHtmlScript))
    [void]$sb.Append("</body></html>")

    $outDir = Split-Path -Path $OutputPath -Parent
    if ($outDir -and -not (Test-Path -Path $outDir)) {
        $null = New-Item -Path $outDir -ItemType Directory -Force
    }

    Set-Content -Path $OutputPath -Value $sb.ToString() -Encoding UTF8
    Write-Verbose -Message "Export-SPSFbaSyncReport: wrote report to '$OutputPath'."

    return $OutputPath
}
