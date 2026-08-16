param(
    [string]$RepoRoot = "D:\Dev\magic-trackpad-windows",
    [Parameter(Mandatory = $true)]
    [string]$ReleaseDir
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $ReleaseDir -PathType Container)) {
    throw "Release directory not found: $ReleaseDir"
}

$UpstreamSourceSha = "8874eaa3994f0e7e40fa40312250bbc5f13cc928"
$UpstreamWorkflowSha = "3611b8c6f4fa06a6912d16bb4b51a47bb8c70afa"
$UpstreamTagSha = "6a308eccf6ae4fbc3cdcf267c3a525b4818824e3"
$UpstreamAsset = "MT2FW11-20260223-MSSigned.zip"
$UpstreamAssetSha256 = "2870c0c7982ce6aafc3ff763fec2999423dc4bdbd1a2c0e31ca216f26a75714f"
$UpstreamActionsRun = "22308909844"
$UpstreamSdkWdkVersion = "10.0.26100.6584"
$UpstreamShort = $UpstreamSourceSha.Substring(0, 12)
$WorkflowShort = $UpstreamWorkflowSha.Substring(0, 12)

$ProvenancePath = Join-Path $ReleaseDir "UPSTREAM_PROVENANCE.txt"

if (-not (Test-Path $ProvenancePath -PathType Leaf)) {
    throw "Release provenance file missing: UPSTREAM_PROVENANCE.txt"
}

$provenanceMap = @{}

foreach ($line in Get-Content $ProvenancePath) {
    if ([string]::IsNullOrWhiteSpace($line)) {
        continue
    }

    if ($line -notmatch '^([^=]+)=(.*)$') {
        throw "Malformed provenance line: $line"
    }

    $key = $matches[1]
    $value = $matches[2]

    if ($provenanceMap.ContainsKey($key)) {
        throw "Duplicate provenance key: $key"
    }

    $provenanceMap[$key] = $value
}

$Version = $provenanceMap["wrapper_version"]
if ([string]::IsNullOrWhiteSpace($Version)) {
    throw "Release provenance does not contain wrapper_version."
}

$BinaryBundleName = "MagicTrackpad-for-Windows-$Version-x64-binary.zip"
$SetupName = "MagicTrackpad-for-Windows-Setup-$Version-x64.exe"
$WrapperSourceName = "MagicTrackpad-for-Windows-source-$Version.zip"
$UpstreamSourceName = "MagicTrackpad2ForWindows-corresponding-source-$UpstreamShort.zip"
$WorkflowName = "UPSTREAM_BUILD_WORKFLOW-$WorkflowShort.yml"

$required = @(
    $BinaryBundleName,
    $WrapperSourceName,
    $UpstreamSourceName,
    $WorkflowName,
    "UPSTREAM_PROVENANCE.txt",
    "SHA256SUMS.txt"
)

foreach ($name in $required) {
    if (-not (Test-Path (Join-Path $ReleaseDir $name) -PathType Leaf)) {
        throw "Required release file missing: $name"
    }
}

$nakedSetup = @(
    Get-ChildItem $ReleaseDir -File -Filter "*.exe"
)

if ($nakedSetup.Count -ne 0) {
    throw "Naked Setup executable found at release root. Publish the binary ZIP instead: $($nakedSetup.Name -join ', ')"
}

$expectedProvenance = @{
    "upstream_binary_asset" = $UpstreamAsset
    "upstream_binary_asset_sha256" = $UpstreamAssetSha256
    "upstream_source_commit" = $UpstreamSourceSha
    "upstream_source_archive" = $UpstreamSourceName
    "upstream_workflow_commit" = $UpstreamWorkflowSha
    "upstream_workflow_snapshot" = $WorkflowName
    "upstream_v2_tag_commit" = $UpstreamTagSha
    "upstream_actions_run" = $UpstreamActionsRun
    "upstream_sdk_wdk_package_version" = $UpstreamSdkWdkVersion
}

foreach ($key in $expectedProvenance.Keys) {
    if ($provenanceMap[$key] -ne $expectedProvenance[$key]) {
        throw "Release provenance mismatch for $key. Expected '$($expectedProvenance[$key])', got '$($provenanceMap[$key])'."
    }
}

$manifestPath = Join-Path $ReleaseDir "SHA256SUMS.txt"
$manifestEntries = @{}

foreach ($line in Get-Content $manifestPath) {
    if ([string]::IsNullOrWhiteSpace($line)) {
        continue
    }

    if ($line -notmatch '^([0-9a-fA-F]{64})\s{2}(.+)$') {
        throw "Malformed SHA256SUMS line: $line"
    }

    $name = $matches[2]
    if ($manifestEntries.ContainsKey($name)) {
        throw "Duplicate SHA256SUMS entry: $name"
    }

    $manifestEntries[$name] = $matches[1].ToLowerInvariant()
}

$releaseFiles = @(
    Get-ChildItem $ReleaseDir -File |
        Where-Object { $_.Name -ne "SHA256SUMS.txt" } |
        Sort-Object Name
)

foreach ($file in $releaseFiles) {
    if (-not $manifestEntries.ContainsKey($file.Name)) {
        throw "Release file is not covered by SHA256SUMS: $($file.Name)"
    }

    $actual = (Get-FileHash $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actual -ne $manifestEntries[$file.Name]) {
        throw "SHA256 mismatch: $($file.Name)"
    }
}

if ($manifestEntries.Count -ne $releaseFiles.Count) {
    throw "SHA256SUMS contains entries that do not map one-to-one to release files."
}

foreach ($hashKeyPair in @(
    @("wrapper_source_archive_sha256", $WrapperSourceName),
    @("upstream_source_archive_sha256", $UpstreamSourceName),
    @("upstream_workflow_snapshot_sha256", $WorkflowName)
)) {
    $key = $hashKeyPair[0]
    $name = $hashKeyPair[1]
    $actual = (Get-FileHash (Join-Path $ReleaseDir $name) -Algorithm SHA256).Hash.ToLowerInvariant()

    if ($provenanceMap[$key] -ne $actual) {
        throw "Provenance hash mismatch for $name."
    }
}

$workflow = Get-Content (Join-Path $ReleaseDir $WorkflowName) -Raw
foreach ($requiredText in @(
    "ref: ossign",
    "Create Source Tarball",
    "Upload Source Tarball",
    "source-code-"
)) {
    if (-not $workflow.Contains($requiredText)) {
        throw "Frozen upstream workflow missing expected evidence: $requiredText"
    }
}

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Get-ZipEntryNames {
    param([string]$Path)

    $zip = [System.IO.Compression.ZipFile]::OpenRead($Path)
    try {
        return @($zip.Entries | ForEach-Object { $_.FullName })
    }
    finally {
        $zip.Dispose()
    }
}

function Get-ZipEntryText {
    param(
        [string]$Path,
        [string]$EntryName
    )

    $zip = [System.IO.Compression.ZipFile]::OpenRead($Path)
    try {
        $entry = $zip.GetEntry($EntryName)
        if ($null -eq $entry) {
            throw "ZIP entry not found: $EntryName"
        }

        $stream = $entry.Open()
        $reader = [System.IO.StreamReader]::new($stream, [System.Text.Encoding]::UTF8, $true)
        try {
            return $reader.ReadToEnd()
        }
        finally {
            $reader.Dispose()
            $stream.Dispose()
        }
    }
    finally {
        $zip.Dispose()
    }
}

function Get-ZipEntrySha256 {
    param(
        [string]$Path,
        [string]$EntryName
    )

    $zip = [System.IO.Compression.ZipFile]::OpenRead($Path)
    try {
        $entry = $zip.GetEntry($EntryName)
        if ($null -eq $entry) {
            throw "ZIP entry not found: $EntryName"
        }

        $stream = $entry.Open()
        $sha = [System.Security.Cryptography.SHA256]::Create()
        try {
            $hashBytes = $sha.ComputeHash($stream)
            return (
                $hashBytes |
                    ForEach-Object { $_.ToString("x2") }
            ) -join ""
        }
        finally {
            $sha.Dispose()
            $stream.Dispose()
        }
    }
    finally {
        $zip.Dispose()
    }
}

$BinaryBundle = Join-Path $ReleaseDir $BinaryBundleName
$binaryEntries = @(
    Get-ZipEntryNames -Path $BinaryBundle |
        Where-Object { -not $_.EndsWith("/") }
)

$expectedBinaryEntries = @(
    $SetupName,
    "LICENSE",
    "GPL-2.0.txt",
    "THIRD_PARTY_NOTICES.md",
    "UPSTREAM_PROVENANCE.txt",
    "SOURCE_AVAILABILITY.txt"
)

foreach ($entry in $expectedBinaryEntries) {
    if ($binaryEntries -notcontains $entry) {
        throw "Binary bundle missing: $entry"
    }
}

if ($binaryEntries.Count -ne $expectedBinaryEntries.Count) {
    $unexpected = @($binaryEntries | Where-Object { $expectedBinaryEntries -notcontains $_ })
    throw "Binary bundle contains unexpected file(s): $($unexpected -join ', ')"
}

foreach ($pair in @(
    @("LICENSE", "LICENSE"),
    @("GPL-2.0.txt", "licenses\GPL-2.0.txt"),
    @("THIRD_PARTY_NOTICES.md", "THIRD_PARTY_NOTICES.md"),
    @("UPSTREAM_PROVENANCE.txt", "UPSTREAM_PROVENANCE.txt")
)) {
    $entryName = $pair[0]
    $source = $pair[1]

    if ($source -eq "UPSTREAM_PROVENANCE.txt") {
        $expectedHash = (Get-FileHash $ProvenancePath -Algorithm SHA256).Hash.ToLowerInvariant()
    }
    else {
        $expectedHash = (Get-FileHash (Join-Path $RepoRoot $source) -Algorithm SHA256).Hash.ToLowerInvariant()
    }

    $entryHash = Get-ZipEntrySha256 -Path $BinaryBundle -EntryName $entryName

    if ($entryHash -ne $expectedHash) {
        throw "Binary bundle file differs from expected source: $entryName"
    }
}

$setupHash = Get-ZipEntrySha256 -Path $BinaryBundle -EntryName $SetupName
if ($provenanceMap["wrapper_setup_sha256"] -ne $setupHash) {
    throw "Setup hash inside binary bundle does not match provenance."
}

$sourceAvailability = Get-ZipEntryText -Path $BinaryBundle -EntryName "SOURCE_AVAILABILITY.txt"
foreach ($requiredText in @($WrapperSourceName, $UpstreamSourceName, $WorkflowName)) {
    if (-not $sourceAvailability.Contains($requiredText)) {
        throw "SOURCE_AVAILABILITY.txt missing: $requiredText"
    }
}

$wrapperEntries = Get-ZipEntryNames -Path (Join-Path $ReleaseDir $WrapperSourceName)
$wrapperPrefix = "MagicTrackpad-for-Windows-source-$Version/"

foreach ($requiredEntry in @(
    "${wrapperPrefix}LICENSE",
    "${wrapperPrefix}THIRD_PARTY_NOTICES.md",
    "${wrapperPrefix}licenses/GPL-2.0.txt",
    "${wrapperPrefix}scripts/Build-ReleaseBundle.ps1",
    "${wrapperPrefix}scripts/Verify-ReleaseBundle.ps1",
    "${wrapperPrefix}scripts/Verify-LicenseDistribution.ps1",
    "${wrapperPrefix}docs/oss/UPSTREAM_SOURCE_PROVENANCE.md",
    "${wrapperPrefix}docs/oss/RELEASE_COMPLIANCE.md"
)) {
    if ($wrapperEntries -notcontains $requiredEntry) {
        throw "Wrapper source archive missing: $requiredEntry"
    }
}

foreach ($forbiddenPrefix in @(
    "${wrapperPrefix}build/",
    "${wrapperPrefix}out/",
    "${wrapperPrefix}third_party/MagicTrackpad2ForWindows-v2.0/"
)) {
    if (@($wrapperEntries | Where-Object { $_.StartsWith($forbiddenPrefix) }).Count -gt 0) {
        throw "Wrapper source archive contains forbidden generated/binary path: $forbiddenPrefix"
    }
}

$UpstreamSource = Join-Path $ReleaseDir $UpstreamSourceName
$upstreamEntries = Get-ZipEntryNames -Path $UpstreamSource
$upstreamPrefix = "MagicTrackpad2ForWindows-corresponding-source-$UpstreamShort/"

foreach ($requiredEntry in @(
    "${upstreamPrefix}AmtPtpDeviceUsbUm/Driver.c",
    "${upstreamPrefix}AmtPtpHidFilter/Driver.c",
    "${upstreamPrefix}AmtPtpDeviceUsbUm/packages.config",
    "${upstreamPrefix}AmtPtpHidFilter/packages.config",
    "${upstreamPrefix}build/AmtPtpDevice_AMD64.inf",
    "${upstreamPrefix}REDISTRIBUTION-GPL-2.0.txt",
    "${upstreamPrefix}$WorkflowName",
    "${upstreamPrefix}SOURCE_ORIGIN.txt"
)) {
    if ($upstreamEntries -notcontains $requiredEntry) {
        throw "Upstream corresponding-source archive missing: $requiredEntry"
    }
}

$repoGplHash = (Get-FileHash (Join-Path $RepoRoot "licenses\GPL-2.0.txt") -Algorithm SHA256).Hash.ToLowerInvariant()
$zipGplHash = Get-ZipEntrySha256 `
    -Path $UpstreamSource `
    -EntryName "${upstreamPrefix}REDISTRIBUTION-GPL-2.0.txt"

if ($repoGplHash -ne $zipGplHash) {
    throw "Upstream source archive GPL redistribution text differs from repository copy."
}

$workflowHash = (Get-FileHash (Join-Path $ReleaseDir $WorkflowName) -Algorithm SHA256).Hash.ToLowerInvariant()
$zipWorkflowHash = Get-ZipEntrySha256 `
    -Path $UpstreamSource `
    -EntryName "${upstreamPrefix}$WorkflowName"

if ($workflowHash -ne $zipWorkflowHash) {
    throw "Workflow snapshot inside upstream source archive differs from release workflow snapshot."
}

$sourceOrigin = Get-ZipEntryText `
    -Path $UpstreamSource `
    -EntryName "${upstreamPrefix}SOURCE_ORIGIN.txt"

foreach ($requiredText in @(
    "upstream_source_commit=$UpstreamSourceSha",
    "upstream_workflow_commit=$UpstreamWorkflowSha",
    "upstream_actions_run=$UpstreamActionsRun"
)) {
    if (-not $sourceOrigin.Contains($requiredText)) {
        throw "Upstream SOURCE_ORIGIN.txt missing: $requiredText"
    }
}

foreach ($entryName in @(
    "${upstreamPrefix}AmtPtpDeviceUsbUm/packages.config",
    "${upstreamPrefix}AmtPtpHidFilter/packages.config"
)) {
    $packages = Get-ZipEntryText -Path $UpstreamSource -EntryName $entryName
    if (-not $packages.Contains($UpstreamSdkWdkVersion)) {
        throw "Upstream packages.config does not preserve expected SDK/WDK version: $entryName"
    }
}

$extractRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("magic-trackpad-release-verify-" + [guid]::NewGuid().ToString("N"))

try {
    [System.IO.Compression.ZipFile]::ExtractToDirectory($BinaryBundle, $extractRoot)
    $setupPath = Join-Path $extractRoot $SetupName

    if (-not (Test-Path $setupPath -PathType Leaf)) {
        throw "Setup was not extracted from binary bundle."
    }

    $setupSignature = Get-AuthenticodeSignature $setupPath
    Write-Host "[INFO] Wrapper Setup Authenticode status: $($setupSignature.Status)"
}
finally {
    if (Test-Path $extractRoot) {
        Remove-Item $extractRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "[PASS] Publish directory contains the controlled binary/source assets and no naked Setup executable."
Write-Host "[PASS] SHA256SUMS covers every release file exactly once."
Write-Host "[PASS] Binary bundle carries Setup plus MIT/GPL/third-party/provenance/source-availability material."
Write-Host "[PASS] Setup and source/workflow hashes close against UPSTREAM_PROVENANCE.txt."
Write-Host "[PASS] Wrapper source archive includes compliance/build tooling and excludes local binary/generated payloads."
Write-Host "[PASS] Exact upstream source archive contains driver/build inputs plus explicit redistribution metadata."
Write-Host "[PASS] Upstream source package declarations preserve SDK/WDK version $UpstreamSdkWdkVersion."
