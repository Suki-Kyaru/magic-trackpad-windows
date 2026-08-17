# v0.1 Status Probe Contract

The status probe separates device presence, real connection state, and a usable
Precision Touchpad driver path.

## Why

Windows can keep a paired Bluetooth HID's PnP nodes enumerated even after the
physical device is powered off. Likewise, a device node can exist and have a
friendly name without a successfully bound and started function driver.

Therefore neither `DIGCF_PRESENT` nor FriendlyName alone is proof that the
Precision Touchpad path is usable.

## Probe inputs

The helper combines:

1. SetupAPI / PnP enumeration for the A3120 device and Precision Touchpad chain.
2. Configuration Manager DevNode status for `DN_STARTED` / `DN_HAS_PROBLEM`.
3. Classic Windows Bluetooth APIs for `remembered`, `paired`, and `connected`.

## Precision binding readiness

`usb.precision=true`, `bluetooth.precision=true`, and `driver.bound=true` are
fail-closed states.

A target Precision interface counts as bound only when all of the following are
true:

- it is the relevant Precision target interface;
- its driver provider matches the expected upstream provider;
- its installed INF path is non-empty;
- its driver version is non-empty;
- DevNode status was successfully retrieved;
- `DN_STARTED` is set;
- `DN_HAS_PROBLEM` is not set.

FriendlyName may help identify which interface is being inspected, but
FriendlyName never proves that the upstream driver is bound.

Other A3120-related interfaces do not veto a healthy target Precision path.
For example, USB `MI_00` may have a start problem while USB `MI_01` is healthy
and provides the usable Precision Touchpad path.

If DevNode status cannot be retrieved, binding fails closed.

## `status` exit codes

`MagicTrackpadHelper.exe status`

- `0`: A3120 is currently usable through an active Precision Touchpad path.
- `2`: no supported A3120 is known to the current probe.
- `3`: A3120 is online/present but Precision Touchpad is not active.
- `4`: A3120 is paired/remembered but Bluetooth is currently disconnected.
- `64`: invalid command line.
- other: internal/unexpected failure.

## Stable top-level output keys

- `helper.version`
- `os.arch`
- `device.model`
- `usb.present`
- `usb.precision`
- `bluetooth.present`
- `bluetooth.remembered`
- `bluetooth.paired`
- `bluetooth.connected`
- `bluetooth.precision`
- `bluetooth.address`
- `driver.bound`
- `driver.published_inf`
- `driver.version`
- `result`

`driver.bound=true` means at least one target USB/Bluetooth Precision interface
satisfies the binding-readiness rules above.

## Verbose per-device diagnostics

`status --verbose` additionally reports relevant PnP nodes with:

- `device.name`
- `device.instance_id`
- `device.inf`
- `device.provider`
- `device.driver_version`
- `device.devnode_status`
- `device.started`
- `device.has_problem`
- `device.problem_code`

`device.devnode_status` is the raw Configuration Manager DevNode status value.

`device.started` reflects `DN_STARTED`.

`device.has_problem` reflects `DN_HAS_PROBLEM`.

`device.problem_code` is populated only when `DN_HAS_PROBLEM` is set; otherwise
the field is intentionally empty. A zero or empty problem code is not, by
itself, proof that a device is started or usable.

## Bluetooth compatibility note

`bluetooth.present` is retained from the original probe contract and means
"Bluetooth PnP tree is present". Consumers must use `bluetooth.connected` to
decide whether the remote trackpad is currently online.

## Safety

The status probe remains read-only. It performs no install/uninstall, device
enable/disable, registry writes, pairing, Driver Store mutation, or gesture
changes.
