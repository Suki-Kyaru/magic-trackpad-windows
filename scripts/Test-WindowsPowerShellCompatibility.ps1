$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$Helper = Join-Path $RepoRoot "build\Release\MagicTrackpadHelper.exe"
$Plan = Join-Path $PSScriptRoot "Get-UninstallPlan.ps1"
$Diagnostics = Join-Path $PSScriptRoot "Collect-Diagnostics.ps1"
$WindowsPowerShell = Join-Path $env:SystemRoot "System32\WindowsPowerShell\v1.0\powershell.exe"
$TempOutput = Join-Path $env:TEMP ("MagicTrackpad-WinPS51-Test-" + [guid]::NewGuid().ToString("N"))

if (-not (Test-Path $WindowsPowerShell -PathType Leaf)) {
    throw "Windows PowerShell was not found: $WindowsPowerShell"
}

if (-not (Test-Path $Helper -PathType Leaf)) {
    throw "Helper not built: $Helper"
}

function Assert-AsciiRuntimeScript {
    param([string]$Path)

    $bytes = [System.IO.File]::ReadAllBytes($Path)

    foreach ($byte in $bytes) {
        if ($byte -gt 0x7F) {
            throw "Runtime script contains non-ASCII source bytes and is unsafe for Windows PowerShell 5.1 without a BOM: $Path"
        }
    }

    Write-Host "[PASS] ASCII runtime source: $Path"
}

Assert-AsciiRuntimeScript -Path $Plan
Assert-AsciiRuntimeScript -Path $Diagnostics

New-Item -ItemType Directory -Path $TempOutput -Force | Out-Null

try {
    Write-Host "[TEST] Windows PowerShell dry-run..."

    & $WindowsPowerShell `
        -NoLogo `
        -NoProfile `
        -NonInteractive `
        -ExecutionPolicy Bypass `
        -File $Plan `
        -HelperPath $Helper

    $planExit = [int]$LASTEXITCODE

    if ($planExit -ne 0) {
        throw "Windows PowerShell uninstall dry-run failed. ExitCode=$planExit"
    }

    Write-Host "[TEST] Windows PowerShell diagnostics write..."

    & $WindowsPowerShell `
        -NoLogo `
        -NoProfile `
        -NonInteractive `
        -ExecutionPolicy Bypass `
        -File $Diagnostics `
        -HelperPath $Helper `
        -OutputDirectory $TempOutput

    $diagExit = [int]$LASTEXITCODE

    if ($diagExit -ne 0) {
        throw "Windows PowerShell diagnostics failed. ExitCode=$diagExit"
    }

    $reports = @(Get-ChildItem $TempOutput -Filter "Diagnostics-*.txt" -File)

    if ($reports.Count -ne 1) {
        throw "Expected exactly one diagnostic report, found $($reports.Count)."
    }

    $bytes = [System.IO.File]::ReadAllBytes($reports[0].FullName)

    if ($bytes.Length -ge 3 -and
        $bytes[0] -eq 0xEF -and
        $bytes[1] -eq 0xBB -and
        $bytes[2] -eq 0xBF) {
        throw "Diagnostic report unexpectedly contains a UTF-8 BOM."
    }

    Write-Host "[PASS] Windows PowerShell 5.1-compatible dry-run path passed."
    Write-Host "[PASS] Windows PowerShell 5.1-compatible diagnostics path passed."
    Write-Host "[PASS] Diagnostic report is UTF-8 without BOM."
}
finally {
    if (Test-Path $TempOutput) {
        Remove-Item $TempOutput -Recurse -Force -ErrorAction SilentlyContinue
    }
}
