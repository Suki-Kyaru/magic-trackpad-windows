$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$PayloadRoot = Join-Path $RepoRoot "third_party\MagicTrackpad2ForWindows-v2.0"
$Manifest = Join-Path $PayloadRoot "PAYLOAD.sha256"

if (-not (Test-Path $PayloadRoot -PathType Container)) {
    throw "Driver payload is not staged: $PayloadRoot"
}

if (-not (Test-Path $Manifest -PathType Leaf)) {
    throw "Driver payload manifest is missing: $Manifest"
}

$failures = @()

foreach ($line in Get-Content $Manifest) {
    if ([string]::IsNullOrWhiteSpace($line)) {
        continue
    }

    if ($line -notmatch '^([0-9a-fA-F]{64})\s{2}(.+)$') {
        $failures += "Malformed manifest line: $line"
        continue
    }

    $expected = $matches[1].ToLowerInvariant()
    $relative = $matches[2]
    $path = Join-Path $PayloadRoot ($relative.Replace("/", "\"))

    if (-not (Test-Path $path -PathType Leaf)) {
        $failures += "Missing file: $relative"
        continue
    }

    $actual = (Get-FileHash -Algorithm SHA256 -Path $path).Hash.ToLowerInvariant()

    if ($actual -ne $expected) {
        $failures += "Hash mismatch: $relative"
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Host "[FAIL] $_" }
    throw "Driver payload integrity verification failed."
}

foreach ($arch in @("AMD64", "ARM64")) {
    foreach ($relative in @("amtptpdevice.cat", "AmtPtpHidFilter.sys")) {
        $path = Join-Path $PayloadRoot "$arch\$relative"
        $signature = Get-AuthenticodeSignature -FilePath $path

        if ($signature.Status -ne "Valid") {
            throw "Signature verification failed: $path ($($signature.Status))"
        }
    }
}

Write-Host "[PASS] Driver payload hashes and signatures verified."
