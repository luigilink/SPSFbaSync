# SPSFbaSync - Release Notes

## [2.1.0] - 2026-07-10

### Added

- HTML sync report: each default run now generates a self-contained
  `Reports\<Application>-<Environment>.html` (summary cards + interactive per-user table),
  produced by the new public function `Export-SPSFbaSyncReport`.
- Stable result naming with history: the JSON result is written to a stable
  `Results\<Application>-<Environment>.json`, and the previous snapshot is archived to
  `Results\history\` (via `Backup-SPSJsonFile`) before each overwrite.
- `-HistoryRetentionDays` parameter (default 30) to prune archived JSON snapshots.
- Wiki `Reports.md` page documenting the report and retention.

### Changed

- `SPSFbaSync.Common` now exports `Backup-SPSJsonFile` and `Export-SPSFbaSyncReport`.

A full list of changes in each version can be found in the [change log](CHANGELOG.md)
