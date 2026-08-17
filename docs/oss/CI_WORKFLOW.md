# GitHub Actions CI Workflow

Status: OSS-1.5B — HOSTED PUSH / PR MERGE-REF / MERGED MAIN VALIDATED

## Purpose

The first CI workflow is intentionally non-destructive.

It should catch repository/contract regressions and compile the C++ helper
without touching Driver Store state or rebuilding frozen dev.5.4.2, dev.6.0,
or rc.1 installers.

Workflow:

```text
.github/workflows/ci.yml
```

## Hosted runner

The initial workflow uses:

```text
windows-2025-vs2026
```

to stay close to the project's validated Visual Studio 2026 development
environment.

## Jobs

### OSS and safety contracts

Runs:

- committed whitespace check;
- PowerShell parser over tracked `.ps1` files;
- repository layout verifier;
- public README verifier;
- license provenance/policy/distribution verifiers;
- contributor workflow verifier;
- CI workflow verifier;
- installer localization/static contract verifier;
- user-safe uninstall static verifier;
This job does not run the dynamic Windows PowerShell 5.1 compatibility path,
because that path requires a built helper.

It also does not stage/download the third-party driver payload and does not
perform install/remove Driver Store operations.

### C++ helper build

Runs the shared local/hosted entry point:

```powershell
.\scripts\Build-CIHelper.ps1
```

The script resolves CMake from PATH first and, on a developer machine where
CMake is not on PATH, falls back to Visual Studio's bundled CMake via
`vswhere.exe`.

It performs a clean x64 configure/build, verifies that
`MagicTrackpadHelper.exe` is produced, then passes that fresh helper explicitly
to:

```text
Test-WindowsPowerShellCompatibility.ps1 -HelperPath <build-ci helper>
```

That test invokes inbox Windows PowerShell 5.1 for the dry-run/diagnostics
runtime paths.

The dry-run test accepts exactly two environment outcomes:

```text
exit 0  + result=plan-ready
    expected on a developer machine with the exact current driver installed

exit 20 + result=nothing-to-remove
    expected on a clean hosted runner where the driver is not installed
```

Both outcomes must still report `uninstall.executed=false`. Other dry-run exit
states remain failures for this compatibility test instead of being silently
accepted.

The hosted runner has no real Magic Trackpad; the compatibility path therefore
tests runtime/encoding/process behavior rather than project hardware support.

## Frozen version boundary

Published/frozen release identities are:

```text
0.1.0-dev.5.4.2
0.1.0-dev.6.0
0.1.0-rc.1
```

Normal CI must not invoke:

```text
Build-Installer.ps1
Build-ReleaseBundle.ps1
```

and must not produce a new Setup under any frozen version.

Current stable-release candidate source `0.1.0-rc.2` is not frozen; installer/release builds
remain explicit maintainer actions and are not part of normal CI.

## Permissions

The CI workflow uses:

```yaml
permissions:
  contents: read
```

and checkout does not persist repository credentials.

The initial CI has no release/package/write path.

## Local reproduction

Run:

```powershell
.\scripts\Invoke-CIStaticChecks.ps1
.\scripts\Build-CIHelper.ps1
```

This intentionally avoids requiring a manually prepared Developer PowerShell
session just to put CMake on PATH.

`build-ci/` is a local build product and is ignored by Git.

## OSS-1.5B hosted acceptance evidence

Hosted CI validation is complete.

Validated workflow runs:

- feature-branch push: `31924121861`;
- pull-request merge ref: `31924711963`;
- merged `main` push: `31925457637`.

Across the hosted validation:

1. workflow YAML was accepted;
2. both jobs ran successfully on `windows-2025-vs2026`;
3. the OSS/safety contract job passed;
4. the fresh-helper Windows PowerShell 5.1 compatibility path passed;
5. a clean hosted runner correctly produced
   `driver-not-installed -> result=nothing-to-remove` with
   `uninstall.executed=false`;
6. the frozen dev.5.4.2 Setup was not rebuilt;
7. no workflow artifacts were uploaded;
8. `GITHUB_TOKEN` remained read-only for repository contents and checkout did
   not persist credentials.

The local current-driver environment separately validates the
`result=plan-ready` dry-run branch. Together, local and hosted validation cover
both supported compatibility-test environments without weakening uninstall
safety.
