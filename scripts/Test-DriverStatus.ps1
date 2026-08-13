param(
    [ValidateSet("Release", "Debug")]
    [string]$Configuration = "Release",
    [switch]$VerbosePackages
)

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$Exe = Join-Path $RepoRoot "build\$Configuration\MagicTrackpadHelper.exe"

if (-not (Test-Path $Exe)) {
    throw "Helper not built: $Exe"
}

if ($VerbosePackages) {
    & $Exe driver-status --verbose
}
else {
    & $Exe driver-status
}

$Code = $LASTEXITCODE

Write-Host ""
Write-Host "ExitCode=$Code"

switch ($Code) {
    0  { Write-Host "[PASS] Expected Magic Trackpad driver package is installed and current." }
    10 { Write-Host "[INFO] Expected Magic Trackpad driver package is not installed." }
    11 { Write-Host "[INFO] An older matching Magic Trackpad driver package is installed." }
    12 { Write-Host "[INFO] A newer matching Magic Trackpad driver package is installed; installer must not downgrade silently." }
    13 { Write-Host "[WARN] Multiple matching Magic Trackpad driver packages are installed; automatic upgrade/uninstall must stop for review." }
    default { Write-Host "[FAIL] Driver status probe returned an unexpected exit code." }
}

exit $Code
