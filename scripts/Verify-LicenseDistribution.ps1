param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = "Stop"

$MitLicense = Join-Path $RepoRoot "LICENSE"
$GplLicense = Join-Path $RepoRoot "licenses\GPL-2.0.txt"
$LicenseReadme = Join-Path $RepoRoot "licenses\README.md"
$ThirdParty = Join-Path $RepoRoot "THIRD_PARTY_NOTICES.md"
$Provenance = Join-Path $RepoRoot "docs\oss\UPSTREAM_SOURCE_PROVENANCE.md"
$ReleaseCompliance = Join-Path $RepoRoot "docs\oss\RELEASE_COMPLIANCE.md"
$Installer = Join-Path $RepoRoot "installer\setup.iss"
$BuildInstaller = Join-Path $RepoRoot "scripts\Build-Installer.ps1"
$BuildRelease = Join-Path $RepoRoot "scripts\Build-ReleaseBundle.ps1"
$VerifyRelease = Join-Path $RepoRoot "scripts\Verify-ReleaseBundle.ps1"
$VersionPath = Join-Path $RepoRoot "VERSION"

$FrozenReleaseSetupSha256ByVersion = @{
    "0.1.0-dev.5.4.2" = "afbe531a5e117820c8643b776b74b82002db27d223366cf07fb390c818aeca04"
    "0.1.0-dev.6.0" = "f6e7155beca5d863b8d70022c5ac9d7a38daa21880b572a25b0bff9c54661791"
    "0.1.0-rc.1" = "fb209f59939dde9291a3879f4e30145192901c397114510301a3a3cf309bd068"
    "0.1.0-rc.2" = "e5e7f4d379e096b3513ed8118c1cf09f29152f24c7ac4282b53678aa4d687d40"
}
$UpstreamSourceSha = "8874eaa3994f0e7e40fa40312250bbc5f13cc928"
$UpstreamWorkflowSha = "3611b8c6f4fa06a6912d16bb4b51a47bb8c70afa"
$UpstreamTagSha = "6a308eccf6ae4fbc3cdcf267c3a525b4818824e3"
$UpstreamAssetSha256 = "2870c0c7982ce6aafc3ff763fec2999423dc4bdbd1a2c0e31ca216f26a75714f"

foreach ($path in @(
    $MitLicense,
    $GplLicense,
    $LicenseReadme,
    $ThirdParty,
    $Provenance,
    $ReleaseCompliance,
    $Installer,
    $BuildInstaller,
    $BuildRelease,
    $VerifyRelease,
    $VersionPath
)) {
    if (-not (Test-Path $path -PathType Leaf)) {
        throw "License/release distribution file missing: $path"
    }
}

$mit = Get-Content $MitLicense -Raw
$gpl = Get-Content $GplLicense -Raw
$third = Get-Content $ThirdParty -Raw
$provenance = Get-Content $Provenance -Raw
$releaseDoc = Get-Content $ReleaseCompliance -Raw
$iss = Get-Content $Installer -Raw
$buildInstallerText = Get-Content $BuildInstaller -Raw
$buildReleaseText = Get-Content $BuildRelease -Raw
$verifyReleaseText = Get-Content $VerifyRelease -Raw

$existingGuardIndex = $buildInstallerText.IndexOf('if (Test-Path $SetupExe -PathType Leaf) {')
$cppBuildIndex = $buildInstallerText.IndexOf('if (-not $SkipCppBuild) {')
$innoCompileIndex = $buildInstallerText.IndexOf('& $Iscc @definitions $Iss')
if ($existingGuardIndex -lt 0 -or $cppBuildIndex -lt 0 -or $innoCompileIndex -lt 0 -or $existingGuardIndex -gt $cppBuildIndex -or $existingGuardIndex -gt $innoCompileIndex) {
    throw "Build-Installer existing-Setup refusal must execute before C++/Inno compilation."
}

foreach ($required in @(
    'Refusing to overwrite existing installer for v$Version',
    '-ReuseExistingInstallerSha256'
)) {
    if (-not $buildInstallerText.Contains($required)) { throw "Build-Installer unique-identity guard missing: $required" }
}

$releaseExistingIndex = $buildReleaseText.IndexOf('if (Test-Path $Installer -PathType Leaf) {')
$releaseBuildIndex = $buildReleaseText.IndexOf('& $BuildInstaller')
if ($releaseExistingIndex -lt 0 -or $releaseBuildIndex -lt 0 -or $releaseExistingIndex -gt $releaseBuildIndex) {
    throw "Build-ReleaseBundle must decide reuse/refusal before calling Build-Installer."
}

foreach ($required in @(
    '[string]$ReuseExistingInstallerSha256 = ""',
    'Refusing to rebuild the same release identity',
    'Existing installer SHA256 does not match -ReuseExistingInstallerSha256',
    'Reusing existing v$Version installer without recompilation',
    'magic-trackpad-release-state-v1',
    'wrapper_commit',
    'wrapper_tree',
    'setup_sha256',
    'source-bound release-state receipt',
    'Release-state source commit mismatch',
    'Release-state source tree mismatch',
    'Existing release directory already passes verification; refusing to regenerate',
    'partial release directory may be replaced only during an exact state-bound resume',
    'Partial release/temp state exists without the source-bound Setup required for resume',
    'Write-ReleaseState -Status "release-complete"'
)) {
    if (-not $buildReleaseText.Contains($required)) { throw "Build-ReleaseBundle identity guard missing: $required" }
}

$intentIndex = $buildReleaseText.IndexOf('Write-ReleaseState -Status "intent"')
$buildCallIndex = $buildReleaseText.IndexOf('& $BuildInstaller')
$builtStateIndex = $buildReleaseText.IndexOf('Write-ReleaseState -Status "installer-built"')
if ($intentIndex -lt 0 -or $buildCallIndex -lt 0 -or $builtStateIndex -lt 0 -or $intentIndex -gt $buildCallIndex -or $buildCallIndex -gt $builtStateIndex) {
    throw "Release-state intent must be written before the unique build and finalized after it."
}

$verifiedReleaseRefusalIndex = $buildReleaseText.IndexOf('Existing release directory already passes verification; refusing to regenerate')
$releaseDirDeleteIndex = $buildReleaseText.IndexOf('Remove-Item $ReleaseDir -Recurse -Force')
if ($verifiedReleaseRefusalIndex -lt 0 -or $releaseDirDeleteIndex -lt 0 -or $verifiedReleaseRefusalIndex -gt $releaseDirDeleteIndex) {
    throw "A verified release directory must be refused before any release-directory deletion path."
}

$exactArchive = '& git -C $RepoRoot archive --format=zip "--prefix=$WrapperPrefix" "--output=$WrapperSource" $Head'
$mutableArchive = '& git -C $RepoRoot archive --format=zip "--prefix=$WrapperPrefix" "--output=$WrapperSource" HEAD'
if (-not $buildReleaseText.Contains($exactArchive) -or $buildReleaseText.Contains($mutableArchive)) {
    throw "Wrapper source archive must use the receipt-bound wrapper commit rather than mutable HEAD."
}

$guardRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("MagicTrackpad-IdentityGuard-" + [guid]::NewGuid().ToString("N"))
try {
    $guardScripts = Join-Path $guardRoot "scripts"
    $guardInstallerDir = Join-Path $guardRoot "installer"
    $guardOutputDir = Join-Path $guardRoot "out\installer"
    New-Item -ItemType Directory -Path $guardScripts -Force | Out-Null
    New-Item -ItemType Directory -Path $guardInstallerDir -Force | Out-Null
    New-Item -ItemType Directory -Path $guardOutputDir -Force | Out-Null
    Copy-Item $BuildInstaller (Join-Path $guardScripts "Build-Installer.ps1") -Force
    $guardVersion = "9.9.9-identity-guard-test"
    $guardUtf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText((Join-Path $guardRoot "VERSION"), $guardVersion + "`n", $guardUtf8)
    [System.IO.File]::WriteAllText((Join-Path $guardInstallerDir "setup.iss"), '#define MyAppVersion "' + $guardVersion + '"' + "`n", $guardUtf8)
    $guardSetup = Join-Path $guardOutputDir "MagicTrackpad-for-Windows-Setup-$guardVersion-x64.exe"
    [System.IO.File]::WriteAllBytes($guardSetup, [byte[]](0x4D,0x54,0x46,0x57,0x31))
    $before = (Get-FileHash $guardSetup -Algorithm SHA256).Hash.ToLowerInvariant()
    $message = ""
    try { & (Join-Path $guardScripts "Build-Installer.ps1") -SkipCppBuild } catch { $message = $_.Exception.Message }
    if (-not $message.Contains("Refusing to overwrite existing installer")) { throw "Build-Installer behavior probe did not fail closed." }
    $after = (Get-FileHash $guardSetup -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($after -ne $before) { throw "Build-Installer behavior probe changed existing Setup bytes." }
    Write-Host "[PASS] Existing same-version Setup is refused and preserved before toolchain work."
}
finally {
    Remove-Item $guardRoot -Recurse -Force -ErrorAction SilentlyContinue
}

foreach ($required in @(
    "e5e7f4d379e096b3513ed8118c1cf09f29152f24c7ac4282b53678aa4d687d40",
    "b54ac7311b1a6e0736e91c2cac248fffcc485e04",
    "4f8ba3444993c601e41bf71c4f82e78629711d6c",
    "RC2_FINAL_VALIDATION.md"
)) {
    if (-not $releaseDoc.Contains($required)) {
        throw "Release compliance rc.2 freeze evidence missing: $required"
    }
}

foreach ($required in @(
    "MIT License",
    "Copyright (c) 2026 Suki-Kyaru",
    "Permission is hereby granted, free of charge",
    'THE SOFTWARE IS PROVIDED "AS IS"'
)) {
    if (-not $mit.Contains($required)) {
        throw "MIT LICENSE contract missing: $required"
    }
}

foreach ($required in @(
    "GNU GENERAL PUBLIC LICENSE",
    "Version 2, June 1991",
    "END OF TERMS AND CONDITIONS"
)) {
    if (-not $gpl.Contains($required)) {
        throw "GPLv2 license text contract missing: $required"
    }
}

foreach ($required in @(
    "vitoplantamura/MagicTrackpad2ForWindows",
    "MT2FW11-20260223-MSSigned.zip",
    $UpstreamAssetSha256,
    $UpstreamSourceSha,
    "**not** relicensed under the MIT License",
    "upstream source archive"
)) {
    if (-not $third.Contains($required)) {
        throw "THIRD_PARTY_NOTICES contract missing: $required"
    }
}

foreach ($required in @(
    $UpstreamSourceSha,
    $UpstreamWorkflowSha,
    $UpstreamTagSha,
    "refs/heads/ossign"
)) {
    if (-not $provenance.Contains($required)) {
        throw "Upstream provenance contract missing: $required"
    }
}

$Version = (Get-Content $VersionPath -Raw).Trim()
$expectedVersionDefine = '#define MyAppVersion "' + $Version + '"'

if (-not $iss.Contains($expectedVersionDefine)) {
    throw "VERSION/setup.iss mismatch in current source state. Expected: $expectedVersionDefine"
}

if (-not $iss.Contains('Source: "{#RepoRoot}\THIRD_PARTY_NOTICES.md"; DestDir: "{app}"')) {
    throw "Installer no longer installs THIRD_PARTY_NOTICES.md."
}

foreach ($required in @(
    '$FrozenReleaseSetupSha256ByVersion = @{' ,
    '"0.1.0-dev.5.4.2" = "afbe531a5e117820c8643b776b74b82002db27d223366cf07fb390c818aeca04"',
    '"0.1.0-dev.6.0" = "f6e7155beca5d863b8d70022c5ac9d7a38daa21880b572a25b0bff9c54661791"',
    '"0.1.0-rc.1" = "fb209f59939dde9291a3879f4e30145192901c397114510301a3a3cf309bd068"',
    '"0.1.0-rc.2" = "e5e7f4d379e096b3513ed8118c1cf09f29152f24c7ac4282b53678aa4d687d40"',
    'ContainsKey($Version)',
    'VERSION/setup.iss mismatch',
    'Verify-LicenseDistribution.ps1',
    'MagicTrackpad-for-Windows-Setup-$Version-x64.exe'
)) {
    if (-not $buildInstallerText.Contains($required)) {
        throw "Build-Installer frozen/version/license gate missing: $required"
    }
}

foreach ($required in @(
    '$FrozenReleaseSetupSha256ByVersion = @{' ,
    '"0.1.0-dev.5.4.2" = "afbe531a5e117820c8643b776b74b82002db27d223366cf07fb390c818aeca04"',
    '"0.1.0-dev.6.0" = "f6e7155beca5d863b8d70022c5ac9d7a38daa21880b572a25b0bff9c54661791"',
    '"0.1.0-rc.1" = "fb209f59939dde9291a3879f4e30145192901c397114510301a3a3cf309bd068"',
    '"0.1.0-rc.2" = "e5e7f4d379e096b3513ed8118c1cf09f29152f24c7ac4282b53678aa4d687d40"',
    'ContainsKey($Version)',
    $UpstreamSourceSha,
    $UpstreamWorkflowSha,
    $UpstreamTagSha,
    $UpstreamAssetSha256,
    'MagicTrackpad-for-Windows-$Version-x64-binary.zip',
    'SOURCE_AVAILABILITY.txt',
    'REDISTRIBUTION-GPL-2.0.txt',
    'SHA256SUMS.txt',
    'Verify-ReleaseBundle.ps1'
)) {
    if (-not $buildReleaseText.Contains($required)) {
        throw "Build-ReleaseBundle compliance contract missing: $required"
    }
}

foreach ($required in @(
    "Naked Setup executable found at release root",
    "SOURCE_AVAILABILITY.txt",
    "REDISTRIBUTION-GPL-2.0.txt",
    "upstream_sdk_wdk_package_version",
    "10.0.26100.6584"
)) {
    if (-not $verifyReleaseText.Contains($required)) {
        throw "Verify-ReleaseBundle compliance contract missing: $required"
    }
}

foreach ($required in @(
    "Publishable binary unit",
    'does not modify `installer/setup.iss`',
    $FrozenReleaseSetupSha256ByVersion["0.1.0-dev.5.4.2"],
    $FrozenReleaseSetupSha256ByVersion["0.1.0-rc.1"],
    "0.1.0-rc.2",
    "Windows 10 validation candidate",
    "ReuseExistingInstallerSha256",
    "exact SHA256",
    "binary ZIP",
    "corresponding-source"
)) {
    if (-not $releaseDoc.Contains($required)) {
        throw "Release compliance documentation missing: $required"
    }
}

foreach ($frozenVersion in ($FrozenReleaseSetupSha256ByVersion.Keys | Sort-Object)) {
    $frozenSetup = Join-Path $RepoRoot "out\installer\MagicTrackpad-for-Windows-Setup-$frozenVersion-x64.exe"

    if (-not (Test-Path $frozenSetup -PathType Leaf)) {
        Write-Host "[INFO] Frozen v$frozenVersion Setup is not present under out\installer; source guard is still enforced."
        continue
    }

    $expectedFrozenHash = $FrozenReleaseSetupSha256ByVersion[$frozenVersion]
    $actualFrozenHash = (Get-FileHash $frozenSetup -Algorithm SHA256).Hash.ToLowerInvariant()

    if ($actualFrozenHash -ne $expectedFrozenHash) {
        throw "Local frozen v$frozenVersion Setup exists but its SHA256 no longer matches the published/validated artifact."
    }

    Write-Host "[PASS] Existing local v$frozenVersion Setup still matches the frozen SHA256."
}

Write-Host "[PASS] Root MIT LICENSE identifies Suki-Kyaru (2026)."
Write-Host "[PASS] Separate GNU GPL version 2 license text is present."
Write-Host "[PASS] THIRD_PARTY_NOTICES preserves upstream identity, payload hash, and source requirement."
Write-Host "[PASS] Upstream source/workflow/tag provenance remains frozen."
Write-Host "[PASS] Current installer source still matches VERSION and installs the third-party notice."
Write-Host "[PASS] Build scripts prevent rebuilds of frozen dev.5.4.2/dev.6.0/rc.1/rc.2 identities and enforce VERSION/Inno consistency."
Write-Host "[PASS] Current-version Setup overwrite is fail-closed; release-bundle reuse requires the exact existing Setup SHA256."
Write-Host "[PASS] Release tooling packages a license-bearing binary ZIP plus exact wrapper/upstream source assets."
Write-Host "[PASS] Release verifier rejects naked Setup publication and checks archive/provenance/source closure."
