# Windows PowerShell 5.1 runtime source-encoding boundary

Windows PowerShell 5.1 must be assumed to run on systems where BOM-less UTF-8
script source is not decoded as UTF-8.

Therefore PowerShell scripts installed for end-user runtime use ASCII source
only.

This restriction applies to:

- installer/Run-SafeInstall.ps1
- scripts/Install-Driver.ps1
- scripts/Verify-DriverPayload.ps1
- scripts/Collect-Diagnostics.ps1
- scripts/Get-UninstallPlan.ps1

Unicode runtime data is still supported:

- Windows device names
- OS descriptions
- helper UTF-8 stdout
- diagnostic reports

Reports are written with `System.Text.UTF8Encoding(false)`.

Localized device discovery must rely on stable hardware identifiers rather than
putting localized non-ASCII names into runtime script source.

Build and compatibility tests enforce this boundary.
