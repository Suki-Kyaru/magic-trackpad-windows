# Contributor Workflow and Validation Matrix

Status: OSS-1.4

This document maps change types to validation expectations.

## Principle

Validation should scale with risk.

Documentation-only work should not trigger destructive driver experiments.
Safety-critical lifecycle changes should not be merged with only formatting or
static checks.

## Change classes

### Class A — Documentation / repository metadata

Examples:

- README/docs edits;
- issue/PR templates;
- contribution/security policy;
- non-runtime `.gitattributes` updates.

Minimum:

```powershell
git diff --check
.\scripts\Verify-OSSRepositoryLayout.ps1
.\scripts\Verify-PublicReadme.ps1
.\scripts\Verify-LicenseReviewBaseline.ps1
.\scripts\Verify-LicensePolicyDecision.ps1
.\scripts\Verify-LicenseDistribution.ps1
.\scripts\Verify-ContributorWorkflow.ps1
```

### Class B — Build / release tooling

Examples:

- `Build-Installer.ps1`;
- release-bundle tooling;
- source/provenance packaging;
- static verifier changes.

Run Class A plus the changed tool's dedicated verifier.

If a future version has already been bumped and is intentionally buildable,
perform the relevant build in a clean environment.

Do not bypass the frozen dev.5.4.2 same-version rebuild guard.

### Class C — C++ helper / state contracts

Examples:

- USB/Bluetooth state detection;
- Driver Store probe;
- helper exit codes.

Run relevant helper/status/driver-status tests and compatibility checks.

Preserve machine-readable state/exit-code contracts unless the change explicitly
versions the contract.

### Class D — Installed PowerShell runtime

Examples:

- `Run-SafeInstall.ps1`;
- `Collect-Diagnostics.ps1`;
- `Get-UninstallPlan.ps1`;
- `Invoke-UserSafeDriverUninstall.ps1`.

Run:

```powershell
.\scripts\Test-WindowsPowerShellCompatibility.ps1
```

plus all feature-specific static/runtime verifiers.

Installed runtime script source must retain the established Windows PowerShell
5.1 encoding contract.

### Class E — Installer UI / flow

Examples:

- `installer/setup.iss`;
- localized InfoBefore files;
- uninstall UI decisions.

Run:

- localization/installer contract verifier;
- user-safe uninstall verifier;
- affected build checks on a **new version**;
- manual screenshot/UI regression when layout changes.

Do not casually change the accepted R10.2 geometry.

### Class F — Driver install/remove safety

Examples:

- exact driver identity;
- PnPUtil install/remove;
- backup/post-check;
- connected-device gating.

Requires the strongest review.

At minimum:

- all relevant static verifiers;
- current/no-op state tests;
- uninstall dry-run;
- Windows PowerShell compatibility;
- targeted VM lifecycle validation where behavior actually changed.

Do not repeat destructive physical-host driver removal simply for ceremony when
an equivalent safe VM test covers the change.

## Mandatory repository hygiene

Before commit:

```powershell
git diff --check
git status -sb
```

Never commit:

```text
build/
out/
.vs/
third_party/MagicTrackpad2ForWindows-v2.0/
runtime logs
driver backups
machine-specific diagnostics
signing/private keys
secrets
```

## Reporting validation in PRs

Use three explicit buckets:

```text
Validated:
- ...

Not run:
- ...

Reason not run:
- ...
```

Do not write "tests pass" when only static checks were executed.

## Version/release gate

`v0.1.0-dev.5.4.2`, published prerelease `v0.1.0-dev.6.0`, frozen Windows 10 validation candidate `v0.1.0-rc.1`, and frozen Windows 11 stable-release candidate `v0.1.0-rc.2` are immutable.

Current final stable-release source uses `v0.1.0`; its public stable binary has not yet been published.

Any later installer/release build requires its own new release identity first.

For release assets, follow:

```text
docs/oss/RELEASE_COMPLIANCE.md
```

and run the release verifier before publication.
