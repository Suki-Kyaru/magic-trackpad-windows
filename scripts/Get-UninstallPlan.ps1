param(
    [string]$HelperPath = "",
    [switch]$WriteLog
)

$ErrorActionPreference = "Stop"

function Resolve-HelperPath {
    param([string]$Requested)

    if ($Requested) {
        if (-not (Test-Path $Requested -PathType Leaf)) {
            throw "MagicTrackpadHelper not found: $Requested"
        }
        return (Resolve-Path $Requested).Path
    }

    $scriptRoot = Split-Path -Parent $MyInvocation.ScriptName
    $repoRoot = Split-Path -Parent $scriptRoot

    $candidates = @(
        (Join-Path $scriptRoot "MagicTrackpadHelper.exe"),
        (Join-Path $repoRoot "build\Release\MagicTrackpadHelper.exe"),
        (Join-Path $repoRoot "Tools\MagicTrackpadHelper.exe")
    )

    foreach ($candidate in $candidates) {
        if (Test-Path $candidate -PathType Leaf) {
            return (Resolve-Path $candidate).Path
        }
    }

    throw "MagicTrackpadHelper.exe could not be located."
}

function Invoke-Helper {
    param(
        [string]$Helper,
        [string[]]$Arguments
    )

    $lines = @(& $Helper @Arguments)
    $code = [int]$LASTEXITCODE

    return @{
        Code = $code
        Lines = $lines
    }
}

function Convert-KeyValueLines {
    param([object[]]$Lines)

    $map = @{}

    foreach ($lineValue in $Lines) {
        $line = [string]$lineValue

        if ($line -match '^([^=]+)=(.*)$') {
            $map[$matches[1]] = $matches[2]
        }
    }

    return $map
}

function Write-Utf8NoBomLines {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string[]]$Lines
    )

    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllLines($Path, $Lines, $encoding)
}

function Write-OptionalLog {
    param([string[]]$Lines)

    if (-not $WriteLog) {
        return
    }

    $logRoot = Join-Path $env:ProgramData "Magic Trackpad for Windows\Logs"

    try {
        New-Item -ItemType Directory -Path $logRoot -Force -ErrorAction Stop | Out-Null
    }
    catch {
        $logRoot = Join-Path $env:LOCALAPPDATA "Magic Trackpad for Windows\Logs"
        New-Item -ItemType Directory -Path $logRoot -Force | Out-Null
    }

    $path = Join-Path $logRoot ("UninstallPlan-" + (Get-Date -Format "yyyyMMdd-HHmmss") + ".log")
    Write-Utf8NoBomLines -Path $path -Lines $Lines
    Write-Host "[INFO] Uninstall dry-run log: $path"
}

$helper = Resolve-HelperPath -Requested $HelperPath

$driver = Invoke-Helper -Helper $helper -Arguments @("driver-status", "--verbose")
$driverMap = Convert-KeyValueLines -Lines $driver.Lines

$device = Invoke-Helper -Helper $helper -Arguments @("status")
$deviceMap = Convert-KeyValueLines -Lines $device.Lines

$output = New-Object System.Collections.Generic.List[string]

$output.Add("uninstall.mode=dry-run")
$output.Add("uninstall.executed=false")
$output.Add("driver_status.exit_code=$($driver.Code)")
$output.Add("device_status.exit_code=$($device.Code)")

$deviceResult = if ($deviceMap.ContainsKey("result")) {
    $deviceMap["result"]
}
else {
    "unknown"
}

$output.Add("uninstall.device_state=$deviceResult")

switch ($driver.Code) {
    0 {
        $published = $driverMap["driver.published_inf"]
        $original = $driverMap["driver.original_inf"]
        $provider = $driverMap["driver.provider"]
        $version = $driverMap["driver.current_version"]
        $count = $driverMap["driver.installed_count"]

        if ($count -ne "1") {
            $output.Add("uninstall.safe_target=false")
            $output.Add("uninstall.blocked_reason=installed-count-not-one")
            $output.Add("result=review-required")
            $output | ForEach-Object { Write-Output $_ }
            Write-OptionalLog -Lines $output
            exit 23
        }

        if ($published -notmatch '^oem[0-9]+\.inf$') {
            $output.Add("uninstall.safe_target=false")
            $output.Add("uninstall.blocked_reason=published-inf-format-invalid")
            $output.Add("result=review-required")
            $output | ForEach-Object { Write-Output $_ }
            Write-OptionalLog -Lines $output
            exit 23
        }

        $infPath = Join-Path $env:windir "INF\$published"

        if (-not (Test-Path $infPath -PathType Leaf)) {
            $output.Add("uninstall.safe_target=false")
            $output.Add("uninstall.blocked_reason=published-inf-file-missing")
            $output.Add("result=review-required")
            $output | ForEach-Object { Write-Output $_ }
            Write-OptionalLog -Lines $output
            exit 23
        }

        $deviceOnline = $deviceResult -eq "ready"

        $output.Add("uninstall.safe_target=true")
        $output.Add("uninstall.target_published_inf=$published")
        $output.Add("uninstall.target_original_inf=$original")
        $output.Add("uninstall.target_provider=$provider")
        $output.Add("uninstall.target_version=$version")
        $output.Add("uninstall.target_inf_path=$infPath")
        $output.Add("uninstall.device_online=$($deviceOnline.ToString().ToLowerInvariant())")
        $output.Add("uninstall.other_apple_drivers_touched=false")
        $output.Add("uninstall.command_preview=pnputil.exe /delete-driver $published /uninstall")

        if ($deviceOnline) {
            $output.Add("uninstall.warning=matching-trackpad-currently-online")
        }
        else {
            $output.Add("uninstall.warning=")
        }

        $output.Add("result=plan-ready")

        $output | ForEach-Object { Write-Output $_ }
        Write-OptionalLog -Lines $output
        exit 0
    }

    10 {
        $output.Add("uninstall.safe_target=false")
        $output.Add("uninstall.blocked_reason=driver-not-installed")
        $output.Add("result=nothing-to-remove")
        $output | ForEach-Object { Write-Output $_ }
        Write-OptionalLog -Lines $output
        exit 20
    }

    11 {
        $output.Add("uninstall.safe_target=false")
        $output.Add("uninstall.blocked_reason=older-driver-review-required")
        $output.Add("result=review-required")
        $output | ForEach-Object { Write-Output $_ }
        Write-OptionalLog -Lines $output
        exit 21
    }

    12 {
        $output.Add("uninstall.safe_target=false")
        $output.Add("uninstall.blocked_reason=newer-driver-review-required")
        $output.Add("result=review-required")
        $output | ForEach-Object { Write-Output $_ }
        Write-OptionalLog -Lines $output
        exit 21
    }

    13 {
        $output.Add("uninstall.safe_target=false")
        $output.Add("uninstall.blocked_reason=multiple-packages-review-required")
        $output.Add("result=review-required")
        $output | ForEach-Object { Write-Output $_ }
        Write-OptionalLog -Lines $output
        exit 22
    }

    default {
        $output.Add("uninstall.safe_target=false")
        $output.Add("uninstall.blocked_reason=unexpected-driver-state")
        $output.Add("result=review-required")
        $output | ForEach-Object { Write-Output $_ }
        Write-OptionalLog -Lines $output
        exit 23
    }
}
