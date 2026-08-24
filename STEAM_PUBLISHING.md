# Steam Workshop publishing checklist

## Recommended title

`L4D2VR – Y Button Vocalizer Shortcut`

## Description

Copy the complete contents of `WORKSHOP_DESCRIPTION.txt` into the Workshop description field.

## Update / change note

Copy `STEAM_UPDATE_NOTE.txt` into the Workshop update note field.

## Workshop addon content

The Workshop item's own addon content should stay neutral.

Recommended source folder:

`WORKSHOP_ADDON/`

It contains only `addoninfo.txt`.

Do **not** include any of these in the Workshop addon:

- `radialmenu.txt`
- `d3d9.dll`
- old Wokgui VR command VPKs
- thumbstick-selection scripts
- controller binding replacements

The actual Y shortcut is distributed separately as:

`L4D2VR_Y_Vocalizer_Current_v2.0.zip`

## What users should install

1. Current `keyou91/l4d2vr`.
2. Their vocalizer, already working with Ctrl.
3. `L4D2VR_Y_Vocalizer_Current_v2.0.zip` from this repository.

## Important legacy warning

The deleted v1.0 Core Patch was made for the old `sd805/L4D2VR` codebase.

Do not tell current L4D2VR users to install the old sd805 binary patch.
