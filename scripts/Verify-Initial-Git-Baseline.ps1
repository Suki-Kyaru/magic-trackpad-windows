$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $RepoRoot

Write-Host "[INFO] Repository: $RepoRoot"

$gitRoot = (& git rev-parse --show-toplevel 2>$null)

if (-not $gitRoot) {
    throw "Git repository is not initialized."
}

$expectedGitRoot = (Resolve-Path $RepoRoot).Path
$actualGitRoot = (Resolve-Path $gitRoot).Path

if ($expectedGitRoot -ne $actualGitRoot) {
    throw "Unexpected Git root. Expected '$expectedGitRoot', got '$actualGitRoot'."
}

$staleManifest = Join-Path $RepoRoot "SHA256SUMS.txt"

if (Test-Path $staleManifest -PathType Leaf) {
    throw "Stale root SHA256SUMS.txt still exists. Remove it before the initial commit."
}

$required = @(
    "README.md",
    ".gitignore",
    "CMakeLists.txt",
    "VERSION",
    "THIRD_PARTY_NOTICES.md",
    "helper\main.cpp",
    "installer\setup.iss",
    "scripts\Build.ps1",
    "scripts\Build-Installer.ps1",
    "docs\DEVELOPMENT_HISTORY.md",
    "docs\VALIDATION_BASELINE.md",
    "docs\INITIAL_GIT_BASELINE.md"
)

foreach ($relative in $required) {
    $path = Join-Path $RepoRoot $relative
    if (-not (Test-Path $path -PathType Leaf)) {
        throw "Required baseline file missing: $relative"
    }
}

$ignored = @(
    "build",
    "out",
    "third_party\MagicTrackpad2ForWindows-v2.0"
)

foreach ($relative in $ignored) {
    $output = & git check-ignore -v -- $relative 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $output) {
        throw "Expected ignored path is not covered by .gitignore: $relative"
    }

    Write-Host "[PASS] ignored: $relative"
}

$version = (Get-Content (Join-Path $RepoRoot "VERSION") -Raw).Trim()

if ($version -ne "0.1.0-dev.5.1") {
    throw "Unexpected baseline VERSION: $version"
}

Write-Host "[PASS] VERSION: $version"

& git diff --check

if ($LASTEXITCODE -ne 0) {
    throw "git diff --check failed."
}

Write-Host "[PASS] git diff --check"
Write-Host "[PASS] Initial Git baseline repository hygiene checks passed."
