# VM real driver-removal validation contract

## Safety boundary

The first destructive test is restricted to a VM where no Magic Trackpad is
present, remembered, paired or connected.

A physical host must not pass the `no-device` gate.

The test also requires an explicit published INF value copied from the VM's
successful dry-run. This prevents a command prepared for `oem8.inf` from
silently deleting a different package on another Windows installation.

## Before executing

Create a VM snapshot named, for example:

```text
Before-Real-Driver-Uninstall-dev5.3
```

Then install dev.5.3 over the existing VM installation and confirm
`driver-status` is still current.

## Execute

From the installed Tools directory, run through Windows PowerShell 5.1 with
ExecutionPolicy Bypass.

Expected result:

```text
remove.executed=true
remove.completed=true
post.driver_status.exit_code=10
post.result=not-installed
other_apple_drivers_touched=false
result=removed
```

A backup export and persistent removal log must exist under ProgramData.

## Reinstall

Rerun dev.5.3 Setup.

Expected safe-install transition:

```text
not-installed -> install -> current
```

Exactly one matching package must exist after reinstall.

Do not assume Windows will reuse the same published `oemN.inf` number.
