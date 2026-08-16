param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot)
)
$ErrorActionPreference = "Stop"
$Script = Join-Path $RepoRoot "scripts\Invoke-UserSafeDriverUninstall.ps1"
if(-not (Test-Path $Script -PathType Leaf)){ throw "User-safe uninstall script missing: $Script" }
$bytes=[System.IO.File]::ReadAllBytes($Script)
foreach($byte in $bytes){ if($byte -gt 0x7F){ throw "User-safe uninstall runtime source must remain ASCII for Windows PowerShell 5.1." } }
$text=Get-Content $Script -Raw
$required=@(
'$ExpectedProvider = "Bingxing Wang, Vito Plantamura"',
'$ExpectedVersion = "2025.3980.1.1000"',
'$ExpectedOriginalInf = "amtptpdevice.inf"',
'driver-status", "--verbose"',
'$published -notmatch ''^oem[0-9]+\.inf$''',
'$device.Code -eq 0 -and $deviceResult -ceq "ready"',
'$device.Code -eq 2 -and $deviceResult -ceq "no-device"',
'$device.Code -eq 4 -and $deviceResult -ceq "paired-not-connected"',
'remove.blocked_reason=device-connected',
'Write-And-Exit -Log $log -LogPath $logPath -Code 61',
'pnputil.exe /export-driver $published <backup-dir>',
'"amtptpdevice.inf"','"AmtPtpDevice.cat"','"AmtPtpDeviceUsbUm.dll"','"AmtPtpHidFilter.sys"',
'pnputil.exe /delete-driver $published /uninstall',
'remove.force_used=false',
'$post.Code -ne 10',
'$postMap["result"] -cne "not-installed"',
'other_apple_drivers_touched=false',
'result=removed'
)
foreach($fragment in $required){ if(-not $text.Contains($fragment)){ throw "Missing user-safe uninstall contract: $fragment" } }
if($text -match '(?i)oem8\.inf|oem116\.inf'){ throw "Published INF must not be hard-coded." }
$badForce=@($text -split "`r?`n" | Where-Object { $_ -notmatch '^\s*#' -and $_ -match '(?i)/force' -and $_ -notmatch 'remove\.force_used=false' })
if($badForce.Count -gt 0){ throw "Executable or command-like /force usage is forbidden." }
$exportPos=$text.IndexOf('$exportOutput = @(& $pnputil /export-driver')
$verifyPos=$text.IndexOf('if ($missingBackupFiles.Count -gt 0)')
$deletePos=$text.IndexOf('$deleteOutput = @(& $pnputil /delete-driver')
$postPos=$text.IndexOf('$post = Invoke-Helper -Helper $helper -Arguments @("driver-status")')
if(-not($exportPos -ge 0 -and $exportPos -lt $verifyPos -and $verifyPos -lt $deletePos -and $deletePos -lt $postPos)){ throw "Required order is export -> verify -> delete -> post-check." }
Write-Host "[PASS] User-safe uninstall runtime source is Windows PowerShell 5.1 ASCII-compatible."
Write-Host "[PASS] Exact driver identity gates are present."
Write-Host "[PASS] Connected devices block real driver removal."
Write-Host "[PASS] No-device and paired-not-connected states are explicitly allowed."
Write-Host "[PASS] Export-before-delete and four-file backup verification are enforced."
Write-Host "[PASS] No hard-coded published INF names exist."
Write-Host "[PASS] No executable /force usage exists."
Write-Host "[PASS] Operation order is export -> verify -> delete -> post-check."
