# L4D2VR Y Vocalizer Shortcut

Y-button shortcut for the **current keyou91/L4D2VR** build.

## Current compatibility

This version targets the current L4D2VR project:

https://github.com/keyou91/l4d2vr

Unlike the old sd805 core patch, **v2.0 does not replace or patch `d3d9.dll`**.

The current L4D2VR code already provides configurable `CustomAction` inputs and can map a VR action to a held keyboard key. v2.0 uses that native feature instead of modifying L4D2VR gameplay/input code.

## What v2.0 does

The installer:

1. finds your Left 4 Dead 2 installation;
2. verifies the current L4D2VR files are present;
3. finds an unused `CustomAction` slot;
4. configures that slot as:

```text
hold:key:ctrl
```

5. remaps **only the physical Y button** on Oculus/Quest Touch controllers to that CustomAction;
6. backs up the original L4D2VR config and Oculus Touch binding files.

If **Ctrl already opens your vocalizer**, holding **Y** now behaves like holding Ctrl.

That means the vocalizer itself remains responsible for its normal behavior and selection.

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

Download the current package:

**`L4D2VR_Y_Vocalizer_Current_v2.0.zip`**

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

- **Hold Y**: behaves like holding Ctrl and opens the same vocalizer.
- **Point / shoot as usual**: selection is handled by your existing vocalizer/L4D2VR setup.
- **Release Y**: releases Ctrl.
- **Thumbsticks**: unchanged.
- **Triggers**: unchanged.

## Backup and uninstall

The installer creates a backup folder inside:

```text
Left 4 Dead 2\VR\Wokgui_Y_Vocalizer_Backup_v2
```

To remove the patch:

1. close Left 4 Dead 2 and SteamVR;
2. run:

```text
UNINSTALL_Y_VOCALIZER_CURRENT.bat
```

The original `config.txt` and `bindings_oculus_touch.json` are restored.

## If Y still opens Pause

SteamVR may still be using a previously saved personal binding instead of L4D2VR's default binding.

Reset the L4D2VR controller binding to its default/current binding, restart SteamVR, then test again.

## Legacy v1.x

The previous **sd805/L4D2VR** binary patch is obsolete for the current project and is no longer the recommended download.

Do not install the old v1.0 Core Patch over the current keyou91/L4D2VR build.

## Source / transparency

The v2.0 ZIP contains the plain-text PowerShell and BAT installer/uninstaller scripts, so the changes can be inspected before running them.

The package changes only:

- `VR\config.txt`
- `VR\SteamVRActionManifest\bindings_oculus_touch.json`

and keeps backups for uninstall.

## Credits

Current L4D2VR:

https://github.com/keyou91/l4d2vr

Shortcut package:

Wokgui / ChatGPT
