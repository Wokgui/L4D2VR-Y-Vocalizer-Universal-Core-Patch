param(
    [string]$GameDir = "",
    [switch]$Quiet
)

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

foreach ($name in @("left4dead2","vrserver","vrmonitor")) {
    if (Get-Process -Name $name -ErrorAction SilentlyContinue) { throw "Ferme Left 4 Dead 2 et SteamVR avant la desinstallation." }
}

$GameDir = Find-L4D2 $GameDir
$backupDir = Join-Path $GameDir "VR\$BackupFolderName"
$backupDll = Join-Path $backupDir "d3d9.dll.original"
$backupManifest = Join-Path $backupDir "action_manifest.json.original"
$backupBindings = Join-Path $backupDir "bindings_oculus_touch.json.original"
$currentDll = Join-Path $GameDir "d3d9.dll"
$manifestPath = Join-Path $GameDir "VR\SteamVRActionManifest\action_manifest.json"
$bindingsPath = Join-Path $GameDir "VR\SteamVRActionManifest\bindings_oculus_touch.json"

foreach ($required in @($backupDll,$backupManifest,$backupBindings)) {
    if (-not (Test-Path -LiteralPath $required)) { throw "Sauvegarde sd805 v3 incomplete. Aucun fichier n'a ete modifie." }
}
Copy-Item -LiteralPath $backupDll -Destination $currentDll -Force
Copy-Item -LiteralPath $backupManifest -Destination $manifestPath -Force
Copy-Item -LiteralPath $backupBindings -Destination $bindingsPath -Force

Write-Host ""
Write-Host "DLL, manifeste et binding Oculus d'origine restaures." -ForegroundColor Green
Write-Host "La sauvegarde est conservee : $backupDir" -ForegroundColor Cyan
Write-Host "Redemarre SteamVR avant de rejouer." -ForegroundColor Yellow
if (-not $Quiet) { Read-Host "Appuie sur Entree pour fermer" }
