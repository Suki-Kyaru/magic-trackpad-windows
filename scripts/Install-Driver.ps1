param(
    [ValidateSet("AMD64")]
    [string]$Architecture = "AMD64"
)

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$Helper = Join-Path $RepoRoot "build\Release\MagicTrackpadHelper.exe"
$VerifyPayload = Join-Path $PSScriptRoot "Verify-DriverPayload.ps1"
$Inf = Join-Path $RepoRoot "third_party\MagicTrackpad2ForWindows-v2.0\$Architecture\AmtPtpDevice.inf"

function Assert-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)

    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "Administrator privileges are required for driver installation."
    }
}

function Get-DriverState {
    # External-process stdout is normally written to PowerShell's success stream.
    # If this function simply invokes the helper and then `return`s the exit code,
    # callers receive BOTH the text lines and the integer exit code.
    #
    # Capture stdout locally, preserve $LASTEXITCODE immediately, then replay the
    # diagnostic text with Write-Host so the function's only success-stream return
    # value is the integer status code.
    $statusLines = @(& $Helper driver-status)
    $code = [int]$LASTEXITCODE

    foreach ($line in $statusLines) {
        Write-Host $line
    }

    return $code
}

if (-not (Test-Path $Helper -PathType Leaf)) {
    throw "MagicTrackpadHelper is not built: $Helper"
}

Assert-Administrator

$state = Get-DriverState

switch ($state) {
    0 {
        Write-Host "[PASS] Expected driver is already installed and current."
        Write-Host "[NO-OP] No driver-store changes were made."
        exit 0
    }

    10 {
        Write-Host "[INFO] Expected driver is not installed. Safe installation may proceed."
    }

    11 {
        throw "An older matching driver package is installed. dev.4.1 does not auto-upgrade yet."
    }

    12 {
        throw "A newer matching driver package is installed. Refusing to downgrade."
    }

    13 {
        throw "Multiple matching driver packages are installed. Refusing automatic changes."
    }

    default {
        throw "Unexpected driver-status exit code: $state"
    }
}

& $VerifyPayload

if (-not (Test-Path $Inf -PathType Leaf)) {
    throw "Expected INF not found after payload verification: $Inf"
}

Write-Host "[WRITE] Installing Microsoft-signed driver package:"
Write-Host "        $Inf"

& pnputil.exe /add-driver $Inf /install
$pnputilExit = $LASTEXITCODE

if ($pnputilExit -ne 0) {
    throw "PnPUtil failed with exit code $pnputilExit."
}

$postState = Get-DriverState

if ($postState -ne 0) {
    throw "PnPUtil returned success, but post-install driver verification did not reach current state. ExitCode=$postState"
}

Write-Host "[PASS] Driver installation completed and post-install verification passed."
