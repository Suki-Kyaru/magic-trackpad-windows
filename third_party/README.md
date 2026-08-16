# Third-party driver payload

The Microsoft-signed upstream driver/control-panel payload is staged locally but
is intentionally not committed into this repository.

## Pinned binary

```text
Project: vitoplantamura/MagicTrackpad2ForWindows
Release: v2.0
Asset: MT2FW11-20260223-MSSigned.zip
SHA256: 2870c0c7982ce6aafc3ff763fec2999423dc4bdbd1a2c0e31ca216f26a75714f
```

For local development, prepare the exact release ZIP with:

```powershell
.\scripts\Prepare-DriverPayload.ps1 `
    -SourceZip "C:\path\to\MT2FW11-20260223-MSSigned.zip"

.\scripts\Verify-DriverPayload.ps1
```

The staging directory is:

```text
third_party/MagicTrackpad2ForWindows-v2.0/
```

Expected payload includes:

- `AMD64/AmtPtpDevice.inf`
- `AMD64/amtptpdevice.cat`
- `AMD64/AmtPtpDeviceUsbUm.dll`
- `AMD64/AmtPtpHidFilter.sys`
- corresponding ARM64 payload
- `AmtPtpControlPanel.exe`

## Rules

1. Never edit or re-sign upstream INF/CAT/SYS/DLL files in place.
2. The wrapper deploys the signed payload byte-for-byte.
3. The root MIT `LICENSE` does **not** relicense this upstream component.
4. GNU GPL version 2 text is preserved at `licenses/GPL-2.0.txt`.
5. Public binary release tooling publishes exact upstream corresponding source
   and build provenance alongside the binary bundle.

## Corresponding source evidence

The strongest frozen signed-build source evidence identifies:

```text
source checkout:
8874eaa3994f0e7e40fa40312250bbc5f13cc928

workflow revision:
3611b8c6f4fa06a6912d16bb4b51a47bb8c70afa

v2.0 tag:
6a308eccf6ae4fbc3cdcf267c3a525b4818824e3

Actions run:
22308909844
```

See `docs/oss/UPSTREAM_SOURCE_PROVENANCE.md` and
`docs/oss/RELEASE_COMPLIANCE.md`.
