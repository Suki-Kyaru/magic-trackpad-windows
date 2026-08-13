param(
    [ValidateSet("Release", "Debug")]
    [string]$Configuration = "Release",
    [switch]$VerboseDevices
)

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$Exe = Join-Path $RepoRoot "build\$Configuration\MagicTrackpadHelper.exe"

if (-not (Test-Path $Exe)) {
    throw "Helper not built: $Exe"
}

if ($VerboseDevices) {
    & $Exe status --verbose
}
else {
    & $Exe status
}

$Code = $LASTEXITCODE

Write-Host ""
Write-Host "ExitCode=$Code"

switch ($Code) {
    0 { Write-Host "[PASS] Supported Magic Trackpad is online and the active Precision Touchpad path is ready." }
    2 { Write-Host "[INFO] No supported A3120 is known to the current probe." }
    3 { Write-Host "[WARN] A3120 is online/present but the Precision Touchpad path was not detected." }
    4 { Write-Host "[INFO] A3120 is paired/remembered but Bluetooth is currently not connected." }
    default { Write-Host "[FAIL] Helper returned an unexpected exit code." }
}

exit $Code
