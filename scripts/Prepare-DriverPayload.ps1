param(
    [Parameter(Mandatory = $true)]
    [string]$SourceZip
)

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$Destination = Join-Path $RepoRoot "third_party\MagicTrackpad2ForWindows-v2.0"
$ExpectedZipSha256 = "2870c0c7982ce6aafc3ff763fec2999423dc4bdbd1a2c0e31ca216f26a75714f"
$ExpectedDriverVersion = "12/06/2025,2025.3980.1.1000"

function Resolve-ReleasePayloadRoot {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ExpandedRoot
    )

    $candidates = @()

    # Layout A: payload files are directly at the ZIP root.
    $directInf = Join-Path $ExpandedRoot "AMD64\AmtPtpDevice.inf"
    if (Test-Path $directInf -PathType Leaf) {
        $candidates += (Get-Item $ExpandedRoot).FullName
    }

    # Layout B: the ZIP contains one wrapper directory such as
    # MT2FW11-20260223-MSSigned\AMD64\AmtPtpDevice.inf.
    Get-ChildItem $ExpandedRoot `
        -Recurse `
        -Filter "AmtPtpDevice.inf" `
        -File `
        -ErrorAction Stop |
        Where-Object {
            $_.Directory.Name -ieq "AMD64"
        } |
        ForEach-Object {
            $candidate = $_.Directory.Parent.FullName

            $amd64Inf = Join-Path $candidate "AMD64\AmtPtpDevice.inf"
            $arm64Inf = Join-Path $candidate "ARM64\AmtPtpDevice.inf"
            $controlPanel = Join-Path $candidate "AmtPtpControlPanel.exe"

            if (
                (Test-Path $amd64Inf -PathType Leaf) -and
                (Test-Path $arm64Inf -PathType Leaf) -and
                (Test-Path $controlPanel -PathType Leaf)
            ) {
                $candidates += $candidate
            }
        }

    $candidates = @(
        $candidates |
        Sort-Object -Unique
    )

    if ($candidates.Count -eq 0) {
        throw "Could not locate the upstream release payload root inside the ZIP."
    }

    if ($candidates.Count -gt 1) {
        Write-Host "[FAIL] Multiple candidate release roots were found:"
        $candidates | ForEach-Object {
            Write-Host "       $_"
        }

        throw "Ambiguous release ZIP layout. Refusing to guess which payload to stage."
    }

    return $candidates[0]
}

if (-not (Test-Path $SourceZip -PathType Leaf)) {
    throw "Source release ZIP not found: $SourceZip"
}

$actualHash = (Get-FileHash -Algorithm SHA256 -Path $SourceZip).Hash.ToLowerInvariant()

Write-Host "[INFO] Source ZIP: $SourceZip"
Write-Host "[INFO] SHA256: $actualHash"

if ($actualHash -ne $ExpectedZipSha256) {
    throw "Release ZIP SHA256 mismatch. Refusing to stage an unknown payload."
}

$temp = Join-Path (
    [System.IO.Path]::GetTempPath()
) (
    "magic-trackpad-driver-" + [guid]::NewGuid().ToString("N")
)

try {
    New-Item -ItemType Directory -Path $temp -Force | Out-Null
    Expand-Archive -Path $SourceZip -DestinationPath $temp -Force

    $payloadRoot = Resolve-ReleasePayloadRoot -ExpandedRoot $temp

    Write-Host "[INFO] Payload root: $payloadRoot"

    $required = @(
        "AMD64\AmtPtpDevice.inf",
        "AMD64\amtptpdevice.cat",
        "AMD64\AmtPtpDeviceUsbUm.dll",
        "AMD64\AmtPtpHidFilter.sys",
        "ARM64\AmtPtpDevice.inf",
        "ARM64\amtptpdevice.cat",
        "ARM64\AmtPtpDeviceUsbUm.dll",
        "ARM64\AmtPtpHidFilter.sys",
        "AmtPtpControlPanel.exe"
    )

    foreach ($relative in $required) {
        $path = Join-Path $payloadRoot $relative
        if (-not (Test-Path $path -PathType Leaf)) {
            throw "Expected release file is missing: $relative"
        }
    }

    foreach ($arch in @("AMD64", "ARM64")) {
        $inf = Join-Path $payloadRoot "$arch\AmtPtpDevice.inf"
        $text = Get-Content $inf -Raw

        if ($text -notmatch [regex]::Escape("Provider = %ManufacturerName%")) {
            throw "$arch INF provider contract not found."
        }

        if ($text -notmatch [regex]::Escape(
            "ManufacturerName = `"Bingxing Wang, Vito Plantamura`""
        )) {
            throw "$arch INF manufacturer contract mismatch."
        }

        if ($text -notmatch [regex]::Escape(
            "DriverVer = $ExpectedDriverVersion"
        )) {
            throw "$arch INF driver version mismatch."
        }

        $cat = Join-Path $payloadRoot "$arch\amtptpdevice.cat"
        $sys = Join-Path $payloadRoot "$arch\AmtPtpHidFilter.sys"

        foreach ($signedFile in @($cat, $sys)) {
            $signature = Get-AuthenticodeSignature -FilePath $signedFile
            if ($signature.Status -ne "Valid") {
                throw "Signature verification failed: $signedFile ($($signature.Status))"
            }
        }
    }

    if (Test-Path $Destination) {
        Remove-Item $Destination -Recurse -Force
    }

    New-Item -ItemType Directory -Path $Destination -Force | Out-Null

    Get-ChildItem $payloadRoot -Force |
        ForEach-Object {
            Copy-Item $_.FullName $Destination -Recurse -Force
        }

    $manifestPath = Join-Path $Destination "PAYLOAD.sha256"

    Get-ChildItem $Destination -Recurse -File |
        Where-Object {
            $_.FullName -ne $manifestPath
        } |
        Sort-Object FullName |
        ForEach-Object {
            $hash = (
                Get-FileHash -Algorithm SHA256 -Path $_.FullName
            ).Hash.ToLowerInvariant()

            $relative = (
                [System.IO.Path]::GetRelativePath(
                    $Destination,
                    $_.FullName
                )
            ).Replace("\", "/")

            "$hash  $relative"
        } |
        Set-Content `
            -Path $manifestPath `
            -Encoding utf8NoBOM

    Write-Host "[PASS] Microsoft-signed upstream v2.0 payload staged."
    Write-Host "[PASS] Destination: $Destination"
}
finally {
    if (Test-Path $temp) {
        Remove-Item $temp `
            -Recurse `
            -Force `
            -ErrorAction SilentlyContinue
    }
}
