#requires -version 5
# ---------------------------------------------------------------
#  Aki Lxstboss optimize - one command installer
#
#  Normal use (downloads the EXE from GitHub):
#    irm https://github.com/onepeat333-alt/Aki-Lxstboss-Project/raw/main/install.ps1 | iex
#
#  Options:
#    -Uninstall     remove the app + shortcuts (keeps your backups)
#    -Purge         with -Uninstall: also delete %LOCALAPPDATA%\AkiLxstboss
#    -Dev           install into ...\AkiLxstboss\app\dev and keep the console visible
#    -File <path>   install from a local EXE instead of downloading
#    -NoDesktop     skip the Desktop shortcuts
#    -NoShortcuts   install only, no shortcuts at all
#    -Force         re-download even when the installed copy is identical
# ---------------------------------------------------------------
[CmdletBinding()]
param(
    [string]$Url = 'https://github.com/onepeat333-alt/Aki-Lxstboss-Project/raw/main/Aki-Lxstboss-optimize.exe',
    [string]$File,
    [switch]$Uninstall,
    [switch]$Purge,
    [switch]$Dev,
    [switch]$NoDesktop,
    [switch]$NoShortcuts,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

$appName    = 'Aki Lxstboss optimize'
$exeName    = 'Aki-Lxstboss-optimize.exe'
$baseDir    = Join-Path $env:LOCALAPPDATA 'AkiLxstboss'
$appDir     = if ($Dev) { Join-Path $baseDir 'app\dev' } else { Join-Path $baseDir 'app' }
$exePath    = Join-Path $appDir $exeName
$desktop    = [Environment]::GetFolderPath('Desktop')
$programs   = [Environment]::GetFolderPath('Programs')

function Say([string]$text, [string]$color = 'Gray') { Write-Host "  $text" -ForegroundColor $color }
function Step([string]$text) { Write-Host ''; Say $text 'Cyan' }

# ------------------------------ uninstall ------------------------------
if ($Uninstall) {
    Step 'removing shortcuts'
    $links = @(
        (Join-Path $desktop "$appName.lnk"),
        (Join-Path $desktop "$appName (Admin).lnk"),
        (Join-Path $programs "$appName.lnk"),
        (Join-Path $programs "$appName (Admin).lnk")
    )
    foreach ($l in $links) {
        if (Test-Path -LiteralPath $l) { Remove-Item -LiteralPath $l -Force; Say "- $l" 'Yellow' }
    }

    Step 'stopping the app'
    $procs = Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" |
             Where-Object { $_.CommandLine -match 'AkiBossMap\.ps1|server\.ps1' -and $_.CommandLine -match 'AkiLxstboss' }
    foreach ($p in $procs) {
        try { Stop-Process -Id $p.ProcessId -Force; Say "- stopped PID $($p.ProcessId)" 'Yellow' } catch { }
    }

    Step 'removing installed files'
    if (Test-Path -LiteralPath $appDir) { Remove-Item -LiteralPath $appDir -Recurse -Force; Say "- $appDir" 'Yellow' }
    $runtime = Join-Path $baseDir 'runtime'
    if (Test-Path -LiteralPath $runtime) { Remove-Item -LiteralPath $runtime -Recurse -Force; Say "- $runtime" 'Yellow' }

    if ($Purge) {
        Step 'purging data (backups, saved values)'
        if (Test-Path -LiteralPath $baseDir) { Remove-Item -LiteralPath $baseDir -Recurse -Force; Say "- $baseDir" 'Red' }
    } else {
        Say ('backups kept in ' + (Join-Path $baseDir 'backups')) 'DarkGray'
    }

    Write-Host ''
    Say 'uninstalled' 'Green'
    Write-Host ''
    exit 0
}

# ------------------------------ install ------------------------------
Write-Host ''
Write-Host '  ============================================================' -ForegroundColor DarkGray
Say "A K I   L X S T B O S S   O P T I M I Z E   -   installer" 'Magenta'
Write-Host '  ============================================================' -ForegroundColor DarkGray

if (-not (Test-Path -LiteralPath $appDir)) { New-Item -ItemType Directory -Path $appDir -Force | Out-Null }

$needDownload = $true
$localSource = $null

if ($File) {
    if (-not (Test-Path -LiteralPath $File)) { Say "file not found: $File" 'Red'; exit 1 }
    $localSource = (Resolve-Path -LiteralPath $File).Path
    $needDownload = $false
    Step "installing from local file"
    Say $localSource 'Gray'
} else {
    $oldHash = if (Test-Path -LiteralPath $exePath) { (Get-FileHash -LiteralPath $exePath -Algorithm SHA256).Hash } else { '' }
    if ($oldHash -and -not $Force) {
        Step 'checking the published build'
        try {
            $head = Invoke-WebRequest -Uri ($Url + '?raw=1') -Method Head -UseBasicParsing -TimeoutSec 20
            $remoteLen = [int64]$head.Headers['Content-Length']
            $localLen = (Get-Item -LiteralPath $exePath).Length
            if ($remoteLen -eq $localLen) {
                Say "already up to date ($([math]::Round($localLen/1KB,1)) KB)" 'Green'
                $needDownload = $false
            }
        } catch { }
    }
}

if ($needDownload) {
    Step "downloading $exeName"
    $tmp = Join-Path $env:TEMP ("aki-dl-" + [guid]::NewGuid().ToString('N') + '.exe')
    $bust = [DateTime]::UtcNow.Ticks
    try {
        Invoke-WebRequest -Uri ($Url + '?raw=1&t=' + $bust) -OutFile $tmp -UseBasicParsing -TimeoutSec 180 `
            -Headers @{ 'Cache-Control' = 'no-cache' }
    } catch {
        Say "download failed: $($_.Exception.Message)" 'Red'
        Say 'check the URL or your connection, then try again' 'DarkGray'
        exit 1
    }
    $localSource = $tmp
}

# --- validate: must be a real Windows executable ---------------------
$bytes = [IO.File]::ReadAllBytes($localSource)
if ($bytes.Length -lt 100000 -or $bytes[0] -ne 0x4D -or $bytes[1] -ne 0x5A) {
    Say 'downloaded file is not a valid EXE (maybe the upload is still processing)' 'Red'
    Say 'open the URL in a browser to check, then retry' 'DarkGray'
    exit 1
}

if (Test-Path -LiteralPath $exePath) { Remove-Item -LiteralPath $exePath -Force }
Copy-Item -LiteralPath $localSource -Destination $exePath -Force
if (-not $File) { Remove-Item -LiteralPath $localSource -Force -ErrorAction SilentlyContinue }
Unblock-File -LiteralPath $exePath -ErrorAction SilentlyContinue

$sha = (Get-FileHash -LiteralPath $exePath -Algorithm SHA256).Hash
$kb  = [math]::Round((Get-Item -LiteralPath $exePath).Length / 1KB, 1)
Say "installed -> $exePath" 'Green'
Say "size $kb KB" 'Gray'
Say "sha256 $sha" 'DarkGray'

# --- shortcuts -------------------------------------------------------
if (-not $NoShortcuts) {
    Step 'creating shortcuts'
    $shell = New-Object -ComObject WScript.Shell
    $windowStyle = if ($Dev) { 1 } else { 7 }   # Dev keeps the console visible

    function New-Shortcut([string]$path, [string]$arguments, [string]$description) {
        $lnk = $shell.CreateShortcut($path)
        $lnk.TargetPath       = $exePath
        $lnk.Arguments        = $arguments
        $lnk.WorkingDirectory = $appDir
        $lnk.IconLocation     = "$exePath,0"
        $lnk.Description      = $description
        $lnk.WindowStyle      = $windowStyle
        $lnk.Save()
        Say "+ $path" 'Green'
    }

    if (-not $NoDesktop) {
        New-Shortcut (Join-Path $desktop "$appName.lnk") '' 'Open Aki Lxstboss optimize'
        New-Shortcut (Join-Path $desktop "$appName (Admin).lnk") '-Admin' 'Open Aki Lxstboss optimize as Administrator'
    }
    New-Shortcut (Join-Path $programs "$appName.lnk") '' 'Open Aki Lxstboss optimize'
    New-Shortcut (Join-Path $programs "$appName (Admin).lnk") '-Admin' 'Open Aki Lxstboss optimize as Administrator'
}

Write-Host ''
Write-Host '  ------------------------------------------------------------' -ForegroundColor DarkGray
Say 'done' 'Green'
Say ('run it:  Start-Process "' + $exePath + '"') 'Gray'
Say ('as admin: Start-Process "' + $exePath + '" -ArgumentList "-Admin" -Verb RunAs') 'Gray'
Say 'remove:  install.ps1 -Uninstall  (add -Purge to delete backups too)' 'DarkGray'
Write-Host ''
