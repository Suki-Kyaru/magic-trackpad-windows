$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$Helper = Join-Path $RepoRoot "build\Release\MagicTrackpadHelper.exe"
$PlanScript = Join-Path $PSScriptRoot "Get-UninstallPlan.ps1"

if (-not (Test-Path $Helper -PathType Leaf)) {
    throw "MagicTrackpadHelper is not built: $Helper"
}

function Invoke-DriverStatus {
    $lines = @(& $Helper driver-status)
    $code = [int]$LASTEXITCODE

    return @{
        Code = $code
        Lines = $lines
        Text = ($lines -join "`n")
    }
}

$before = Invoke-DriverStatus

if ($before.Code -ne 0) {
    throw "Dry-run mutation guard expects the current driver state. Before=$($before.Code)"
}

Write-Host "[TEST] Generating uninstall plan. No delete command is allowed in this stage."

$planLines = @(& $PlanScript -HelperPath $Helper -WriteLog)
$planCode = [int]$LASTEXITCODE

foreach ($line in $planLines) {
    Write-Host $line
}

if ($planCode -ne 0) {
    throw "Uninstall plan was not ready. ExitCode=$planCode"
}

$planText = $planLines -join "`n"

if ($planText -notmatch 'uninstall\.executed=false') {
    throw "Dry-run contract marker missing: uninstall.executed=false"
}

if ($planText -notmatch 'uninstall\.safe_target=true') {
    throw "Safe uninstall target was not established."
}

if ($planText -match '(?im)^\s*\[WRITE\]') {
    throw "Unexpected write marker detected in dry-run output."
}

$after = Invoke-DriverStatus

if ($after.Code -ne 0) {
    throw "Driver state changed unexpectedly after dry-run. After=$($after.Code)"
}

if ($before.Text -ne $after.Text) {
    Write-Host "[FAIL] Driver status before dry-run:"
    $before.Lines | ForEach-Object { Write-Host $_ }

    Write-Host "[FAIL] Driver status after dry-run:"
    $after.Lines | ForEach-Object { Write-Host $_ }

    throw "Driver Store probe output changed during uninstall dry-run."
}

Write-Host "[PASS] Uninstall dry-run identified one exact target."
Write-Host "[PASS] Driver Store probe output remained byte-for-byte identical."
Write-Host "[PASS] No driver delete operation was executed."
