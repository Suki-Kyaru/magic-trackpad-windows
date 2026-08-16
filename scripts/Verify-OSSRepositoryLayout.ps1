param(
    [string]$RepoRoot = "D:\Dev\magic-trackpad-windows"
)

$ErrorActionPreference = "Stop"

$required = @(
    "docs\README.md",
    "docs\history\README.md",
    "docs\history\patch-notes\README.md",
    "docs\oss\REPOSITORY_STRUCTURE.md",
    "docs\oss\README_PUBLIC_BLUEPRINT.md",
    "docs\oss\LICENSE_REVIEW_CHECKLIST.md",
    "docs\oss\LICENSE_POLICY_DECISION.md",
    "docs\oss\UPSTREAM_SOURCE_PROVENANCE.md",
    "docs\oss\RELEASE_COMPLIANCE.md",
    "LICENSE",
    "licenses\GPL-2.0.txt",
    "licenses\README.md",
    "THIRD_PARTY_NOTICES.md"
)

foreach ($relative in $required) {
    $path = Join-Path $RepoRoot $relative

    if (-not (Test-Path $path -PathType Leaf)) {
        throw "Required OSS-1.1B file missing: $relative"
    }
}

$rootPatchNotes = @(
    Get-ChildItem -Path $RepoRoot -File -Filter "PATCH_NOTES*.md" -ErrorAction Stop
)

if ($rootPatchNotes.Count -ne 0) {
    throw "Repository-root patch notes remain: $($rootPatchNotes.Name -join ', ')"
}

$archivedPatchNotes = @(
    Get-ChildItem `
        -Path (Join-Path $RepoRoot "docs\history\patch-notes") `
        -File `
        -Filter "PATCH_NOTES*.md"
)

if ($archivedPatchNotes.Count -lt 1) {
    throw "No historical patch notes were archived."
}

$legacyOldInfo = Join-Path $RepoRoot "docs\history\legacy\INFO_BEFORE.dev5.1.txt"

if (-not (Test-Path $legacyOldInfo -PathType Leaf)) {
    throw "Legacy INFO_BEFORE.txt was not archived."
}

if (Test-Path (Join-Path $RepoRoot "installer\INFO_BEFORE.txt") -PathType Leaf) {
    throw "Unreferenced legacy installer\INFO_BEFORE.txt still exists in active installer resources."
}

foreach ($current in @(
    "installer\INFO_BEFORE.en.txt",
    "installer\INFO_BEFORE.zh-CN.txt"
)) {
    if (-not (Test-Path (Join-Path $RepoRoot $current) -PathType Leaf)) {
        throw "Current localized installer resource missing: $current"
    }
}

$tracked = @(& git -C $RepoRoot ls-files)

foreach ($forbidden in @(
    "build/",
    "out/",
    ".vs/",
    "third_party/MagicTrackpad2ForWindows-v2.0/"
)) {
    $matches = @($tracked | Where-Object { $_.StartsWith($forbidden) })

    if ($matches.Count -gt 0) {
        throw "Local/generated path is unexpectedly tracked: $forbidden"
    }
}

Write-Host "[PASS] Repository root no longer contains raw PATCH_NOTES files."
Write-Host "[PASS] Historical patch notes are preserved under docs/history/patch-notes."
Write-Host "[PASS] Legacy unreferenced INFO_BEFORE.txt is preserved under docs/history/legacy."
Write-Host "[PASS] Current localized installer resources remain active."
Write-Host "[PASS] Generated/build and third-party payload directories remain untracked."
Write-Host "[PASS] Documentation and OSS planning indexes are present."
Write-Host "[PASS] Root MIT LICENSE and separate third-party GPLv2 license text are present."
