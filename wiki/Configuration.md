# Configuration

To customize the script for your environment, prepare a JSON configuration file. Below is a sample structure:

```json
{
  "$schema": "http://json-schema.org/schema#",
  "contentVersion": "1.0.0.0",
  "ConfigurationName": "PROD",
  "ApplicationName": "contoso",
  "Settings": {
    "WebApplicationUrl": "https://extranet.contoso.com",
    "SqlConnectionString": "data Source=localhost;Integrated Security=SSPI;Initial Catalog=aspnetdb",
    "SqlMembershipProviderName": "fbamembershipprovider",
    "SqlQuery": "",
    "CreateIfMissing": true,
    "UpdateUserInfoList": true,
    "IncludeLockedOut": false,
    "IncludeNotApproved": false
  }
}
```

## Configuration and Application

- `ConfigurationName`: Populates the Environment PowerShell variable.
- `ApplicationName`: Populates the Application PowerShell variable.

## Settings

The Settings section defines parameters for environment setup:

| Parameter                   | Description                                                                       |
| --------------------------- | --------------------------------------------------------------------------------- |
| `WebApplicationUrl`         | Target SharePoint Web Application.                                                |
| `SqlConnectionString`       | Connection string for SQL database access.                                        |
| `SqlMembershipProviderName` | Name of the SQL membership provider.                                              |
| `SqlQuery`                  | Optional SQL query to execute.                                                    |
| `CreateIfMissing`           | If true, add missing user profiles in User Profile Service Application.           |
| `UpdateUserInfoList`        | If true, updates the user info list in SharePoint Site.                           |
| `IncludeLockedOut`          | If true, includes locked-out users from SqlMembershipProvider Database.           |
| `IncludeNotApproved`        | If true, includes users who are not approved from SqlMembershipProvider Database. |

## Next Step

For the next steps, go to the [Usage](./Usage) page.
