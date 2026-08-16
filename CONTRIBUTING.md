# Contributing to Magic Trackpad for Windows

Thanks for helping improve the project.

This repository wraps a validated third-party Precision Touchpad driver with
installation, diagnostics, lifecycle-management, and release-safety tooling.
Small changes can affect Driver Store state, uninstall safety, or public
redistribution compliance, so contribution rules are intentionally explicit.

## Before you start

Read:

- [README](README.md)
- [Documentation Index](docs/README.md)
- [Contributor Workflow](docs/oss/CONTRIBUTOR_WORKFLOW.md)
- [Repository Agent Map](AGENTS.md)
- [Security Policy](SECURITY.md)

For driver lifecycle or installer work, also read:

- `docs/SAFE_INSTALL_CONTRACT.md`
- `docs/DRIVER_STORE_PROBE_CONTRACT.md`
- `docs/DEV5_4_2_USER_SAFE_UNINSTALL_CONTRACT.md`
- `docs/DEV5_4_2_USER_SAFE_UNINSTALL_VALIDATION.md`
- `docs/OSS_INSTALLER_UX_BASELINE.md`

## Supported contribution areas

Useful contributions include:

- reproducible bug reports;
- diagnostics/privacy improvements;
- documentation;
- build/verification tooling;
- installer accessibility/localization;
- safe lifecycle fixes backed by regression tests;
- additional hardware/architecture validation;
- CI/release engineering.

Please avoid speculative changes to a working safety path without a reproduced
problem or a clearly defined requirement.

## Development environment

The currently validated environment includes:

- Windows 11 x64;
- Visual Studio Community 2026 / MSVC x64;
- Windows SDK 10.0.26100;
- CMake 4.3.1 (minimum 3.25);
- Inno Setup 6.7.0;
- PowerShell 7 for development;
- Windows PowerShell 5.1 compatibility for installed runtime scripts.

Build artifacts belong in `build/` and `out/` and must not be committed.

The third-party driver payload is locally staged under:

```text
third_party/MagicTrackpad2ForWindows-v2.0/
```

and is intentionally excluded from Git.

## Frozen dev.5.4.2 rule

`v0.1.0-dev.5.4.2` is a validated frozen artifact.

Do not rebuild or publish a different Setup binary using that same version.

Future installer work must first move to a new version with matching:

```text
VERSION
installer/setup.iss -> MyAppVersion
```

See `docs/oss/RELEASE_COMPLIANCE.md`.

## Safety-critical rules

Contributions must preserve the contracts summarized in `AGENTS.md`, especially:

- dynamic `oemN.inf` discovery;
- exact driver identity gates;
- no generic Apple-driver deletion;
- no `/force` in normal removal;
- backup-before-delete;
- connected-device fail-closed behavior;
- post-delete verification;
- no automated `MI_00` workaround;
- byte-for-byte upstream signed payload preservation.

A PR that intentionally changes one of these rules must clearly identify the
contract being changed, the reason, and the evidence supporting the change.

## PowerShell runtime compatibility

Installed runtime scripts are intentionally compatible with inbox Windows
PowerShell 5.1.

Do not introduce non-ASCII source into those runtime `.ps1` files without first
changing and validating the encoding strategy.

Use absolute paths when calling `.NET` file APIs. PowerShell's location and
`[Environment]::CurrentDirectory` may differ.

Maintainer scripts that accept `-RepoRoot` must derive their default repository
root from `$PSScriptRoot`; do not commit author-specific absolute clone paths.

## Licensing

Project-authored wrapper code and original documentation are MIT licensed.

The upstream `vitoplantamura/MagicTrackpad2ForWindows` driver/control-panel
payload remains third-party GPLv2 software and is not relicensed by this project.

Do not copy upstream GPL-covered source into wrapper-authored source files or
change the packaging model without reopening the license review documented in
`docs/oss/`.

## Validation

Use the matrix in `docs/oss/CONTRIBUTOR_WORKFLOW.md`.

Every PR should run:

```powershell
git diff --check
.\scripts\Verify-ContributorWorkflow.ps1
.\scripts\Verify-MaintainerPortability.ps1
.\scripts\Verify-CIWorkflow.ps1
```

For a local reproduction of the hosted helper-build job, run:

```powershell
.\scripts\Build-CIHelper.ps1
```

The script resolves CMake from PATH or Visual Studio via `vswhere.exe`.

and all additional checks relevant to the files/behavior changed.

The repository also contains a GitHub Actions workflow that mirrors the
non-destructive OSS/static checks and compiles the C++ helper on a hosted Windows
runner. Hosted CI must not rebuild the frozen dev.5.4.2 installer.

Do not claim a check passed if it was not run.

## Commit and PR scope

Prefer one coherent change per PR.

Good examples:

```text
docs: clarify Bluetooth diagnostics privacy
fix: preserve dynamic Driver Store package discovery
test: add connected-device removal regression
build: tighten release source-bundle verification
```

Avoid mixing:

- unrelated UI redesign;
- driver lifecycle changes;
- license changes;
- broad refactors;

in one PR unless they are inseparable.

## Privacy in bug reports

Do not post raw logs blindly.

`Diagnostics-*.txt` is the preferred shareable diagnostic report because it is
privacy-minimized by default.

Raw install/removal logs can contain machine/user/path identifiers. Review and
redact them before posting.

## Security issues

Do not disclose a security vulnerability with exploit details in a public issue.

Follow [SECURITY.md](SECURITY.md).

## Contributions and copyright

By submitting a contribution, you agree that your contribution is provided
under the repository license applicable to the material you change.

This project currently has no Contributor License Agreement (CLA).
