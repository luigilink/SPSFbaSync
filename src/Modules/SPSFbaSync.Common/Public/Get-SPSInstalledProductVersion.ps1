function Get-SPSInstalledProductVersion {
    <#
        .SYNOPSIS
        Returns the installed SharePoint product version, or $null when SharePoint is not installed.

        .DESCRIPTION
        Reads the file version of Microsoft.SharePoint.dll from the highest installed
        Web Server Extensions hive. Used by the entry script as a guard to confirm that
        SharePoint Server is present before importing the SharePointServer module.
        Returns $null when no SharePoint installation is found.

        .EXAMPLE
        Get-SPSInstalledProductVersion
    #>
    [CmdletBinding()]
    [OutputType([System.Version])]
    param ()

    $pathToSearch = 'C:\Program Files\Common Files\microsoft shared\Web Server Extensions\*\ISAPI\Microsoft.SharePoint.dll'
    $fullPath = Get-Item $pathToSearch -ErrorAction SilentlyContinue | Sort-Object { $_.Directory } -Descending | Select-Object -First 1
    if ($null -eq $fullPath) {
        return $null
    }
    else {
        return ([System.Diagnostics.FileVersionInfo]::GetVersionInfo($fullPath.FullName)).FileVersion
    }
}
