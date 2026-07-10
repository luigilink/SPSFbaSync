@{
    # SPSFbaSync configuration file (PowerShell data file).
    # Copy this example to '<Application>-<Environment>.psd1' (e.g. CONTOSO-PROD.psd1)
    # and adjust the values to match your environment, then run:
    #   .\SPSFbaSync.ps1 -ConfigFile '.\Config\CONTOSO-PROD.psd1'

    # Logical environment name (e.g. PROD, PPRD, DEV). Used in log/result file names.
    ConfigurationName         = 'PROD'

    # Application / customer short name. Used in log/result file names.
    ApplicationName           = 'contoso'

    # Target SharePoint Web Application URL (root site collection is used to bind the
    # User Profile Service context).
    WebApplicationUrl         = 'https://extranet.contoso.com'

    # Connection string to the ASP.NET SQL Membership (FBA) database.
    SqlConnectionString       = 'data Source=localhost;Integrated Security=SSPI;Initial Catalog=aspnetdb'

    # Name of the SQL membership provider, used to build the FBA claim
    # (i:0#.f|<SqlMembershipProviderName>|<userName>).
    SqlMembershipProviderName = 'fbamembershipprovider'

    # Optional custom SQL query. Leave empty to use the built-in query against
    # dbo.vw_aspnet_MembershipUsers (honouring IncludeLockedOut / IncludeNotApproved).
    SqlQuery                  = ''

    # If $true, missing User Profile Service profiles are auto-provisioned.
    CreateIfMissing           = $true

    # If $true, the User Information List (SPUser) is updated across the web application.
    UpdateUserInfoList        = $true

    # If $true, locked-out membership users are included in the default query.
    IncludeLockedOut          = $false

    # If $true, not-approved membership users are included in the default query.
    IncludeNotApproved        = $false
}
