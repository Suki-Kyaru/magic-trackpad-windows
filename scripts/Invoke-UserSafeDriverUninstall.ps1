param(
    [string]$HelperPath = ""
)

$ErrorActionPreference = "Stop"

$ExpectedProvider = "Bingxing Wang, Vito Plantamura"
$ExpectedVersion = "2025.3980.1.1000"
$ExpectedOriginalInf = "amtptpdevice.inf"

function Resolve-HelperPath {
    param([string]$Requested)
    if ($Requested) {
        if (-not (Test-Path $Requested -PathType Leaf)) { throw "MagicTrackpadHelper not found: $Requested" }
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
        if (Test-Path $candidate -PathType Leaf) { return (Resolve-Path $candidate).Path }
    }
    throw "MagicTrackpadHelper.exe could not be located."
}

function Invoke-Helper {
    param([string]$Helper, [string[]]$Arguments)
    $lines = @(& $Helper @Arguments)
    $code = [int]$LASTEXITCODE
    return @{ Code = $code; Lines = $lines }
}

function Convert-KeyValueLines {
    param([object[]]$Lines)
    $map = @{}
    foreach ($lineValue in $Lines) {
        $line = [string]$lineValue
        if ($line -match '^([^=]+)=(.*)$') { $map[$matches[1]] = $matches[2] }
    }
    return $map
}

function New-Utf8NoBomEncoding {
    return New-Object -TypeName System.Text.UTF8Encoding -ArgumentList $false
}

function Write-Utf8NoBomLines {
    param([string]$Path, [object[]]$Lines)
    $normalized = @(foreach ($line in $Lines) { if ($null -eq $line) { "" } else { [string]$line } })
    [System.IO.File]::WriteAllLines($Path, [string[]]$normalized, (New-Utf8NoBomEncoding))
}

function Append-Utf8NoBomLines {
    param([string]$Path, [object[]]$Lines)
    $normalized = @(foreach ($line in $Lines) { if ($null -eq $line) { "" } else { [string]$line } })
    [System.IO.File]::AppendAllLines($Path, [string[]]$normalized, (New-Utf8NoBomEncoding))
}

function Test-IsAdministrator {
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object -TypeName System.Security.Principal.WindowsPrincipal -ArgumentList $identity
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Write-And-Exit {
    param([System.Collections.Generic.List[string]]$Log, [string]$LogPath, [int]$Code)
    foreach ($line in $Log) { Write-Output $line }
    if ($LogPath) {
        try { Append-Utf8NoBomLines -Path $LogPath -Lines $Log.ToArray() }
        catch { Write-Host "[WARN] Final log append failed: $($_.Exception.Message)" }
    }
    exit $Code
}

if (-not (Test-IsAdministrator)) {
    Write-Error "Administrator privileges are required."
    exit 40
}

$helper = Resolve-HelperPath -Requested $HelperPath
$logRoot = Join-Path $env:ProgramData "Magic Trackpad for Windows\Logs"
$backupRoot = Join-Path $env:ProgramData "Magic Trackpad for Windows\DriverBackup"
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logPath = Join-Path $logRoot "DriverRemoval-$stamp.log"

try {
    New-Item -ItemType Directory -Path $logRoot -Force -ErrorAction Stop | Out-Null
    Write-Utf8NoBomLines -Path $logPath -Lines @(
        "Magic Trackpad for Windows - user safe driver removal",
        "generated_at=$(Get-Date -Format o)",
        "mode=user-uninstall",
        "force_used=false",
        ""
    )
}
catch {
    Write-Error "A writable persistent log directory is required before driver removal: $($_.Exception.Message)"
    exit 43
}

$log = New-Object -TypeName System.Collections.Generic.List[string]
$log.Add("remove.executed=false")
$log.Add("other_apple_drivers_touched=false")

$driver = Invoke-Helper -Helper $helper -Arguments @("driver-status", "--verbose")
$driverMap = Convert-KeyValueLines -Lines $driver.Lines
$log.Add("pre.driver_status.exit_code=$($driver.Code)")

if ($driver.Code -eq 10) {
    $log.Add("pre.driver_installed=false")
    $log.Add("remove.completed=true")
    $log.Add("result=already-not-installed")
    Write-And-Exit -Log $log -LogPath $logPath -Code 0
}

if ($driver.Code -ne 0) {
    $log.Add("remove.blocked_reason=driver-state-review-required")
    $log.Add("result=blocked")
    Write-And-Exit -Log $log -LogPath $logPath -Code 64
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
    Write-And-Exit -Log $log -LogPath $logPath -Code 65
}
if ($published -notmatch '^oem[0-9]+\.inf$') {
    $log.Add("remove.blocked_reason=published-inf-format-invalid")
    $log.Add("result=blocked")
    Write-And-Exit -Log $log -LogPath $logPath -Code 66
}
if ($original.ToLowerInvariant() -cne $ExpectedOriginalInf) {
    $log.Add("remove.blocked_reason=original-inf-mismatch")
    $log.Add("result=blocked")
    Write-And-Exit -Log $log -LogPath $logPath -Code 67
}
if ($provider -cne $ExpectedProvider) {
    $log.Add("remove.blocked_reason=provider-mismatch")
    $log.Add("result=blocked")
    Write-And-Exit -Log $log -LogPath $logPath -Code 68
}
if ($version -cne $ExpectedVersion) {
    $log.Add("remove.blocked_reason=version-mismatch")
    $log.Add("result=blocked")
    Write-And-Exit -Log $log -LogPath $logPath -Code 69
}

$infPath = Join-Path $env:windir "INF\$published"
if (-not (Test-Path $infPath -PathType Leaf)) {
    $log.Add("remove.blocked_reason=published-inf-file-missing")
    $log.Add("result=blocked")
    Write-And-Exit -Log $log -LogPath $logPath -Code 70
}

$device = Invoke-Helper -Helper $helper -Arguments @("status")
$deviceMap = Convert-KeyValueLines -Lines $device.Lines
$deviceResult = if ($deviceMap.ContainsKey("result")) { $deviceMap["result"] } else { "unknown" }
$log.Add("pre.device_status.exit_code=$($device.Code)")
$log.Add("pre.device_state=$deviceResult")

if ($device.Code -eq 0 -and $deviceResult -ceq "ready") {
    $log.Add("remove.blocked_reason=device-connected")
    $log.Add("result=connected")
    Write-And-Exit -Log $log -LogPath $logPath -Code 61
}

$allowedDeviceState =
    ($device.Code -eq 2 -and $deviceResult -ceq "no-device") -or
    ($device.Code -eq 4 -and $deviceResult -ceq "paired-not-connected")

if (-not $allowedDeviceState) {
    $log.Add("remove.blocked_reason=device-state-unknown")
    $log.Add("result=blocked")
    Write-And-Exit -Log $log -LogPath $logPath -Code 62
}
$log.Add("pre.device_state_allowed=true")

$pnputil = Join-Path $env:SystemRoot "System32\pnputil.exe"
if (-not (Test-Path $pnputil -PathType Leaf)) {
    $log.Add("remove.blocked_reason=pnputil-not-found")
    $log.Add("result=blocked")
    Write-And-Exit -Log $log -LogPath $logPath -Code 71
}

$backupDir = Join-Path $backupRoot $stamp
try { New-Item -ItemType Directory -Path $backupDir -Force -ErrorAction Stop | Out-Null }
catch {
    $log.Add("remove.blocked_reason=backup-directory-create-failed")
    $log.Add("result=blocked")
    Write-And-Exit -Log $log -LogPath $logPath -Code 72
}

$log.Add("backup.directory=$backupDir")
$log.Add("backup.command=pnputil.exe /export-driver $published <backup-dir>")
$exportOutput = @(& $pnputil /export-driver $published $backupDir 2>&1)
$exportExit = [int]$LASTEXITCODE
$log.Add("backup.exit_code=$exportExit")
foreach ($line in $exportOutput) { $log.Add("backup.output=$([string]$line)") }
if ($exportExit -ne 0) {
    $log.Add("remove.blocked_reason=driver-export-failed")
    $log.Add("result=blocked")
    Write-And-Exit -Log $log -LogPath $logPath -Code 73
}

$requiredBackupFiles = @(
    "amtptpdevice.inf",
    "AmtPtpDevice.cat",
    "AmtPtpDeviceUsbUm.dll",
    "AmtPtpHidFilter.sys"
)
$missingBackupFiles = @()
foreach ($requiredFile in $requiredBackupFiles) {
    $found = Get-ChildItem -Path $backupDir -Filter $requiredFile -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $found) { $missingBackupFiles += $requiredFile }
}
if ($missingBackupFiles.Count -gt 0) {
    $log.Add("backup.verified=false")
    $log.Add("backup.missing=$($missingBackupFiles -join ',')")
    $log.Add("remove.blocked_reason=driver-export-verification-failed")
    $log.Add("result=blocked")
    Write-And-Exit -Log $log -LogPath $logPath -Code 74
}

$log.Add("backup.verified=true")
$log.Add("remove.command=pnputil.exe /delete-driver $published /uninstall")
$log.Add("remove.force_used=false")
$deleteOutput = @(& $pnputil /delete-driver $published /uninstall 2>&1)
$deleteExit = [int]$LASTEXITCODE
$log.Add("remove.pnputil_exit_code=$deleteExit")
foreach ($line in $deleteOutput) { $log.Add("remove.output=$([string]$line)") }
if ($deleteExit -ne 0) {
    $log.Add("remove.executed=true")
    $log.Add("remove.completed=false")
    $log.Add("result=remove-command-failed")
    Write-And-Exit -Log $log -LogPath $logPath -Code 75
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
    Write-And-Exit -Log $log -LogPath $logPath -Code 76
}

$log.Add("remove.completed=true")
$log.Add("result=removed")
Write-And-Exit -Log $log -LogPath $logPath -Code 0
