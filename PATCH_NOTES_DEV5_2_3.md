# v0.1.0-dev.5.2.3 — Windows PowerShell 5.1 UTF-8 compatibility hotfix

## VM finding

The uninstall dry-run logic correctly produced:

- safe target: `oem8.inf`
- `uninstall.executed=false`
- exact provider/version
- no unrelated Apple driver target

It then failed only while writing the optional log because Windows PowerShell
5.1 does not accept:

`Set-Content -Encoding utf8NoBOM`

That encoding enum is available in newer PowerShell versions, but the installed
Tools are intentionally launched with the Windows inbox PowerShell engine.

## Fix

Runtime report/log writers now use:

`System.Text.UTF8Encoding(false)`

plus:

`System.IO.File.WriteAllLines(...)`

This provides UTF-8 without BOM on both Windows PowerShell 5.1 and PowerShell 7.

The same fix is applied to:

- `Get-UninstallPlan.ps1`
- `Collect-Diagnostics.ps1`

A new regression script invokes both tools explicitly through the Windows inbox
PowerShell executable.

## Safety

The VM dry-run failure happened after plan calculation and before any delete
operation. Post-failure Driver Store verification still showed:

- installed_count = 1
- published_inf = oem8.inf
- state = current

No driver delete operation was executed.
