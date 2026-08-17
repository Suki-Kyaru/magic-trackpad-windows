param(
    [switch]$SkipCppBuild
)

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$VersionPath = Join-Path $RepoRoot "VERSION"
$FrozenReleaseSetupSha256ByVersion = @{
    "0.1.0-dev.5.4.2" = "afbe531a5e117820c8643b776b74b82002db27d223366cf07fb390c818aeca04"
    "0.1.0-dev.6.0" = "f6e7155beca5d863b8d70022c5ac9d7a38daa21880b572a25b0bff9c54661791"
    "0.1.0-rc.1" = "fb209f59939dde9291a3879f4e30145192901c397114510301a3a3cf309bd068"
}

if (-not (Test-Path $VersionPath -PathType Leaf)) {
    throw "VERSION file not found: $VersionPath"
}

$Version = (Get-Content $VersionPath -Raw).Trim()

if ([string]::IsNullOrWhiteSpace($Version)) {
    throw "VERSION is empty."
}

if ($FrozenReleaseSetupSha256ByVersion.ContainsKey($Version)) {
    $frozenSetupSha256 = $FrozenReleaseSetupSha256ByVersion[$Version]
    throw "v$Version is frozen (Setup SHA256 $frozenSetupSha256). Bump VERSION and installer/setup.iss MyAppVersion together before rebuilding from post-tag source."
}
$BuildScript = Join-Path $PSScriptRoot "Build.ps1"
$VerifyPayload = Join-Path $PSScriptRoot "Verify-DriverPayload.ps1"
$Helper = Join-Path $RepoRoot "build\Release\MagicTrackpadHelper.exe"
$ThirdParty = Join-Path $RepoRoot "third_party\MagicTrackpad2ForWindows-v2.0"
$RuntimeRoot = Join-Path $RepoRoot "out\installer-runtime\root"
$RuntimeZip = Join-Path $RepoRoot "out\installer-runtime\MagicTrackpadSetupPayload.zip"
$InstallerOutput = Join-Path $RepoRoot "out\installer"
$Iss = Join-Path $RepoRoot "installer\setup.iss"

if (-not (Test-Path $Iss -PathType Leaf)) {
    throw "Inno Setup source not found: $Iss"
}

$issText = Get-Content $Iss -Raw
$expectedVersionDefine = '#define MyAppVersion "' + $Version + '"'

if (-not $issText.Contains($expectedVersionDefine)) {
    throw "VERSION/setup.iss mismatch. Expected Inno definition: $expectedVersionDefine"
}

$IsccCandidates = @(
    "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
    "$env:ProgramFiles\Inno Setup 6\ISCC.exe",
    "${env:ProgramFiles(x86)}\Inno Setup 7\ISCC.exe",
    "$env:ProgramFiles\Inno Setup 7\ISCC.exe"
)

$Iscc = $IsccCandidates |
    Where-Object { Test-Path $_ -PathType Leaf } |
    Select-Object -First 1

if (-not $Iscc) {
    throw "Inno Setup compiler (ISCC.exe) was not found."
}

$InnoRoot = Split-Path -Parent $Iscc

$ChineseCandidates = @(
    (Join-Path $InnoRoot "Languages\ChineseSimplified.isl"),
    (Join-Path $InnoRoot "ChineseSimplified.isl")
)

$ChineseMessagesFile = $ChineseCandidates |
    Where-Object { Test-Path $_ -PathType Leaf } |
    Select-Object -First 1

if (-not $SkipCppBuild) {
    & $BuildScript
    if ($LASTEXITCODE -ne 0) {
        throw "C++ helper build failed."
    }
}

if (-not (Test-Path $Helper -PathType Leaf)) {
    throw "MagicTrackpadHelper.exe not found: $Helper"
}

& $VerifyPayload

$VerifyLocalization = Join-Path $PSScriptRoot "Verify-InstallerLocalizationPreview.ps1"

if (-not (Test-Path $VerifyLocalization -PathType Leaf)) {
    throw "Installer localization verifier is missing: $VerifyLocalization"
}

& $VerifyLocalization -RepoRoot $RepoRoot

$VerifyUserUninstall = Join-Path $PSScriptRoot "Verify-UserSafeUninstall.ps1"

if (-not (Test-Path $VerifyUserUninstall -PathType Leaf)) {
    throw "User-safe uninstall verifier is missing: $VerifyUserUninstall"
}

& $VerifyUserUninstall -RepoRoot $RepoRoot

$VerifyLicenseDistribution = Join-Path $PSScriptRoot "Verify-LicenseDistribution.ps1"

if (-not (Test-Path $VerifyLicenseDistribution -PathType Leaf)) {
    throw "License distribution verifier is missing: $VerifyLicenseDistribution"
}

& $VerifyLicenseDistribution -RepoRoot $RepoRoot

foreach ($requiredTool in @(
    (Join-Path $PSScriptRoot "Collect-Diagnostics.ps1"),
    (Join-Path $PSScriptRoot "Get-UninstallPlan.ps1"),
    (Join-Path $PSScriptRoot "Invoke-UserSafeDriverUninstall.ps1")
)) {
    if (-not (Test-Path $requiredTool -PathType Leaf)) {
        throw "Installer diagnostic tool is missing: $requiredTool"
    }
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

foreach ($runtimeScript in @(
    (Join-Path $RepoRoot "installer\Run-SafeInstall.ps1"),
    (Join-Path $PSScriptRoot "Install-Driver.ps1"),
    (Join-Path $PSScriptRoot "Verify-DriverPayload.ps1"),
    (Join-Path $PSScriptRoot "Collect-Diagnostics.ps1"),
    (Join-Path $PSScriptRoot "Get-UninstallPlan.ps1"),
    (Join-Path $PSScriptRoot "Invoke-UserSafeDriverUninstall.ps1")
)) {
    Assert-AsciiRuntimeScript -Path $runtimeScript
}

if (Test-Path $RuntimeRoot) {
    Remove-Item $RuntimeRoot -Recurse -Force
}

New-Item -ItemType Directory -Path $RuntimeRoot -Force | Out-Null

$runtimeBuild = Join-Path $RuntimeRoot "build\Release"
$runtimeScripts = Join-Path $RuntimeRoot "scripts"
$runtimeThirdParty = Join-Path $RuntimeRoot "third_party\MagicTrackpad2ForWindows-v2.0"

New-Item -ItemType Directory -Path $runtimeBuild -Force | Out-Null
New-Item -ItemType Directory -Path $runtimeScripts -Force | Out-Null
New-Item -ItemType Directory -Path (Split-Path -Parent $runtimeThirdParty) -Force | Out-Null

Copy-Item $Helper (Join-Path $runtimeBuild "MagicTrackpadHelper.exe") -Force
Copy-Item (Join-Path $PSScriptRoot "Install-Driver.ps1") $runtimeScripts -Force
Copy-Item (Join-Path $PSScriptRoot "Verify-DriverPayload.ps1") $runtimeScripts -Force
Copy-Item $ThirdParty $runtimeThirdParty -Recurse -Force

$runtimeZipParent = Split-Path -Parent $RuntimeZip
New-Item -ItemType Directory -Path $runtimeZipParent -Force | Out-Null

if (Test-Path $RuntimeZip) {
    Remove-Item $RuntimeZip -Force
}

Compress-Archive `
    -Path (Join-Path $RuntimeRoot "*") `
    -DestinationPath $RuntimeZip `
    -CompressionLevel Optimal

$runtimeHash = (Get-FileHash -Algorithm SHA256 -Path $RuntimeZip).Hash.ToLowerInvariant()

Write-Host "[PASS] Installer runtime payload built."
Write-Host "[INFO] Runtime ZIP SHA256: $runtimeHash"

New-Item -ItemType Directory -Path $InstallerOutput -Force | Out-Null

$definitions = @(
    "/DRepoRoot=$RepoRoot",
    "/DRuntimeZip=$RuntimeZip",
    "/DOutputDir=$InstallerOutput"
)

if (-not $ChineseMessagesFile) {
    throw "Simplified Chinese Inno Setup language file (ChineseSimplified.isl) was not found."
}

$definitions += "/DChineseMessagesFile=$ChineseMessagesFile"
Write-Host "[PASS] Simplified Chinese messages: $ChineseMessagesFile"
Write-Host "[PASS] Installer languages: English + Simplified Chinese"
Write-Host "[INFO] Unsupported Windows UI languages fall back to English."

Write-Host "[INFO] Inno Setup compiler: $Iscc"

& $Iscc @definitions $Iss

if ($LASTEXITCODE -ne 0) {
    throw "Inno Setup compilation failed."
}

$SetupExe = Join-Path $InstallerOutput "MagicTrackpad-for-Windows-Setup-$Version-x64.exe"

if (-not (Test-Path $SetupExe -PathType Leaf)) {
    throw "Setup.exe was not produced at the expected path: $SetupExe"
}

$setupHash = (Get-FileHash -Algorithm SHA256 -Path $SetupExe).Hash.ToLowerInvariant()
$setupSignature = Get-AuthenticodeSignature -FilePath $SetupExe

Write-Host ""
Write-Host "[PASS] $Version installer built."
Write-Host "[PASS] Setup: $SetupExe"
Write-Host "[INFO] Setup SHA256: $setupHash"
Write-Host "[INFO] Setup Authenticode: $($setupSignature.Status)"

if ($setupSignature.Status -ne "Valid") {
    Write-Host "[WARN] The wrapper Setup.exe itself is not code-signed yet."
    Write-Host "[INFO] Embedded upstream CAT/SYS files remain Microsoft-signed and are verified separately."
}
