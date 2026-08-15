# v0.1.0-dev.5.2.2 — instance-id redaction hotfix

The dev.5.2.1 report fixed UTF-8 decoding and redacted the top-level Bluetooth
address, user name, and computer name.

Real-report review found one remaining privacy leak: the Bluetooth device address
was still present inside the machine-specific final segment of some PnP instance
IDs.

dev.5.2.2 changes the default privacy mode to:

- preserve stable hardware identifiers such as VID/PID/MI/collection information;
- redact the final machine-specific device-instance segment;
- retain existing Bluetooth DEV_/BLUETOOTHDEVICE_ redaction;
- retain an explicit `-IncludeIdentifiers` escape hatch for local deep diagnostics.

No driver, install, uninstall, device, registry, Bluetooth, MI_00, or gesture
behavior is changed.
