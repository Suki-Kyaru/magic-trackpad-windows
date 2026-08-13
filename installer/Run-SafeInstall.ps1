param(
    [Parameter(Mandatory = $true)]
    [string]$PayloadZip
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $PayloadZip -PathType Leaf)) {
    throw "Installer runtime payload not found: $PayloadZip"
}

$runtimeRoot = Join-Path `
    ([System.IO.Path]::GetTempPath()) `
    ("MagicTrackpadSetupRuntime-" + [guid]::NewGuid().ToString("N"))

$windowsPowerShell = Join-Path `
    $env:SystemRoot `
    "System32\WindowsPowerShell\v1.0\powershell.exe"

try {
    New-Item -ItemType Directory -Path $runtimeRoot -Force | Out-Null

    Write-Host "[INFO] Expanding validated installer runtime..."
    Expand-Archive `
        -LiteralPath $PayloadZip `
        -DestinationPath $runtimeRoot `
        -Force

    $installScript = Join-Path $runtimeRoot "scripts\Install-Driver.ps1"

    if (-not (Test-Path $installScript -PathType Leaf)) {
        throw "Installer runtime is incomplete: scripts\Install-Driver.ps1"
    }

    Write-Host "[INFO] Starting safe driver state/install gate..."

    & $windowsPowerShell `
        -NoLogo `
        -NoProfile `
        -NonInteractive `
        -ExecutionPolicy Bypass `
        -File $installScript

    $installExit = [int]$LASTEXITCODE

    if ($installExit -ne 0) {
        throw "Safe driver install gate failed with exit code $installExit."
    }

    Write-Host "[PASS] Safe driver install gate completed."
}
finally {
    if (Test-Path $runtimeRoot) {
        Remove-Item `
            $runtimeRoot `
            -Recurse `
            -Force `
            -ErrorAction SilentlyContinue
    }
}
