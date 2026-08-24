# L4D2VR Y Vocalizer Shortcut

Y-button shortcut for the **current keyou91/L4D2VR** build.

## Current compatibility

Current L4D2VR:

- Steam Workshop: https://steamcommunity.com/sharedfiles/filedetails/?id=3724995607
- Source: https://github.com/keyou91/l4d2vr

Unlike the old sd805 Core Patch, **v2.0 does not replace or patch `d3d9.dll`**.

The current L4D2VR code already provides configurable `CustomAction` inputs and can map a VR action to a held keyboard key. v2.0 uses that native feature instead of modifying L4D2VR gameplay/input code.

## What v2.0 does

The installer:

1. finds your Left 4 Dead 2 installation;
2. verifies the current L4D2VR CustomAction system is present;
3. finds an unused `CustomAction2` to `CustomAction5` slot without overwriting an existing custom action;
4. configures that slot as:

```text
hold:key:ctrl
```

5. remaps **only the physical Y button** on Oculus/Quest Touch controllers to that CustomAction;
6. backs up the original L4D2VR config and Oculus Touch binding files.

If **Ctrl already opens your vocalizer**, holding **Y** now behaves like holding Ctrl.

That means phrase selection remains exactly the same as with your already-working Ctrl vocalizer.

## What it does NOT change

v2.0 does **not**:

- patch `d3d9.dll`;
- modify L4D2VR C++ code;
- replace `radialmenu.txt`;
- install a custom vocalizer;
- read the thumbsticks for vocalizer selection;
- change movement or turning;
- add a custom VR pointer/overlay mode;
- alter the trigger binding.

This is intentionally much less invasive than the old v1.x patch.

## Requirements

- Left 4 Dead 2
- current keyou91/L4D2VR
- Oculus / Meta Quest Touch-style controllers
- a vocalizer already accessible with the keyboard **Ctrl** key

If Ctrl does not already open your vocalizer, configure your vocalizer first.

## Download

**[Download L4D2VR_Y_Vocalizer_Current_v2.0.zip](https://github.com/Wokgui/L4D2VR-Y-Vocalizer-Universal-Core-Patch/raw/main/L4D2VR_Y_Vocalizer_Current_v2.0.zip)**

SHA-256 checksums are published in [`SHA256SUMS.txt`](SHA256SUMS.txt).

The exact installer/uninstaller source included in the ZIP is also available in [`current_v2/`](current_v2/).

## Installation

1. Install the current keyou91/L4D2VR build.
2. Confirm that **Ctrl** opens the vocalizer you want to use.
3. Close Left 4 Dead 2.
4. Close SteamVR.
5. Extract `L4D2VR_Y_Vocalizer_Current_v2.0.zip`.
6. Run:

```text
INSTALL_Y_VOCALIZER_CURRENT.bat
```

7. Restart SteamVR.
8. Launch L4D2VR.

## Controls

- **Hold Y:** behaves like holding Ctrl and opens the same vocalizer.
- **Point / shoot as usual:** selection is handled by your existing vocalizer/L4D2VR setup.
- **Release Y:** releases Ctrl.
- **Thumbsticks:** unchanged.
- **Triggers:** unchanged.

## Exactly what is modified

Only these two existing L4D2VR text files are changed:

```text
VR\config.txt
VR\SteamVRActionManifest\bindings_oculus_touch.json
```

The installer does not copy a DLL or radial menu into the game.

## Backup and uninstall

The installer creates an exact backup inside:

```text
Left 4 Dead 2\VR\Wokgui_Y_Vocalizer_Backup_v2
```

To remove the shortcut:

1. close Left 4 Dead 2 and SteamVR;
2. run:

```text
UNINSTALL_Y_VOCALIZER_CURRENT.bat
```

The original `config.txt` and `bindings_oculus_touch.json` are restored.

## If Y still opens Pause

SteamVR may still be using a previously saved personal binding instead of L4D2VR's edited default binding.

Reset the L4D2VR controller binding to **Default/current**, restart SteamVR, then test again.

## If Y does nothing

Verify first that keyboard Ctrl itself opens the vocalizer. v2.0 deliberately mirrors Ctrl instead of creating a second vocalizer/menu implementation.

## Legacy v1.x

The previous **sd805/L4D2VR** binary patch is obsolete for the current project and its binary package has been removed from the current branch to prevent accidental installation.

Do not install the old v1.0 Core Patch over the current keyou91/L4D2VR build.

Historical details are in [`LEGACY_SD805.md`](LEGACY_SD805.md).

## Steam Workshop publishing files

Ready-to-copy Workshop material is included in the repository:

- [`WORKSHOP_DESCRIPTION.txt`](WORKSHOP_DESCRIPTION.txt) — formatted Steam description;
- [`STEAM_UPDATE_NOTE.txt`](STEAM_UPDATE_NOTE.txt) — update note;
- [`STEAM_PUBLISHING.md`](STEAM_PUBLISHING.md) — publishing checklist;
- [`WORKSHOP_ADDON/addoninfo.txt`](WORKSHOP_ADDON/addoninfo.txt) — neutral Workshop payload.

The Workshop payload intentionally contains no `radialmenu.txt`, no patched `d3d9.dll` and no stick-selection code.

## Source / transparency

The v2.0 ZIP contains plain-text PowerShell and BAT installer/uninstaller scripts. The same files are kept unpacked in `current_v2/` for review.

## Credits

Current L4D2VR:

https://github.com/keyou91/l4d2vr

Shortcut package:

Wokgui / ChatGPT
