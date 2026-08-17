param(
    [Parameter(Mandatory = $true)]
    [string]$HelperPath,

    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = "Stop"

$RepoRoot = (Resolve-Path $RepoRoot).Path
$VersionPath = Join-Path $RepoRoot "VERSION"

if (-not (Test-Path $VersionPath -PathType Leaf)) {
    throw "VERSION file not found: $VersionPath"
}

if (-not (Test-Path $HelperPath -PathType Leaf)) {
    throw "Helper not found: $HelperPath"
}

$Helper = (Resolve-Path $HelperPath).Path
$ExpectedVersion = (Get-Content $VersionPath -Raw).Trim()

if ([string]::IsNullOrWhiteSpace($ExpectedVersion)) {
    throw "VERSION is empty."
}

function Invoke-VersionProbe {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,

        [string[]]$Arguments = @(),

        [Parameter(Mandatory = $true)]
        [int[]]$AllowedExitCodes,

        [Parameter(Mandatory = $true)]
        [string]$ExpectedVersionLine,

        [Parameter(Mandatory = $true)]
        [string]$VersionLinePrefix
    )

    Write-Host "[TEST] $Label"

    $output = @(
        & $Helper @Arguments
    )

    $exitCode = [int]$LASTEXITCODE

    $output | ForEach-Object {
        Write-Host $_
    }

    Write-Host "[INFO] ExitCode=$exitCode"

    if ($AllowedExitCodes -notcontains $exitCode) {
        throw "$Label returned unexpected exit code: $exitCode"
    }

    $reportedVersionLines = @(
        $output |
        Where-Object {
            ([string]$_).StartsWith(
                $VersionLinePrefix,
                [System.StringComparison]::Ordinal
            )
        }
    )

    if ($reportedVersionLines.Count -ne 1) {
        throw "$Label reported $($reportedVersionLines.Count) version lines with prefix: $VersionLinePrefix"
    }

    if ([string]$reportedVersionLines[0] -ne $ExpectedVersionLine) {
        throw "$Label reported unexpected version line: $($reportedVersionLines[0]); expected: $ExpectedVersionLine"
    }

    Write-Host "[PASS] $Label matches VERSION."
}

Invoke-VersionProbe `
    -Label "driver-status product version" `
    -Arguments @("driver-status") `
    -AllowedExitCodes @(0, 10, 11, 12, 13) `
    -ExpectedVersionLine "helper.version=$ExpectedVersion" `
    -VersionLinePrefix "helper.version="

Invoke-VersionProbe `
    -Label "status product version" `
    -Arguments @("status") `
    -AllowedExitCodes @(0, 2, 3, 4) `
    -ExpectedVersionLine "helper.version=$ExpectedVersion" `
    -VersionLinePrefix "helper.version="

Invoke-VersionProbe `
    -Label "usage product version" `
    -Arguments @() `
    -AllowedExitCodes @(64) `
    -ExpectedVersionLine "MagicTrackpadHelper $ExpectedVersion" `
    -VersionLinePrefix "MagicTrackpadHelper "

Write-Host "[PASS] Helper product version matches VERSION across driver-status, status, and usage."
