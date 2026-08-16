# OSS-1.5A GitHub Actions CI Foundation

Defined the first non-destructive CI workflow.

Added:

- `.github/workflows/ci.yml`
- `scripts/Invoke-CIStaticChecks.ps1`
- `scripts/Verify-CIWorkflow.ps1`
- `docs/oss/CI_WORKFLOW.md`

The workflow runs OSS/license/contributor/static-installer contracts, explicitly
invokes Windows PowerShell 5.1 compatibility testing, and compiles the x64 C++
helper on `windows-2025-vs2026`.

The frozen `0.1.0-dev.5.4.2` installer is not rebuilt.

OSS-1.5B is reserved for the first actual GitHub-hosted workflow run and any
run-time-only fixes discovered there.
