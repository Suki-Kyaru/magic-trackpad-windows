# Support

## Before opening an issue

Please check:

- [README](README.md)
- [Documentation Index](docs/README.md)
- existing GitHub issues once the public repository is available.

## Best diagnostic attachment

Use the Start-menu action **Generate Diagnostic Report** and attach the resulting:

```text
Diagnostics-*.txt
```

It is privacy-minimized by default.

Raw technical logs may contain machine/user/path identifiers. Review and redact
them before sharing publicly.

## Include in a bug report

Please provide:

- project version;
- Windows version/build;
- x64/ARM64;
- Magic Trackpad model if known;
- USB or Bluetooth;
- whether Windows Precision Touchpad settings appear;
- exact steps to reproduce;
- expected behavior;
- actual behavior;
- sanitized diagnostic report;
- relevant screenshots.

## Scope

This repository focuses on the wrapper/install/diagnostic/lifecycle layer around
the upstream driver.

For problems clearly inside the upstream driver's touch-processing behavior,
maintainers may ask you to reproduce or report the issue upstream as well.

## Current release OS support

The current `v0.1.0` stable source line supports Windows 11 x64. The frozen `v0.1.0-rc.2` candidate completed the final Windows 11 x64 validation.
`v0.1.0-rc.1` was tested on Windows 10 x64 build 19044, but the pinned
Microsoft-signed upstream driver could not configure the A3120 `MI_01` UMDF
function-driver path. The current `v0.1.0` line therefore does not support Windows 10.

## Unsupported / not yet validated

The wrapper currently does not claim project-level validation for:

- ARM64 installation/lifecycle;
- Windows 10 installation/lifecycle with the current pinned upstream driver package;
- automatic cleanup of ambiguous historical driver packages;
- arbitrary Apple pointing-device models not covered by the validated baseline.

Reports are still useful, but "not yet validated" is different from a promise of
support.
