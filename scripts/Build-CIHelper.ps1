param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = "Stop"

$RepoRoot = (Resolve-Path $RepoRoot).Path
$BuildDir = Join-Path $RepoRoot "build-ci"
$CompatScript = Join-Path $RepoRoot "scripts\Test-WindowsPowerShellCompatibility.ps1"
$VersionContractScript = Join-Path $RepoRoot "scripts\Test-HelperVersionContract.ps1"

function Resolve-CMakeExecutable {
    $command = Get-Command "cmake.exe" -ErrorAction SilentlyContinue

    if (-not $command) {
        $command = Get-Command "cmake" -ErrorAction SilentlyContinue
    }

    if ($command) {
        return $command.Source
    }

    $vswhere = Join-Path `
        ${env:ProgramFiles(x86)} `
        "Microsoft Visual Studio\Installer\vswhere.exe"

    if (-not (Test-Path $vswhere -PathType Leaf)) {
        throw "CMake was not found on PATH and vswhere.exe is unavailable."
    }

    $vsRoot = (
        & $vswhere `
            -latest `
            -products * `
            -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
            -property installationPath
    ).Trim()

    if ([string]::IsNullOrWhiteSpace($vsRoot)) {
        throw "Visual Studio with the C++ toolchain was not found."
    }

    $bundled = Join-Path `
        $vsRoot `
        "Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"

    if (-not (Test-Path $bundled -PathType Leaf)) {
        throw "Visual Studio was found but its bundled CMake executable is missing: $bundled"
    }

    return $bundled
}

if (-not (Test-Path $CompatScript -PathType Leaf)) {
    throw "Windows PowerShell compatibility test missing: $CompatScript"
}

if (-not (Test-Path $VersionContractScript -PathType Leaf)) {
    throw "Helper product-version contract test missing: $VersionContractScript"
}

$cmake = Resolve-CMakeExecutable
$ctest = Join-Path (Split-Path -Parent $cmake) "ctest.exe"

if (-not (Test-Path $ctest -PathType Leaf)) {
    throw "CTest executable was not found next to CMake: $ctest"
}

Write-Host "Magic Trackpad for Windows - CI helper build"
Write-Host "[INFO] Repository: $RepoRoot"
Write-Host "[INFO] CMake: $cmake"
Write-Host "[INFO] CTest: $ctest"

& $cmake --version

if ($LASTEXITCODE -ne 0) {
    throw "CMake version probe failed with exit code $LASTEXITCODE."
}

if (Test-Path $BuildDir) {
    Remove-Item $BuildDir -Recurse -Force
}

& $cmake -S $RepoRoot -B $BuildDir -A x64

if ($LASTEXITCODE -ne 0) {
    throw "CMake configure failed with exit code $LASTEXITCODE."
}

& $cmake --build $BuildDir --config Release --parallel

if ($LASTEXITCODE -ne 0) {
    throw "CMake build failed with exit code $LASTEXITCODE."
}

Write-Host "[TEST] C++ status-binding regression..."

& $ctest `
    --test-dir $BuildDir `
    -C Release `
    --output-on-failure

if ($LASTEXITCODE -ne 0) {
    throw "C++ status-binding regression failed with exit code $LASTEXITCODE."
}

Write-Host "[PASS] C++ status-binding regression passed."

$helper = Join-Path $BuildDir "Release\MagicTrackpadHelper.exe"

if (-not (Test-Path $helper -PathType Leaf)) {
    throw "MagicTrackpadHelper.exe was not produced: $helper"
}

$item = Get-Item $helper
Write-Host "[PASS] Fresh helper built: $($item.FullName)"
Write-Host "[INFO] Helper size: $($item.Length) bytes"

Write-Host "[TEST] Helper product-version contract..."

& $VersionContractScript `
    -RepoRoot $RepoRoot `
    -HelperPath $helper

Write-Host "[PASS] Helper product-version contract passed."

& $CompatScript -HelperPath $helper

if (-not $?) {
    throw "Windows PowerShell 5.1 compatibility test failed."
}

Write-Host "[PASS] Fresh-helper Windows PowerShell 5.1 compatibility passed."
Write-Host "[PASS] CI helper build workflow completed."
