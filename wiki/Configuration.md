# Configuration

To customize the script for your environment, prepare a JSON configuration file. Below is a sample structure:

```json
{
  "$schema": "http://json-schema.org/schema#",
  "contentVersion": "1.0.0.0",
  "ConfigurationName": "PROD",
  "ApplicationName": "contoso",
  "Settings": {
    "SiteUrl": "https://extranet.contoso.com",
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

`ConfigurationName`: Populates the Environment PowerShell variable.
`ApplicationName`: Populates the Application PowerShell variable.

## Next Step

For the next steps, go to the [Usage](./Usage) page.
