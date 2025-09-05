# Getting Started

## Prerequisites

- PowerShell 5.1 or later.
- Necessary permissions to access the SharePoint Farm.
- Ensure the script is placed in a directory accessible by the user.
- Administrative privileges on the SharePoint Server
- SharePoint farm with User Profile Service Application configured.
- SQL Membership Provider database accessible
- Read access to SQL membership Provider database

## Installation

1. [Download the latest release](https://github.com/luigilink/SPSFbaSync/releases/latest) and unzip to a directory on your SharePoint Server.
2. Prepare your JSON configuration file with the required SqlMembershipProvider and farm details.
3. Add the script in task scheduler by running the following command:

```powershell
.\SPSFbaSync.ps1 -ConfigFile 'contoso-PROD-CONTENT.json' -Action Install -InstallAccount (Get-Credential)
```

> [!IMPORTANT]
> Configure all parameters in JSON before running the script.
> Run the Install mode with the same account than you used the in InstallAccount parameter

## Next Step

For the next steps, go to the [Configuration](./Configuration) page.

## Change log

A full list of changes in each version can be found in the [change log](https://github.com/luigilink/SPSFbaSync/blob/main/CHANGELOG.md).
