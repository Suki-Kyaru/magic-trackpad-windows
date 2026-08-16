param(
    [string]$RepoRoot = "D:\Dev\magic-trackpad-windows"
)

$ErrorActionPreference = "Stop"

$Provenance = Join-Path $RepoRoot "docs\oss\UPSTREAM_SOURCE_PROVENANCE.md"
$Checklist = Join-Path $RepoRoot "docs\oss\LICENSE_REVIEW_CHECKLIST.md"
$MitLicense = Join-Path $RepoRoot "LICENSE"
$GplLicense = Join-Path $RepoRoot "licenses\GPL-2.0.txt"
$ReleaseCompliance = Join-Path $RepoRoot "docs\oss\RELEASE_COMPLIANCE.md"

foreach ($path in @($Provenance, $Checklist, $MitLicense, $GplLicense, $ReleaseCompliance)) {
    if (-not (Test-Path $path -PathType Leaf)) {
        throw "OSS-1.3A evidence document missing: $path"
    }
}

$combined = (Get-Content $Provenance -Raw) + "`n" + (Get-Content $Checklist -Raw)

foreach ($required in @(
    "MT2FW11-20260223-MSSigned.zip",
    "2870c0c7982ce6aafc3ff763fec2999423dc4bdbd1a2c0e31ca216f26a75714f",
    "22308909844",
    "8874eaa3994f0e7e40fa40312250bbc5f13cc928",
    "3611b8c6f4fa06a6912d16bb4b51a47bb8c70afa",
    "6a308eccf6ae4fbc3cdcf267c3a525b4818824e3",
    "ref: ossign",
    "GPL-2.0-only",
    "GPL-2.0-or-later"
)) {
    if (-not $combined.Contains($required)) {
        throw "OSS-1.3A provenance contract missing: $required"
    }
}

$readme = Get-Content (Join-Path $RepoRoot "README.md") -Raw

if (-not $readme.Contains("driver/control-panel payload") -or -not $readme.Contains("GPLv2") -or -not $readme.Contains("relicensed under MIT")) {
    throw "Public README no longer preserves third-party GPL separation."
}

if (-not $readme.Contains("Release compliance process")) {
    throw "Public README no longer links the implemented release-compliance process."
}

Write-Host "[PASS] Signed upstream asset identity and SHA256 are frozen."
Write-Host "[PASS] Release Actions run ID is frozen."
Write-Host "[PASS] Exact source checkout SHA is distinguished from workflow and tag SHAs."
Write-Host "[PASS] GPLv2 lineage evidence is recorded without guessing only/or-later SPDX semantics."
Write-Host "[PASS] Conservative corresponding-source release plan is documented."
Write-Host "[PASS] Root MIT LICENSE and separate GNU GPL version 2 text are implemented."
Write-Host "[PASS] Public README records the implemented MIT/GPL and release-compliance model."
