param(
    [string]$GameDir = ""
)

$ErrorActionPreference = "Stop"
$TargetCommand = "+mouse_menu Orders"
$LegacyCommand = "hold:key:ctrl"
$BackupFolderName = "Wokgui_Y_Vocalizer_Backup_v3"

function Write-Info([string]$Text) { Write-Host $Text -ForegroundColor Cyan }
function Write-Ok([string]$Text) { Write-Host $Text -ForegroundColor Green }
function Write-Warn([string]$Text) { Write-Host $Text -ForegroundColor Yellow }

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

    $here = Split-Path -Parent $MyInvocation.MyCommand.Path
    if (Test-Path -LiteralPath (Join-Path $here "left4dead2.exe")) {
        return $here
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

function Read-CustomActionValue {
    param(
        [string[]]$Lines,
        [int]$Slot
    )

    $pattern = "^\s*CustomAction$($Slot)Command\s*=(.*)$"
    foreach ($line in $Lines) {
        $m = [regex]::Match($line, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        if ($m.Success) {
            return $m.Groups[1].Value.Trim()
        }
    }
    return $null
}

function Write-Utf8NoBomLines {
    param([string]$Path, [string[]]$Lines)
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllLines($Path, $Lines, $utf8)
}

function Write-Utf8NoBomText {
    param([string]$Path, [string]$Text)
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Text, $utf8)
}

Write-Host ""
Write-Host "L4D2VR - Y Vocalizer Shortcut v3.0" -ForegroundColor White
Write-Host "Y press = open Orders / Y release = close Orders" -ForegroundColor DarkGray
Write-Host ""

$runningNames = @("left4dead2", "vrserver", "vrmonitor")
$running = @()
foreach ($name in $runningNames) {
    if (Get-Process -Name $name -ErrorAction SilentlyContinue) {
        $running += $name
    }
}
if ($running.Count -gt 0) {
    throw "Ferme Left 4 Dead 2 et SteamVR avant l'installation. Processus detectes : $($running -join ', ')"
}

$GameDir = Find-L4D2 -Requested $GameDir
Write-Info "Jeu detecte : $GameDir"

$vrDir = Join-Path $GameDir "VR"
$configPath = Join-Path $vrDir "config.txt"
$manifestPath = Join-Path $vrDir "SteamVRActionManifest\action_manifest.json"
$bindingsPath = Join-Path $vrDir "SteamVRActionManifest\bindings_oculus_touch.json"

foreach ($required in @($configPath, $manifestPath, $bindingsPath)) {
    if (-not (Test-Path -LiteralPath $required)) {
        throw "Fichier L4D2VR actuel introuvable : $required"
    }
}

$manifestText = Get-Content -LiteralPath $manifestPath -Raw
if ($manifestText -notmatch [regex]::Escape("/actions/main/in/CustomAction5")) {
    throw "Cette version de L4D2VR ne contient pas les CustomAction actuelles. Installation annulee sans modification."
}

$configLines = @(Get-Content -LiteralPath $configPath)
$slot = $null

# Reutiliser en priorite le slot du patch v2 ou une installation v3 existante.
foreach ($candidate in @(5,4,3,2)) {
    $value = Read-CustomActionValue -Lines $configLines -Slot $candidate
    if ($null -eq $value) { continue }

    if ($value.Equals($TargetCommand, [System.StringComparison]::OrdinalIgnoreCase) -or
        $value.Equals($LegacyCommand, [System.StringComparison]::OrdinalIgnoreCase)) {
        $slot = $candidate
        break
    }
}

# Sinon prendre un CustomAction libre sans ecraser les actions de l'utilisateur.
if ($null -eq $slot) {
    foreach ($candidate in @(5,4,3,2)) {
        $value = Read-CustomActionValue -Lines $configLines -Slot $candidate
        if ($null -ne $value -and [string]::IsNullOrWhiteSpace($value)) {
            $slot = $candidate
            break
        }
    }
}

if ($null -eq $slot) {
    throw "Aucun CustomAction2-5 libre. Libere un CustomAction dans VR\config.txt puis relance l'installateur."
}

Write-Info "CustomAction utilise : $slot"

$backupDir = Join-Path $vrDir $BackupFolderName
if (-not (Test-Path -LiteralPath $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir | Out-Null
    Copy-Item -LiteralPath $configPath -Destination (Join-Path $backupDir "config.txt.original") -Force
    Copy-Item -LiteralPath $bindingsPath -Destination (Join-Path $backupDir "bindings_oculus_touch.json.original") -Force
    Write-Ok "Sauvegarde creee : $backupDir"
} else {
    Write-Warn "Sauvegarde v3 deja presente : elle est conservee."
}

# Le L4D2VR actuel traite nativement toute CustomAction commencant par '+' comme
# une commande press/release : appui => +mouse_menu Orders ; relachement => -mouse_menu Orders.
$pattern = "^\s*CustomAction$($slot)Command\s*=.*$"
$foundLine = $false
for ($i = 0; $i -lt $configLines.Count; $i++) {
    if ($configLines[$i] -match $pattern) {
        $configLines[$i] = "CustomAction$($slot)Command=$TargetCommand"
        $foundLine = $true
        break
    }
}
if (-not $foundLine) {
    $configLines += "CustomAction$($slot)Command=$TargetCommand"
}
Write-Utf8NoBomLines -Path $configPath -Lines $configLines

# Remapper uniquement le bouton Y physique du Touch gauche.
$bindingRaw = Get-Content -LiteralPath $bindingsPath -Raw
$bindingJson = $bindingRaw | ConvertFrom-Json

$mainProp = $bindingJson.bindings.PSObject.Properties["/actions/main"]
if (-not $mainProp) {
    throw "Section /actions/main introuvable dans bindings_oculus_touch.json"
}

$ySource = $null
foreach ($source in $mainProp.Value.sources) {
    if ($source.path -eq "/user/hand/left/input/y") {
        $ySource = $source
        break
    }
}
if (-not $ySource) {
    throw "Binding du bouton Y Oculus/Quest introuvable."
}
if (-not $ySource.inputs -or -not $ySource.inputs.click) {
    throw "Binding click du bouton Y invalide."
}

$oldYOutput = [string]$ySource.inputs.click.output
$ySource.inputs.click.output = "/actions/main/in/CustomAction$slot"

$bindingOut = $bindingJson | ConvertTo-Json -Depth 100
Write-Utf8NoBomText -Path $bindingsPath -Text $bindingOut

$state = [ordered]@{
    version = "3.0"
    installedUtc = [DateTime]::UtcNow.ToString("o")
    gameDir = $GameDir
    customActionSlot = $slot
    pressCommand = "+mouse_menu Orders"
    releaseCommand = "-mouse_menu Orders"
    originalYOutput = $oldYOutput
}
Write-Utf8NoBomText -Path (Join-Path $backupDir "state.json") -Text ($state | ConvertTo-Json -Depth 10)

Write-Host ""
Write-Ok "Installation terminee."
Write-Host ""
Write-Host "Fonctionnement :" -ForegroundColor White
Write-Host "  - Appuie sur Y : ouverture du vocalizer Orders." -ForegroundColor Gray
Write-Host "  - Maintiens Y : le vocalizer reste ouvert." -ForegroundColor Gray
Write-Host "  - Relache Y : fermeture immediate du vocalizer." -ForegroundColor Gray
Write-Host "  - Si aucune phrase n'est selectionnee, rien n'est prononce." -ForegroundColor Gray
Write-Host "  - Sticks, armes, bras VR et gachettes ne sont pas modifies." -ForegroundColor Gray
Write-Host ""
Write-Warn "Redemarre SteamVR apres l'installation."
Write-Warn "Si Y ouvre encore Pause, remets les bindings SteamVR de L4D2VR sur Default/current."
Write-Host ""
Read-Host "Appuie sur Entree pour fermer"
