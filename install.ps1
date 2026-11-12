#requires -version 5
# ---------------------------------------------------------------
#  Aki Lxstboss optimize - one command installer
#
#  Normal use (downloads the EXE from GitHub):
#    irm https://github.com/onepeat333-alt/Aki-Lxstboss-Project/raw/main/install.ps1 | iex
#
#  The download is checked against SHA256SUMS.txt and the installer keeps the
#  copy you already have when it is identical. The EXE comes from the pinned
#  release asset first, the raw file in the repository is the fallback.
#
#  Options:
#    -Uninstall     remove the app + shortcuts (keeps your backups)
#    -Purge         with -Uninstall: also delete %LOCALAPPDATA%\AkiLxstboss
#    -Dev           install into ...\AkiLxstboss\app\dev and keep the console visible
#    -File <path>   install from a local EXE instead of downloading
#    -NoDesktop     skip the Desktop shortcuts
#    -NoShortcuts   install only, no shortcuts at all
#    -Force         reinstall even when the installed copy is identical
#    -Url <url>     download the EXE from somewhere else
#    -FallbackUrl   second source to try when the first one fails
# ---------------------------------------------------------------
[CmdletBinding()]
param(
    [string]$Url = 'https://github.com/onepeat333-alt/Aki-Lxstboss-Project/releases/download/v2.6.0/Aki-Lxstboss-optimize.exe',
    [string]$FallbackUrl = 'https://github.com/onepeat333-alt/Aki-Lxstboss-Project/raw/main/Aki-Lxstboss-optimize.exe',
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

function Get-CacheBusted([string]$uri) {
    $sep = if ($uri.Contains('?')) { '&' } else { '?' }
    return ($uri + $sep + 't=' + [DateTime]::UtcNow.Ticks)
}

# $sourcePath = the file that will be copied into place
# $tempFile   = temporary download that has to be cleaned up afterwards
$sourcePath = $null
$tempFile   = $null

if ($File) {
    if (-not (Test-Path -LiteralPath $File)) { Say "file not found: $File" 'Red'; exit 1 }
    $sourcePath = (Resolve-Path -LiteralPath $File).Path
    Step 'installing from local file'
    Say $sourcePath 'Gray'
} else {
    # The release asset is pinned (it can never change), the raw file in the
    # repository is the fallback for a build that is not tagged yet.
    $candidates = @($Url)
    if ($FallbackUrl) { $candidates += $FallbackUrl }

    $newHash = ''
    $usedUrl = ''
    foreach ($cand in $candidates) {
        Step "downloading $exeName"
        $dl = Join-Path $env:TEMP ("aki-dl-" + [guid]::NewGuid().ToString('N') + '.exe')
        try {
            Invoke-WebRequest -Uri (Get-CacheBusted $cand) -OutFile $dl -UseBasicParsing -TimeoutSec 180 `
                -Headers @{ 'Cache-Control' = 'no-cache' }
        } catch {
            Say "download failed: $($_.Exception.Message)" 'Yellow'
            if (Test-Path -LiteralPath $dl) { Remove-Item -LiteralPath $dl -Force -ErrorAction SilentlyContinue }
            continue
        }

        # --- it has to be a real Windows executable ----------------------
        $bytes = [IO.File]::ReadAllBytes($dl)
        if ($bytes.Length -lt 100000 -or $bytes[0] -ne 0x4D -or $bytes[1] -ne 0x5A) {
            Say 'that file is not a valid EXE - trying the next source' 'Yellow'
            Remove-Item -LiteralPath $dl -Force -ErrorAction SilentlyContinue
            continue
        }

        $newHash = (Get-FileHash -LiteralPath $dl -Algorithm SHA256).Hash
        $usedUrl = $cand
        $tempFile = $dl
        break
    }

    if (-not $tempFile) {
        Say 'could not download the app from any source' 'Red'
        Say 'check the URL or your connection, then try again' 'DarkGray'
        exit 1
    }

    # --- verify the download against the published SHA256 list ---------
    $sumsUrl = $usedUrl -replace '[^/]+$', 'SHA256SUMS.txt'
    $published = ''
    try {
        $raw = (Invoke-WebRequest -Uri (Get-CacheBusted $sumsUrl) -UseBasicParsing -TimeoutSec 30 `
                   -Headers @{ 'Cache-Control' = 'no-cache' }).Content
        # GitHub hands out release assets as octet-stream, so the body can be bytes
        if ($raw -is [byte[]]) { $sumsText = [Text.Encoding]::UTF8.GetString($raw) }
        else { $sumsText = [string]$raw }
        $sumsText = $sumsText -replace "^\uFEFF", ''
        foreach ($line in ($sumsText -split "`n")) {
            if ($line -match '^\s*([0-9a-fA-F]{64})\s+\*?(.+?)\s*$' -and $matches[2] -eq $exeName) {
                $published = $matches[1].ToUpper()
                break
            }
        }
    } catch { }

    if ($published -and $published -ne $newHash) {
        Say 'checksum mismatch - the download does not match the published build' 'Red'
        Say "expected $published" 'DarkGray'
        Say "got      $newHash" 'DarkGray'
        Say 'nothing was installed - try again in a minute' 'DarkGray'
        Remove-Item -LiteralPath $tempFile -Force -ErrorAction SilentlyContinue
        exit 1
    }
    if ($published) { Say 'checksum OK (matches SHA256SUMS.txt)' 'Green' }
    else { Say 'checksum list unavailable - skipped the check' 'Yellow' }

    # --- same build? then keep the copy that is already installed ------
    $oldHash = if (Test-Path -LiteralPath $exePath) { (Get-FileHash -LiteralPath $exePath -Algorithm SHA256).Hash } else { '' }
    if ($oldHash -and $oldHash -eq $newHash -and -not $Force) {
        $kbUp = [math]::Round((Get-Item -LiteralPath $tempFile).Length / 1KB, 1)
        Say "already up to date ($kbUp KB)" 'Green'
        Remove-Item -LiteralPath $tempFile -Force -ErrorAction SilentlyContinue
        $tempFile = $null
    } else {
        $sourcePath = $tempFile
    }
}

if ($sourcePath) {
    if (Test-Path -LiteralPath $exePath) { Remove-Item -LiteralPath $exePath -Force }
    Copy-Item -LiteralPath $sourcePath -Destination $exePath -Force
}

if ($tempFile) { Remove-Item -LiteralPath $tempFile -Force -ErrorAction SilentlyContinue }
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
