# v0.1.0-dev.5.4.2 - user-facing safe driver removal

dev.5.4.2 connects a new user-safe removal runtime to the existing bilingual
uninstaller. The dev.5.3 VM/lab script remains in the repository as a frozen
validation reference but is no longer shipped to end users.

Allowed real removal states:
- no-device
- paired-not-connected

Blocked:
- actively connected / ready
- unknown device state
- non-current, ambiguous, older, or newer driver state

The exact dynamically discovered package is exported and all four payload files
are verified before deletion. `/force` is never used. Post-delete verification
must return `not-installed`.

Silent uninstall remains non-destructive and keeps the driver.

If removal is blocked or fails, the interactive UI offers to continue removing
only the application while preserving the driver, or cancel and retry later.

First destructive dev.5.4.2 validation must remain inside the VM.
