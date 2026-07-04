# Lola Outfit Zone Grace Patch

Standalone loose-script override for `cfl_TaskOutfit` from `cfl_LolaAddon_`.

## Runtime Mod

MO2 mod name:

`[NoDelete] 611 Lola Outfit Zone Grace Patch`

Install/enable this above:

`[NoDelete] 610 Lola Vampire Lord Outfit Task Patch`

## Behavior

On Lola outfit-task location changes:

- reset `WarnedForViolation` to `0`
- clamp the first post-location-change outfit check to at least 30 seconds

This prevents stale warnings from causing immediate punishment/zaps before the player has time to change outfits after entering a new zone.

## Build Notes

Compiled `Source/Scripts/cfl_TaskOutfit.psc` with the Skyrim Papyrus compiler.

Compile-only stubs in `build-stubs/` are not runtime files and should not be copied into the MO2 mod.

Runtime files:

- `Scripts/cfl_TaskOutfit.pex`
- `Source/Scripts/cfl_TaskOutfit.psc` for source tracking only
