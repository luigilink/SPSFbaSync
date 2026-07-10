@{
    RootModule        = 'SPSFbaSync.Common.psm1'
    ModuleVersion     = '2.1.0'
    GUID              = '77fa42f2-31e4-48e5-ad82-512f27282793'
    Author            = 'Jean-Cyril DROUHIN'
    CompanyName       = 'luigilink'
    Copyright         = '(c) Jean-Cyril DROUHIN. All rights reserved.'
    Description       = 'Shared functions for the SPSFbaSync toolkit (synchronize user information from a SQL Membership Provider / Forms Based Authentication database to the SharePoint User Profile Service, and manage the SPSFbaSync scheduled task).'

    PowerShellVersion = '5.1'

    FunctionsToExport = @(
        'Add-SPSScheduledTask'
        'Backup-SPSJsonFile'
        'Clear-SPSLogFolder'
        'Export-SPSFbaSyncReport'
        'Get-SPSInstalledProductVersion'
        'Remove-SPSScheduledTask'
        'Set-SPSUserProfileProperty'
    )

    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()

    PrivateData = @{
        PSData = @{
            Tags         = @('SharePoint', 'SharePointServer', 'FBA', 'FormsBasedAuthentication', 'UserProfile', 'Membership')
            LicenseUri   = 'https://github.com/luigilink/SPSFbaSync/blob/main/LICENSE'
            ProjectUri   = 'https://github.com/luigilink/SPSFbaSync'
            ReleaseNotes = 'https://github.com/luigilink/SPSFbaSync/blob/main/RELEASE-NOTES.md'
        }
    }
}
