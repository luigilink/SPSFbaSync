# Usage Guide for `SPSFbaSync.ps1`

## Overview

`SPSFbaSync.ps1` synchronizes user information (email, display name, etc.) from a SQL Membership Provider (Forms Based Authentication) database to the SharePoint User Profile Service, and optionally to the User Information List.

## Prerequisites

- PowerShell 5.1 or later.
- Administrative privileges on the SharePoint Server.
- SharePoint farm with a User Profile Service Application configured.
- Access to the SQL Membership Provider (FBA) database.

## Parameters

| Parameter           | Description                                                                                                                                                                             |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `-ConfigFile`       | **Mandatory.** Path to the `.psd1` configuration file.                                                                                                                                 |
| `-Action`           | (Optional) `Default` runs the sync (default). `Install` registers the scheduled task (requires `-InstallAccount`). `Uninstall` removes the scheduled task.                             |
| `-InstallAccount`   | (Optional) Credential required when `-Action Install` is used. The account runs the scheduled task.                                                                                    |
| `-LogRetentionDays` | (Optional) Number of days of transcript logs to keep in the `Logs` folder. Defaults to 180. Set to 0 to disable pruning.                                                               |

> Configuration values such as `WebApplicationUrl`, `SqlConnectionString`, and `SqlMembershipProviderName` are defined in the `.psd1` file (see [Configuration](./Configuration)), not passed as script parameters.

## Examples

### Example 1: Default sync run

```powershell
.\SPSFbaSync.ps1 -ConfigFile '.\Config\contoso-PROD.psd1'
```

### Example 2: Install the scheduled task

```powershell
.\SPSFbaSync.ps1 -ConfigFile '.\Config\contoso-PROD.psd1' -Action Install -InstallAccount (Get-Credential)
```

### Example 3: Uninstall the scheduled task

```powershell
.\SPSFbaSync.ps1 -ConfigFile '.\Config\contoso-PROD.psd1' -Action Uninstall
```

### Example 4: Dry-run

```powershell
.\SPSFbaSync.ps1 -ConfigFile '.\Config\contoso-PROD.psd1' -WhatIf
```

## Logging

The script writes a transcript log per run to the `Logs` folder and a JSON result file (one row per processed user, with a Status such as `Updated`, `NoChange`, `MissingProfile`, or `Error`) to the `Results` folder. Old transcript logs are pruned based on `-LogRetentionDays`.

## Error Handling

- Ensure the provided credentials have access to the SharePoint Farm and the SQL membership database.
- Critical configuration values (`WebApplicationUrl`, `SqlConnectionString`, `SqlMembershipProviderName`) are validated before the sync runs.

## Notes

- Test the script in a non-production environment before deploying it widely.

## Support

For issues or questions, open an [issue](https://github.com/luigilink/SPSFbaSync/issues) or start a [discussion](https://github.com/luigilink/SPSFbaSync/discussions).
