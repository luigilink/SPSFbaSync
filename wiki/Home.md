# SPSFbaSync - SharePoint Cumulative Update Tool

SPSFbaSync is a PowerShell script to Synchronize user information (email, display name, etc.) from a SQL Membership Provider (Forms Based Authentication) database to SharePoint User Profile Service Application.

## Key Features

- Reads user data from `dbo.vw_aspnet_MembershipUsers` (or custom SQL query).
- Updates **User Profile Service** properties:
  - `WorkEmail`
  - `PreferredName`
  - `FirstName`
  - `LastName`
- Optionally updates **User Information List** (`SPUser`) for alerts and people pickers.
- Supports:
  - `-CreateIfMissing` → auto-create missing profiles
  - `-UpdateSiteUserInfo` → sync SPUser email/display name
  - `-WhatIf` → safe dry-run
- Generates a json file of all actions.

For details on usage, configuration, and parameters, explore the links below:

- [Getting Started](./Getting-Started)
- [Configuration](./Configuration)
- [Usage](./Usage)
