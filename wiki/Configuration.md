# Configuration

To customize the script for your environment, prepare a PowerShell data file (`.psd1`). Copy
`Config\CONTOSO-PROD.example.psd1` and adjust the values. Below is the structure:

```powershell
@{
    # Logical environment name (e.g. PROD, PPRD, DEV). Used in log/result file names.
    ConfigurationName         = 'PROD'

    # Application / customer short name. Used in log/result file names.
    ApplicationName           = 'contoso'

    # Target SharePoint Web Application URL.
    WebApplicationUrl         = 'https://extranet.contoso.com'

    # Connection string to the ASP.NET SQL Membership (FBA) database.
    SqlConnectionString       = 'data Source=localhost;Integrated Security=SSPI;Initial Catalog=aspnetdb'

    # Name of the SQL membership provider (used to build the FBA claim).
    SqlMembershipProviderName = 'fbamembershipprovider'

    # Optional custom SQL query. Leave empty to use the built-in query.
    SqlQuery                  = ''

    CreateIfMissing           = $true
    UpdateUserInfoList        = $true
    IncludeLockedOut          = $false
    IncludeNotApproved        = $false
}
```

## Configuration and Application

- `ConfigurationName`: Populates the Environment PowerShell variable (used in log/result file names).
- `ApplicationName`: Populates the Application PowerShell variable (used in log/result file names).

## Settings

| Parameter                   | Description                                                                       |
| --------------------------- | --------------------------------------------------------------------------------- |
| `WebApplicationUrl`         | Target SharePoint Web Application.                                                 |
| `SqlConnectionString`       | Connection string for SQL database access.                                        |
| `SqlMembershipProviderName` | Name of the SQL membership provider.                                              |
| `SqlQuery`                  | Optional SQL query to execute. Leave empty to use the built-in query.             |
| `CreateIfMissing`           | If `$true`, add missing user profiles in the User Profile Service Application.     |
| `UpdateUserInfoList`        | If `$true`, updates the User Information List across the web application sites.    |
| `IncludeLockedOut`          | If `$true`, includes locked-out users from the SQL Membership Provider database.   |
| `IncludeNotApproved`        | If `$true`, includes not-approved users from the SQL Membership Provider database. |

## Next Step

For the next steps, go to the [Usage](./Usage) page.
