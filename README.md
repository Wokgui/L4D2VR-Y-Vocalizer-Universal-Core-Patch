# L4D2VR Y Vocalizer Universal Core Patch

Universal **Y-button vocalizer bridge** for a specific build of **sd805/L4D2VR**.

## Exact compatibility

This patch was built for the **sd805/L4D2VR `main` codebase at commit**:

`628820257ae755ae120b8f86740a145b6fb74f51`

Repository:
https://github.com/sd805/l4d2vr

Exact commit:
https://github.com/sd805/l4d2vr/commit/628820257ae755ae120b8f86740a145b6fb74f51

Other forks, older releases, newer incompatible builds, or modified L4D2VR versions may use a different `d3d9.dll` and are **not guaranteed to be compatible**.

## What it does

The patch makes the **Y button** open the standard Left 4 Dead 2 radial menu:

`+mouse_menu Orders`

That means:

- If you use a standard vocalizer that replaces the `Orders` radial, **Y opens your installed vocalizer**.
- The vocalizer's own **language, phrases and layout are preserved**.
- If you do not use a vocalizer, Y opens the normal Left 4 Dead 2 `Orders` radial.

This patch does **not** include or replace `radialmenu.txt`.

## Download

Download:

`L4D2VR_Y_Vocalizer_Universal_Core_Patch_v1.0.zip`

## Installation

1. Install the compatible **sd805/L4D2VR** build listed above.
2. Download and extract the Core Patch ZIP.
3. Close Left 4 Dead 2 if it is running.
4. Double-click `INSTALL_Y_VOCALIZER_UNIVERSAL.bat`.
5. Start SteamVR and launch L4D2VR with `-insecure`.

The installer automatically detects Left 4 Dead 2 and backs up the previous L4D2VR `d3d9.dll`.

## Uninstall

Run `UNINSTALL_Y_VOCALIZER_UNIVERSAL.bat` to restore the previous L4D2VR DLL.

## Notes

Designed for standard L4D2 vocalizers that use or replace the `Orders` radial. Vocalizers using completely custom radial names may require additional configuration.
