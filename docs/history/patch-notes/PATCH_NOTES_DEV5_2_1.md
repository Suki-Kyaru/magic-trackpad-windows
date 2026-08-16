# v0.1.0-dev.5.2.1 — diagnostics encoding/privacy hotfix

## Real-machine finding

The dev.5.2 uninstall dry-run passed and identified exactly one safe target.

The generated diagnostic report exposed two non-blocking issues:

1. Chinese device names emitted by `MagicTrackpadHelper.exe` could be decoded
   incorrectly when captured by Windows PowerShell, producing mojibake.
2. The default report included the Windows user name, computer name and
   Bluetooth device address.

## Fix

`Collect-Diagnostics.ps1` now launches the helper with
`System.Diagnostics.Process` and explicitly requests UTF-8 stdout/stderr
decoding when supported by the installed .NET runtime.

Diagnostics are privacy-minimized by default:

- computer name -> redacted
- user name -> redacted
- Bluetooth address -> redacted
- Bluetooth device address fragments in Instance IDs -> redacted
- Magic Trackpad USB serial-like container ID -> redacted
- user-profile prefix in helper paths -> `%USERPROFILE%`

For local deep diagnostics, an explicit switch restores full identifiers:

```powershell
.\scripts\Collect-Diagnostics.ps1 -IncludeIdentifiers
```

No driver logic, Driver Store logic, uninstall logic, Bluetooth behavior,
MI_00 behavior or gesture behavior is changed.
