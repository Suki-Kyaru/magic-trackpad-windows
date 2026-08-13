# v0.1 Status Probe Contract — dev.2

The status probe now separates Bluetooth device-tree state from real connection
state.

Why:

Windows can keep a paired Bluetooth HID's PnP nodes enumerated even after the
physical device is powered off. Therefore `DIGCF_PRESENT` is not treated as proof
that the remote Bluetooth device is currently connected.

The helper combines:

1. SetupAPI / PnP enumeration for the driver and Precision Touchpad chain.
2. Classic Windows Bluetooth APIs for `remembered`, `paired`, and `connected`.

`MagicTrackpadHelper.exe status`

Exit codes:

- `0`: A3120 is currently usable through an active Precision Touchpad path.
- `2`: no supported A3120 is known to the current probe.
- `3`: A3120 is online/present but Precision Touchpad is not active.
- `4`: A3120 is paired/remembered but Bluetooth is currently disconnected.
- `64`: invalid command line.
- other: internal/unexpected failure.

Output keys:

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

Compatibility note:

`bluetooth.present` is retained from dev.1 but means "Bluetooth PnP tree is
present". Consumers must use `bluetooth.connected` to decide whether the remote
trackpad is currently online.

This milestone remains read-only. It performs no install/uninstall, device
enable/disable, registry writes, pairing, or gesture changes.
