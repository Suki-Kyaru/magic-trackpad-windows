$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$InstallScript = Join-Path $PSScriptRoot "Install-Driver.ps1"
$Helper = Join-Path $RepoRoot "build\Release\MagicTrackpadHelper.exe"

if (-not (Test-Path $Helper -PathType Leaf)) {
    throw "MagicTrackpadHelper is not built: $Helper"
}

function Invoke-DriverStatusForTest {
    $lines = @(& $Helper driver-status)
    $code = [int]$LASTEXITCODE

    foreach ($line in $lines) {
        Write-Host $line
    }

    return @{
        Code = $code
        Lines = $lines
    }
}

$before = Invoke-DriverStatusForTest

if ($before.Code -ne 0) {
    throw "This test is only valid when the expected current driver is already installed. Current state=$($before.Code)"
}

$beforePublished = (
    $before.Lines |
    Where-Object { $_ -like "driver.published_inf=*" } |
    Select-Object -First 1
)

Write-Host ""
Write-Host "[TEST] Invoking safe install against an already-current driver..."

& $InstallScript
$installExit = [int]$LASTEXITCODE

if ($installExit -ne 0) {
    throw "Safe-install no-op test failed with exit code $installExit."
}

Write-Host ""
$after = Invoke-DriverStatusForTest

if ($after.Code -ne 0) {
    throw "Driver state changed unexpectedly after no-op test. State=$($after.Code)"
}

$afterPublished = (
    $after.Lines |
    Where-Object { $_ -like "driver.published_inf=*" } |
    Select-Object -First 1
)

if ($beforePublished -ne $afterPublished) {
    throw "Published INF changed unexpectedly during the no-op path. Before='$beforePublished' After='$afterPublished'"
}

Write-Host "[PASS] Current-driver installation path is idempotent."
Write-Host "[PASS] Published INF remained unchanged: $afterPublished"
Write-Host "[PASS] No driver installation was requested by the current-state path."
