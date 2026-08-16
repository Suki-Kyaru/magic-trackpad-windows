# dev.6.0 Candidate 1 Release Validation

## Status

Candidate 1 behavioral validation: **PASS**

Final publishable dev.6.0 prerelease: **PENDING**

This document records the first release-candidate validation pass for
`v0.1.0-dev.6.0`. It does not promote Candidate 1 to the final downloadable
binary. Repository documentation/screenshots changed after Candidate 1 was built,
so the publishable binary must be rebuilt from the final clean committed HEAD and
verified again before release.

## Candidate identity

Wrapper source version:

```text
0.1.0-dev.6.0
```

Candidate 1 Setup:

```text
MagicTrackpad-for-Windows-Setup-0.1.0-dev.6.0-x64.exe
```

Candidate 1 Setup SHA256:

```text
b8a3d937e2aaed436697573843a0e3d21294f312cbff9e202c5c6c5f198bbe6a
```

Wrapper Setup Authenticode status:

```text
NotSigned
```

The embedded upstream driver payload remained the pinned Microsoft-signed
MagicTrackpad2ForWindows v2.0 payload and passed the existing payload
hash/signature gate.

The frozen `v0.1.0-dev.5.4.2` Setup identity remained unchanged:

```text
afbe531a5e117820c8643b776b74b82002db27d223366cf07fb390c818aeca04
```

## Clean-VM lifecycle validation

Environment: clean Windows 11 x64 VM with no target application and no target
Driver Store package before the first install.

### 1. Clean install

Precondition:

```text
application=false
target driver package count=0
driver.state=not-installed
```

Observed result:

```text
application=true
target driver package count=1
driver.state=current
result=current
```

The target package was dynamically published as `oem8.inf` in this VM. The
published name is evidence from this run only and is not a product constant.

The installed package identity matched:

```text
original INF: amtptpdevice.inf
provider: Bingxing Wang, Vito Plantamura
version: 2025.3980.1.1000
signer: Microsoft Windows Hardware Compatibility Publisher
```

The install runtime executed under Windows PowerShell 5.1 and completed its
post-install verification.

### 2. Application-only uninstall

The interactive uninstall path selected application removal while keeping the
driver.

Observed result:

```text
application=false
target driver package count=1
driver remained current
```

Decision log normalized evidence:

```text
remove_driver_requested=false
driver_removal_ran=false
driver_removal_completed=false
app_uninstall_started=true
```

The driver-removal tool was not run.

### 3. Reinstall with current driver

The same Candidate 1 Setup was installed again without restoring the VM.

Precondition:

```text
application=false
target driver package count=1
driver.state=current
```

Observed install-gate result:

```text
driver.installed_count=1
driver.state=current
result=current
[PASS] Expected driver is already installed and current.
[NO-OP] No driver-store changes were made.
```

The exact target package count remained one.

### 4. User-safe real driver removal

A snapshot was taken before the destructive VM-only test.

Precondition:

```text
application=true
target driver package count=1
device state=no-device
driver backup directory absent
```

The user selected removal of both the application and the Magic Trackpad driver.

Normalized removal evidence:

```text
pre.driver_installed_count=1
pre.driver_published_inf=oem8.inf
pre.device_state=no-device
pre.device_state_allowed=true

backup.exit_code=0
backup.verified=true

remove.command=pnputil.exe /delete-driver oem8.inf /uninstall
remove.force_used=false
remove.pnputil_exit_code=0

post.driver_status.exit_code=10
post.driver_installed_count=0
post.driver_state=not-installed
post.result=not-installed

remove.executed=true
remove.completed=true
other_apple_drivers_touched=false
result=removed
```

The exported backup contained all four required files:

```text
amtptpdevice.inf
AmtPtpDevice.cat
AmtPtpDeviceUsbUm.dll
AmtPtpHidFilter.sys
```

The application directory was removed and no target Driver Store package remained.

### 5. Reinstall after real removal

Without restoring a VM snapshot, the same Candidate 1 Setup was installed again.

Observed result:

```text
application=true
target driver package count=1
driver.state=current
result=current
```

The safe-removal backup directory remained preserved after reinstall.

This closes the VM lifecycle:

```text
clean
-> install
-> application-only uninstall / keep driver
-> reinstall / Driver Store NO-OP
-> safe real driver removal
-> not-installed
-> reinstall
-> current
```

## Physical-host connected-device fail-closed validation

Environment: Windows 11 x64 physical host with Apple USB-C Magic Trackpad A3120
connected through Bluetooth.

Precondition normalized evidence:

```text
application=true
target driver package count=1
driver.published_inf=oem116.inf
driver.state=current
bluetooth.present=true
bluetooth.paired=true
bluetooth.connected=true
bluetooth.precision=true
result=ready
```

The `oem116.inf` published name is machine-local evidence from this host only and
is not hard-coded by the product.

The connected-device removal guard was exercised while capturing both Simplified
Chinese and English UI evidence.

Recent removal logs closed as:

```text
remove.executed=false
other_apple_drivers_touched=false
pre.driver_installed_count=1
pre.device_state=ready
remove.blocked_reason=device-connected
result=connected
```

After the blocked attempts:

```text
application=true
target driver package count=1
driver.state=current
result=current
```

No Driver Store deletion was executed.

## Bilingual UI evidence

Candidate 1 was used to refresh six README screenshots:

```text
installer-information-en.png
installer-destination-en.png
uninstall-connected-guard-en.png
installer-information-zh-cn.png
installer-destination-zh-cn.png
uninstall-connected-guard-zh-cn.png
```

The English README references only the English set; the Simplified Chinese README
references only the Simplified Chinese set.

## Privacy handling

Raw install/removal/device logs can contain machine-specific values such as user
names, computer names, temporary paths, Bluetooth addresses, or PnP instance
details.

Those raw values are intentionally not copied into this maintained validation
document. Only normalized product-state evidence needed to prove the safety
contracts is retained here.

## Candidate 1 conclusion

Candidate 1 passed the intended behavioral validation matrix:

- clean install;
- exact Driver Store identity;
- application-only uninstall;
- idempotent current-driver reinstall;
- export-before-delete;
- four-file backup verification;
- real removal without `/force`;
- post-delete `not-installed` verification;
- reinstall after removal;
- backup preservation;
- physical-host connected-device fail-closed behavior;
- bilingual installer/guard UI capture.

Candidate 1 is therefore accepted as the behavioral reference for the dev.6.0
release line.

It is **not** the final publishable binary. The final release candidate must be
rebuilt from the final clean committed source state, then receive focused binary
identity/signature/smoke checks and controlled release-bundle verification before
GitHub prerelease publication.
