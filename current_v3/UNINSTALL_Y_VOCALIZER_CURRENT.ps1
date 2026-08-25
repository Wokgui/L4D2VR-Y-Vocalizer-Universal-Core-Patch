param(
    [string]$GameDir = ""
)

$ErrorActionPreference = "Stop"
$BackupFolderName = "Wokgui_Y_Vocalizer_Backup_v3"

function Get-SteamLibraries {
    $libraries = New-Object System.Collections.Generic.List[string]
    $steamPaths = @()

    try {
        $steamReg = Get-ItemProperty -Path "HKCU:\Software\Valve\Steam" -ErrorAction SilentlyContinue
        if ($steamReg -and $steamReg.SteamPath) {
            $steamPaths += [string]$steamReg.SteamPath
        }
    } catch {}

    $steamPaths += @(
        "${env:ProgramFiles(x86)}\Steam",
        "$env:ProgramFiles\Steam"
    )

    foreach ($steamPath in ($steamPaths | Where-Object { $_ } | Select-Object -Unique)) {
        if (-not (Test-Path -LiteralPath $steamPath)) { continue }

        if (-not $libraries.Contains($steamPath)) {
            $libraries.Add($steamPath)
        }

        $vdf = Join-Path $steamPath "steamapps\libraryfolders.vdf"
        if (Test-Path -LiteralPath $vdf) {
            $raw = Get-Content -LiteralPath $vdf -Raw -ErrorAction SilentlyContinue
            if ($raw) {
                foreach ($m in [regex]::Matches($raw, '"path"\s+"([^"]+)"')) {
                    $path = $m.Groups[1].Value -replace '\\\\','\'
                    if ($path -and -not $libraries.Contains($path)) {
                        $libraries.Add($path)
                    }
                }
            }
        }
    }

    return $libraries
}

function Find-L4D2 {
    param([string]$Requested)

    if ($Requested) {
        $candidate = [System.IO.Path]::GetFullPath($Requested)
        if (Test-Path -LiteralPath (Join-Path $candidate "left4dead2.exe")) {
            return $candidate
        }
        throw "Left 4 Dead 2 introuvable dans : $candidate"
    }

    foreach ($library in Get-SteamLibraries) {
        $candidate = Join-Path $library "steamapps\common\Left 4 Dead 2"
        if (Test-Path -LiteralPath (Join-Path $candidate "left4dead2.exe")) {
            return $candidate
        }
    }

    foreach ($drive in @("C:","D:","E:","F:","G:")) {
        foreach ($relative in @(
            "Program Files (x86)\Steam\steamapps\common\Left 4 Dead 2",
            "Program Files\Steam\steamapps\common\Left 4 Dead 2",
            "SteamLibrary\steamapps\common\Left 4 Dead 2"
        )) {
            $candidate = Join-Path $drive $relative
            if (Test-Path -LiteralPath (Join-Path $candidate "left4dead2.exe")) {
                return $candidate
            }
        }
    }

    throw "Impossible de detecter automatiquement Left 4 Dead 2."
}

Write-Host ""
Write-Host "L4D2VR - Y Vocalizer Shortcut v3.0 - Desinstallation" -ForegroundColor White
Write-Host ""

foreach ($name in @("left4dead2", "vrserver", "vrmonitor")) {
    if (Get-Process -Name $name -ErrorAction SilentlyContinue) {
        throw "Ferme Left 4 Dead 2 et SteamVR avant la desinstallation."
    }
}

$GameDir = Find-L4D2 -Requested $GameDir
$vrDir = Join-Path $GameDir "VR"
$backupDir = Join-Path $vrDir $BackupFolderName
$configBackup = Join-Path $backupDir "config.txt.original"
$bindingBackup = Join-Path $backupDir "bindings_oculus_touch.json.original"

if (-not (Test-Path -LiteralPath $configBackup) -or
    -not (Test-Path -LiteralPath $bindingBackup)) {
    throw "Sauvegarde v3.0 introuvable. Aucun fichier n'a ete modifie."
}

$configPath = Join-Path $vrDir "config.txt"
$bindingsPath = Join-Path $vrDir "SteamVRActionManifest\bindings_oculus_touch.json"

Copy-Item -LiteralPath $configBackup -Destination $configPath -Force
Copy-Item -LiteralPath $bindingBackup -Destination $bindingsPath -Force
Remove-Item -LiteralPath $backupDir -Recurse -Force

Write-Host ""
Write-Host "Configuration precedente restauree." -ForegroundColor Green
Write-Host "Redemarre SteamVR avant de rejouer." -ForegroundColor Yellow
Write-Host ""
Read-Host "Appuie sur Entree pour fermer"
