param(
    [string]$GameDir = ""
)

$ErrorActionPreference = "Stop"

function Write-Info([string]$Text) {
    Write-Host $Text -ForegroundColor Cyan
}

function Write-Ok([string]$Text) {
    Write-Host $Text -ForegroundColor Green
}

function Write-Warn([string]$Text) {
    Write-Host $Text -ForegroundColor Yellow
}

function Write-Utf8NoBomText {
    param(
        [string]$Path,
        [string]$Text
    )
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Text, $utf8)
}

function Ensure-Admin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        return
    }

    Write-Info "Elevation administrateur requise pour pouvoir corriger OVR Advanced Settings."

    $scriptPath = $PSCommandPath
    if (-not $scriptPath) {
        throw "Impossible de retrouver le chemin du script pour l'elevation administrateur."
    }

    $args = @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", ('"' + $scriptPath + '"')
    )
    if ($GameDir) {
        $args += @("-GameDir", ('"' + $GameDir + '"'))
    }

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

    foreach ($candidate in @(
        "${env:ProgramFiles(x86)}\Steam",
        "$env:ProgramFiles\Steam"
    )) {
        if ($candidate -and (Test-Path -LiteralPath $candidate) -and -not $paths.Contains($candidate)) {
            $paths.Add($candidate)
        }
    }

    return $paths
}

function Get-SteamLibraries {
    $libraries = New-Object System.Collections.Generic.List[string]

    foreach ($steamPath in Get-SteamPaths) {
        if (-not $libraries.Contains($steamPath)) {
            $libraries.Add($steamPath)
        }

        $vdf = Join-Path $steamPath "steamapps\libraryfolders.vdf"
        if (-not (Test-Path -LiteralPath $vdf)) {
            continue
        }

        $raw = Get-Content -LiteralPath $vdf -Raw -ErrorAction SilentlyContinue
        if (-not $raw) {
            continue
        }

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

function Disable-L4D2VRResetPosition {
    param([string]$Root)

    $bindingPath = Join-Path $Root "VR\SteamVRActionManifest\bindings_oculus_touch.json"
    if (-not (Test-Path -LiteralPath $bindingPath)) {
        throw "Binding L4D2VR Oculus/Quest introuvable : $bindingPath"
    }

    $backupPath = "$bindingPath.wokgui-heightfix-backup"
    if (-not (Test-Path -LiteralPath $backupPath)) {
        Copy-Item -LiteralPath $bindingPath -Destination $backupPath -Force
    }

    $json = (Get-Content -LiteralPath $bindingPath -Raw) | ConvertFrom-Json
    $main = $json.bindings.PSObject.Properties["/actions/main"]
    if (-not $main) {
        throw "Section /actions/main introuvable dans le binding L4D2VR."
    }

    $changed = $false
    foreach ($source in $main.Value.sources) {
        if ($source.path -ne "/user/hand/left/input/joystick") {
            continue
        }

        if ($source.inputs -and $source.inputs.click -and
            [string]$source.inputs.click.output -eq "/actions/main/in/ResetPosition") {
            $source.inputs.PSObject.Properties.Remove("click")
            $changed = $true
        }
    }

    if ($changed) {
        Write-Utf8NoBomText -Path $bindingPath -Text ($json | ConvertTo-Json -Depth 100)
        Write-Ok "L4D2VR : clic stick gauche -> Reset Position supprime."
    } else {
        Write-Ok "L4D2VR : Reset Position n'est deja plus lie au clic du stick gauche."
    }
}

function Patch-OvrasBindingFile {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return $false
    }

    $raw = Get-Content -LiteralPath $Path -Raw -ErrorAction SilentlyContinue
    if (-not $raw -or $raw -notmatch 'oculus_touch') {
        return $false
    }

    try {
        $json = $raw | ConvertFrom-Json
    } catch {
        return $false
    }

    if ([string]$json.controller_type -ne "oculus_touch") {
        return $false
    }

    if ($json.PSObject.Properties["app_key"] -and
        [string]$json.app_key -ne "steam.overlay.1009850") {
        return $false
    }

    $motion = $json.bindings.PSObject.Properties["/actions/motion"]
    if (-not $motion -or -not $motion.Value.sources) {
        return $false
    }

    $oldSources = @($motion.Value.sources)
    $newSources = @()
    foreach ($source in $oldSources) {
        if ($source.path -eq "/user/hand/left/input/y" -or
            $source.path -eq "/user/hand/right/input/b") {
            continue
        }
        $newSources += $source
    }

    if ($newSources.Count -eq $oldSources.Count) {
        return $true
    }

    $backupPath = "$Path.wokgui-heightfix-backup"
    if (-not (Test-Path -LiteralPath $backupPath)) {
        Copy-Item -LiteralPath $Path -Destination $backupPath -Force
    }

    $motion.Value.sources = $newSources
    Write-Utf8NoBomText -Path $Path -Text ($json | ConvertTo-Json -Depth 100)
    Write-Ok "OVR Advanced Settings : Space Turn/Drag supprime de Y et B dans $Path"
    return $true
}

function Find-And-Patch-Ovras {
    $patched = New-Object System.Collections.Generic.List[string]
    $candidates = New-Object System.Collections.Generic.List[string]

    try {
        $regKey = Get-Item -LiteralPath "HKLM:\Software\OpenVR-AdvancedSettings" -ErrorAction SilentlyContinue
        if ($regKey) {
            $installDir = [string]$regKey.GetValue("")
            if ($installDir) {
                $candidates.Add((Join-Path $installDir "default_action_manifests\ovras-team.advancedsettings_default_touch.json"))
            }
        }
    } catch {}

    foreach ($installDir in @(
        "$env:ProgramFiles\OpenVR-AdvancedSettings",
        "${env:ProgramFiles(x86)}\OpenVR-AdvancedSettings"
    )) {
        if ($installDir) {
            $candidate = Join-Path $installDir "default_action_manifests\ovras-team.advancedsettings_default_touch.json"
            if (-not $candidates.Contains($candidate)) {
                $candidates.Add($candidate)
            }
        }
    }

    foreach ($path in $candidates) {
        if ((Test-Path -LiteralPath $path) -and (Patch-OvrasBindingFile -Path $path)) {
            if (-not $patched.Contains($path)) {
                $patched.Add($path)
            }
        }
    }

    $searchRoots = New-Object System.Collections.Generic.List[string]
    foreach ($root in @(
        (Join-Path $env:LOCALAPPDATA "openvr"),
        (Join-Path $env:APPDATA "openvr")
    )) {
        if ($root -and (Test-Path -LiteralPath $root) -and -not $searchRoots.Contains($root)) {
            $searchRoots.Add($root)
        }
    }

    foreach ($steamPath in Get-SteamPaths) {
        $configRoot = Join-Path $steamPath "config"
        if ((Test-Path -LiteralPath $configRoot) -and -not $searchRoots.Contains($configRoot)) {
            $searchRoots.Add($configRoot)
        }
    }

    foreach ($root in $searchRoots) {
        $jsonFiles = Get-ChildItem -LiteralPath $root -Filter "*.json" -File -Recurse -ErrorAction SilentlyContinue
        foreach ($file in $jsonFiles) {
            $path = $file.FullName
            if ($patched.Contains($path)) {
                continue
            }

            $raw = Get-Content -LiteralPath $path -Raw -ErrorAction SilentlyContinue
            if ($raw -and $raw -match 'steam\.overlay\.1009850' -and $raw -match 'oculus_touch') {
                if (Patch-OvrasBindingFile -Path $path) {
                    $patched.Add($path)
                }
            }
        }
    }

    return $patched.Count
}

Write-Host ""
Write-Host "L4D2VR / Quest 3 - Height Safety Fix" -ForegroundColor White
Write-Host ""

Ensure-Admin

$runningNames = @("left4dead2", "vrserver", "vrmonitor", "AdvancedSettings")
$running = @()
foreach ($name in $runningNames) {
    if (Get-Process -Name $name -ErrorAction SilentlyContinue) {
        $running += $name
    }
}
if ($running.Count -gt 0) {
    throw "Ferme Left 4 Dead 2, SteamVR et OVR Advanced Settings avant de lancer le correctif. Processus detectes : $($running -join ', ')"
}

$GameDir = Find-L4D2 -Requested $GameDir
Write-Info "Jeu detecte : $GameDir"

Disable-L4D2VRResetPosition -Root $GameDir
$ovrasCount = Find-And-Patch-Ovras

Write-Host ""
if ($ovrasCount -gt 0) {
    Write-Ok "OVR Advanced Settings : $ovrasCount binding(s) Quest/Oculus corrige(s)."
} else {
    Write-Warn "Aucun binding OVR Advanced Settings Quest/Oculus n'a ete trouve automatiquement."
    Write-Warn "Le correctif L4D2VR a tout de meme ete applique."
}

Write-Host ""
Write-Ok "Correctif termine."
Write-Host "  - Y reste disponible pour ton vocalizer L4D2VR." -ForegroundColor Gray
Write-Host "  - Le clic du stick gauche ne recentre plus L4D2VR." -ForegroundColor Gray
Write-Host "  - Y/B ne declenchent plus Space Turn/Space Drag dans les bindings OVRAS trouves." -ForegroundColor Gray
Write-Host ""
Write-Warn "Redemarre SteamVR avant de rejouer."
Write-Host ""
Read-Host "Appuie sur Entree pour fermer"
