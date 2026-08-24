# Changelog

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
