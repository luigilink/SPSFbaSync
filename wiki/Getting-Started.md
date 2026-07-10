# Getting Started

## Prerequisites

- PowerShell 5.1 or later.
- Administrative privileges on the SharePoint Server.
- SharePoint farm with a User Profile Service Application configured.
- Access to the SQL Membership Provider (FBA) database (SQL Reader on the membership database).
- The account running the sync needs Farm Admin and Full Control on the User Profile Service Application.

## Installation

1. [Download the latest release](https://github.com/luigilink/SPSFbaSync/releases/latest) and unzip it to a directory on your SharePoint Server. The archive extracts straight to `SPSFbaSync.ps1` and a `Modules\` folder (no `src/` wrapper).
2. Copy `Config\CONTOSO-PROD.example.psd1` to your own `Config\<Application>-<Environment>.psd1` (e.g. `contoso-PROD.psd1`) and adjust the values (see [Configuration](./Configuration)).
3. Register the script as a scheduled task by running:

```powershell
.\SPSFbaSync.ps1 -ConfigFile '.\Config\contoso-PROD.psd1' -Action Install -InstallAccount (Get-Credential)
```

> [!IMPORTANT]
> Fill in all values in the `.psd1` configuration file before running the script.
> Run the Install action with the same account you pass to the `InstallAccount` parameter.

## Next Step

For the next steps, go to the [Configuration](./Configuration) page.

## Change log

A full list of changes in each version can be found in the [change log](https://github.com/luigilink/SPSFbaSync/blob/main/CHANGELOG.md).
