param(
    [string]$HelperPath = "",
    [Parameter(Mandatory = $true)]
    [string]$ExpectedPublishedInf,
    [Parameter(Mandatory = $true)]
    [string]$ConfirmToken
)

$ErrorActionPreference = "Stop"

$ExpectedProvider = "Bingxing Wang, Vito Plantamura"
$ExpectedVersion = "2025.3980.1.1000"
$ExpectedOriginalInf = "amtptpdevice.inf"

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

function New-Utf8NoBomEncoding {
    return New-Object -TypeName System.Text.UTF8Encoding -ArgumentList $false
}

function Write-Utf8NoBomLines {
    param(
        [string]$Path,
        [object[]]$Lines
    )

    $normalized = @(
        foreach ($line in $Lines) {
            if ($null -eq $line) {
                ""
            }
            else {
                [string]$line
            }
        }
    )

    [System.IO.File]::WriteAllLines(
        $Path,
        [string[]]$normalized,
        (New-Utf8NoBomEncoding)
    )
}

function Append-Utf8NoBomLines {
    param(
        [string]$Path,
        [object[]]$Lines
    )

    $normalized = @(
        foreach ($line in $Lines) {
            if ($null -eq $line) {
                ""
            }
            else {
                [string]$line
            }
        }
    )

    [System.IO.File]::AppendAllLines(
        $Path,
        [string[]]$normalized,
        (New-Utf8NoBomEncoding)
    )
}

function Test-IsAdministrator {
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object -TypeName System.Security.Principal.WindowsPrincipal -ArgumentList $identity

    return $principal.IsInRole(
        [System.Security.Principal.WindowsBuiltInRole]::Administrator
    )
}

function Write-And-Exit {
    param(
        [System.Collections.Generic.List[string]]$Log,
        [string]$LogPath,
        [int]$Code
    )

    foreach ($line in $Log) {
        Write-Output $line
    }

    if ($LogPath) {
        try {
            Append-Utf8NoBomLines -Path $LogPath -Lines $Log.ToArray()
        }
        catch {
            Write-Host "[WARN] Final log append failed: $($_.Exception.Message)"
        }
    }

    exit $Code
}

if (-not (Test-IsAdministrator)) {
    Write-Error "Administrator privileges are required."
    exit 40
}

if ($ExpectedPublishedInf -notmatch '^oem[0-9]+\.inf$') {
    Write-Error "ExpectedPublishedInf must match oemN.inf."
    exit 41
}

$requiredToken = "REMOVE:$ExpectedPublishedInf"

if ($ConfirmToken -cne $requiredToken) {
    Write-Error "Confirmation token mismatch. Expected: $requiredToken"
    exit 42
}

$helper = Resolve-HelperPath -Requested $HelperPath

$logRoot = Join-Path $env:ProgramData "Magic Trackpad for Windows\Logs"
$backupRoot = Join-Path $env:ProgramData "Magic Trackpad for Windows\DriverBackup"
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logPath = Join-Path $logRoot "DriverRemoval-$stamp.log"
$backupDir = Join-Path $backupRoot $stamp

try {
    New-Item -ItemType Directory -Path $logRoot -Force -ErrorAction Stop | Out-Null
    New-Item -ItemType Directory -Path $backupDir -Force -ErrorAction Stop | Out-Null

    Write-Utf8NoBomLines -Path $logPath -Lines @(
        "Magic Trackpad for Windows - VM safe driver removal experiment",
        "generated_at=$(Get-Date -Format o)",
        "mode=execute",
        "expected_published_inf=$ExpectedPublishedInf",
        "force_used=false",
        ""
    )
}
catch {
    Write-Error "A writable persistent log/backup directory is required before removal: $($_.Exception.Message)"
    exit 43
}

$log = New-Object -TypeName System.Collections.Generic.List[string]
$log.Add("remove.executed=false")

$driver = Invoke-Helper -Helper $helper -Arguments @("driver-status", "--verbose")
$driverMap = Convert-KeyValueLines -Lines $driver.Lines

$log.Add("pre.driver_status.exit_code=$($driver.Code)")

if ($driver.Code -ne 0) {
    $log.Add("remove.blocked_reason=driver-not-current")
    $log.Add("result=blocked")
    Write-And-Exit -Log $log -LogPath $logPath -Code 44
}

$installedCount = $driverMap["driver.installed_count"]
$published = $driverMap["driver.published_inf"]
$original = $driverMap["driver.original_inf"]
$provider = $driverMap["driver.provider"]
$version = $driverMap["driver.current_version"]

$log.Add("pre.driver_installed_count=$installedCount")
$log.Add("pre.driver_published_inf=$published")
$log.Add("pre.driver_original_inf=$original")
$log.Add("pre.driver_provider=$provider")
$log.Add("pre.driver_version=$version")

if ($installedCount -ne "1") {
    $log.Add("remove.blocked_reason=installed-count-not-one")
    $log.Add("result=blocked")
    Write-And-Exit -Log $log -LogPath $logPath -Code 45
}

if ($published -cne $ExpectedPublishedInf) {
    $log.Add("remove.blocked_reason=published-inf-mismatch")
    $log.Add("result=blocked")
    Write-And-Exit -Log $log -LogPath $logPath -Code 46
}

if ($original.ToLowerInvariant() -cne $ExpectedOriginalInf) {
    $log.Add("remove.blocked_reason=original-inf-mismatch")
    $log.Add("result=blocked")
    Write-And-Exit -Log $log -LogPath $logPath -Code 47
}

if ($provider -cne $ExpectedProvider) {
    $log.Add("remove.blocked_reason=provider-mismatch")
    $log.Add("result=blocked")
    Write-And-Exit -Log $log -LogPath $logPath -Code 48
}

if ($version -cne $ExpectedVersion) {
    $log.Add("remove.blocked_reason=version-mismatch")
    $log.Add("result=blocked")
    Write-And-Exit -Log $log -LogPath $logPath -Code 49
}

$infPath = Join-Path $env:windir "INF\$published"

if (-not (Test-Path $infPath -PathType Leaf)) {
    $log.Add("remove.blocked_reason=published-inf-file-missing")
    $log.Add("result=blocked")
    Write-And-Exit -Log $log -LogPath $logPath -Code 50
}

$device = Invoke-Helper -Helper $helper -Arguments @("status")
$deviceMap = Convert-KeyValueLines -Lines $device.Lines
$deviceResult = if ($deviceMap.ContainsKey("result")) {
    $deviceMap["result"]
}
else {
    "unknown"
}

$log.Add("pre.device_status.exit_code=$($device.Code)")
$log.Add("pre.device_state=$deviceResult")

# dev.5.3 is intentionally a VM/no-device-only destructive experiment.
# A real machine with a connected, paired, remembered, or otherwise detected
# Magic Trackpad must not pass this gate.
if ($deviceResult -cne "no-device" -or $device.Code -ne 2) {
    $log.Add("remove.blocked_reason=vm-no-device-gate")
    $log.Add("result=blocked")
    Write-And-Exit -Log $log -LogPath $logPath -Code 51
}

$pnputil = Join-Path $env:SystemRoot "System32\pnputil.exe"

if (-not (Test-Path $pnputil -PathType Leaf)) {
    $log.Add("remove.blocked_reason=pnputil-not-found")
    $log.Add("result=blocked")
    Write-And-Exit -Log $log -LogPath $logPath -Code 52
}

$log.Add("backup.directory=$backupDir")
$log.Add("backup.command=pnputil.exe /export-driver $published <backup-dir>")

$exportOutput = @(& $pnputil /export-driver $published $backupDir 2>&1)
$exportExit = [int]$LASTEXITCODE

$log.Add("backup.exit_code=$exportExit")
foreach ($line in $exportOutput) {
    $log.Add("backup.output=$([string]$line)")
}

if ($exportExit -ne 0) {
    $log.Add("remove.blocked_reason=driver-export-failed")
    $log.Add("result=blocked")
    Write-And-Exit -Log $log -LogPath $logPath -Code 53
}

$backupInf = Get-ChildItem -Path $backupDir -Filter "amtptpdevice.inf" -File -Recurse -ErrorAction SilentlyContinue |
    Select-Object -First 1

if (-not $backupInf) {
    $log.Add("remove.blocked_reason=driver-export-verification-failed")
    $log.Add("result=blocked")
    Write-And-Exit -Log $log -LogPath $logPath -Code 54
}

$log.Add("backup.verified=true")
$log.Add("backup.inf=$($backupInf.FullName)")
$log.Add("remove.command=pnputil.exe /delete-driver $published /uninstall")
$log.Add("remove.force_used=false")

# Do not add /force. If Windows considers the package unsafe to remove,
# this experiment must fail closed.
$deleteOutput = @(& $pnputil /delete-driver $published /uninstall 2>&1)
$deleteExit = [int]$LASTEXITCODE

$log.Add("remove.pnputil_exit_code=$deleteExit")
foreach ($line in $deleteOutput) {
    $log.Add("remove.output=$([string]$line)")
}

if ($deleteExit -ne 0) {
    $log.Add("remove.executed=true")
    $log.Add("remove.completed=false")
    $log.Add("result=remove-command-failed")
    Write-And-Exit -Log $log -LogPath $logPath -Code 55
}

$post = Invoke-Helper -Helper $helper -Arguments @("driver-status")
$postMap = Convert-KeyValueLines -Lines $post.Lines

$log.Add("post.driver_status.exit_code=$($post.Code)")
$log.Add("post.driver_installed=$($postMap["driver.installed"])")
$log.Add("post.driver_installed_count=$($postMap["driver.installed_count"])")
$log.Add("post.driver_state=$($postMap["driver.state"])")
$log.Add("post.result=$($postMap["result"])")
$log.Add("remove.executed=true")

if ($post.Code -ne 10 -or $postMap["result"] -cne "not-installed") {
    $log.Add("remove.completed=false")
    $log.Add("result=post-verification-failed")
    Write-And-Exit -Log $log -LogPath $logPath -Code 56
}

$log.Add("remove.completed=true")
$log.Add("other_apple_drivers_touched=false")
$log.Add("result=removed")

Write-And-Exit -Log $log -LogPath $logPath -Code 0
