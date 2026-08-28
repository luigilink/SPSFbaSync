# SPSFbaSync - Release Notes

## [3.0.0] - 2026-08-28

### Removed

- **BREAKING:** dropped support for SharePoint Server 2016 and 2019 (both reached end of
  support on 14 July 2026). SPSFbaSync now targets SharePoint Server Subscription Edition only.
- Removed the product-version detection and the deprecated
  `Add-PSSnapin Microsoft.SharePoint.PowerShell` path from the entry script.

### Changed

- The entry script now guards on "is SharePoint installed?" (throwing an explicit error when
  it is not) and loads the `SharePointServer` module idempotently.
- `Get-SPSInstalledProductVersion` is now a presence guard returning `$null` when SharePoint
  is not installed.

### Migration

- Users still running SharePoint Server 2016 or 2019 must stay on the previous major release
  (**v2.1.0**), which retains the PSSnapin path.

A full list of changes in each version can be found in the [change log](CHANGELOG.md)
