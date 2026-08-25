param([string]$GameDir = "")

$ErrorActionPreference = "Stop"
$BackupFolderName = "Wokgui_Y_Vocalizer_Backup_sd805_v3"

function Get-SteamLibraries {
    $libraries = New-Object System.Collections.Generic.List[string]
    $steamPaths = @()
    try {
        $steamReg = Get-ItemProperty -Path "HKCU:\Software\Valve\Steam" -ErrorAction SilentlyContinue
        if ($steamReg -and $steamReg.SteamPath) { $steamPaths += [string]$steamReg.SteamPath }
    } catch {}
    $steamPaths += @("${env:ProgramFiles(x86)}\Steam", "$env:ProgramFiles\Steam")
    foreach ($steamPath in ($steamPaths | Where-Object { $_ } | Select-Object -Unique)) {
        if (-not (Test-Path -LiteralPath $steamPath)) { continue }
        if (-not $libraries.Contains($steamPath)) { $libraries.Add($steamPath) }
        $vdf = Join-Path $steamPath "steamapps\libraryfolders.vdf"
        if (Test-Path -LiteralPath $vdf) {
            $raw = Get-Content -LiteralPath $vdf -Raw -ErrorAction SilentlyContinue
            foreach ($m in [regex]::Matches([string]$raw, '"path"\s+"([^"]+)"')) {
                $p = $m.Groups[1].Value -replace '\\\\','\'
                if ($p -and -not $libraries.Contains($p)) { $libraries.Add($p) }
            }
        }
    }
    return $libraries
}

function Find-L4D2([string]$Requested) {
    if ($Requested) {
        $candidate = [System.IO.Path]::GetFullPath($Requested)
        if (Test-Path -LiteralPath (Join-Path $candidate "left4dead2.exe")) { return $candidate }
        throw "Left 4 Dead 2 introuvable dans : $candidate"
    }
    foreach ($library in Get-SteamLibraries) {
        $candidate = Join-Path $library "steamapps\common\Left 4 Dead 2"
        if (Test-Path -LiteralPath (Join-Path $candidate "left4dead2.exe")) { return $candidate }
    }
    foreach ($drive in @("C:","D:","E:","F:","G:")) {
        foreach ($relative in @("Program Files (x86)\Steam\steamapps\common\Left 4 Dead 2","Program Files\Steam\steamapps\common\Left 4 Dead 2","SteamLibrary\steamapps\common\Left 4 Dead 2")) {
            $candidate = Join-Path $drive $relative
            if (Test-Path -LiteralPath (Join-Path $candidate "left4dead2.exe")) { return $candidate }
        }
    }
    throw "Impossible de detecter automatiquement Left 4 Dead 2."
}

Write-Host ""
Write-Host "L4D2VR sd805 - Y Vocalizer v3.0" -ForegroundColor White
Write-Host "Y press = open Orders / Y release = close Orders" -ForegroundColor DarkGray
Write-Host ""

foreach ($name in @("left4dead2","vrserver","vrmonitor")) {
    if (Get-Process -Name $name -ErrorAction SilentlyContinue) {
        throw "Ferme Left 4 Dead 2 et SteamVR avant l'installation."
    }
}

$GameDir = Find-L4D2 $GameDir
Write-Host "Jeu detecte : $GameDir" -ForegroundColor Cyan

$manifestPath = Join-Path $GameDir "VR\SteamVRActionManifest\action_manifest.json"
$bindingsPath = Join-Path $GameDir "VR\SteamVRActionManifest\bindings_oculus_touch.json"
$currentDll = Join-Path $GameDir "d3d9.dll"
$payloadDll = Join-Path $PSScriptRoot "payload\d3d9.dll"

foreach ($required in @($manifestPath,$bindingsPath,$currentDll,$payloadDll)) {
    if (-not (Test-Path -LiteralPath $required)) { throw "Fichier requis introuvable : $required" }
}

$manifest = Get-Content -LiteralPath $manifestPath -Raw
$bindings = Get-Content -LiteralPath $bindingsPath -Raw
if ($manifest -notmatch [regex]::Escape('/actions/main/in/Pause') -or $bindings -notmatch [regex]::Escape('/user/hand/left/input/y')) {
    throw "Cette installation ne ressemble pas a la version sd805 compatible. Aucun fichier n'a ete modifie."
}

$backupDir = Join-Path $GameDir "VR\$BackupFolderName"
if (-not (Test-Path -LiteralPath $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir | Out-Null
    Copy-Item -LiteralPath $currentDll -Destination (Join-Path $backupDir "d3d9.dll.original") -Force
    Write-Host "Sauvegarde creee : $backupDir" -ForegroundColor Green
} else {
    Write-Host "Sauvegarde existante conservee : $backupDir" -ForegroundColor Yellow
}

Copy-Item -LiteralPath $payloadDll -Destination $currentDll -Force

Write-Host ""
Write-Host "Installation terminee." -ForegroundColor Green
Write-Host "- Appuie sur Y : le vocalizer Orders s'ouvre." -ForegroundColor Gray
Write-Host "- Maintiens Y : il reste ouvert." -ForegroundColor Gray
Write-Host "- Relache Y : il se ferme immediatement." -ForegroundColor Gray
Write-Host "- Aucun CustomAction n'est necessaire sur cette version sd805." -ForegroundColor Gray
Write-Host ""
Write-Host "Redemarre SteamVR avant de lancer L4D2VR." -ForegroundColor Yellow
Read-Host "Appuie sur Entree pour fermer"
