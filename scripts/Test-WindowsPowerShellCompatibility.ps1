param(
    [string]$HelperPath
)

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$DefaultHelper = Join-Path $RepoRoot "build\Release\MagicTrackpadHelper.exe"

if ([string]::IsNullOrWhiteSpace($HelperPath)) {
    $Helper = $DefaultHelper
}
else {
    if (-not (Test-Path $HelperPath -PathType Leaf)) {
        throw "Helper not built: $HelperPath"
    }

    $Helper = (Resolve-Path $HelperPath).Path
}
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

    $planOutput = @(
        & $WindowsPowerShell `
            -NoLogo `
            -NoProfile `
            -NonInteractive `
            -ExecutionPolicy Bypass `
            -File $Plan `
            -HelperPath $Helper
    )

    $planExit = [int]$LASTEXITCODE

    $planLines = @(
        $planOutput |
            ForEach-Object { [string]$_ }
    )

    $planLines | ForEach-Object { Write-Host $_ }

    if (-not ($planLines -contains "uninstall.executed=false")) {
        throw "Windows PowerShell uninstall dry-run did not preserve the non-destructive contract."
    }

    switch ($planExit) {
        0 {
            if (-not ($planLines -contains "result=plan-ready")) {
                throw "ExitCode=0 did not report result=plan-ready."
            }

            Write-Host "[PASS] Dry-run accepted current-driver environment."
        }

        20 {
            if (-not ($planLines -contains "result=nothing-to-remove")) {
                throw "ExitCode=20 did not report result=nothing-to-remove."
            }

            Write-Host "[PASS] Dry-run accepted clean driver-not-installed environment."
        }

        default {
            throw "Windows PowerShell uninstall dry-run returned an unsupported environment state. ExitCode=$planExit"
        }
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

    Write-Host "[PASS] Windows PowerShell 5.1-compatible dry-run path passed for the detected supported environment."
    Write-Host "[PASS] Windows PowerShell 5.1-compatible diagnostics path passed."
    Write-Host "[PASS] Diagnostic report is UTF-8 without BOM."
}
finally {
    if (Test-Path $TempOutput) {
        Remove-Item $TempOutput -Recurse -Force -ErrorAction SilentlyContinue
    }
}
