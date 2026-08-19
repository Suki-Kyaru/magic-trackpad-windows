# v0.1.0-rc.2 Final Stable-Candidate Validation

Status: FROZEN INTERNAL RELEASE CANDIDATE; NOT PUBLICLY TAGGED OR PUBLISHED

Validation date: 2026-08-17

## Frozen identity

Version:

```text
0.1.0-rc.2
```

Source commit:

```text
b54ac7311b1a6e0736e91c2cac248fffcc485e04
```

Source tree:

```text
4f8ba3444993c601e41bf71c4f82e78629711d6c
```

Setup:

```text
MagicTrackpad-for-Windows-Setup-0.1.0-rc.2-x64.exe
bytes=2983225
sha256=e5e7f4d379e096b3513ed8118c1cf09f29152f24c7ac4282b53678aa4d687d40
authenticode=NotSigned
```

Installer runtime ZIP:

```text
bytes=362985
sha256=5ac9fe209f4f0f9068754cc14b462f4e8d5be894fcba563463b7dca91bed63b1
```

Final Helper:

```text
bytes=99328
sha256=59a0ec744bcf34912c15ceb06ddbaa2d7129c4bd492d666f188fb53c3445e014
```

The build-output Helper, installer-runtime root Helper, and Helper embedded in the
runtime ZIP all matched that same SHA256.

The external unique-build receipt was recovered read-only after the binary build
had already completed. No rc.2 rebuild occurred.

Receipt SHA256:

```text
2a8d48cd4ab5a9c1780bbc6eb621dc546579d500b0157ec2b4ff4b209099ed11
```

The outer Setup remains unsigned. The pinned upstream CAT/SYS driver payload
remains the original Microsoft-signed package and passed the existing payload
hash/signature verification.

## Validated support scope

Project-level validation remains intentionally narrow:

```text
Operating system: Windows 11 x64
Hardware: Apple USB-C Magic Trackpad A3120
USB: validated by the established project baseline
Bluetooth: validated
Windows Precision Touchpad: validated
ARM64 wrapper/install lifecycle: not validated
Windows 10 wrapper/install lifecycle: not supported by the current v0.1.0 line
```

The final rc.2 binary smoke did not repeat USB passthrough in VMware. USB behavior
remains covered by the established project baseline; the final physical rc.2 smoke
used the real A3120 over Bluetooth.

Windows 10 x64 build 19044 was separately tested with the frozen rc.1 candidate
and failed at the pinned upstream A3120 MI_01 UMDF function-driver configuration
stage. rc.2 did not reopen that support claim.

## Clean Windows 11 x64 VM

Final rc.2 smoke used Windows 11 x64 build 26100.

Initial state:

- application absent;
- target MagicTrackpad2ForWindows driver package absent;
- no A3120/Trackpad device present;
- the copied Setup matched the frozen rc.2 byte length and SHA256.

Clean install result:

- installed Helper matched the frozen rc.2 Helper SHA256;
- exactly one target Driver Store package was present;
- the VM assigned dynamic published name `oem8.inf`;
- driver state was `current`, exit code 0;
- with no A3120 attached, device state was `no-device`, exit code 2;
- `driver.bound=false`.

Same-version reinstall result:

- Helper identity remained unchanged;
- Driver Store package count remained one;
- no duplicate target package was created;
- driver remained `current`;
- no-device behavior remained exit code 2.

Application-only uninstall result:

- application directory was removed;
- uninstall decision log recorded:

```text
remove_driver_requested=false
driver_removal_ran=false
driver_removal_exit_code=-1
driver_removal_completed=false
app_uninstall_started=true
silent_uninstall=false
```

- the target Driver Store package remained installed;
- PnPUtil and published-name DISM/Get-WindowsDriver checks confirmed the same
  `oem8.inf` package, provider, Microsoft signature, and driver version.

## Physical Windows 11 x64 + A3120

Physical-host final smoke used Windows 11 x64 build 26200.

Before rc.2 installation:

- one current target Driver Store package was present as dynamic `oem116.inf`;
- driver version was `2025.3980.1.1000`;
- the A3120 was connected over Bluetooth;
- the pre-rc.2 installed Helper reported `result=ready`.

The physical host intentionally exercised an in-place wrapper upgrade.

After rc.2 installation:

- the old installed Helper was replaced by the exact frozen rc.2 Helper;
- Helper reported `helper.version=0.1.0-rc.2`;
- Driver Store remained the same `oem116.inf` package;
- no duplicate package was added;
- `bluetooth.connected=true`;
- `bluetooth.precision=true`;
- `driver.bound=true`;
- `result=ready`;
- status exit code was 0;
- Windows PnP reported the Bluetooth Trackpad HID Filter as OK;
- the installed application registration reported version `0.1.0-rc.2`.

## Connected-device fail-closed validation

With the real A3120 still actively connected over Bluetooth, the installed
user-safe driver-removal entry point was invoked directly.

Expected and observed result:

```text
remove.executed=false
other_apple_drivers_touched=false
pre.driver_status.exit_code=0
pre.driver_installed_count=1
pre.driver_published_inf=oem116.inf
pre.driver_original_inf=amtptpdevice.inf
pre.driver_provider=Bingxing Wang, Vito Plantamura
pre.driver_version=2025.3980.1.1000
pre.device_status.exit_code=0
pre.device_state=ready
remove.blocked_reason=device-connected
result=connected
exit_code=61
```

No driver-export path was entered.
No driver-delete path was entered.
No new DriverBackup directory was created.

After the blocked removal attempt:

- the exact rc.2 Helper identity was unchanged;
- driver package remained `oem116.inf`;
- driver state remained `current`;
- the physical A3120 remained Precision-ready;
- status remained `ready`, exit code 0.

## Freeze decision

`v0.1.0-rc.2` is now an immutable internal stable-release candidate.

It must never be rebuilt or reissued under the same version.

No `v0.1.0-rc.2` Git tag was created, and no public rc.2 GitHub Release was
published. Its frozen identity is defined by the exact source commit/tree,
binary SHA256 values, and this validation evidence.

The repository source advances from `0.1.0-rc.2` to final `0.1.0` only after
this freeze is encoded in the build, CI, contributor, and release-compliance
contracts.

The final `0.1.0` release must receive its own unique controlled release-bundle
build and publication identity. It must not reuse or rebuild the rc.2 binary.
