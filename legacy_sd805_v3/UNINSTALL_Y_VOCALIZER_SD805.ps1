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

foreach ($name in @("left4dead2","vrserver","vrmonitor")) {
    if (Get-Process -Name $name -ErrorAction SilentlyContinue) { throw "Ferme Left 4 Dead 2 et SteamVR avant la desinstallation." }
}

$GameDir = Find-L4D2 $GameDir
$backupDir = Join-Path $GameDir "VR\$BackupFolderName"
$backupDll = Join-Path $backupDir "d3d9.dll.original"
$currentDll = Join-Path $GameDir "d3d9.dll"

if (-not (Test-Path -LiteralPath $backupDll)) { throw "Sauvegarde sd805 v3 introuvable. Aucun fichier n'a ete modifie." }
Copy-Item -LiteralPath $backupDll -Destination $currentDll -Force
Remove-Item -LiteralPath $backupDir -Recurse -Force

Write-Host ""
Write-Host "Ancien d3d9.dll restaure." -ForegroundColor Green
Write-Host "Redemarre SteamVR avant de rejouer." -ForegroundColor Yellow
Read-Host "Appuie sur Entree pour fermer"
