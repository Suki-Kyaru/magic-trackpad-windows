param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot),
    [string]$UpstreamRepoPath = "",
    [string]$ReuseExistingInstallerSha256 = ""
)

$ErrorActionPreference = "Stop"

$VersionPath = Join-Path $RepoRoot "VERSION"
$Iss = Join-Path $RepoRoot "installer\setup.iss"
$BuildInstaller = Join-Path $RepoRoot "scripts\Build-Installer.ps1"
$VerifyLicenseDistribution = Join-Path $RepoRoot "scripts\Verify-LicenseDistribution.ps1"
$VerifyRelease = Join-Path $RepoRoot "scripts\Verify-ReleaseBundle.ps1"

$FrozenReleaseSetupSha256ByVersion = @{
    "0.1.0-dev.5.4.2" = "afbe531a5e117820c8643b776b74b82002db27d223366cf07fb390c818aeca04"
    "0.1.0-dev.6.0" = "f6e7155beca5d863b8d70022c5ac9d7a38daa21880b572a25b0bff9c54661791"
    "0.1.0-rc.1" = "fb209f59939dde9291a3879f4e30145192901c397114510301a3a3cf309bd068"
    "0.1.0-rc.2" = "e5e7f4d379e096b3513ed8118c1cf09f29152f24c7ac4282b53678aa4d687d40"
}

$UpstreamUrl = "https://github.com/vitoplantamura/MagicTrackpad2ForWindows.git"
$UpstreamSourceSha = "8874eaa3994f0e7e40fa40312250bbc5f13cc928"
$UpstreamWorkflowSha = "3611b8c6f4fa06a6912d16bb4b51a47bb8c70afa"
$UpstreamTagSha = "6a308eccf6ae4fbc3cdcf267c3a525b4818824e3"
$UpstreamAsset = "MT2FW11-20260223-MSSigned.zip"
$UpstreamAssetSha256 = "2870c0c7982ce6aafc3ff763fec2999423dc4bdbd1a2c0e31ca216f26a75714f"
$UpstreamActionsRun = "22308909844"
$UpstreamSdkWdkVersion = "10.0.26100.6584"

if (-not (Test-Path $VersionPath -PathType Leaf)) {
    throw "VERSION file not found: $VersionPath"
}

$Version = (Get-Content $VersionPath -Raw).Trim()

if ([string]::IsNullOrWhiteSpace($Version)) {
    throw "VERSION is empty."
}

if ($FrozenReleaseSetupSha256ByVersion.ContainsKey($Version)) {
    $frozenSetupSha256 = $FrozenReleaseSetupSha256ByVersion[$Version]
    throw "v$Version is frozen (Setup SHA256 $frozenSetupSha256). Create a new wrapper version before building another release identity."
}

if (-not (Test-Path $Iss -PathType Leaf)) {
    throw "Inno Setup source not found: $Iss"
}

$issText = Get-Content $Iss -Raw
$expectedVersionDefine = '#define MyAppVersion "' + $Version + '"'

if (-not $issText.Contains($expectedVersionDefine)) {
    throw "VERSION/setup.iss mismatch. Expected Inno definition: $expectedVersionDefine"
}

foreach ($requiredScript in @($BuildInstaller, $VerifyLicenseDistribution, $VerifyRelease)) {
    if (-not (Test-Path $requiredScript -PathType Leaf)) {
        throw "Required release script missing: $requiredScript"
    }
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "Git is required to build release source archives."
}

& $VerifyLicenseDistribution -RepoRoot $RepoRoot

$status = @(& git -C $RepoRoot status --porcelain)
if ($LASTEXITCODE -ne 0) {
    throw "Unable to inspect wrapper repository status."
}

if ($status.Count -ne 0) {
    throw "Release source must come from a clean committed working tree."
}

$Head = (& git -C $RepoRoot rev-parse HEAD).Trim()
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($Head)) {
    throw "Unable to resolve wrapper HEAD."
}

$HeadTree = (& git -C $RepoRoot rev-parse "$Head^{tree}").Trim()
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($HeadTree)) {
    throw "Unable to resolve wrapper source tree."
}

$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$ReleaseStateRoot = Join-Path $RepoRoot "out\release-state"
$ReleaseStatePath = Join-Path $ReleaseStateRoot "MagicTrackpad-for-Windows-$Version.json"
$ReleaseRoot = Join-Path $RepoRoot "out\release"
$ReleaseDir = Join-Path $ReleaseRoot "MagicTrackpad-for-Windows-$Version"
$TempRoot = Join-Path $RepoRoot "out\release-temp\MagicTrackpad-for-Windows-$Version"
$Installer = Join-Path $RepoRoot "out\installer\MagicTrackpad-for-Windows-Setup-$Version-x64.exe"
$reuseSha256 = $ReuseExistingInstallerSha256.Trim().ToLowerInvariant()
$IsResume = $false
$PartialReleaseDirPresent = $false

function Write-ReleaseState {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Status,
        [string]$SetupSha256 = ""
    )

    New-Item -ItemType Directory -Path $ReleaseStateRoot -Force | Out-Null

    $state = [ordered]@{
        schema = "magic-trackpad-release-state-v1"
        version = $Version
        wrapper_commit = $Head
        wrapper_tree = $HeadTree
        setup_sha256 = $SetupSha256.ToLowerInvariant()
        status = $Status
    }

    $stateJson = $state | ConvertTo-Json -Depth 3
    $temporaryStatePath = "$ReleaseStatePath.tmp-$([guid]::NewGuid().ToString('N'))"

    try {
        [System.IO.File]::WriteAllText($temporaryStatePath, $stateJson + [Environment]::NewLine, $Utf8NoBom)
        Move-Item $temporaryStatePath $ReleaseStatePath -Force
    }
    finally {
        Remove-Item $temporaryStatePath -Force -ErrorAction SilentlyContinue
    }
}

function Read-ReleaseState {
    if (-not (Test-Path $ReleaseStatePath -PathType Leaf)) {
        throw "Release-state receipt is missing: $ReleaseStatePath"
    }

    try {
        return (Get-Content $ReleaseStatePath -Raw | ConvertFrom-Json)
    }
    catch {
        throw "Release-state receipt is unreadable: $ReleaseStatePath. $($_.Exception.Message)"
    }
}

function Assert-ReleaseStateSource {
    param(
        [Parameter(Mandatory = $true)]
        $State
    )

    foreach ($requiredProperty in @("schema", "version", "wrapper_commit", "wrapper_tree", "setup_sha256", "status")) {
        if ($State.PSObject.Properties.Name -notcontains $requiredProperty) {
            throw "Release-state receipt is missing required property: $requiredProperty"
        }
    }

    if ($State.schema -ne "magic-trackpad-release-state-v1") {
        throw "Release-state receipt schema is not supported: $($State.schema)"
    }

    if ($State.version -ne $Version) {
        throw "Release-state version mismatch. Receipt=$($State.version), current=$Version."
    }

    if ($State.wrapper_commit -ne $Head) {
        throw "Release-state source commit mismatch. Receipt=$($State.wrapper_commit), current=$Head. Refusing cross-commit binary reuse."
    }

    if ($State.wrapper_tree -ne $HeadTree) {
        throw "Release-state source tree mismatch. Receipt=$($State.wrapper_tree), current=$HeadTree. Refusing cross-tree binary reuse."
    }
}

if (Test-Path $ReleaseDir) {
    $existingReleaseVerified = $false
    $existingReleaseVerificationError = ""

    try {
        & $VerifyRelease -RepoRoot $RepoRoot -ReleaseDir $ReleaseDir
        $existingReleaseVerified = $true
    }
    catch {
        $existingReleaseVerificationError = $_.Exception.Message
    }

    if ($existingReleaseVerified) {
        throw "Existing release directory already passes verification; refusing to regenerate v$Version release assets: $ReleaseDir"
    }

    $PartialReleaseDirPresent = $true
    Write-Host "[INFO] Existing release directory is partial/unverified: $ReleaseDir"
    Write-Host "[INFO] Existing release verification error: $existingReleaseVerificationError"
}

$ExistingTempRootPresent = Test-Path $TempRoot

if (Test-Path $Installer -PathType Leaf) {
    $existingInstallerSha256 = (Get-FileHash -Algorithm SHA256 -Path $Installer).Hash.ToLowerInvariant()

    if ([string]::IsNullOrWhiteSpace($reuseSha256)) {
        throw "Installer for v$Version already exists (SHA256 $existingInstallerSha256): $Installer. Refusing to rebuild the same release identity. Controlled resume requires the exact Setup SHA256 plus the matching local release-state receipt."
    }

    $releaseState = Read-ReleaseState
    Assert-ReleaseStateSource -State $releaseState

    if ($releaseState.status -eq "release-complete") {
        throw "Release-state receipt already marks v$Version complete; refusing to regenerate release assets."
    }

    if ($releaseState.status -ne "installer-built") {
        throw "Release-state receipt is not resumable. Expected status installer-built, actual=$($releaseState.status)."
    }

    $receiptSetupSha256 = ([string]$releaseState.setup_sha256).Trim().ToLowerInvariant()

    if ([string]::IsNullOrWhiteSpace($receiptSetupSha256)) {
        throw "Release-state receipt does not contain the built Setup SHA256."
    }

    if ($reuseSha256 -ne $existingInstallerSha256) {
        throw "Existing installer SHA256 does not match -ReuseExistingInstallerSha256. Expected $reuseSha256, actual $existingInstallerSha256."
    }

    if ($receiptSetupSha256 -ne $existingInstallerSha256) {
        throw "Existing installer SHA256 does not match the source-bound release-state receipt. Receipt=$receiptSetupSha256, actual=$existingInstallerSha256."
    }

    $IsResume = $true
    Write-Host "[PASS] Reusing existing v$Version installer without recompilation."
    Write-Host "[PASS] Release-state source commit/tree match the current clean source."
    Write-Host "[INFO] Reused Setup SHA256: $existingInstallerSha256"
}
else {
    if (-not [string]::IsNullOrWhiteSpace($reuseSha256)) {
        throw "-ReuseExistingInstallerSha256 was supplied, but the expected v$Version installer does not exist: $Installer"
    }

    if ($PartialReleaseDirPresent -or $ExistingTempRootPresent) {
        throw "Partial release/temp state exists without the source-bound Setup required for resume. Refusing to create another same-version installer."
    }

    if (Test-Path $ReleaseStatePath -PathType Leaf) {
        $releaseState = Read-ReleaseState
        Assert-ReleaseStateSource -State $releaseState

        if ($releaseState.status -ne "intent" -or -not [string]::IsNullOrWhiteSpace([string]$releaseState.setup_sha256)) {
            throw "Existing release-state receipt is not a clean pre-build intent; refusing to start another same-version build."
        }
    }
    else {
        Write-ReleaseState -Status "intent"
    }

    & $BuildInstaller

    if (-not (Test-Path $Installer -PathType Leaf)) {
        throw "Expected installer not found after Build-Installer: $Installer"
    }

    $builtInstallerSha256 = (Get-FileHash -Algorithm SHA256 -Path $Installer).Hash.ToLowerInvariant()
    Write-ReleaseState -Status "installer-built" -SetupSha256 $builtInstallerSha256
}

$postBuildStatus = @(& git -C $RepoRoot status --porcelain)
if ($LASTEXITCODE -ne 0) {
    throw "Unable to re-check wrapper repository status after installer selection/build."
}

if ($postBuildStatus.Count -ne 0) {
    throw "Installer selection/build modified tracked source files. Refusing to archive an uncommitted release state."
}

$postBuildHead = (& git -C $RepoRoot rev-parse HEAD).Trim()
if ($LASTEXITCODE -ne 0 -or $postBuildHead -ne $Head) {
    throw "Wrapper HEAD changed during installer selection/build. Refusing release continuation."
}

if (-not (Test-Path $Installer -PathType Leaf)) {
    throw "Expected installer not found: $Installer"
}

$InstallerSha256 = (Get-FileHash -Algorithm SHA256 -Path $Installer).Hash.ToLowerInvariant()
Write-Host "[INFO] Release Setup SHA256: $InstallerSha256"

if ($PartialReleaseDirPresent -and -not $IsResume) {
    throw "A partial release directory may be replaced only during an exact state-bound resume."
}

if ((Test-Path $TempRoot) -and -not $IsResume) {
    throw "Existing release temp state may be replaced only during an exact state-bound resume: $TempRoot"
}

if ([string]::IsNullOrWhiteSpace($UpstreamRepoPath)) {
    $UpstreamRepoPath = Join-Path $RepoRoot "out\release-cache\MagicTrackpad2ForWindows"
}

if (-not (Test-Path (Join-Path $UpstreamRepoPath ".git") -PathType Container)) {
    $parent = Split-Path -Parent $UpstreamRepoPath
    New-Item -ItemType Directory -Path $parent -Force | Out-Null

    & git clone --no-checkout $UpstreamUrl $UpstreamRepoPath
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to clone upstream repository."
    }
}

$originUrl = (& git -C $UpstreamRepoPath remote get-url origin).Trim()
if ($LASTEXITCODE -ne 0) {
    throw "Unable to read upstream repository origin."
}

$normalizedOrigin = $originUrl.TrimEnd("/")
if ($normalizedOrigin -notmatch '(^|[:/])vitoplantamura/MagicTrackpad2ForWindows(?:\.git)?$') {
    throw "Upstream repository origin does not match the frozen project: $originUrl"
}

& git -C $UpstreamRepoPath fetch --force --prune --tags origin
if ($LASTEXITCODE -ne 0) {
    throw "Unable to refresh upstream repository."
}

foreach ($sha in @($UpstreamSourceSha, $UpstreamWorkflowSha, $UpstreamTagSha)) {
    & git -C $UpstreamRepoPath cat-file -e "$sha^{commit}"
    if ($LASTEXITCODE -ne 0) {
        throw "Required upstream commit is unavailable: $sha"
    }
}

if (Test-Path $ReleaseDir) {
    Remove-Item $ReleaseDir -Recurse -Force
}

if (Test-Path $TempRoot) {
    Remove-Item $TempRoot -Recurse -Force
}

New-Item -ItemType Directory -Path $ReleaseDir -Force | Out-Null
New-Item -ItemType Directory -Path $TempRoot -Force | Out-Null

$UpstreamShort = $UpstreamSourceSha.Substring(0, 12)
$WorkflowShort = $UpstreamWorkflowSha.Substring(0, 12)

$BinaryBundleName = "MagicTrackpad-for-Windows-$Version-x64-binary.zip"
$WrapperSourceName = "MagicTrackpad-for-Windows-source-$Version.zip"
$UpstreamSourceName = "MagicTrackpad2ForWindows-corresponding-source-$UpstreamShort.zip"
$WorkflowName = "UPSTREAM_BUILD_WORKFLOW-$WorkflowShort.yml"

$WrapperSource = Join-Path $ReleaseDir $WrapperSourceName
$WrapperPrefix = "MagicTrackpad-for-Windows-source-$Version/"

& git -C $RepoRoot archive --format=zip "--prefix=$WrapperPrefix" "--output=$WrapperSource" $Head
if ($LASTEXITCODE -ne 0) {
    throw "Failed to archive wrapper source."
}

$WorkflowPath = Join-Path $ReleaseDir $WorkflowName
$workflowLines = @(& git -C $UpstreamRepoPath show "${UpstreamWorkflowSha}:.github/workflows/build.yml")
if ($LASTEXITCODE -ne 0 -or $workflowLines.Count -eq 0) {
    throw "Failed to preserve upstream build workflow."
}

[System.IO.File]::WriteAllLines($WorkflowPath, $workflowLines, $Utf8NoBom)

$UpstreamSource = Join-Path $ReleaseDir $UpstreamSourceName
$UpstreamPrefix = "MagicTrackpad2ForWindows-corresponding-source-$UpstreamShort/"

& git -C $UpstreamRepoPath archive --format=zip "--prefix=$UpstreamPrefix" "--output=$UpstreamSource" $UpstreamSourceSha
if ($LASTEXITCODE -ne 0) {
    throw "Failed to archive exact upstream corresponding source."
}

$SourceOriginPath = Join-Path $TempRoot "SOURCE_ORIGIN.txt"
$sourceOriginLines = @(
    "upstream_repository=vitoplantamura/MagicTrackpad2ForWindows",
    "upstream_source_commit=$UpstreamSourceSha",
    "upstream_source_evidence=Actions artifact source-code-$UpstreamSourceSha",
    "upstream_workflow_commit=$UpstreamWorkflowSha",
    "upstream_v2_tag_commit=$UpstreamTagSha",
    "upstream_actions_run=$UpstreamActionsRun",
    "redistribution_note=Source tree is git archive of the exact source commit. REDISTRIBUTION-GPL-2.0.txt, the preserved workflow, and this SOURCE_ORIGIN.txt are redistribution metadata added by Magic Trackpad for Windows."
)
[System.IO.File]::WriteAllLines($SourceOriginPath, $sourceOriginLines, $Utf8NoBom)

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Add-FileToZip {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ZipPath,
        [Parameter(Mandatory = $true)]
        [string]$SourcePath,
        [Parameter(Mandatory = $true)]
        [string]$EntryName
    )

    $zip = [System.IO.Compression.ZipFile]::Open(
        $ZipPath,
        [System.IO.Compression.ZipArchiveMode]::Update
    )

    try {
        $existing = $zip.GetEntry($EntryName)
        if ($null -ne $existing) {
            $existing.Delete()
        }

        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
            $zip,
            $SourcePath,
            $EntryName,
            [System.IO.Compression.CompressionLevel]::Optimal
        ) | Out-Null
    }
    finally {
        $zip.Dispose()
    }
}

Add-FileToZip `
    -ZipPath $UpstreamSource `
    -SourcePath (Join-Path $RepoRoot "licenses\GPL-2.0.txt") `
    -EntryName "${UpstreamPrefix}REDISTRIBUTION-GPL-2.0.txt"

Add-FileToZip `
    -ZipPath $UpstreamSource `
    -SourcePath $WorkflowPath `
    -EntryName "${UpstreamPrefix}$WorkflowName"

Add-FileToZip `
    -ZipPath $UpstreamSource `
    -SourcePath $SourceOriginPath `
    -EntryName "${UpstreamPrefix}SOURCE_ORIGIN.txt"

$SetupHash = (Get-FileHash $Installer -Algorithm SHA256).Hash.ToLowerInvariant()
$WrapperSourceHash = (Get-FileHash $WrapperSource -Algorithm SHA256).Hash.ToLowerInvariant()
$UpstreamSourceHash = (Get-FileHash $UpstreamSource -Algorithm SHA256).Hash.ToLowerInvariant()
$WorkflowHash = (Get-FileHash $WorkflowPath -Algorithm SHA256).Hash.ToLowerInvariant()

$ProvenancePath = Join-Path $ReleaseDir "UPSTREAM_PROVENANCE.txt"
$provenanceLines = @(
    "wrapper_project=Magic Trackpad for Windows",
    "wrapper_version=$Version",
    "wrapper_commit=$Head",
    "wrapper_setup_sha256=$SetupHash",
    "wrapper_source_archive=$WrapperSourceName",
    "wrapper_source_archive_sha256=$WrapperSourceHash",
    "upstream_repository=vitoplantamura/MagicTrackpad2ForWindows",
    "upstream_release=v2.0",
    "upstream_binary_asset=$UpstreamAsset",
    "upstream_binary_asset_sha256=$UpstreamAssetSha256",
    "upstream_source_commit=$UpstreamSourceSha",
    "upstream_source_archive=$UpstreamSourceName",
    "upstream_source_archive_sha256=$UpstreamSourceHash",
    "upstream_workflow_commit=$UpstreamWorkflowSha",
    "upstream_workflow_snapshot=$WorkflowName",
    "upstream_workflow_snapshot_sha256=$WorkflowHash",
    "upstream_v2_tag_commit=$UpstreamTagSha",
    "upstream_actions_run=$UpstreamActionsRun",
    "upstream_sdk_wdk_package_version=$UpstreamSdkWdkVersion"
)
[System.IO.File]::WriteAllLines($ProvenancePath, $provenanceLines, $Utf8NoBom)

$BinaryStage = Join-Path $TempRoot "binary"
New-Item -ItemType Directory -Path $BinaryStage -Force | Out-Null

Copy-Item $Installer (Join-Path $BinaryStage (Split-Path -Leaf $Installer)) -Force
Copy-Item (Join-Path $RepoRoot "LICENSE") (Join-Path $BinaryStage "LICENSE") -Force
Copy-Item (Join-Path $RepoRoot "licenses\GPL-2.0.txt") (Join-Path $BinaryStage "GPL-2.0.txt") -Force
Copy-Item (Join-Path $RepoRoot "THIRD_PARTY_NOTICES.md") (Join-Path $BinaryStage "THIRD_PARTY_NOTICES.md") -Force
Copy-Item $ProvenancePath (Join-Path $BinaryStage "UPSTREAM_PROVENANCE.txt") -Force

$SourceAvailabilityPath = Join-Path $BinaryStage "SOURCE_AVAILABILITY.txt"
$sourceAvailabilityLines = @(
    "Magic Trackpad for Windows source availability",
    "",
    "Wrapper source archive published alongside this binary bundle:",
    $WrapperSourceName,
    "",
    "MagicTrackpad2ForWindows corresponding source archive published alongside this binary bundle:",
    $UpstreamSourceName,
    "",
    "Preserved upstream build-workflow snapshot:",
    $WorkflowName,
    "",
    "See UPSTREAM_PROVENANCE.txt for exact commits and SHA256 identifiers."
)
[System.IO.File]::WriteAllLines($SourceAvailabilityPath, $sourceAvailabilityLines, $Utf8NoBom)

$BinaryBundle = Join-Path $ReleaseDir $BinaryBundleName
Compress-Archive `
    -Path (Join-Path $BinaryStage "*") `
    -DestinationPath $BinaryBundle `
    -CompressionLevel Optimal

$ManifestPath = Join-Path $ReleaseDir "SHA256SUMS.txt"
$manifestLines = @(
    Get-ChildItem $ReleaseDir -File |
        Where-Object { $_.Name -ne "SHA256SUMS.txt" } |
        Sort-Object Name |
        ForEach-Object {
            $hash = (Get-FileHash $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
            "$hash  $($_.Name)"
        }
)
[System.IO.File]::WriteAllLines($ManifestPath, $manifestLines, $Utf8NoBom)

& $VerifyRelease -RepoRoot $RepoRoot -ReleaseDir $ReleaseDir
Write-ReleaseState -Status "release-complete" -SetupSha256 $SetupHash

Remove-Item $TempRoot -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "[PASS] Release compliance bundle built."
Write-Host "[PASS] Publish directory: $ReleaseDir"
Write-Host "[INFO] Wrapper source commit: $Head"
Write-Host "[INFO] Upstream corresponding source: $UpstreamSourceSha"
Write-Host "[INFO] Upload the verified release-directory files together; do not upload raw out\installer Setup.exe separately."
