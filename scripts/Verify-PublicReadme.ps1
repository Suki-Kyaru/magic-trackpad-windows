param(
    [string]$RepoRoot = "D:\Dev\magic-trackpad-windows"
)

$ErrorActionPreference = "Stop"

$Readme = Join-Path $RepoRoot "README.md"
$ReadmeZh = Join-Path $RepoRoot "README.zh-CN.md"

foreach ($path in @($Readme, $ReadmeZh)) {
    if (-not (Test-Path $path -PathType Leaf)) {
        throw "Public README file missing: $path"
    }
}

$en = Get-Content $Readme -Raw
$zh = Get-Content $ReadmeZh -Raw

foreach ($stale in @(
    'v0.1.0-dev.5.1',
    '尚未完成的关键验收',
    '当前卸载程序只移除'
)) {
    if ($en.Contains($stale) -or $zh.Contains($stale)) {
        throw "Stale pre-OSS README statement remains: $stale"
    }
}

foreach ($required in @(
    'v0.1.0-dev.5.4.2',
    'Windows 11 x64',
    'Apple USB-C Magic Trackpad A3120',
    'ARM64 wrapper/install lifecycle | **Not yet validated**',
    'Remove the application and Magic Trackpad driver',
    'without `/force`',
    'Diagnostics-*.txt',
    'MagicTrackpad2ForWindows',
    'MT2FW11-20260223-MSSigned.zip',
    '2870c0c7982ce6aafc3ff763fec2999423dc4bdbd1a2c0e31ca216f26a75714f',
    'top-level license expression',
    'docs/assets/screenshots/installer-information-zh-cn.png',
    'docs/assets/screenshots/installer-destination-zh-cn.png',
    'docs/assets/screenshots/uninstall-connected-guard-zh-cn.png'
)) {
    if (-not $en.Contains($required)) {
        throw "English public README contract missing: $required"
    }
}

foreach ($required in @(
    'v0.1.0-dev.5.4.2',
    'Windows 11 x64',
    'Apple USB-C Magic Trackpad A3120',
    'ARM64 包装/安装生命周期',
    '同时卸载程序和 Magic Trackpad 驱动',
    '禁止 `/force`',
    'Diagnostics-*.txt',
    'MagicTrackpad2ForWindows',
    'MT2FW11-20260223-MSSigned.zip',
    '2870c0c7982ce6aafc3ff763fec2999423dc4bdbd1a2c0e31ca216f26a75714f',
    '顶层 license expression'
)) {
    if (-not $zh.Contains($required)) {
        throw "Chinese public README contract missing: $required"
    }
}

foreach ($image in @(
    "docs\assets\screenshots\installer-information-zh-cn.png",
    "docs\assets\screenshots\installer-destination-zh-cn.png",
    "docs\assets\screenshots\uninstall-connected-guard-zh-cn.png"
)) {
    $path = Join-Path $RepoRoot $image

    if (-not (Test-Path $path -PathType Leaf)) {
        throw "README screenshot missing: $image"
    }

    if ((Get-Item $path).Length -le 0) {
        throw "README screenshot is empty: $image"
    }
}

if (Test-Path (Join-Path $RepoRoot "LICENSE") -PathType Leaf) {
    throw "OSS-1.2 must not create the root LICENSE before OSS-1.3 review."
}

$rootPatchNotes = @(Get-ChildItem -Path $RepoRoot -File -Filter "PATCH_NOTES*.md")

if ($rootPatchNotes.Count -ne 0) {
    throw "OSS-1.1B root cleanup regressed."
}

Write-Host "[PASS] Public English README targets dev.5.4.2 and contains no dev.5.1 stale status."
Write-Host "[PASS] Simplified Chinese companion README is present."
Write-Host "[PASS] Validated support is separated from unvalidated ARM64/Windows 10 claims."
Write-Host "[PASS] Install, safe uninstall, diagnostics/privacy, and safety model are documented."
Write-Host "[PASS] Pinned upstream v2.0 asset and SHA256 are documented."
Write-Host "[PASS] Three accepted Windows 11 screenshots are present."
Write-Host "[PASS] License status is explicit without inventing the OSS-1.3 root LICENSE."
Write-Host "[PASS] OSS-1.1B root-history cleanup remains intact."
