# L4D2VR Y Vocalizer Shortcut

Y-button shortcut for the **current keyou91/L4D2VR** build.

## Current version: v3.0

v3.0 fixes the remaining Y-button behavior:

- **press Y** -> opens the `Orders` vocalizer;
- **hold Y** -> keeps the vocalizer open;
- **release Y** -> closes the vocalizer immediately;
- if no phrase is selected, nothing is spoken.

Unlike v2.0, v3.0 no longer mirrors the keyboard Ctrl key. It uses L4D2VR's native CustomAction press/release support directly:

```text
CustomActionXCommand=+mouse_menu Orders
```

The current L4D2VR code automatically sends the corresponding release command when Y is released:

```text
-mouse_menu Orders
```

No `d3d9.dll`, C++ source file or `radialmenu.txt` is replaced.

## Compatibility

Current L4D2VR:

- Steam Workshop: https://steamcommunity.com/sharedfiles/filedetails/?id=3724995607
- Source: https://github.com/keyou91/l4d2vr

Controllers:

- Oculus Touch
- Meta Quest Touch-style controllers

## Installation

1. Install the current keyou91/L4D2VR build.
2. Close Left 4 Dead 2.
3. Close SteamVR.
4. Download this repository with **Code -> Download ZIP** and extract it.
5. Open [`current_v3/`](current_v3/).
6. Run:

```text
INSTALL_Y_VOCALIZER_CURRENT.bat
```

7. Restart SteamVR.
8. Launch L4D2VR.

If v2 is already installed, the v3 installer detects `hold:key:ctrl` and reuses that CustomAction slot instead of consuming another one.

## Controls

- **Press Y:** opens `Orders`.
- **Hold Y:** menu remains open.
- **Release Y:** menu closes.
- **Thumbsticks:** unchanged.
- **Triggers:** unchanged.
- **Weapons / VR hands:** unchanged.

## Exactly what is modified

Only these two existing L4D2VR text files are changed:

```text
VR\config.txt
VR\SteamVRActionManifest\bindings_oculus_touch.json
```

The installer chooses an unused `CustomAction2` to `CustomAction5`, or reuses the slot previously occupied by the v2 shortcut.

## Backup and uninstall

Before changing anything, v3 backs up the current files in:

```text
Left 4 Dead 2\VR\Wokgui_Y_Vocalizer_Backup_v3
```

To restore the state that existed immediately before v3 installation:

```text
UNINSTALL_Y_VOCALIZER_CURRENT.bat
```

from the `current_v3` folder.

## If Y still opens Pause

SteamVR may still be using a personal controller binding instead of L4D2VR's edited default binding.

Reset the L4D2VR controller binding to **Default/current**, restart SteamVR, then test again.

## v2.0 archive

v2.0 is kept in [`current_v2/`](current_v2/) and the old ZIP remains available for reference. Its behavior is different: Y mirrors `hold:key:ctrl`, so releasing Y only releases the virtual Ctrl key and may leave some vocalizers open.

Use **v3.0** for the release-to-close behavior.

## Legacy v1.x

The previous **sd805/L4D2VR** binary patch is obsolete for the current project. Do not install the old v1.0 Core Patch over the current keyou91/L4D2VR build.

Historical details are in [`LEGACY_SD805.md`](LEGACY_SD805.md).

## Source / transparency

The v3 installer and uninstaller are plain-text PowerShell/BAT files in [`current_v3/`](current_v3/).

## Credits

Current L4D2VR:

https://github.com/keyou91/l4d2vr

Shortcut package:

Wokgui / ChatGPT
