# Third-party driver payload

Do not modify or re-sign the upstream driver payload.

For local development, copy the exact contents of the Microsoft-signed upstream
release package into:

`third_party/MagicTrackpad2ForWindows-v2.0/`

Expected layout:

- `AMD64/AmtPtpDevice.inf`
- `AMD64/amtptpdevice.cat`
- `AMD64/AmtPtpDeviceUsbUm.dll`
- `AMD64/AmtPtpHidFilter.sys`
- `ARM64/...`
- `AmtPtpControlPanel.exe`

Current validated upstream release:

- Project: `vitoplantamura/MagicTrackpad2ForWindows`
- Release: `v2.0`
- Asset: `MT2FW11-20260223-MSSigned.zip`

Important:

1. Never edit INF/CAT/SYS/DLL files in place.
2. The installer must deploy the signed driver files byte-for-byte.
3. Before public redistribution, include the upstream GPL-2.0 license and
   corresponding source availability information.
