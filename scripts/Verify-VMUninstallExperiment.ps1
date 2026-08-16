param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = "Stop"

$runtimeScripts = @(
    (Join-Path $RepoRoot "scripts\Invoke-SafeDriverUninstall.ps1"),
    (Join-Path $RepoRoot "scripts\Get-UninstallPlan.ps1"),
    (Join-Path $RepoRoot "scripts\Collect-Diagnostics.ps1")
)

foreach ($path in $runtimeScripts) {
    if (-not (Test-Path $path -PathType Leaf)) {
        throw "Missing runtime script: $path"
    }

    $bytes = [System.IO.File]::ReadAllBytes($path)

    foreach ($byte in $bytes) {
        if ($byte -gt 0x7F) {
            throw "Runtime script contains non-ASCII source bytes: $path"
        }
    }

    Write-Host "[PASS] ASCII runtime source: $path"
}

$uninstallText = Get-Content (Join-Path $RepoRoot "scripts\Invoke-SafeDriverUninstall.ps1") -Raw

$requiredFragments = @(
    'ExpectedPublishedInf',
    'ConfirmToken',
    'REMOVE:$ExpectedPublishedInf',
    'driver.installed_count',
    'driver.published_inf',
    'driver.original_inf',
    'driver.provider',
    'driver.current_version',
    'vm-no-device-gate',
    '/export-driver',
    '/delete-driver $published /uninstall',
    'remove.force_used=false',
    'result=removed'
)

foreach ($fragment in $requiredFragments) {
    if ($uninstallText -notlike "*$fragment*") {
        throw "Missing uninstall safety contract fragment: $fragment"
    }
}

if ($uninstallText -match '(?i)/force') {
    $nonCommentForce = @(
        $uninstallText -split "`r?`n" |
        Where-Object {
            $_ -notmatch '^\s*#' -and
            $_ -match '(?i)/force'
        }
    )

    if ($nonCommentForce.Count -gt 0) {
        throw "Executable /force usage is forbidden in the VM uninstall experiment."
    }
}

Write-Host "[PASS] Exact published-INF confirmation gate present."
Write-Host "[PASS] VM no-device destructive gate present."
Write-Host "[PASS] Driver export-before-delete gate present."
Write-Host "[PASS] No executable /force usage found."
Write-Host "[PASS] Post-delete not-installed verification contract present."
