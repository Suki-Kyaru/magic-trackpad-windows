param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = "Stop"

$workflowPath = Join-Path $RepoRoot ".github\workflows\ci.yml"
$runnerPath = Join-Path $RepoRoot "scripts\Invoke-CIStaticChecks.ps1"
$compatPath = Join-Path $RepoRoot "scripts\Test-WindowsPowerShellCompatibility.ps1"
$buildHelperPath = Join-Path $RepoRoot "scripts\Build-CIHelper.ps1"

foreach ($path in @($workflowPath, $runnerPath, $compatPath, $buildHelperPath)) {
    if (-not (Test-Path $path -PathType Leaf)) {
        throw "CI foundation file missing: $path"
    }
}

$workflow = Get-Content $workflowPath -Raw
$runner = Get-Content $runnerPath -Raw
$compat = Get-Content $compatPath -Raw
$buildHelper = Get-Content $buildHelperPath -Raw

foreach ($required in @(
    "actions/checkout@v6",
    "windows-2025-vs2026",
    "contents: read",
    "persist-credentials: false",
    "Invoke-CIStaticChecks.ps1",
    "Build-CIHelper.ps1",
    "Build helper and run Windows PowerShell 5.1 compatibility",
    "Confirm frozen installers are not produced",
    "0.1.0-dev.5.4.2",
    "0.1.0-dev.6.0",
    "0.1.0-rc.1"
)) {
    if (-not $workflow.Contains($required)) {
        throw "CI workflow contract missing: $required"
    }
}

foreach ($forbidden in @(
    "Build-Installer.ps1",
    "Build-ReleaseBundle.ps1",
    "/force",
    "pnputil /delete-driver"
)) {
    if ($workflow.Contains($forbidden)) {
        throw "CI workflow contains forbidden destructive/release action: $forbidden"
    }
}

foreach ($required in @(
    "Verify-OSSRepositoryLayout.ps1",
    "Verify-PublicReadme.ps1",
    "Verify-LicenseReviewBaseline.ps1",
    "Verify-LicensePolicyDecision.ps1",
    "Verify-LicenseDistribution.ps1",
    "Verify-ContributorWorkflow.ps1",
    "Verify-MaintainerPortability.ps1",
    "Verify-CIWorkflow.ps1",
    "Verify-InstallerLocalizationPreview.ps1",
    "Verify-UserSafeUninstall.ps1",
    "Windows PowerShell 5.1 runtime compatibility is deferred to the helper-build job",
    "0.1.0-dev.5.4.2",
    "0.1.0-dev.6.0",
    "0.1.0-rc.1",
    "installer/release build intentionally skipped"
)) {
    if (-not $runner.Contains($required)) {
        throw "CI static runner contract missing: $required"
    }
}

$attributes = Get-Content (Join-Path $RepoRoot ".gitattributes") -Raw
if (-not $attributes.Contains("*.yml text eol=lf")) {
    throw "YAML LF normalization contract missing."
}
if (-not $attributes.Contains(".gitignore text eol=lf")) {
    throw ".gitignore LF normalization contract missing."
}

foreach ($required in @(
    "Resolve-CMakeExecutable",
    "Get-Command `"cmake.exe`"",
    "vswhere.exe",
    "Microsoft.VisualStudio.Component.VC.Tools.x86.x64",
    "Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe",
    "--build",
    "-A x64",
    "Test-WindowsPowerShellCompatibility.ps1",
    "-HelperPath"
)) {
    if (-not $buildHelper.Contains($required)) {
        throw "Shared CI helper-build contract missing: $required"
    }
}

foreach ($required in @(
    '[string]$HelperPath',
    '$DefaultHelper',
    'Resolve-Path $HelperPath',
    'uninstall.executed=false',
    'result=plan-ready',
    'result=nothing-to-remove',
    'Dry-run accepted clean driver-not-installed environment',
    '20 {'
)) {
    if (-not $compat.Contains($required)) {
        throw "Windows PowerShell clean-runner compatibility contract missing: $required"
    }
}

foreach ($required in @(
    '-HelperPath $Helper'
)) {
    if (-not ($compat.Contains($required) -or $workflow.Contains($required))) {
        throw "Windows PowerShell compatibility clean-runner contract missing: $required"
    }
}

$gitignore = Get-Content (Join-Path $RepoRoot ".gitignore") -Raw
if (-not $gitignore.Contains("/build-ci/")) {
    throw "Local CI build directory is not ignored: /build-ci/"
}

Write-Host "[PASS] GitHub Actions workflow uses read-only repository permissions."
Write-Host "[PASS] CI targets the Windows 2025 + Visual Studio 2026 hosted runner."
Write-Host "[PASS] CI runs the OSS/license/contributor and static installer safety contracts."
Write-Host "[PASS] CI runs Windows PowerShell 5.1 compatibility only after a fresh helper build."
Write-Host "[PASS] WinPS compatibility accepts both current-driver and clean no-driver environments without weakening dry-run safety."
Write-Host "[PASS] CI and local reproduction share the same CMake/helper-build script."
Write-Host "[PASS] Frozen dev.5.4.2, dev.6.0, and rc.1 installer/release builds are excluded from CI."
Write-Host "[PASS] CI contains no driver-removal or `/force` execution path."
