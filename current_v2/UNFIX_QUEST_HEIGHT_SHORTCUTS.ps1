param(
    [string]$GameDir = ""
)

$ErrorActionPreference = "Stop"

function Write-Info([string]$Text) { Write-Host $Text -ForegroundColor Cyan }
function Write-Ok([string]$Text) { Write-Host $Text -ForegroundColor Green }
function Write-Warn([string]$Text) { Write-Host $Text -ForegroundColor Yellow }

function Ensure-Admin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { return }

    $scriptPath = $PSCommandPath
    if (-not $scriptPath) { throw "Impossible de retrouver le chemin du script." }

    $args = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", ('"' + $scriptPath + '"'))
    if ($GameDir) { $args += @("-GameDir", ('"' + $GameDir + '"')) }
    Start-Process powershell.exe -Verb RunAs -ArgumentList ($args -join " ") -Wait
    exit
}

function Get-SteamPaths {
    $paths = New-Object System.Collections.Generic.List[string]
    try {
        $steamReg = Get-ItemProperty -Path "HKCU:\Software\Valve\Steam" -ErrorAction SilentlyContinue
        if ($steamReg -and $steamReg.SteamPath -and (Test-Path -LiteralPath $steamReg.SteamPath)) {
            $paths.Add([string]$steamReg.SteamPath)
        }
    } catch {}

    foreach ($candidate in @("${env:ProgramFiles(x86)}\Steam", "$env:ProgramFiles\Steam")) {
        if ($candidate -and (Test-Path -LiteralPath $candidate) -and -not $paths.Contains($candidate)) {
            $paths.Add($candidate)
        }
    }
    return $paths
}

function Get-SteamLibraries {
    $libraries = New-Object System.Collections.Generic.List[string]
    foreach ($steamPath in Get-SteamPaths) {
        if (-not $libraries.Contains($steamPath)) { $libraries.Add($steamPath) }
        $vdf = Join-Path $steamPath "steamapps\libraryfolders.vdf"
        if (-not (Test-Path -LiteralPath $vdf)) { continue }
        $raw = Get-Content -LiteralPath $vdf -Raw -ErrorAction SilentlyContinue
        if (-not $raw) { continue }
        foreach ($m in [regex]::Matches($raw, '"path"\s+"([^"]+)"')) {
            $path = $m.Groups[1].Value -replace '\\\\','\'
            if ($path -and (Test-Path -LiteralPath $path) -and -not $libraries.Contains($path)) {
                $libraries.Add($path)
            }
        }
    }
    return $libraries
}

function Find-L4D2 {
    param([string]$Requested)

    if ($Requested) {
        $candidate = [System.IO.Path]::GetFullPath($Requested)
        if (Test-Path -LiteralPath (Join-Path $candidate "left4dead2.exe")) { return $candidate }
        throw "Left 4 Dead 2 introuvable dans : $candidate"
    }

    foreach ($library in Get-SteamLibraries) {
        $candidate = Join-Path $library "steamapps\common\Left 4 Dead 2"
        if (Test-Path -LiteralPath (Join-Path $candidate "left4dead2.exe")) { return $candidate }
    }

    foreach ($drive in @("C:\", "D:\", "E:\", "F:\", "G:\")) {
        foreach ($relative in @(
            "Program Files (x86)\Steam\steamapps\common\Left 4 Dead 2",
            "Program Files\Steam\steamapps\common\Left 4 Dead 2",
            "SteamLibrary\steamapps\common\Left 4 Dead 2"
        )) {
            $candidate = Join-Path $drive $relative
            if (Test-Path -LiteralPath (Join-Path $candidate "left4dead2.exe")) { return $candidate }
        }
    }
    throw "Impossible de detecter automatiquement Left 4 Dead 2."
}

function Restore-Target {
    param([string]$Target)
    $backup = "$Target.wokgui-heightfix-backup"
    if (-not (Test-Path -LiteralPath $backup)) { return $false }
    Copy-Item -LiteralPath $backup -Destination $Target -Force
    Remove-Item -LiteralPath $backup -Force
    Write-Ok "Restaure : $Target"
    return $true
}

Write-Host ""
Write-Host "L4D2VR / Quest 3 - Desinstallation Height Safety Fix" -ForegroundColor White
Write-Host ""

Ensure-Admin

$runningNames = @("left4dead2", "vrserver", "vrmonitor", "AdvancedSettings")
$running = @()
foreach ($name in $runningNames) {
    if (Get-Process -Name $name -ErrorAction SilentlyContinue) { $running += $name }
}
if ($running.Count -gt 0) {
    throw "Ferme Left 4 Dead 2, SteamVR et OVR Advanced Settings avant la desinstallation. Processus detectes : $($running -join ', ')"
}

$GameDir = Find-L4D2 -Requested $GameDir
Write-Info "Jeu detecte : $GameDir"

$restored = 0
$l4dBinding = Join-Path $GameDir "VR\SteamVRActionManifest\bindings_oculus_touch.json"
if (Restore-Target -Target $l4dBinding) { $restored++ }

$roots = New-Object System.Collections.Generic.List[string]
try {
    $regKey = Get-Item -LiteralPath "HKLM:\Software\OpenVR-AdvancedSettings" -ErrorAction SilentlyContinue
    if ($regKey) {
        $installDir = [string]$regKey.GetValue("")
        if ($installDir -and (Test-Path -LiteralPath $installDir)) { $roots.Add($installDir) }
    }
} catch {}

foreach ($root in @(
    "$env:ProgramFiles\OpenVR-AdvancedSettings",
    "${env:ProgramFiles(x86)}\OpenVR-AdvancedSettings",
    (Join-Path $env:LOCALAPPDATA "openvr"),
    (Join-Path $env:APPDATA "openvr")
)) {
    if ($root -and (Test-Path -LiteralPath $root) -and -not $roots.Contains($root)) { $roots.Add($root) }
}

foreach ($steamPath in Get-SteamPaths) {
    $configRoot = Join-Path $steamPath "config"
    if ((Test-Path -LiteralPath $configRoot) -and -not $roots.Contains($configRoot)) { $roots.Add($configRoot) }
}

foreach ($root in $roots) {
    $backups = Get-ChildItem -LiteralPath $root -Filter "*.wokgui-heightfix-backup" -File -Recurse -ErrorAction SilentlyContinue
    foreach ($backup in $backups) {
        $target = $backup.FullName.Substring(0, $backup.FullName.Length - ".wokgui-heightfix-backup".Length)
        if (Test-Path -LiteralPath $target) {
            Copy-Item -LiteralPath $backup.FullName -Destination $target -Force
            Remove-Item -LiteralPath $backup.FullName -Force
            Write-Ok "Restaure : $target"
            $restored++
        }
    }
}

Write-Host ""
if ($restored -gt 0) {
    Write-Ok "Desinstallation terminee : $restored fichier(s) restaure(s)."
} else {
    Write-Warn "Aucune sauvegarde du correctif n'a ete trouvee. Rien n'a ete modifie."
}
Write-Warn "Redemarre SteamVR avant de rejouer."
Write-Host ""
Read-Host "Appuie sur Entree pour fermer"
