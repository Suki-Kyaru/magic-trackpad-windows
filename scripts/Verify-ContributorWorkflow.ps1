param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = "Stop"

$required = @(
    "AGENTS.md",
    "CONTRIBUTING.md",
    "SECURITY.md",
    "SUPPORT.md",
    ".github\ISSUE_TEMPLATE\bug_report.yml",
    ".github\ISSUE_TEMPLATE\feature_request.yml",
    ".github\ISSUE_TEMPLATE\config.yml",
    ".github\PULL_REQUEST_TEMPLATE.md",
    "docs\oss\CONTRIBUTOR_WORKFLOW.md",
    "docs\DEV6_0_FINAL_RELEASE_VALIDATION.md",
    "docs\RC2_FINAL_VALIDATION.md"
)

foreach ($relative in $required) {
    $path = Join-Path $RepoRoot $relative
    if (-not (Test-Path $path -PathType Leaf)) {
        throw "Contributor workflow file missing: $relative"
    }
}

$agents = Get-Content (Join-Path $RepoRoot "AGENTS.md") -Raw
$contrib = Get-Content (Join-Path $RepoRoot "CONTRIBUTING.md") -Raw
$security = Get-Content (Join-Path $RepoRoot "SECURITY.md") -Raw
$workflow = Get-Content (Join-Path $RepoRoot "docs\oss\CONTRIBUTOR_WORKFLOW.md") -Raw
$pr = Get-Content (Join-Path $RepoRoot ".github\PULL_REQUEST_TEMPLATE.md") -Raw
$attrs = Get-Content (Join-Path $RepoRoot ".gitattributes") -Raw
$rc2Validation = Get-Content (Join-Path $RepoRoot "docs\RC2_FINAL_VALIDATION.md") -Raw

foreach ($requiredText in @(
    'Never hard-code a published `oemN.inf` name.',
    'Never generically delete drivers by searching for `Apple`.',
    'Never add `/force`',
    "Windows PowerShell 5.1",
    "0.1.0-dev.5.4.2",
    "0.1.0-dev.6.0",
    "0.1.0-rc.1",
    "0.1.0-rc.2",
    "DEV6_0_FINAL_RELEASE_VALIDATION.md",
    "Verify-ContributorWorkflow.ps1"
)) {
    if (-not $agents.Contains($requiredText)) {
        throw "AGENTS.md safety map missing: $requiredText"
    }
}

foreach ($requiredText in @(
    "v0.1.0-dev.5.4.2",
    "v0.1.0-dev.6.0",
    "0.1.0-rc.1",
    "0.1.0-rc.2",
    "PowerShell's location",
    "MagicTrackpad2ForWindows",
    "third-party GPLv2 software",
    "not relicensed",
    "SECURITY.md"
)) {
    if (-not $contrib.Contains($requiredText)) {
        throw "CONTRIBUTING.md contract missing: $requiredText"
    }
}

foreach ($requiredText in @(
    "do **not** publish exploit details",
    "private security",
    "v0.1.0-dev.5.4.2",
    "v0.1.0-dev.6.0",
    "v0.1.0-rc.1",
    "v0.1.0-rc.2"
)) {
    if (-not $security.Contains($requiredText)) {
        throw "SECURITY.md contract missing: $requiredText"
    }
}

foreach ($requiredText in @(
    "Class A",
    "Class F",
    "git diff --check",
    "Build-Installer.ps1",
    "runtime logs",
    "v0.1.0-dev.6.0",
    "v0.1.0-rc.1",
    "v0.1.0-rc.2"
)) {
    if (-not $workflow.Contains($requiredText)) {
        throw "Contributor validation matrix missing: $requiredText"
    }
}

foreach ($requiredText in @(
    "Safety contract impact",
    "Validated",
    "Not run",
    "v0.1.0-dev.5.4.2",
    "v0.1.0-dev.6.0",
    "v0.1.0-rc.1"
)) {
    if (-not $pr.Contains($requiredText)) {
        throw "PR template contract missing: $requiredText"
    }
}

foreach ($requiredText in @(
    "e5e7f4d379e096b3513ed8118c1cf09f29152f24c7ac4282b53678aa4d687d40",
    "b54ac7311b1a6e0736e91c2cac248fffcc485e04",
    "4f8ba3444993c601e41bf71c4f82e78629711d6c",
    "RC2_FINAL_VALIDATION.md"
)) {
    if (-not ($rc2Validation.Contains($requiredText) -or $agents.Contains($requiredText))) {
        throw "rc.2 frozen validation contract missing: $requiredText"
    }
}

if (-not $pr.Contains("v0.1.0-rc.2")) {
    throw "PR template does not protect frozen v0.1.0-rc.2."
}

foreach ($line in @(
    "LICENSE text eol=lf",
    "*.yml text eol=lf",
    "*.yaml text eol=lf"
)) {
    if (-not $attrs.Contains($line)) {
        throw ".gitattributes EOL contract missing: $line"
    }
}

$setup = Join-Path $RepoRoot "installer\setup.iss"
if (-not (Test-Path $setup -PathType Leaf)) {
    throw "Frozen installer source missing."
}

$rootPatchNotes = @(Get-ChildItem -Path $RepoRoot -File -Filter "PATCH_NOTES*.md")
if ($rootPatchNotes.Count -ne 0) {
    throw "Repository-root PATCH_NOTES regression."
}

Write-Host "[PASS] CONTRIBUTING, SUPPORT, and SECURITY policies are present."
Write-Host "[PASS] Root AGENTS.md is a concise safety/navigation map for coding agents."
Write-Host "[PASS] GitHub bug/feature issue forms and PR template are present."
Write-Host "[PASS] Risk-based contributor validation matrix is documented."
Write-Host "[PASS] Frozen dev.5.4.2/dev.6.0/rc.1/rc.2 identities and current-version guidance are carried into contributor contracts."
Write-Host "[PASS] LICENSE/YAML files are explicitly normalized to LF."
Write-Host "[PASS] OSS-1.1B root-history cleanup remains intact."
