# SPSFbaSync - FBA to User Profile Sync Tool

SPSFbaSync is a PowerShell script to synchronize user information (email, display name, etc.) from a SQL Membership Provider (Forms Based Authentication) database to the SharePoint User Profile Service Application.

## Key Features

- Reads user data from `dbo.vw_aspnet_MembershipUsers` (or a custom SQL query).
- Updates **User Profile Service** properties:
  - `WorkEmail`
  - `PreferredName`
  - `FirstName`
  - `LastName`
- Optionally updates the **User Information List** (`SPUser`) for alerts and people pickers.
- Configuration-driven toggles:
  - `CreateIfMissing` -> auto-create missing profiles
  - `UpdateUserInfoList` -> sync SPUser email/display name across the web application
  - `IncludeLockedOut` / `IncludeNotApproved` -> widen the default membership query
- Supports `-WhatIf` for a safe dry-run.
- Manages its own Windows scheduled task via the `-Action Install` / `-Action Uninstall` parameter.
- Generates a JSON result file and a self-contained **HTML sync report** of all actions, and rotates its own transcript logs.

For details on usage, configuration, and parameters, explore the links below:

- [Getting Started](./Getting-Started)
- [Configuration](./Configuration)
- [Usage](./Usage)
- [Reports & Audit](./Reports)
- [Release Process](./Release-Process)
