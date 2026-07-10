function Get-SPSInstalledProductVersion {
    <#
        .SYNOPSIS
        Returns the installed SharePoint product version.

        .DESCRIPTION
        Reads the file version of Microsoft.SharePoint.dll from the highest installed
        Web Server Extensions hive. Used by the entry script to decide whether to load
        the SharePoint PowerShell snap-in (2016/2019) or the SharePointServer module
        (Subscription Edition).

        .EXAMPLE
        Get-SPSInstalledProductVersion
    #>
    [CmdletBinding()]
    [OutputType([System.Version])]
    param ()

    $pathToSearch = 'C:\Program Files\Common Files\microsoft shared\Web Server Extensions\*\ISAPI\Microsoft.SharePoint.dll'
    $fullPath = Get-Item $pathToSearch -ErrorAction SilentlyContinue | Sort-Object { $_.Directory } -Descending | Select-Object -First 1
    if ($null -eq $fullPath) {
        Write-Error -Message 'SharePoint path {C:\Program Files\Common Files\microsoft shared\Web Server Extensions} does not exist'
    }
    else {
        return ([System.Diagnostics.FileVersionInfo]::GetVersionInfo($fullPath.FullName)).FileVersion
    }
}
