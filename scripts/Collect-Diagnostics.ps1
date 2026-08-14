param(
    [string]$HelperPath = "",
    [string]$OutputDirectory = "",
    [switch]$OpenFolder,
    [switch]$IncludeIdentifiers
)

$ErrorActionPreference = "Stop"

function Resolve-HelperPath {
    param([string]$Requested)

    if ($Requested) {
        if (-not (Test-Path $Requested -PathType Leaf)) {
            throw "MagicTrackpadHelper not found: $Requested"
        }
        return (Resolve-Path $Requested).Path
    }

    $scriptRoot = Split-Path -Parent $MyInvocation.ScriptName
    $repoRoot = Split-Path -Parent $scriptRoot

    $candidates = @(
        (Join-Path $scriptRoot "MagicTrackpadHelper.exe"),
        (Join-Path $repoRoot "build\Release\MagicTrackpadHelper.exe"),
        (Join-Path $repoRoot "Tools\MagicTrackpadHelper.exe")
    )

    foreach ($candidate in $candidates) {
        if (Test-Path $candidate -PathType Leaf) {
            return (Resolve-Path $candidate).Path
        }
    }

    throw "MagicTrackpadHelper.exe could not be located."
}

function Resolve-LogDirectory {
    param([string]$Requested)

    if ($Requested) {
        New-Item -ItemType Directory -Path $Requested -Force | Out-Null
        return (Resolve-Path $Requested).Path
    }

    $candidates = @(
        (Join-Path $env:ProgramData "Magic Trackpad for Windows\Logs"),
        (Join-Path $env:LOCALAPPDATA "Magic Trackpad for Windows\Logs"),
        (Join-Path $env:TEMP "Magic Trackpad for Windows\Logs")
    )

    foreach ($candidate in $candidates) {
        try {
            New-Item -ItemType Directory -Path $candidate -Force -ErrorAction Stop | Out-Null
            $probe = Join-Path $candidate (".write-test-" + [guid]::NewGuid().ToString("N"))
            Set-Content -Path $probe -Value "ok" -Encoding ascii -ErrorAction Stop
            Remove-Item $probe -Force -ErrorAction SilentlyContinue
            return $candidate
        }
        catch {
            continue
        }
    }

    throw "No writable diagnostic log directory could be created."
}

function Quote-NativeArgument {
    param([string]$Value)

    if ($Value -notmatch '[\s"]') {
        return $Value
    }

    return '"' + ($Value -replace '(\\*)"', '$1$1\"' -replace '(\\+)$', '$1$1') + '"'
}

function Invoke-HelperCommand {
    param(
        [string]$Helper,
        [string[]]$Arguments
    )

    $startInfo = New-Object -TypeName System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = $Helper
    $startInfo.Arguments = (($Arguments | ForEach-Object { Quote-NativeArgument $_ }) -join " ")
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.CreateNoWindow = $true

    $utf8 = New-Object -TypeName System.Text.UTF8Encoding -ArgumentList $false

    try {
        $startInfo.StandardOutputEncoding = $utf8
        $startInfo.StandardErrorEncoding = $utf8
    }
    catch {
    }

    $process = New-Object -TypeName System.Diagnostics.Process
    $process.StartInfo = $startInfo

    if (-not $process.Start()) {
        throw "Failed to start MagicTrackpadHelper.exe."
    }

    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $process.StandardError.ReadToEnd()
    $process.WaitForExit()

    $lines = @(
        $stdout -split "\r?\n" |
        Where-Object { $_ -ne "" }
    )

    return @{
        Code = [int]$process.ExitCode
        Lines = $lines
        Error = $stderr
    }
}

function Protect-DiagnosticLine {
    param([string]$Line)

    if ($IncludeIdentifiers) {
        return $Line
    }

    if ($Line -match '^bluetooth\.address=') {
        return 'bluetooth.address=<redacted>'
    }

    $protected = $Line
    $protected = $protected -replace '(?i)(BTHENUM\\DEV_)[0-9A-F]{12}', '$1<redacted>'
    $protected = $protected -replace '(?i)(BLUETOOTHDEVICE_)[0-9A-F]{12}', '$1<redacted>'

    if ($protected -match '(?i)instance_id=') {
        $protected = $protected -replace '(?i)(instance_id=.*\\)[^\\;]+(?=;|$)', '$1<redacted>'
    }

    $protected = $protected -replace '(?i)([\\&])[0-9A-F]{12}(_C[0-9A-F]+)', '$1<redacted>$2'

    if ($env:USERPROFILE) {
        $protected = $protected.Replace($env:USERPROFILE, '%USERPROFILE%')
    }

    return $protected
}

function Write-Utf8NoBomLines {
    param(
        [string]$Path,
        [object[]]$Lines
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        throw "Output path must not be empty."
    }

    $normalized = @(
        foreach ($line in $Lines) {
            if ($null -eq $line) {
                ""
            }
            else {
                [string]$line
            }
        }
    )

    $encoding = New-Object -TypeName System.Text.UTF8Encoding -ArgumentList $false
    [System.IO.File]::WriteAllLines(
        $Path,
        [string[]]$normalized,
        $encoding
    )
}

$helper = Resolve-HelperPath -Requested $HelperPath
$logRoot = Resolve-LogDirectory -Requested $OutputDirectory
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$report = Join-Path $logRoot "Diagnostics-$timestamp.txt"

$os = Get-CimInstance Win32_OperatingSystem
$computer = Get-CimInstance Win32_ComputerSystem
$driverStatus = Invoke-HelperCommand -Helper $helper -Arguments @("driver-status", "--verbose")
$deviceStatus = Invoke-HelperCommand -Helper $helper -Arguments @("status", "--verbose")

$lines = New-Object -TypeName System.Collections.Generic.List[string]

$lines.Add("Magic Trackpad for Windows Diagnostic Report")
$lines.Add("==========================================")
$lines.Add("generated_at=$(Get-Date -Format o)")
$lines.Add("identifiers_included=$($IncludeIdentifiers.IsPresent.ToString().ToLowerInvariant())")

if ($IncludeIdentifiers) {
    $lines.Add("computer_name=$env:COMPUTERNAME")
    $lines.Add("user_name=$env:USERNAME")
}
else {
    $lines.Add("computer_name=<redacted>")
    $lines.Add("user_name=<redacted>")
}

$lines.Add("os_caption=$($os.Caption)")
$lines.Add("os_version=$($os.Version)")
$lines.Add("os_build=$($os.BuildNumber)")
$lines.Add("os_architecture=$($os.OSArchitecture)")
$lines.Add("system_model=$($computer.Model)")

$helperDisplayPath = if ($IncludeIdentifiers) {
    $helper
}
else {
    Protect-DiagnosticLine $helper
}

$lines.Add("helper_path=$helperDisplayPath")
$lines.Add("helper_sha256=$((Get-FileHash -Algorithm SHA256 -Path $helper).Hash.ToLowerInvariant())")
$lines.Add("")

$lines.Add("[driver-status]")
$lines.Add("exit_code=$($driverStatus.Code)")
foreach ($line in $driverStatus.Lines) {
    $lines.Add((Protect-DiagnosticLine ([string]$line)))
}
if ($driverStatus.Error) {
    $lines.Add("stderr=$(Protect-DiagnosticLine $driverStatus.Error.Trim())")
}

$lines.Add("")
$lines.Add("[device-status]")
$lines.Add("exit_code=$($deviceStatus.Code)")
foreach ($line in $deviceStatus.Lines) {
    $lines.Add((Protect-DiagnosticLine ([string]$line)))
}
if ($deviceStatus.Error) {
    $lines.Add("stderr=$(Protect-DiagnosticLine $deviceStatus.Error.Trim())")
}

$lines.Add("")
$lines.Add("[relevant-pnp-devices]")

try {
    $pnp = Get-PnpDevice -PresentOnly -ErrorAction Stop |
        Where-Object {
            $_.InstanceId -match "05AC|004C|0324" -or
            $_.FriendlyName -match "Magic Trackpad|Apple Multi-touch"
        } |
        Select-Object Status, Class, FriendlyName, InstanceId

    if ($pnp) {
        foreach ($item in $pnp) {
            $entry = "status=$($item.Status); class=$($item.Class); name=$($item.FriendlyName); instance_id=$($item.InstanceId)"
            $lines.Add((Protect-DiagnosticLine $entry))
        }
    }
    else {
        $lines.Add("none")
    }
}
catch {
    $lines.Add("pnp_query_error=$($_.Exception.Message)")
}

Write-Utf8NoBomLines -Path $report -Lines $lines.ToArray()

Write-Host "[PASS] Diagnostic report created."
Write-Host "[INFO] Identifiers included: $($IncludeIdentifiers.IsPresent)"
Write-Host "[INFO] $report"

if ($OpenFolder) {
    Start-Process explorer.exe -ArgumentList "/select,`"$report`""
}

$report
