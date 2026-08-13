# v0.1 Driver Store Probe Contract — dev.3

This milestone remains read-only.

It detects the exact upstream Magic Trackpad driver family in `%WINDIR%\INF`
without requiring the physical trackpad to be connected.

Identity evidence:

1. Published package is an `oem*.inf`.
2. `SetupQueryInfOriginalFileInformationW` reports:
   - original INF: `AmtPtpDevice.inf`
   - original catalog: `AmtPtpDevice.cat`
3. INF `[Strings]` `ManufacturerName` is:
   - `Bingxing Wang, Vito Plantamura`

Expected driver version for the bundled v2.0 package:

`2025.3980.1.1000`

Commands:

```text
MagicTrackpadHelper.exe driver-status
MagicTrackpadHelper.exe driver-status --verbose
```

Exit codes:

- `0`: exactly one matching package, current version.
- `10`: no matching package.
- `11`: exactly one matching package, older version.
- `12`: exactly one matching package, newer version.
- `13`: multiple matching packages.
- `64`: invalid command.

Safety rules carried forward to the installer:

- Current version: installation may be skipped.
- Older version: upgrade may be offered/performed explicitly.
- Newer version: never downgrade silently.
- Multiple matching packages: stop automatic upgrade/uninstall for review.
- Never identify or delete drivers by a loose search for `Apple`.
- Never hard-code a published name such as `oem116.inf`.

No install, uninstall, enable/disable, registry write, device restart or pairing
action is introduced in dev.3.
