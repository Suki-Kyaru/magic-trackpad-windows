# dev.5.4.2 User-Safe Uninstall Validation

Status: FROZEN / VALIDATED
Target: Windows 11 x64
Installer visual baseline: dev.5.4.1 R10.2
Driver lifecycle safety baseline: dev.5.3

## Scope

dev.5.4.2 closes the first user-facing real safe driver-removal lifecycle.

The validated user experience now supports:

```text
Uninstall application only
  -> keep driver

Uninstall application + driver
  -> validate exact driver package
  -> validate device state
  -> export backup
  -> verify backup
  -> delete driver without /force
  -> verify not-installed
  -> uninstall application
```

Connected devices fail closed before backup or deletion.

Silent uninstall remains non-destructive and keeps the driver.

## Host static/build validation

The following gates passed before VM testing:

- Windows 11 bilingual installer baseline remained frozen.
- Destination-folder freedom and R10.2 geometry remained frozen.
- User-facing uninstall invoked the new user-safe removal runtime.
- Connected-device failure had a dedicated bilingual path.
- Silent uninstall remained keep-driver only.
- The VM/lab destructive script was not shipped to users.
- Raw PnPUtil deletion remained isolated from Inno Pascal code.
- Runtime PowerShell source remained Windows PowerShell 5.1 ASCII-compatible.
- Exact driver identity gates were present.
- `no-device` and `paired-not-connected` were explicitly allowed.
- Connected devices explicitly blocked real removal.
- Export-before-delete and four-file backup verification were enforced.
- No hard-coded Published INF names existed.
- No executable `/force` usage existed.
- Required order was export -> verify -> delete -> post-check.

The dev.5.4.2 Setup built successfully.

## VM real user-facing removal

Starting VM state:

```text
driver.installed_count=1
driver.installed=true
driver.published_inf=oem8.inf
driver.state=current
result=current
```

The user selected:

```text
remove application + Magic Trackpad driver
```

The user-safe removal runtime observed:

```text
pre.driver_installed_count=1
pre.driver_published_inf=oem8.inf
pre.driver_original_inf=amtptpdevice.inf
pre.driver_provider=Bingxing Wang, Vito Plantamura
pre.driver_version=2025.3980.1.1000

pre.device_status.exit_code=2
pre.device_state=no-device
pre.device_state_allowed=true
```

The exact package was exported before deletion.

Backup verification passed.

The runtime then executed:

```text
pnputil.exe /delete-driver oem8.inf /uninstall
```

and recorded:

```text
remove.force_used=false
remove.pnputil_exit_code=0
```

PnPUtil reported successful uninstall and driver package deletion.

Post-removal state:

```text
post.driver_status.exit_code=10
post.driver_installed=false
post.driver_installed_count=0
post.driver_state=not-installed
post.result=not-installed
remove.executed=true
remove.completed=true
result=removed
```

The application directory was also removed.

## VM backup evidence

A new timestamped backup directory was created for the user-facing removal.

The backup contained all four expected files:

```text
AmtPtpDevice.cat
amtptpdevice.inf
AmtPtpDeviceUsbUm.dll
AmtPtpHidFilter.sys
```

A prior dev.5.3 backup remained untouched, proving backups are timestamped and
non-destructive to historical evidence.

## VM reinstall recovery

Without restoring the VM snapshot, the same dev.5.4.2 Setup was executed.

The installer first observed:

```text
driver.installed_count=0
driver.installed=false
driver.state=not-installed
result=not-installed
```

It then:

1. verified the frozen upstream payload hashes and signatures;
2. added the Microsoft-signed driver package;
3. received a successful PnPUtil result;
4. dynamically received Published Name `oem8.inf`;
5. re-probed Driver Store state.

Final state:

```text
driver.installed_count=1
driver.installed=true
driver.published_inf=oem8.inf
driver.original_inf=amtptpdevice.inf
driver.provider=Bingxing Wang, Vito Plantamura
driver.current_version=2025.3980.1.1000
driver.state=current
result=current
```

The Published INF number remains dynamic evidence and is never assumed.

## Physical-host connected-device validation

Real host starting state:

```text
device.model=A3120
bluetooth.present=true
bluetooth.remembered=true
bluetooth.paired=true
bluetooth.connected=true
bluetooth.precision=true
driver.bound=true
driver.published_inf=oem116.inf
driver.version=2025.3980.1.1000
result=ready
```

Helper exit code: 0.

The user selected the user-facing "remove driver as well" option.

The uninstaller displayed the bilingual connected-device warning and did not
proceed with destructive work.

The user chose not to continue application-only uninstall.

After the blocked attempt:

```text
application directory exists = true

driver.installed_count=1
driver.installed=true
driver.published_inf=oem116.inf
driver.state=current
result=current
```

Driver-removal log:

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
```

Critically, the blocked log contains no backup command, delete command, or
successful destructive marker.

This proves the connected-device gate runs before backup/delete work.

## Validated device-state policy

Real removal:

```text
no-device              -> allowed
paired-not-connected   -> allowed by validated static contract
ready / connected      -> blocked
unknown/inconsistent   -> blocked
```

The physical host was not destructively tested in the paired-not-connected
state. That path remains covered by the runtime contract and static gates; it
must not be "validated" by unnecessarily deleting the known-good host driver.

## Frozen safety rules

Future work must not weaken:

- dynamic Published INF discovery;
- exactly-one-package identity gate;
- exact Original INF / Provider / Version checks;
- connected-device fail-closed gate;
- backup-before-delete;
- four-file backup verification;
- no `/force`;
- post-delete `not-installed` verification;
- silent uninstall keeps driver;
- unrelated Apple/iPhone driver isolation;
- destructive validation stays off the known-good host unless explicitly
  required.

## Freeze decision

dev.5.4.2 is the frozen Windows 11 x64 installation + user-safe uninstall
lifecycle baseline.

Further work should move to OSS productization, repository quality,
documentation, CI, licensing/source distribution, release reproducibility, and
public maintenance workflows rather than repeatedly exercising the validated
Driver Store core.
