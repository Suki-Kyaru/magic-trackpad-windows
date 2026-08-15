# Public README Blueprint

The current root README is a pre-OSS development README and is materially stale:
it still describes dev.5.1 and claims clean-VM first-install validation is
pending.

OSS-1.2 should replace it as a coherent public README rather than patching a few
version strings.

## Proposed public README order

### 1. Project identity

Short statement:

- what Magic Trackpad for Windows does;
- that it wraps an upstream Microsoft-signed Precision Touchpad driver;
- that this project focuses on safe installation, diagnostics, lifecycle
  management, and Windows integration.

Avoid implying authorship of the upstream driver.

### 2. Status badges

Later, after CI exists:

- Windows build
- validation / CI
- license
- latest release

Do not add meaningless badge clutter.

### 3. Screenshots

Use real accepted Windows 11 screenshots:

- Installation Information page
- Destination folder page
- connected-device safe-uninstall warning

Redact machine-specific information.

### 4. Supported systems / hardware

Separate "validated" from "upstream may support".

Current project-validated baseline should state:

- Windows 11 x64
- Apple USB-C Magic Trackpad A3120 / PID_0324
- USB + Bluetooth
- Precision Touchpad
- battery / haptics
- native Windows gesture settings

Do not claim ARM64 support until this wrapper is validated on real ARM64
hardware.

### 5. Install

Public user flow:

1. download Setup
2. verify SHA256 when desired
3. run Setup
4. choose destination
5. connect/pair the trackpad
6. use Windows Touchpad Settings

Explain wrapper Setup signature status separately from the Microsoft-signed
driver payload.

### 6. Uninstall

Explain both choices:

- application only / keep driver (default/recommended)
- application + driver

Describe connected-device fail-closed behavior in plain language.

### 7. Safety model

Short user-level summary:

- dynamic exact driver identification
- no generic Apple-driver deletion
- backup before real driver removal
- no `/force`
- post-removal verification

Link to technical validation docs instead of dumping implementation detail into
the README.

### 8. Diagnostics / privacy

Document the Start-menu diagnostic action.

Clarify:

- `Diagnostics-*.txt` is privacy-minimized and intended for support sharing;
- raw install/removal logs can include machine identifiers and should be
  reviewed before public posting.

### 9. Build from source

Keep concise:

- Visual Studio / MSVC
- Windows SDK
- CMake
- Inno Setup
- pinned upstream release staging
- verification/build commands

Detailed build documentation can live under `docs/`.

### 10. Upstream / credits / licensing

Clearly distinguish:

- upstream driver project and authors;
- this wrapper/helper/installer project;
- unmodified upstream signed payload;
- license/source-availability obligations.

Do not finalize the repository license wording until OSS-1.3 is complete.

### 11. Contributing / security

Link to future:

- CONTRIBUTING.md
- SECURITY.md

### 12. Development history

Keep one short note and link to:

```text
docs/README.md
docs/history/
```

Do not expose dozens of raw patch notes in the public README.
