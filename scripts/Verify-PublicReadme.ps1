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
    '当前已验证基线：`v0.1.0-dev.5.4.2`。',
    'Last fully validated binary baseline: `v0.1.0-dev.5.4.2`.',
    '最近一个完整验收的二进制基线：`v0.1.0-dev.5.4.2`。',
    'No public binary release',
    'A public binary release is not published yet',
    'first public-binary prerelease candidate',
    'not considered validated until its release regression closes',
    '本仓库暂未发布公开二进制 Release',
    '当前尚未发布公开二进制 Release',
    '公开二进制预发布的候选版本线',
    '完整发布回归收口前不视为“已验证二进制版本”',
    'first real GitHub-hosted run is tracked separately',
    '首次真实 GitHub hosted-run 仍作为独立验收项'
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
    'Current public prerelease: [`v0.1.0-dev.6.0`](https://github.com/Suki-Kyaru/magic-trackpad-windows/releases/tag/v0.1.0-dev.6.0).',
    'Final Setup SHA256 inside the published binary ZIP:',
    'f6e7155beca5d863b8d70022c5ac9d7a38daa21880b572a25b0bff9c54661791',
    'Previous frozen validated binary baseline: `v0.1.0-dev.5.4.2`.',
    '`0.1.0-dev.6.0`, and `0.1.0-rc.1` identities',
    '`v0.1.0-dev.6.0` completed the controlled release regression and is now frozen.',
    'The current public binary prerelease is `v0.1.0-dev.6.0`.',
    'The workflow has completed successfully on GitHub-hosted',
    'The screenshots below were refreshed from the dev.6.0 prerelease candidate UI.',
    'Windows 11 x64',
    'The current `v0.1.0` line therefore remains Windows 11 x64 only.',
    '| Windows 10 wrapper/install lifecycle | **Not supported by the current `v0.1.0` line; `v0.1.0-rc.1` failed A3120 validation on Windows 10 x64 build 19044** |',
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
    '当前公开预发行版：[`v0.1.0-dev.6.0`](https://github.com/Suki-Kyaru/magic-trackpad-windows/releases/tag/v0.1.0-dev.6.0)。',
    '已发布二进制 ZIP 内 Final Setup SHA256：',
    'f6e7155beca5d863b8d70022c5ac9d7a38daa21880b572a25b0bff9c54661791',
    '上一个冻结并完成验收的二进制基线：`v0.1.0-dev.5.4.2`。',
    '和 `0.1.0-rc.1` 主动阻断。',
    '`v0.1.0-dev.6.0` 已完成受控发布回归并正式冻结。',
    '当前公开二进制预发行版为 `v0.1.0-dev.6.0`。',
    '该工作流已经在 GitHub-hosted Windows runner 上实际成功运行',
    '以下截图已使用 dev.6.0 预发布候选界面重新采集。',
    'Windows 11 x64',
    '因此当前 `v0.1.0` 版本线继续仅支持 Windows 11 x64。',
    '| Windows 10 包装/安装生命周期 | **当前 `v0.1.0` 版本线不支持；`v0.1.0-rc.1` 已在 Windows 10 x64 build 19044 上完成 A3120 失败验证** |',
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
    '非破坏性的 GitHub Actions CI',
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

Write-Host "[PASS] Public README reports current source version v$Version and published dev.6.0 prerelease."
Write-Host "[PASS] English and Simplified Chinese READMEs use language-matched screenshot sets."
Write-Host "[PASS] All six dev.6.0 bilingual screenshot assets exist and are non-empty."
Write-Host "[PASS] ARM64 remains unvalidated; Windows 10 rc.1 validation failed and the current v0.1.0 line remains Windows 11 x64 only."
Write-Host "[PASS] Install, safe uninstall, diagnostics/privacy, and safety model are documented."
Write-Host "[PASS] Pinned upstream v2.0 asset and SHA256 are documented."
Write-Host "[PASS] README records MIT/GPL separation, release compliance, and frozen dev.5.4.2/dev.6.0/rc.1 identities."
Write-Host "[PASS] Public status distinguishes published dev.6.0 from current v$Version stable-release candidate source."
Write-Host "[PASS] OSS-1.1B root-history cleanup remains intact."
