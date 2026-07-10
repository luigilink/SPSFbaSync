# Change log for SPSFbaSync

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0] - 2026-07-10

### Added

- HTML sync report generated on each default run (Reports/<Application>-<Environment>.html),
  produced by the new public function Export-SPSFbaSyncReport (summary cards + interactive,
  filterable/sortable per-user table, self-contained/offline).
- Stable result naming with history: the JSON result is written to a stable
  Results/<Application>-<Environment>.json, and the previous snapshot is archived to
  Results/history/ (via Backup-SPSJsonFile) before each overwrite.
- -HistoryRetentionDays parameter (default 30) to prune archived JSON snapshots.
- Wiki Reports.md page and sidebar entry.

### Changed

- SPSFbaSync.Common now exports Backup-SPSJsonFile and Export-SPSFbaSyncReport.

## [2.0.0] - 2026-07-10

### Added

- SPSFbaSync.Common module (src/Modules/SPSFbaSync.Common) with Public/Private layout,
  a .psm1 loader and a .psd1 manifest whose ModuleVersion is the single source of truth
  for the script version.
- Flat PowerShell data file configuration (src/Config/CONTOSO-PROD.example.psd1) loaded
  with Import-PowerShellDataFile.
- Pester test suite (tests/) and PSScriptAnalyzerSettings.psd1.
- pester.yml workflow running Pester and PSScriptAnalyzer on pull requests.
- -LogRetentionDays parameter and automatic transcript-log rotation via Clear-SPSLogFolder.
- Wiki _Sidebar.md and Release-Process.md pages.

### Changed

- BREAKING: restructured scripts/ into src/; the release ZIP now extracts straight to
  SPSFbaSync.ps1 and Modules\ (no src/ wrapper).
- BREAKING: configuration migrated from JSON to a flat PowerShell data file (.psd1);
  -ConfigFile now validates a .psd1 path.
- Bumped GitHub Actions: checkout@v7, action-gh-release@v3, upload-artifact@v7, with
  explicit workflow permissions.
- Rewrote the README to point at the wiki and updated all wiki pages for the new layout.
- Rewrote .github/CONTRIBUTING.md to point at this project's wiki/issues/discussions.

### Fixed

- Install action now registers the scheduled task with a valid -File argument
  ($fullScriptPath was undefined).
- Renamed Set-USPUserProfileProperty to Set-SPSUserProfileProperty (typo).
- Removed the SPSUpdate-inherited "cumulative update" wording and copy-paste bugs in the
  README and wiki.

## [1.1.0] - 2025-09-19

### Changed

- scripts\SPSFbaSync.ps1

  - Change variable site => WebAppUrl
  - Add UserInfoList update for all SPSite of WebApplication object

- Update Wiki Documentation
  - wiki/Configuration.md
  - wiki/Usage.md

## [1.0.0] - 2025-09-03

### Changed

- README.md
  - Add Requirement and Changelog sections
- release.yml
  - Zip scripts folder and mane it with Tag version
- PULL_REQUEST_TEMPLATE.md => Remove examples and unit test tasks

### Added

- README.md
  - Add code_of_conduct.md badge
- Add CODE_OF_CONDUCT.md file
- Add Issue Templates files:
  - 1_bug_report.yml
  - 2_feature_request.yml
  - 3_documentation_request.yml
  - 4_improvement_request.yml
  - config.yml
- Add RELEASE-NOTES.md file
- Add CHANGELOG.md file
- Add CONTRIBUTING.md file
- Add release.yml file
- Add scripts folder with first version of SPSFbaSync
- Wiki Documentation in repository - Add :
  - wiki/Configuration.md
  - wiki/Getting-Started.md
  - wiki/Home.md
  - wiki/Usage.md
  - .github/workflows/wiki.yml
