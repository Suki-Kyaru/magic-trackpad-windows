param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = "Stop"

$RepoRoot = (Resolve-Path $RepoRoot).Path

$expectedDefault = '[string]$RepoRoot = (Split-Path -Parent $PSScriptRoot)'

$maintainerScripts = @(
    "scripts\Build-ReleaseBundle.ps1",
    "scripts\Verify-CIWorkflow.ps1",
    "scripts\Verify-ContributorWorkflow.ps1",
    "scripts\Verify-InstallerLocalizationPreview.ps1",
    "scripts\Verify-LicenseDistribution.ps1",
    "scripts\Verify-LicensePolicyDecision.ps1",
    "scripts\Verify-LicenseReviewBaseline.ps1",
    "scripts\Verify-OSSRepositoryLayout.ps1",
    "scripts\Verify-PublicReadme.ps1",
    "scripts\Verify-ReleaseBundle.ps1",
    "scripts\Verify-UserSafeUninstall.ps1",
    "scripts\Verify-VMUninstallExperiment.ps1",
    "scripts\Verify-MaintainerPortability.ps1"
)

foreach ($relative in $maintainerScripts) {
    $path = Join-Path $RepoRoot $relative

    if (-not (Test-Path $path -PathType Leaf)) {
        throw "Maintainer portability file missing: $relative"
    }

    $text = Get-Content $path -Raw

    if (-not $text.Contains($expectedDefault)) {
        throw "Maintainer script does not derive RepoRoot from PSScriptRoot: $relative"
    }

    if ($text -match '\[string\]\$RepoRoot\s*=\s*["''][A-Za-z]:\\') {
        throw "Maintainer script contains an absolute RepoRoot default: $relative"
    }
}

# Build these strings at runtime so this verifier does not match its own source.
$forbiddenRoots = @(
    ('D:' + '\Dev\'),
    ('D:' + '\IDM\'),
    ('C:' + '\Users\Shang')
)

$maintainedFiles = @(
    "README.md",
    "README.zh-CN.md",
    "AGENTS.md",
    "CONTRIBUTING.md",
    "SECURITY.md",
    "SUPPORT.md"
)

$maintainedFiles += @(
    Get-ChildItem (Join-Path $RepoRoot "docs\oss") -File -Recurse |
        ForEach-Object { $_.FullName.Substring($RepoRoot.Length + 1) }
)

$maintainedFiles += @(
    Get-ChildItem (Join-Path $RepoRoot "scripts") -File -Filter "*.ps1" |
        ForEach-Object { $_.FullName.Substring($RepoRoot.Length + 1) }
)

foreach ($relative in ($maintainedFiles | Sort-Object -Unique)) {
    $path = Join-Path $RepoRoot $relative
    $text = Get-Content $path -Raw

    foreach ($forbidden in $forbiddenRoots) {
        if ($text.Contains($forbidden)) {
            throw "Author-specific local path remains in maintained content: $relative -> $forbidden"
        }
    }
}

$readme = Get-Content (Join-Path $RepoRoot "README.md") -Raw
$readmeZh = Get-Content (Join-Path $RepoRoot "README.zh-CN.md") -Raw
$release = Get-Content (Join-Path $RepoRoot "docs\oss\RELEASE_COMPLIANCE.md") -Raw
$agents = Get-Content (Join-Path $RepoRoot "AGENTS.md") -Raw
$contributing = Get-Content (Join-Path $RepoRoot "CONTRIBUTING.md") -Raw
$runner = Get-Content (Join-Path $RepoRoot "scripts\Invoke-CIStaticChecks.ps1") -Raw

if (-not $readme.Contains("From the repository root:")) {
    throw "English README does not use repository-root-relative build guidance."
}

if (-not $readmeZh.Contains("在仓库根目录运行：")) {
    throw "Chinese README does not use repository-root-relative build guidance."
}

if (-not $release.Contains('-UpstreamRepoPath "<path-to-MagicTrackpad2ForWindows-checkout>"')) {
    throw "Release compliance guide does not use a portable upstream checkout placeholder."
}

foreach ($text in @($agents, $contributing, $runner)) {
    if (-not $text.Contains("Verify-MaintainerPortability.ps1")) {
        throw "Maintainer portability verifier is not wired into contributor/CI guidance."
    }
}

Write-Host "[PASS] Maintainer scripts derive default RepoRoot from PSScriptRoot."
Write-Host "[PASS] No author-specific clone paths remain in maintained scripts/docs."
Write-Host "[PASS] README build examples are repository-root relative."
Write-Host "[PASS] Release compliance uses a portable upstream checkout placeholder."
Write-Host "[PASS] Maintainer portability regression gate is wired into contributor guidance and CI."
