# SPSFbaSync - Release Notes

## [2.0.0] - 2026-07-10

### Added

- `SPSFbaSync.Common` PowerShell module (`src/Modules/SPSFbaSync.Common`) with a
  Public/Private layout, a `.psm1` loader, and a `.psd1` manifest whose `ModuleVersion`
  is the single source of truth for the script version.
- Flat PowerShell data file configuration (`src/Config/CONTOSO-PROD.example.psd1`) loaded
  with `Import-PowerShellDataFile`.
- Pester test suite (`tests/`) and `PSScriptAnalyzerSettings.psd1`.
- `pester.yml` workflow: runs Pester and PSScriptAnalyzer on pull requests.
- `-LogRetentionDays` parameter and automatic transcript-log rotation via `Clear-SPSLogFolder`.
- Wiki `_Sidebar.md` and `Release-Process.md`.

### Changed

- **BREAKING:** restructured `scripts/` into `src/`; the release ZIP now extracts straight
  to `SPSFbaSync.ps1` and `Modules\` (no `src/` wrapper).
- **BREAKING:** configuration migrated from JSON (`*.json`) to a flat PowerShell data file
  (`*.psd1`); `-ConfigFile` now validates a `.psd1` path.
- `release.yml`/`wiki.yml` bumped to `actions/checkout@v7`,
  `softprops/action-gh-release@v3`, `actions/upload-artifact@v7`, with explicit permissions.
- Rewrote the README to point at the wiki and updated all wiki pages for the new layout.
- Rewrote `.github/CONTRIBUTING.md` to point at this project's wiki/issues/discussions.

### Fixed

- Install action now registers the scheduled task with a valid `-File` argument
  (`$fullScriptPath` was undefined).
- Renamed `Set-USPUserProfileProperty` to `Set-SPSUserProfileProperty` (typo).
- Removed the SPSUpdate-inherited "cumulative update" wording and copy-paste bugs in the
  README and wiki.

A full list of changes in each version can be found in the [change log](CHANGELOG.md)
