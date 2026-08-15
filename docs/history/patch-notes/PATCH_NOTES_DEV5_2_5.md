# v0.1.0-dev.5.2.5 - Windows PowerShell 5.1 empty-line binding hotfix

## Real-machine finding

dev.5.2.4 passed:

- ASCII runtime-source gate
- Windows PowerShell 5.1 parsing
- uninstall dry-run execution

The diagnostic report then failed only at the final write call:

`Cannot bind argument to parameter 'Lines' because it is an empty string.`

The report intentionally contains blank separator lines between sections. In
Windows PowerShell 5.1, a mandatory strongly typed string-array parameter can
reject empty-string values during parameter binding.

## Fix

`Write-Utf8NoBomLines` now:

- does not use mandatory string-array binding for report content;
- accepts object-array input;
- explicitly normalizes `$null` to an empty string;
- preserves intentional blank report lines;
- converts the final sequence to `[string[]]` immediately before
  `System.IO.File.WriteAllLines`.

UTF-8 without BOM behavior remains unchanged.

## Scope

No changes to:

- driver detection;
- Driver Store writes;
- uninstall dry-run target logic;
- real driver deletion;
- Bluetooth;
- USB;
- MI_00;
- gestures;
- diagnostic redaction rules.
