param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = "Stop"

$RepoRoot = (Resolve-Path $RepoRoot).Path

function Invoke-CheckedScript {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RelativePath
    )

    $path = Join-Path $RepoRoot $RelativePath

    if (-not (Test-Path $path -PathType Leaf)) {
        throw "Required CI script missing: $RelativePath"
    }

    Write-Host ""
    Write-Host "===== $RelativePath =====" -ForegroundColor Cyan

    & $path -RepoRoot $RepoRoot

    if (-not $?) {
        throw "CI check failed: $RelativePath"
    }
}

Write-Host "Magic Trackpad for Windows - non-destructive CI checks"
Write-Host "Repository: $RepoRoot"

# Parse every tracked PowerShell file with the current PowerShell parser.
$parseErrors = @()

$trackedPs1 = @(
    & git -C $RepoRoot ls-files --cached --others --exclude-standard -- "*.ps1"
) | Sort-Object -Unique

foreach ($relative in $trackedPs1) {
    $path = Join-Path $RepoRoot $relative
    $tokens = $null
    $errors = $null

    [System.Management.Automation.Language.Parser]::ParseFile(
        $path,
        [ref]$tokens,
        [ref]$errors
    ) | Out-Null

    foreach ($error in @($errors)) {
        $parseErrors += (
            "{0}:{1}: {2}" -f
            $relative,
            $error.Extent.StartLineNumber,
            $error.Message
        )
    }
}

if ($parseErrors.Count -gt 0) {
    $parseErrors | ForEach-Object { Write-Host "[FAIL] $_" }
    throw "PowerShell syntax parsing failed."
}

Write-Host "[PASS] Tracked/untracked non-ignored PowerShell files parsed successfully."

Invoke-CheckedScript "scripts\Verify-OSSRepositoryLayout.ps1"
Invoke-CheckedScript "scripts\Verify-PublicReadme.ps1"
Invoke-CheckedScript "scripts\Verify-LicenseReviewBaseline.ps1"
Invoke-CheckedScript "scripts\Verify-LicensePolicyDecision.ps1"
Invoke-CheckedScript "scripts\Verify-LicenseDistribution.ps1"
Invoke-CheckedScript "scripts\Verify-ContributorWorkflow.ps1"
Invoke-CheckedScript "scripts\Verify-MaintainerPortability.ps1"
Invoke-CheckedScript "scripts\Verify-CIWorkflow.ps1"
Invoke-CheckedScript "scripts\Verify-InstallerLocalizationPreview.ps1"
Invoke-CheckedScript "scripts\Verify-UserSafeUninstall.ps1"

# Windows PowerShell 5.1 runtime compatibility requires a freshly built helper.
# GitHub CI runs that test in the helper-build job after CMake compilation.
Write-Host "[INFO] Windows PowerShell 5.1 runtime compatibility is deferred to the helper-build job."

# Frozen version rule: CI must not build/reissue published/frozen releases.
$version = (Get-Content (Join-Path $RepoRoot "VERSION") -Raw).Trim()
$frozenVersions = @(
    "0.1.0-dev.5.4.2",
    "0.1.0-dev.6.0",
    "0.1.0-rc.1",
    "0.1.0-rc.2"
)

if ($frozenVersions -contains $version) {
    Write-Host "[PASS] Frozen release v$version detected; installer/release build intentionally skipped."
}
else {
    Write-Host "[INFO] VERSION is not a frozen release: $version"
    Write-Host "[INFO] CI installer/release build remains opt-in until a later reviewed phase."
}

Write-Host ""
Write-Host "[PASS] Non-destructive CI contract suite completed."
