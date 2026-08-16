param(
    [string]$RepoRoot = "D:\Dev\magic-trackpad-windows"
)

$ErrorActionPreference = "Stop"

$Policy = Join-Path $RepoRoot "docs\oss\LICENSE_POLICY_DECISION.md"
$Checklist = Join-Path $RepoRoot "docs\oss\LICENSE_REVIEW_CHECKLIST.md"

foreach ($path in @($Policy, $Checklist)) {
    if (-not (Test-Path $path -PathType Leaf)) {
        throw "OSS-1.3B policy document missing: $path"
    }
}

$combined = (Get-Content $Policy -Raw) + "`n" + (Get-Content $Checklist -Raw)

foreach ($required in @(
    "MIT License",
    "SPDX identifier: MIT",
    "Suki-Kyaru",
    "MagicTrackpad2ForWindows",
    "upstream GPLv2",
    "does not relicense",
    "separate works",
    "aggregation",
    "8874eaa3994f0e7e40fa40312250bbc5f13cc928",
    "OSS-1.3C"
)) {
    if (-not $combined.Contains($required)) {
        throw "OSS-1.3B policy contract missing: $required"
    }
}

$MitLicense = Join-Path $RepoRoot "LICENSE"
$GplLicense = Join-Path $RepoRoot "licenses\GPL-2.0.txt"

foreach ($path in @($MitLicense, $GplLicense)) {
    if (-not (Test-Path $path -PathType Leaf)) {
        throw "OSS-1.3C license implementation missing: $path"
    }
}

$mitText = Get-Content $MitLicense -Raw
if (-not $mitText.Contains("Copyright (c) 2026 Suki-Kyaru")) {
    throw "Root MIT LICENSE does not match the decided copyright identity."
}

$thirdParty = Get-Content (Join-Path $RepoRoot "THIRD_PARTY_NOTICES.md") -Raw
if (-not $thirdParty.Contains("vitoplantamura/MagicTrackpad2ForWindows")) {
    throw "Third-party upstream attribution unexpectedly disappeared."
}

$en = Get-Content (Join-Path $RepoRoot "README.md") -Raw
$zh = Get-Content (Join-Path $RepoRoot "README.zh-CN.md") -Raw

foreach ($required in @("SPDX: MIT", "relicensed under MIT", "Release compliance process")) {
    if (-not $en.Contains($required)) {
        throw "English README license-policy status missing: $required"
    }
}

foreach ($required in @("SPDX: MIT", "不会", "Release 合规流程")) {
    if (-not $zh.Contains($required)) {
        throw "Chinese README license-policy status missing: $required"
    }
}

Write-Host "[PASS] Project-authored wrapper license policy is MIT (SPDX MIT)."
Write-Host "[PASS] Initial public copyright holder is Suki-Kyaru (2026)."
Write-Host "[PASS] Upstream MagicTrackpad2ForWindows remains explicitly third-party GPLv2 software."
Write-Host "[PASS] MIT policy does not claim to relicense upstream driver material."
Write-Host "[PASS] Separate-works/aggregation policy and revisit triggers are documented."
Write-Host "[PASS] Public README files reflect the decided policy."
Write-Host "[PASS] Root MIT LICENSE and separate upstream GPLv2 text implement the decided policy."
