# v0.1.0-dev.5.1 — UAC launch + Chinese wizard hotfix

## Real-machine findings from dev.5

The first Inno Setup preview successfully:

- preserved the existing current driver (`oem116.inf`);
- kept installed driver count at 1;
- installed the control panel, documentation and shortcuts;
- created the uninstaller.

Two installer UX defects were observed:

1. The Setup wizard shell remained English.
2. Selecting "打开 Magic Trackpad 控制面板" on the Finish page failed with
   Windows error 740 ("The requested operation requires elevation").

## Root cause of error 740

The upstream `AmtPtpControlPanel.exe` manifest declares:

`requestedExecutionLevel level="requireAdministrator"`

Inno Setup's `postinstall` entries normally run as the original, normally
non-elevated user. Starting this requireAdministrator executable through the
normal CreateProcess path therefore failed with error 740.

## Fix

The [Run] entry now adds:

`runascurrentuser`

This makes the post-install process inherit Setup's already elevated credentials.

## Chinese wizard

The build script now detects a local Inno Setup
`Languages\ChineseSimplified.isl` file and uses it when available.

The installer also contains Chinese overrides for its main wizard flow so that
the important pages and buttons remain Chinese even when the local Inno Setup
installation does not ship the translation file.

No driver logic, C++ helper, signed payload, Driver Store state, MI_00 behavior,
Bluetooth pairing or gesture settings are changed.
