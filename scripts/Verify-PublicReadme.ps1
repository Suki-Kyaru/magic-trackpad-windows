param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = "Stop"

$Readme = Join-Path $RepoRoot "README.md"
$ReadmeZh = Join-Path $RepoRoot "README.zh-CN.md"
$VersionPath = Join-Path $RepoRoot "VERSION"

foreach ($path in @($Readme, $ReadmeZh, $VersionPath)) {
    if (-not (Test-Path $path -PathType Leaf)) {
        throw "Public README/version file missing: $path"
    }
}

$en = Get-Content $Readme -Raw
$zh = Get-Content $ReadmeZh -Raw
$Version = (Get-Content $VersionPath -Raw).Trim()

if ([string]::IsNullOrWhiteSpace($Version)) {
    throw "VERSION is empty."
}

$currentEn = 'Current source version: `v' + $Version + '`.'
$currentZh = '当前源码版本：`v' + $Version + '`。'

foreach ($stale in @(
    'v0.1.0-dev.5.1',
    '尚未完成的关键验收',
    '当前卸载程序只移除',
    'are still being prepared.',
    'CI、贡献流程和首个公开 Release 仍在继续准备',
    'Current validated baseline: `v0.1.0-dev.5.4.2`.',
    '当前已验证基线：`v0.1.0-dev.5.4.2`。'
)) {
    if ($en.Contains($stale) -or $zh.Contains($stale)) {
        throw "Stale pre-current README statement remains: $stale"
    }
}

$englishScreenshots = @(
    'docs/assets/screenshots/installer-information-en.png',
    'docs/assets/screenshots/installer-destination-en.png',
    'docs/assets/screenshots/uninstall-connected-guard-en.png'
)

$chineseScreenshots = @(
    'docs/assets/screenshots/installer-information-zh-cn.png',
    'docs/assets/screenshots/installer-destination-zh-cn.png',
    'docs/assets/screenshots/uninstall-connected-guard-zh-cn.png'
)

foreach ($required in @(
    $currentEn,
    'Last fully validated binary baseline: `v0.1.0-dev.5.4.2`.',
    'first public-binary prerelease candidate',
    'not considered validated until its release regression closes',
    'The screenshots below were refreshed from the dev.6.0 prerelease candidate UI.',
    'Windows 11 x64',
    'Apple USB-C Magic Trackpad A3120',
    'ARM64 wrapper/install lifecycle | **Not yet validated**',
    'Remove the application and Magic Trackpad driver',
    'without `/force`',
    'Diagnostics-*.txt',
    'MagicTrackpad2ForWindows',
    'MT2FW11-20260223-MSSigned.zip',
    '2870c0c7982ce6aafc3ff763fec2999423dc4bdbd1a2c0e31ca216f26a75714f',
    'SPDX: MIT',
    'GPLv2',
    'Release compliance process',
    'non-destructive GitHub Actions CI',
    'afbe531a5e117820c8643b776b74b82002db27d223366cf07fb390c818aeca04'
) + $englishScreenshots) {
    if (-not $en.Contains($required)) {
        throw "English public README contract missing: $required"
    }
}

foreach ($forbidden in $chineseScreenshots) {
    if ($en.Contains($forbidden)) {
        throw "English README must not reference Simplified Chinese screenshot: $forbidden"
    }
}

foreach ($required in @(
    $currentZh,
    '最近一个完整验收的二进制基线：`v0.1.0-dev.5.4.2`。',
    '公开二进制预发布的候选版本线',
    '完整发布回归收口前不视为“已验证二进制版本”',
    '以下截图已使用 dev.6.0 预发布候选界面重新采集。',
    'Windows 11 x64',
    'Apple USB-C Magic Trackpad A3120',
    'ARM64 包装/安装生命周期',
    '同时卸载程序和 Magic Trackpad 驱动',
    '禁止 `/force`',
    'Diagnostics-*.txt',
    'MagicTrackpad2ForWindows',
    'MT2FW11-20260223-MSSigned.zip',
    '2870c0c7982ce6aafc3ff763fec2999423dc4bdbd1a2c0e31ca216f26a75714f',
    'SPDX: MIT',
    '不会**被本项目重新许可为 MIT',
    'Release 合规流程',
    '非破坏性 GitHub Actions CI',
    'afbe531a5e117820c8643b776b74b82002db27d223366cf07fb390c818aeca04'
) + $chineseScreenshots) {
    if (-not $zh.Contains($required)) {
        throw "Chinese public README contract missing: $required"
    }
}

foreach ($forbidden in $englishScreenshots) {
    if ($zh.Contains($forbidden)) {
        throw "Chinese README must not reference English screenshot: $forbidden"
    }
}

foreach ($image in @($englishScreenshots + $chineseScreenshots)) {
    $relative = $image.Replace('/', '\')
    $path = Join-Path $RepoRoot $relative

    if (-not (Test-Path $path -PathType Leaf)) {
        throw "README screenshot missing: $image"
    }

    if ((Get-Item $path).Length -le 0) {
        throw "README screenshot is empty: $image"
    }
}

$rootPatchNotes = @(Get-ChildItem -Path $RepoRoot -File -Filter "PATCH_NOTES*.md")
if ($rootPatchNotes.Count -ne 0) {
    throw "OSS-1.1B root cleanup regressed."
}

Write-Host "[PASS] Public README reports current source version v$Version and frozen dev.5.4.2 binary baseline."
Write-Host "[PASS] English and Simplified Chinese READMEs use language-matched screenshot sets."
Write-Host "[PASS] All six dev.6.0 bilingual screenshot assets exist and are non-empty."
Write-Host "[PASS] Validated support is separated from unvalidated ARM64/Windows 10 claims."
Write-Host "[PASS] Install, safe uninstall, diagnostics/privacy, and safety model are documented."
Write-Host "[PASS] Pinned upstream v2.0 asset and SHA256 are documented."
Write-Host "[PASS] README records implemented MIT/GPL separation, release compliance, and frozen dev.5.4.2 artifact identity."
Write-Host "[PASS] Public status copy distinguishes source-version transition from binary validation."
Write-Host "[PASS] OSS-1.1B root-history cleanup remains intact."
