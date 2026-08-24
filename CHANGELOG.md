# Changelog

## Height safety fix — Quest / Oculus Touch

Added a one-click safety fix for accidental playspace/height changes while playing L4D2VR with Quest Touch controllers.

- Removes L4D2VR `ResetPosition` from the left thumbstick click while preserving normal stick movement.
- Removes OVR Advanced Settings Space Turn / Space Drag motion actions from physical Y and B in detected Oculus Touch bindings.
- Keeps Y available for the L4D2VR vocalizer shortcut.
- Creates backups before changing L4D2VR and OVR Advanced Settings binding files.
- Scans the OVR Advanced Settings install binding and common SteamVR/OpenVR user-binding locations.
- Adds `current_v2/FIX_QUEST_HEIGHT_ONE_CLICK.bat` and `current_v2/FIX_QUEST_HEIGHT_SHORTCUTS.ps1`.

## v2.0 — current L4D2VR

Major redesign for the current `keyou91/l4d2vr` codebase.

- Removed dependency on the old sd805/L4D2VR build.
- Removed binary `d3d9.dll` replacement.
- Removed C++ patching.
- Removed all thumbstick-based vocalizer selection logic.
- Removed custom radial-menu logic.
- Removed custom pointer/overlay handling.
- Uses L4D2VR's native `CustomAction` support.
- Uses `hold:key:ctrl` so Y mirrors the user's existing Ctrl vocalizer shortcut.
- Remaps only Oculus/Quest Touch Y to the selected free CustomAction.
- Keeps normal movement, turning and trigger bindings untouched.
- Adds automatic backup and uninstall restore.
- Installer refuses to continue if the expected current L4D2VR CustomAction system is absent.

## v1.0 — legacy

Legacy binary Core Patch for a specific `sd805/L4D2VR` commit.

This version is obsolete for the current keyou91/L4D2VR project and should not be installed on it.
