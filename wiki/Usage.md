# Usage Guide for `SPSFbaSync.ps1`

## Overview

`SPSFbaSync.ps1` is a PowerShell script to Synchronize user information (email, display name, etc.) from a SQL Membership Provider (Forms Based Authentication) database to SharePoint User Profile Service.

## Prerequisites

- PowerShell 5.1 or later.
- Necessary permissions to access the SharePoint Farm.
- Ensure the script is placed in a directory accessible by the user.
- Administrative privileges on the SharePoint Server
- SharePoint farm with User Profile Service Application configured.
- SQL Membership Provider database accessible
- Read access to SQL membership Provider database

## Parameters

| Parameter           | Description                                                                                                                                                                                                            |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `WebApplicationUrl` | Target SharePoint Web Application.                                                                                                                                                                                     |
| `-ConfigFile`       | Specifies the path to the configuration file.                                                                                                                                                                          |
| `-Action`           | (Optional) Use the Action parameter equal to Install to add the script in taskscheduler, InstallAccount parameter need to be set. Use the Action parameter equal to Uninstall to remove the script from taskscheduler. |
| `-InstallAccount`   | (Optional) Need parameter InstallAccount whent you use the Action parameter equal to Install.                                                                                                                          |

## Examples

### Example 1: Default Usage Example

```powershell
.\SPSFbaSync.ps1 -ConfigFile 'contoso-PROD.json'
```

### Example 2: Installation Usage Example

```powershell
.\SPSFbaSync.ps1 -ConfigFile 'contoso-PROD.json' -Action Install -InstallAccount (Get-Credential)
```

### Example 3: Uninstallation Usage Example

```powershell
.\SPSFbaSync.ps1 -ConfigFile 'contoso-PROD.json' -Action Uninstall
```

## Logging

The script logs the status of each task, including success or failure, and saves it to the specified log file or the default location.

## Error Handling

- Ensure the provided credentials have access to the SharePoint Farm.

## Notes

- Test the script in a non-production environment before deploying it widely.

## Support

For issues or questions, please contact the script maintainer or refer to the project documentation.
