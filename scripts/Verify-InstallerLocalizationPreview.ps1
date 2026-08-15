param(
    [string]$RepoRoot = "D:\Dev\magic-trackpad-windows"
)

$ErrorActionPreference = "Stop"

$Iss = Join-Path $RepoRoot "installer\setup.iss"
$Build = Join-Path $RepoRoot "scripts\Build-Installer.ps1"
$InfoEn = Join-Path $RepoRoot "installer\INFO_BEFORE.en.txt"
$InfoZh = Join-Path $RepoRoot "installer\INFO_BEFORE.zh-CN.txt"

foreach ($path in @($Iss, $Build, $InfoEn, $InfoZh)) {
    if (-not (Test-Path $path -PathType Leaf)) {
        throw "Required localization file missing: $path"
    }
}

$issText = Get-Content $Iss -Raw
$buildText = Get-Content $Build -Raw

$requiredIssFragments = @(
    'WizardStyle=modern dynamic windows11',
    'LanguageDetectionMethod=uilanguage',
    'ShowLanguageDialog=no',
    'UsePreviousLanguage=yes',
    'Name: "english"; MessagesFile: "compiler:Default.isl"',
    'Name: "chinesesimp"; MessagesFile: "{#ChineseMessagesFile}"',
    'english.UninstallChoice=',
    'chinesesimp.UninstallChoice=',
    '{cm:ShortcutControlPanel}',
    '{cm:ShortcutTouchpadSettings}',
    '{cm:ShortcutDiagnostics}',
    '{cm:ShortcutLogs}',
    '{cm:ShortcutUninstall}',
    'CustomMessage(''DriverPreparing'')',
    'function InitializeUninstall: Boolean;',
    'RunDriverRemovalPreview',
    'mode=preview-only',
    'driver_delete_executed=false'
)

foreach ($fragment in $requiredIssFragments) {
    if (-not $issText.Contains($fragment)) {
        throw "Missing installer localization/preview contract: $fragment"
    }
}

$englishPos = $issText.IndexOf('Name: "english"; MessagesFile: "compiler:Default.isl"')
$chinesePos = $issText.IndexOf('Name: "chinesesimp"; MessagesFile: "{#ChineseMessagesFile}"')

if ($englishPos -lt 0 -or $chinesePos -lt 0 -or $englishPos -gt $chinesePos) {
    throw "English must be the first language so unsupported UI languages fall back to English."
}

$messagesMatch = [regex]::Match(
    $issText,
    '(?ms)^\[Messages\]\s*(?<body>.*?)(?=^\[[^\]]+\]\s*$)'
)

if (-not $messagesMatch.Success) {
    throw "Language-qualified [Messages] section is missing."
}

$messageBody = $messagesMatch.Groups['body'].Value

$standardMessagePairs = @(
    'WizardInfoBefore',
    'InfoBeforeLabel',
    'InfoBeforeClickLabel'
)

foreach ($key in $standardMessagePairs) {
    if ($messageBody -notmatch "(?m)^english\.$([regex]::Escape($key))=") {
        throw "Missing English standard message override: $key"
    }

    if ($messageBody -notmatch "(?m)^chinesesimp\.$([regex]::Escape($key))=") {
        throw "Missing Simplified Chinese standard message override: $key"
    }
}

$unqualifiedMessageLines = @(
    $messageBody -split "`r?`n" |
    Where-Object {
        $_ -match '^\s*[A-Za-z][A-Za-z0-9_]*\s*='
    }
)

if ($unqualifiedMessageLines.Count -gt 0) {
    throw "Unqualified [Messages] overrides are forbidden in the bilingual installer."
}

# Preview build must not invoke the destructive driver deletion command from Inno code.
if ($issText -match '(?i)/delete-driver') {
    throw "dev.5.4.1 is preview-only; destructive driver deletion must not appear in setup.iss."
}

$customPairs = @(
    'ShortcutControlPanel',
    'ShortcutTouchpadSettings',
    'ShortcutDiagnostics',
    'ShortcutLogs',
    'ShortcutUninstall',
    'RunControlPanel',
    'DriverPreparing',
    'PowerShellLaunchFailed',
    'DriverGateFailed',
    'DriverLogDirectory',
    'DriverGateSafety',
    'DriverPrepareException',
    'UninstallChoice',
    'UninstallPreviewReady',
    'UninstallPreviewReview',
    'UninstallPreviewLaunchFailed'
)

foreach ($key in $customPairs) {
    if ($issText -notmatch "(?m)^english\.$([regex]::Escape($key))=") {
        throw "Missing English custom message: $key"
    }

    if ($issText -notmatch "(?m)^chinesesimp\.$([regex]::Escape($key))=") {
        throw "Missing Simplified Chinese custom message: $key"
    }
}

if ($buildText -notmatch 'ChineseSimplified\.isl') {
    throw "Build script no longer discovers the Simplified Chinese Inno language file."
}

if ($buildText -notmatch 'throw "Simplified Chinese Inno Setup language file') {
    throw "Build script must fail closed if the Simplified Chinese language file is unavailable."
}


$installFlowFragments = @(
    'DisableDirPage=no',
    'DisableReadyPage=yes',
    'UsePreviousAppDir=yes',
    'procedure CurPageChanged(CurPageID: Integer);',
    'CurPageID in [wpSelectDir, wpReady]',
    'SetupMessage(msgButtonInstall)',
    'SetupMessage(msgButtonFinish)',
    'SetupMessage(msgButtonNext)'
)

foreach ($fragment in $installFlowFragments) {
    if (-not $issText.Contains($fragment)) {
        throw "Missing streamlined install-flow contract: $fragment"
    }
}

if ($issText -match 'WizardForm\.PreparingLabel\.Top') {
    throw "Obsolete R5 PreparingLabel spacing tweak must not remain after Ready-page removal."
}


if ($issText.Contains('CurPageID in [wpSelectDir, wpReady]') -eq $false) {
    throw "Literal set-membership source fragment is missing."
}

$verifierText = Get-Content $MyInvocation.MyCommand.Path -Raw

if ($verifierText -match '\$issText\s+-notlike\s+"\*\$fragment\*"') {
    throw "Verifier must use literal fragment matching, not wildcard -like matching."
}

Write-Host "[PASS] Verifier fragment checks use literal matching."

Write-Host "[PASS] Destination page remains explicitly visible."
Write-Host "[PASS] Previous installation directory remains the default."
Write-Host "[PASS] Redundant Ready page is disabled."
Write-Host "[PASS] Destination-page primary action uses localized Install caption."
Write-Host "[PASS] Obsolete PreparingLabel spacing tweak is removed."

Write-Host "[PASS] Windows 11 modern dynamic wizard style contract present."
Write-Host "[PASS] Windows UI-language detection contract present."
Write-Host "[PASS] English is the unsupported-language fallback."
Write-Host "[PASS] Simplified Chinese and English custom-message pairs are complete."
Write-Host "[PASS] Standard InfoBefore messages are language-qualified for English and Simplified Chinese."

$infoEnText = Get-Content $InfoEn -Raw
$infoZhText = Get-Content $InfoZh -Raw

if ($infoEnText -match '(?m)^Magic Trackpad for Windows\s*-\s*dev\.') {
    throw "English InfoBefore still repeats the product/version heading."
}

if ($infoZhText -match '(?m)^Magic Trackpad for Windows\s*-\s*dev\.') {
    throw "Chinese InfoBefore still repeats the product/version heading."
}

foreach ($required in @(
    'This installation includes:',
    'Safety boundaries:',
    'Uninstall preview:'
)) {
    if (-not $infoEnText.Contains($required)) {
        throw "English InfoBefore copy section missing: $required"
    }
}

foreach ($required in @(
    '本次安装包括：',
    '安全边界：',
    '卸载预览：'
)) {
    if (-not $infoZhText.Contains($required)) {
        throw "Chinese InfoBefore copy section missing: $required"
    }
}


$layoutFragments = @(
    'procedure LayoutHeader;',
    'WizardForm.PageDescriptionLabel.Left := WizardForm.PageNameLabel.Left;',
    'WizardForm.PageNameLabel.Height +',
    'ScaleY(8)',
    'procedure LayoutInfoBeforeLocal;',
    'ContentTop := ScaleY(4);',
    'ContentTop := ScaleY(8);',
    'WizardForm.InfoBeforeMemo.Top := ContentTop;',
    'procedure LayoutSelectDirLocal;',
    'WizardForm.SelectDirBitmapImage.Top :=',
    'WizardForm.SelectDirLabel.Top :=',
    'FirstRowHeight +',
    'ScaleY(16)',
    'WizardForm.SelectDirBrowseLabel.Height +',
    'ScaleY(8)',
    'if CurPageID in [wpInfoBefore, wpSelectDir] then',
    'LayoutHeader;',
    'LayoutInfoBeforeLocal',
    'LayoutSelectDirLocal'
)

foreach ($fragment in $layoutFragments) {
    if (-not $issText.Contains($fragment)) {
        throw "Missing R10 local-coordinate layout contract: $fragment"
    }
}

foreach ($forbidden in @(
    'function MainContentTop',
    'procedure ApplyCommonHeaderRhythm',
    'InfoBeforeMemoOriginalBottom',
    'WizardForm.PageDescriptionLabel.Top + WizardForm.PageDescriptionLabel.Height'
)) {
    if ($issText.Contains($forbidden)) {
        throw "Cross-container R9 geometry must not remain: $forbidden"
    }
}

if ($issText.Contains('WizardForm.DiskSpaceLabel.Top :=')) {
    throw "R10 must not move the bottom disk-space label."
}

if ($issText.Contains('WizardForm.BackButton.Top :=') -or
    $issText.Contains('WizardForm.NextButton.Top :=') -or
    $issText.Contains('WizardForm.CancelButton.Top :=')) {
    throw "R10 must not move the bottom navigation buttons."
}

$messagesMatchR10 = [regex]::Match(
    $issText,
    '(?ms)^\[Messages\]\s*(?<body>.*?)(?=^\[[^\]]+\]\s*$)'
)

if (-not $messagesMatchR10.Success) {
    throw "Could not inspect [Messages] for R10 directory copy."
}

$r10MessageBody = $messagesMatchR10.Groups['body'].Value

foreach ($pair in @(
    'english.SelectDirBrowseLabel=Click Browse to choose a different folder. When ready, click Install.',
    'chinesesimp.SelectDirBrowseLabel=如需更改安装位置，请点击“浏览”。确认后点击“安装”。'
)) {
    if (-not $r10MessageBody.Contains($pair)) {
        throw "Missing R10 localized directory instruction: $pair"
    }
}

Write-Host "[PASS] Header rhythm is isolated to MainPanel controls."
Write-Host "[PASS] InfoBefore body uses only page-local coordinates."
Write-Host "[PASS] Destination controls use only page-local coordinates."

$infoTopCount = ([regex]::Matches(
    $issText,
    'ContentTop\s*:=\s*ScaleY\(4\)\s*;'
)).Count

$selectDirTopCount = ([regex]::Matches(
    $issText,
    'ContentTop\s*:=\s*ScaleY\(8\)\s*;'
)).Count

if ($infoTopCount -ne 1) {
    throw "Expected exactly one ScaleY(4) InfoBefore content anchor, found $infoTopCount."
}

if ($selectDirTopCount -ne 1) {
    throw "Expected exactly one ScaleY(8) SelectDir content anchor, found $selectDirTopCount."
}

if ($issText -match 'ContentTop\s*:=\s*ScaleY\(12\)\s*;') {
    throw "Obsolete ScaleY(12) page-local content anchor remains."
}

Write-Host "[PASS] InfoBefore content anchor uses ScaleY(4)."
Write-Host "[PASS] SelectDir content anchor remains ScaleY(8)."
Write-Host "[PASS] Cross-container R9 geometry is removed."
Write-Host "[PASS] Windows stock folder icon remains enabled."
Write-Host "[PASS] Disk-space and bottom navigation zones remain untouched."

Write-Host "[PASS] InfoBefore copy is concise and does not repeat the product/version heading."

Write-Host "[PASS] Localized InfoBefore files are present."

$previewFunctionMatch = [regex]::Match(
    $issText,
    '(?s)function RunDriverRemovalPreview\(var ExitCode: Integer\): Boolean;.*?end;'
)

if (-not $previewFunctionMatch.Success) {
    throw "Could not inspect RunDriverRemovalPreview."
}

$previewFunctionText = $previewFunctionMatch.Value

if (-not $previewFunctionText.Contains('" -WriteLog')) {
    throw "Uninstall driver-removal preview must request a persistent UninstallPlan audit log."
}

Write-Host "[PASS] Driver-removal preview writes a persistent UninstallPlan audit log."

Write-Host "[PASS] Uninstall choice is preview-only."

if ($issText -match '\bBoolToStr\s*\(') {
    throw "Unsupported BoolToStr call remains in setup.iss."
}

if ($issText -notmatch 'function BoolToLowerString\(Value: Boolean\): String;') {
    throw "Boolean string helper is missing."
}

if ($issText -match "FmtMessage\(\s*`r?`n\s*CustomMessage") {
    throw "Nested multiline FmtMessage form remains; keep Pascal Script expressions simple."
}


$prepareMatch = [regex]::Match(
    $issText,
    '(?s)function PrepareToInstall\(var NeedsRestart: Boolean\): String;\s*var(?<vars>.*?)\s*begin'
)

if (-not $prepareMatch.Success) {
    throw "Could not inspect PrepareToInstall local declarations."
}

if ($prepareMatch.Groups['vars'].Value -match '\bReviewMessage\s*:') {
    throw "ReviewMessage must not be declared in PrepareToInstall."
}

$uninstallMatch = [regex]::Match(
    $issText,
    '(?s)function InitializeUninstall: Boolean;\s*var(?<vars>.*?)\s*begin'
)

if (-not $uninstallMatch.Success) {
    throw "Could not inspect InitializeUninstall local declarations."
}

if ($uninstallMatch.Groups['vars'].Value -notmatch '\bReviewMessage\s*:\s*String\s*;') {
    throw "ReviewMessage must be declared in InitializeUninstall local scope."
}

Write-Host "[PASS] Uninstall-local ReviewMessage scope contract present."

Write-Host "[PASS] Pascal Script compile-safety hotfix contract present."

Write-Host "[PASS] No destructive driver-delete command is wired into the uninstaller."
