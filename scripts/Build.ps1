param(
    [ValidateSet("Release", "Debug")]
    [string]$Configuration = "Release"
)

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$BuildDir = Join-Path $RepoRoot "build"
$VsWhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"

if (-not (Test-Path $VsWhere)) {
    throw "vswhere.exe not found. Install Visual Studio first."
}

$VsPath = & $VsWhere -latest -products * `
    -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
    -property installationPath

if (-not $VsPath) {
    throw "MSVC x86/x64 toolchain not found."
}

$DevShell = Join-Path $VsPath "Common7\Tools\Launch-VsDevShell.ps1"
& $DevShell -Arch amd64 -HostArch amd64

$CMakeHelp = (& cmake --help | Out-String)
$Generator = $null

if ($CMakeHelp -match "Visual Studio 18 2026") {
    $Generator = "Visual Studio 18 2026"
}
elseif ($CMakeHelp -match "Visual Studio 17 2022") {
    $Generator = "Visual Studio 17 2022"
}
else {
    throw "No supported Visual Studio CMake generator was found."
}

Write-Host "[INFO] Visual Studio: $VsPath"
Write-Host "[INFO] CMake generator: $Generator"
Write-Host "[INFO] Configuration: $Configuration"

cmake -S $RepoRoot -B $BuildDir -G $Generator -A x64
if ($LASTEXITCODE -ne 0) {
    throw "CMake configure failed."
}

cmake --build $BuildDir --config $Configuration
if ($LASTEXITCODE -ne 0) {
    throw "Build failed."
}

$Exe = Join-Path $BuildDir "$Configuration\MagicTrackpadHelper.exe"
if (-not (Test-Path $Exe)) {
    throw "Build completed but executable was not found: $Exe"
}

Write-Host "[PASS] $Exe"
