param(
    [string]$RepoRoot = "D:\Dev\magic-trackpad-windows"
)

$ErrorActionPreference = "Stop"

$Provenance = Join-Path $RepoRoot "docs\oss\UPSTREAM_SOURCE_PROVENANCE.md"
$Checklist = Join-Path $RepoRoot "docs\oss\LICENSE_REVIEW_CHECKLIST.md"

foreach ($path in @($Provenance, $Checklist)) {
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

if (Test-Path (Join-Path $RepoRoot "LICENSE") -PathType Leaf) {
    throw "OSS-1.3A must not create the wrapper root LICENSE before policy review."
}

$readme = Get-Content (Join-Path $RepoRoot "README.md") -Raw

if (-not $readme.Contains("still being reviewed in OSS-1.3")) {
    throw "Public README no longer preserves license-review-in-progress status."
}

Write-Host "[PASS] Signed upstream asset identity and SHA256 are frozen."
Write-Host "[PASS] Release Actions run ID is frozen."
Write-Host "[PASS] Exact source checkout SHA is distinguished from workflow and tag SHAs."
Write-Host "[PASS] GPLv2 lineage evidence is recorded without guessing only/or-later SPDX semantics."
Write-Host "[PASS] Conservative corresponding-source release plan is documented."
Write-Host "[PASS] Root LICENSE remains intentionally deferred to OSS-1.3B."
Write-Host "[PASS] Public README still states license review is in progress."
