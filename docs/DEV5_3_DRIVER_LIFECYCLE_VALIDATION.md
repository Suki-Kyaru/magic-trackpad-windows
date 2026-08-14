# dev.5.3 Driver Lifecycle Validation

Status: FROZEN / VALIDATED
Target: Windows 11 x64
Upstream driver: MagicTrackpad2ForWindows v2.0
Expected driver version: 2025.3980.1.1000
Expected provider: Bingxing Wang, Vito Plantamura

## Scope

This validation closes the first complete safe driver lifecycle for the
Magic Trackpad for Windows wrapper installer.

The validated lifecycle is:

```text
clean / not-installed
    -> Setup install
    -> current

current
    -> repeated Setup
    -> NO-OP / current

current
    -> exact uninstall dry-run
    -> current

current
    -> safe export-before-delete
    -> real driver removal
    -> not-installed

not-installed
    -> Setup reinstall
    -> current

current
    -> exact uninstall dry-run again
    -> current
```

## Physical-host validation

Real A3120 USB-C Magic Trackpad validation already established:

- USB operation
- Bluetooth operation
- Windows Precision Touchpad integration
- battery reporting
- haptic operation
- native Windows gesture configuration
- current-driver NO-OP install path
- dynamic Driver Store identification

The host published INF observed during validation was `oem116.inf`.

That value is evidence only and is never hard-coded.

## Clean Windows 11 x64 VM validation

The clean VM initially reported:

```text
driver.installed_count=0
driver.installed=false
driver.state=not-installed
result=not-installed
```

First Setup installation transitioned the VM to exactly one matching current
driver package.

The VM published INF was dynamically assigned as:

```text
oem8.inf
```

A repeated Setup run kept exactly one package and took the current-driver
NO-OP path.

## Windows PowerShell 5.1 compatibility

Installed runtime PowerShell scripts were validated against the inbox Windows
PowerShell 5.1 engine.

Compatibility work closed the following issues:

1. `utf8NoBOM` is not a valid Windows PowerShell 5.1 `Set-Content` encoding.
2. BOM-less UTF-8 script source containing non-ASCII literals is unsafe for
   Windows PowerShell 5.1 parsing on legacy code-page systems.
3. Mandatory strongly typed string-array binding can reject intentionally blank
   report separator lines.

The final compatibility baseline is:

- runtime PowerShell source is ASCII-only;
- Unicode runtime data remains supported;
- diagnostic reports are UTF-8 without BOM;
- .NET `UTF8Encoding(false)` is used for runtime report/log writing;
- compatibility tests explicitly invoke Windows PowerShell 5.1.

## Diagnostic validation

Shareable diagnostic reports were validated to:

- decode Chinese device names correctly;
- redact computer name;
- redact user name;
- redact Bluetooth address;
- redact machine-specific device-instance tails;
- preserve stable hardware information useful for troubleshooting.

A no-device VM report correctly returned:

```text
device.model=not-detected
result=no-device
```

## Uninstall dry-run validation

Dry-run validation proved that published INF selection is dynamic.

Physical host:

```text
uninstall.target_published_inf=oem116.inf
```

VM:

```text
uninstall.target_published_inf=oem8.inf
```

Both runs reported:

```text
uninstall.executed=false
uninstall.safe_target=true
uninstall.other_apple_drivers_touched=false
result=plan-ready
```

Driver Store state remained unchanged after dry-run.

## First real driver-removal validation

The destructive experiment was restricted to the no-device VM and required:

- administrator token;
- exact expected published INF;
- exact confirmation token;
- exactly one current matching package;
- exact Original INF;
- exact provider;
- exact driver version;
- `no-device` state;
- successful export before delete;
- exported `amtptpdevice.inf` verification;
- no `/force`.

The VM successfully exported the package, then executed:

```text
pnputil.exe /delete-driver oem8.inf /uninstall
```

PnPUtil reported successful uninstall and package deletion.

Post-removal helper state was:

```text
driver.installed_count=0
driver.installed=false
driver.state=not-installed
result=not-installed
```

Helper exit code: 10.

The exported backup contained:

- AmtPtpDevice.cat
- amtptpdevice.inf
- AmtPtpDeviceUsbUm.dll
- AmtPtpHidFilter.sys

## Reinstall-after-removal validation

Without restoring the VM snapshot, the same dev.5.3 Setup was run again.

The installer first observed:

```text
driver.installed_count=0
driver.installed=false
driver.state=not-installed
result=not-installed
```

It then:

1. verified driver payload hashes and signatures;
2. called PnPUtil to add the Microsoft-signed package;
3. received a successful package-add result;
4. re-probed Driver Store state.

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

The fact that Windows reused `oem8.inf` is valid behavior. No published-INF
number is assumed by the implementation.

A final uninstall dry-run again dynamically selected the current VM package and
returned `plan-ready` without modifying Driver Store state.

## Frozen safety rules

The validated low-level lifecycle must not be weakened.

Do not:

- search or remove drivers using a generic `Apple` string;
- hard-code `oem8.inf`, `oem116.inf`, or any other published INF number;
- silently downgrade a newer package;
- silently upgrade an older package until upgrade semantics are designed and
  separately validated;
- auto-resolve multiple matching packages;
- use `/force` for normal removal;
- alter MI_00 as part of install/uninstall;
- auto-pair Bluetooth;
- modify Windows gesture configuration;
- delete unrelated iPhone / Apple Mobile Device drivers.

## Validation freeze

The low-level Windows 11 x64 lifecycle is considered validated at dev.5.3.

Further work should focus on user-facing uninstall UX, logging presentation,
licensing/source distribution, wrapper signing, and later architecture
expansion rather than repeatedly modifying the validated Driver Store core.
