param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = "Stop"
$Iss = Join-Path $RepoRoot "installer\setup.iss"
$Build = Join-Path $RepoRoot "scripts\Build-Installer.ps1"
$InfoEn = Join-Path $RepoRoot "installer\INFO_BEFORE.en.txt"
$InfoZh = Join-Path $RepoRoot "installer\INFO_BEFORE.zh-CN.txt"
$UserRemoval = Join-Path $RepoRoot "scripts\Invoke-UserSafeDriverUninstall.ps1"
foreach ($path in @($Iss,$Build,$InfoEn,$InfoZh,$UserRemoval)) {
    if (-not (Test-Path $path -PathType Leaf)) { throw "Required dev.5.4.2 file missing: $path" }
}
$issText = Get-Content $Iss -Raw
$buildText = Get-Content $Build -Raw
$infoEnText = Get-Content $InfoEn -Raw
$infoZhText = Get-Content $InfoZh -Raw

$required = @(
'WizardStyle=modern dynamic windows11','MinVersion=10.0.19044','LanguageDetectionMethod=uilanguage','ShowLanguageDialog=no','UsePreviousLanguage=yes',
'DisableDirPage=no','DisableReadyPage=yes','UsePreviousAppDir=yes',
'Name: "english"; MessagesFile: "compiler:Default.isl"','Name: "chinesesimp"; MessagesFile: "{#ChineseMessagesFile}"',
'english.UninstallRemovalSuccess=','chinesesimp.UninstallRemovalSuccess=','english.UninstallRemovalConnected=','chinesesimp.UninstallRemovalConnected=',
'function RunUserDriverRemoval(var ExitCode: Integer): Boolean;','Invoke-UserSafeDriverUninstall.ps1','mode=user-uninstall',
'driver_removal_completed=','if UninstallSilent then','else if UninstallDriverRemovalExitCode = 61 then','WriteUninstallDecisionLog'
)
foreach($fragment in $required){ if(-not $issText.Contains($fragment)){ throw "Missing dev.5.4.2 installer contract: $fragment" } }

$englishPos=$issText.IndexOf('Name: "english"; MessagesFile: "compiler:Default.isl"')
$chinesePos=$issText.IndexOf('Name: "chinesesimp"; MessagesFile: "{#ChineseMessagesFile}"')
if($englishPos -lt 0 -or $chinesePos -lt 0 -or $englishPos -gt $chinesePos){ throw "English fallback order changed." }

foreach($key in @('UninstallChoice','UninstallRemovalSuccess','UninstallRemovalConnected','UninstallRemovalFailed','UninstallRemovalLaunchFailed')){
    if($issText -notmatch "(?m)^english\.$([regex]::Escape($key))="){ throw "Missing English custom message: $key" }
    if($issText -notmatch "(?m)^chinesesimp\.$([regex]::Escape($key))="){ throw "Missing Simplified Chinese custom message: $key" }
}

if($issText.Contains('RunDriverRemovalPreview') -or $issText.Contains('mode=preview-only')){ throw "Preview-only uninstaller contract remains." }
if($issText.Contains('Source: "{#RepoRoot}\scripts\Invoke-SafeDriverUninstall.ps1"')){ throw "VM/lab script must not be shipped." }
if(-not $issText.Contains('Source: "{#RepoRoot}\scripts\Invoke-UserSafeDriverUninstall.ps1"')){ throw "User-safe script is not packaged." }
if($issText -match '(?i)/delete-driver'){ throw "Raw driver deletion must stay outside setup.iss." }
if($issText -notmatch '(?s)if UninstallSilent then\s*begin\s*Result := True;\s*exit;\s*end;'){ throw "Silent uninstall must keep the driver." }

foreach($fragment in @('procedure LayoutHeader;','ContentTop := ScaleY(4);','procedure LayoutSelectDirLocal;','ContentTop := ScaleY(8);','InitializeBitmapImageFromStockIcon(WizardForm.SelectDirBitmapImage, SIID_FOLDER, clNone, [16, 20, 24, 32, 40, 48, 64]);','SetupMessage(msgButtonInstall)')){
    if(-not $issText.Contains($fragment)){ throw "Frozen installer geometry changed: $fragment" }
}
if($issText.Contains('WizardForm.DiskSpaceLabel.Top :=') -or $issText.Contains('WizardForm.NextButton.Top :=')){ throw "Frozen bottom geometry changed." }

foreach($requiredText in @('Minimum OS for this release candidate: Windows 10 x64 build 19044 or later.','Windows 10 validation is in progress; Windows 11 x64 remains validated.','This installation includes:','Safety boundaries:','Uninstall options:','Driver removal is fail-closed:')){
    if(-not $infoEnText.Contains($requiredText)){ throw "English InfoBefore section missing: $requiredText" }
}
foreach($requiredText in @('当前发布候选最低系统要求为 Windows 10 x64 build 19044 或更高版本。','Windows 10 验证正在进行中；Windows 11 x64 仍为已验证环境。','本次安装包括：','安全边界：','卸载选项：','驱动移除采用失败即保留策略：')){
    if(-not $infoZhText.Contains($requiredText)){ throw "Chinese InfoBefore section missing: $requiredText" }
}
if($buildText -notmatch 'ChineseSimplified\.isl'){ throw "Simplified Chinese resource discovery changed." }

Write-Host "[PASS] Bilingual installer UX/safety baseline remains frozen; RC minimum OS gate is Windows 10 x64 build 19044."
Write-Host "[PASS] Destination-folder freedom and R10.2 geometry remain frozen."
Write-Host "[PASS] User-facing uninstall invokes the safe removal runtime."
Write-Host "[PASS] Connected-device failure has a dedicated bilingual path."
Write-Host "[PASS] Silent uninstall remains keep-driver only."
Write-Host "[PASS] VM/lab destructive script is not shipped to users."
Write-Host "[PASS] Raw pnputil deletion remains isolated from Inno Pascal code."
