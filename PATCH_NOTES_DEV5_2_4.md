# v0.1.0-dev.5.2.4 - Windows PowerShell 5.1 source-encoding hotfix

## Root cause

dev.5.2.3 correctly removed the unsupported `utf8NoBOM` output encoding enum,
but `Collect-Diagnostics.ps1` itself was still stored as UTF-8 without BOM and
contained a non-ASCII source literal used to match a localized touchpad name.

Windows PowerShell 5.1 uses legacy encoding rules for BOM-less script source.
On a DBCS locale this can corrupt tokenization before execution begins,
causing cascading parser errors far below the actual non-ASCII source line.

## Fix

Installed/runtime PowerShell scripts are now treated as an ASCII-source
compatibility boundary.

`Collect-Diagnostics.ps1` no longer contains localized source literals.
Relevant devices are still discovered through stable hardware IDs and English
Magic Trackpad identifiers.

.NET constructors use explicit Windows PowerShell-compatible forms:

`New-Object -TypeName ... -ArgumentList ...`

`Test-WindowsPowerShellCompatibility.ps1` now verifies that the dry-run and
diagnostic runtime scripts contain no non-ASCII source bytes before executing
them through the inbox Windows PowerShell engine.

`Build-Installer.ps1` applies the same ASCII gate to every PowerShell script
that will run on an end-user machine.

Runtime output remains Unicode and diagnostic reports remain UTF-8 without BOM.

## Safety

The previous VM run completed the uninstall plan before the diagnostics parser
failure. The target was `oem8.inf`, `uninstall.executed=false`, and a subsequent
Driver Store probe remained `current` with one matching package.
