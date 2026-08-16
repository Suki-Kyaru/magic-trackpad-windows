# GitHub Actions CI Workflow

Status: OSS-1.5A — DEFINED LOCALLY; FIRST HOSTED RUN PENDING

## Purpose

The first CI workflow is intentionally non-destructive.

It should catch repository/contract regressions and compile the C++ helper
without touching Driver Store state or rebuilding the frozen dev.5.4.2
installer.

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

While:

```text
VERSION = 0.1.0-dev.5.4.2
```

CI must not invoke:

```text
Build-Installer.ps1
Build-ReleaseBundle.ps1
```

and must not produce a new Setup with the frozen dev.5.4.2 version.

A future version can add installer/release CI only after version-bump and
reproducibility behavior are reviewed explicitly.

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

## OSS-1.5B acceptance

Do not mark hosted CI as validated until the repository is connected to GitHub
and an actual Actions run proves:

1. workflow YAML is accepted;
2. both jobs start on the intended Windows runner;
3. static contract job passes;
4. Windows PowerShell 5.1 compatibility passes;
5. helper config/build passes;
6. no installer/release artifact is produced;
7. no permissions/secrets warning indicates unexpected write access.

Any hosted-run fix belongs to OSS-1.5B, not a silent rewrite of this baseline.
