# AGENTS.md

This file is the repository-level map for coding agents.

Keep it short. Detailed contracts and historical evidence live under `docs/`.

## Start here

Before changing code, read the documents relevant to the task:

- `README.md` — public project scope and supported baseline.
- `docs/README.md` — technical documentation index.
- `docs/OSS_INSTALLER_UX_BASELINE.md` — frozen installer UX/safety baseline.
- `docs/DEV5_4_2_USER_SAFE_UNINSTALL_CONTRACT.md` — user-safe removal contract.
- `docs/DEV5_4_2_USER_SAFE_UNINSTALL_VALIDATION.md` — historical validated baseline evidence.
- `docs/DEV6_0_FINAL_RELEASE_VALIDATION.md` — first public prerelease identity and final validation evidence.
- `docs/RC2_FINAL_VALIDATION.md` — frozen rc.2 stable-candidate identity and final Windows 11 validation evidence.
- `docs/oss/RELEASE_COMPLIANCE.md` — release/source-distribution rules.
- `docs/oss/CONTRIBUTOR_WORKFLOW.md` — change-risk and validation matrix.

## Frozen release identities

`v0.1.0-dev.5.4.2` is the previous validated frozen artifact.

Frozen dev.5.4.2 Setup SHA256:

```text
afbe531a5e117820c8643b776b74b82002db27d223366cf07fb390c818aeca04
```

`v0.1.0-dev.6.0` is the first public binary prerelease and is also frozen.

Frozen dev.6.0 final Setup SHA256:

```text
f6e7155beca5d863b8d70022c5ac9d7a38daa21880b572a25b0bff9c54661791
```

Do not rebuild or republish a different installer under any frozen release identity.

`v0.1.0-rc.1` is a frozen Windows 10 validation candidate, not a public release.
Frozen rc.1 Setup SHA256: `fb209f59939dde9291a3879f4e30145192901c397114510301a3a3cf309bd068`.
Its source commit is `bdad6cb24a39f479436763db774f46ee4a5ab154`.

`v0.1.0-rc.2` is the frozen Windows 11 stable-release candidate, not a public release.
Frozen rc.2 Setup SHA256: `e5e7f4d379e096b3513ed8118c1cf09f29152f24c7ac4282b53678aa4d687d40`.
Its source commit is `b54ac7311b1a6e0736e91c2cac248fffcc485e04`; source tree is `4f8ba3444993c601e41bf71c4f82e78629711d6c`.
Validation evidence is recorded in `docs/RC2_FINAL_VALIDATION.md`.
No `v0.1.0-rc.2` tag was created; do not invent one retroactively.

Current final stable-release source uses `0.1.0`; its public stable binary has not yet been published.

## Never weaken these rules

- Never hard-code a published `oemN.inf` name.
- Never generically delete drivers by searching for `Apple`.
- Never touch unrelated Apple/iPhone/Apple Mobile Device/Boot Camp drivers.
- Never add `/force` to the normal driver-removal path.
- Keep export-before-delete and backup verification.
- Keep connected-device removal fail-closed.
- Keep post-delete `not-installed` verification.
- Do not auto-"fix" the A3120 `MI_00` interface.
- Do not edit or re-sign the upstream signed driver payload.
- Do not silently upgrade/downgrade or resolve ambiguous multiple packages.
- Do not claim ARM64/Windows 10 wrapper support without project-level validation.

## Windows PowerShell runtime rule

Installed runtime `.ps1` files must remain safe for inbox Windows PowerShell 5.1.

For runtime scripts:

- ASCII source only unless the encoding contract is deliberately redesigned;
- Unicode runtime data is allowed;
- do not replace established UTF-8-without-BOM writers casually.

Read:

- `docs/WINDOWS_POWERSHELL_51_COMPATIBILITY.md`
- `docs/WINDOWS_POWERSHELL_51_SOURCE_ENCODING.md`
- `docs/WINDOWS_POWERSHELL_51_EMPTY_LINES.md`

## Third-party boundary

Project-authored wrapper code/docs are MIT.

`vitoplantamura/MagicTrackpad2ForWindows` remains third-party GPLv2 software.

Do not copy upstream driver source into wrapper-authored files or change the
packaging relationship without reopening the license review.

## Validation

Run checks appropriate to the change. For repository/meta changes, at minimum:

```powershell
.\scripts\Verify-OSSRepositoryLayout.ps1
.\scripts\Verify-PublicReadme.ps1
.\scripts\Verify-LicenseReviewBaseline.ps1
.\scripts\Verify-LicensePolicyDecision.ps1
.\scripts\Verify-LicenseDistribution.ps1
.\scripts\Verify-ContributorWorkflow.ps1
.\scripts\Verify-MaintainerPortability.ps1
.\scripts\Verify-CIWorkflow.ps1
.\scripts\Build-CIHelper.ps1
git diff --check
```

For installer/runtime/driver lifecycle changes, also run the relevant existing
installer, PowerShell compatibility, payload, status, and uninstall verifiers
listed in `docs/oss/CONTRIBUTOR_WORKFLOW.md`.

Do not run `Build-Installer.ps1` or `Build-ReleaseBundle.ps1` with any frozen
`VERSION`: `0.1.0-dev.5.4.2`, `0.1.0-dev.6.0`, `0.1.0-rc.1`, or `0.1.0-rc.2`; refusal is intentional.
Current `0.1.0` source is not yet frozen; final stable release building remains an
explicit maintainer action rather than part of normal CI.
If a release-bundle run fails after Setup is produced, do not delete or rebuild that
same-version Setup. Resume only with its exact SHA256 via
`Build-ReleaseBundle.ps1 -ReuseExistingInstallerSha256`.

The GitHub Actions CI workflow must preserve this rule: CI may build the C++
helper and run static/runtime compatibility checks, but must not produce a new
Setup for any frozen version.

## Change discipline

- Prefer minimal, local changes over broad refactors.
- Preserve existing machine-readable helper exit codes and state names.
- Add/adjust a verifier when introducing a new safety contract.
- Do not delete historical validation merely to make the repository smaller.
- Never commit `build/`, `out/`, `.vs/`, staged driver binaries, runtime logs,
  driver backups, machine identifiers, or secrets.

## Pull requests

PRs should state:

- what changed;
- why it changed;
- risk area;
- validation actually run;
- validation not run and why;
- whether frozen installer/driver behavior changed;
- whether licensing/third-party boundaries changed.

If safety-critical behavior changes, make that explicit rather than hiding it in
a general cleanup/refactor PR.
