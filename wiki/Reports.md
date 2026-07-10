# Reports & Audit

From version **2.1.0**, every default sync run produces a self-contained HTML report in the
`Reports\` folder, alongside the JSON result in `Results\`.

## What is generated

| Artifact | Path | Notes |
|---|---|---|
| HTML report | `Reports\<Application>-<Environment>.html` | Stable name, overwritten each run. Opens offline (no CDN). |
| JSON result | `Results\<Application>-<Environment>.json` | Stable name, overwritten each run. |
| JSON history | `Results\history\<Application>-<Environment>-<timestamp>.json` | Previous result, archived before each overwrite. |
| Transcript log | `Logs\<Application>-<Environment>_<timestamp>.log` | One per run. |

The report is self-contained (inline CSS/JS, no external dependency), so it opens directly on
a SharePoint server with no internet access.

## What the report shows

- A metadata line: application, environment, generation time (UTC), and SPSFbaSync version.
- Summary cards: total users processed, plus **Updated**, **No change**, and **Errors** counts.
- An interactive per-user table (Login, UserName, Email, Status, Notes) with:
  - a **search box** that filters rows as you type, and
  - **click-to-sort** column headers.

Each row carries a colour-coded status pill (e.g. `Updated`, `NoChange`, `MissingProfile`,
`Error`, `UserInfoListUpdated`).

## Retention

Two independent retention windows keep the folders tidy:

| Parameter | Default | Controls |
|---|---|---|
| `-LogRetentionDays` | 180 | Transcript logs in `Logs\`. |
| `-HistoryRetentionDays` | 30 | Archived JSON snapshots in `Results\history\`. |

Set either to `0` to disable pruning.

```powershell
.\SPSFbaSync.ps1 -ConfigFile '.\Config\contoso-PROD.psd1' -HistoryRetentionDays 90
```

## Regenerating a report from a past result

`Export-SPSFbaSyncReport` (from the `SPSFbaSync.Common` module) can rebuild an HTML report
from any archived JSON result:

```powershell
Import-Module .\Modules\SPSFbaSync.Common\SPSFbaSync.Common.psd1
Export-SPSFbaSyncReport -InputFile '.\Results\history\contoso-PROD-20260710-1200.json' `
                        -OutputPath '.\Reports\contoso-PROD-20260710-1200.html'
```

## See also

- [Usage](./Usage)
- [Configuration](./Configuration)
