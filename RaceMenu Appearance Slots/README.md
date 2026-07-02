# RaceMenu Appearance Slots

Standalone NEFARAM add-on that stores two player-authored appearance slots and toggles between them.

## What It Saves

Version 2 stores:

- RaceMenu/CharGen player presets for Slot 1 and Slot 2, using RaceMenu's Papyrus API.
- The player's race for each slot, so presets authored on different races can be reapplied.
- CBBE 3BA RaceMenu body morph target values from the installed morph list.
- Player hair color, using powerofthree's Papyrus Extender.
- Player scale.

RaceMenu's CharGen preset path is now the primary save/load path. The older morph JSON is still saved and reapplied as a fallback/normalization layer after the preset load.

It does not manage BnP installer texture options, external skin texture swaps, custom transformation animations, or Vampire Lord faction/quest state repairs.

## How It Works

The mod is a two-slot runtime appearance switcher. It does not come with a built-in human/vampire look. The player creates both looks manually, then the MCM captures the supported runtime values into Slot 1 and Slot 2.

When saving a slot, the MCM:

- clears this mod's own temporary BodyMorph key so it does not accidentally save its active delta as part of the new target;
- saves the current RaceMenu/CharGen character and preset data for the selected slot;
- stores the current race;
- reads the current RaceMenu/NiOverride body morph result for each tracked CBBE 3BA morph;
- stores those target values in a PapyrusUtil JSON file;
- stores current hair color and player scale.

When applying a slot, the MCM:

- clears only this mod's BodyMorph key, `RaceMenuAppearanceSlots.Active`;
- restores the saved race, hair color, and RaceMenu/CharGen preset;
- reads the current underlying morph value after other systems such as RaceMenu, OBody, MME, or other mods have done their work;
- applies `saved target - current underlying value` as this mod's own keyed BodyMorph delta;
- applies saved hair color and scale;
- refreshes the player model with `NiOverride.UpdateModelWeight` and `QueueNiNodeUpdate`.

This means applying a slot is meant to restore the visible target appearance without deleting morph keys owned by other mods. If another mod changes body morphs after a slot is applied, reapply the slot or use the toggle power again.

## Use

1. Open RaceMenu and make the first appearance.
2. Close RaceMenu.
3. Open `RaceMenu Appearance Slots` in MCM and select `Save Slot 1`.
4. Open RaceMenu and make the second appearance.
5. Close RaceMenu.
6. Select `Save Slot 2`.
7. Use the `Toggle Appearance Slot` lesser power or the MCM apply buttons.

Applying a slot clears only this mod's own BodyMorph key, then applies the saved target shape as a delta from the current underlying RaceMenu/OBody/MME state.

## MCM Pages

`Slots`:

- shows the active slot and whether Slot 1 / Slot 2 have been saved;
- saves current appearance to Slot 1 or Slot 2;
- applies either slot directly;
- toggles between both saved slots;
- cleans up this mod's applied morphs;
- regrants the lesser power;
- refreshes the player model.

`Diagnostics`:

- shows RaceMenu/SKEE, NiOverride, PapyrusUtil, and JSON status;
- shows the tracked morph count;
- shows a few example saved/applied morph values for quick troubleshooting.

## Vampire Lord Bridge

The companion `RaceMenu Appearance Slots - Vampire Lord Bridge` mod calls this MCM script automatically:

- Slot 2 after entering Vampire Lord form.
- Slot 1 after reverting from Vampire Lord form.

Author Slot 1 as your mortal appearance and Slot 2 as your Vampire Lord appearance.

## Source, Build, and Install

- Purpose: provide a standalone two-slot appearance switcher for the player.
- Source: `Source/Scripts/ras_AppearanceSlotsMCM.psc`, `Source/Scripts/ras_ToggleSlotEffect.psc`, and `RMAppSlots.esp`.
- Build: compile the Papyrus sources against vanilla, RaceMenu/SKEE, SkyUI, PapyrusUtil, and powerofthree's Papyrus Extender sources; the packaged `.pex` files are already built.
- Install: copy this folder to MO2 `mods`, enable it, and enable `RMAppSlots.esp`.

## Not Implemented Yet

These are intentionally not implemented:

- BnP FOMOD/install-option swapping or live skin texture replacement;
- automatic vampire stage, starvation, hunting, city, combat, or Sacrosanct-driven switching beyond the Vampire Lord race-switch bridge;
- custom transformation animation or OAR/Pandora behavior package;
- NPC support.

The practical next step would be user-owned overlay support if RaceMenu/CharGen does not cover a specific overlay stack in your setup: explicit MCM fields or JSON entries for known SlaveTats/RaceMenu overlay names to apply per slot.

## Animation Options For Swapping

Best low-risk option:

- Keep the current lesser-power cast and let installed casting animation replacers handle the visual. `Smooth Magic Casting Animation` is present and includes self-cast, release, ready, charge, and ritual-style HKX files. This requires no behavior generation and is least likely to break.

Best configurable option:

- Use `Dynamic Animation Casting - NG`, which is installed and has `SKSE\plugins\_DynamicAnimationCasting\AnimEvents.txt` plus `template.toml`. This can route a specific spell/cast event to selected animation events without building a custom behavior graph.

Good dramatic candidates already present:

- `Smooth Magic Casting Animation`: ritual spell animations under DAR/OAR condition folders such as `1391`, `1392`, `1830`, and `1831`.
- `Goetia Animations - Conditional Shouts`: shout-style animations that could fit a transformation reveal if the power is changed to a shout-like event.
- `Anubs Animation Pack`: contains `magick_*`, `r_ritual_*`, and `vamp*` HKX files, but these are adult/SLAL-oriented assets and should not be reused unless the specific animation context is acceptable.

Recommendation for the next implementation pass:

1. Add the native RaceMenu preset DLL first so slot save/load is complete and reliable.
2. Keep the current lesser power and vanilla/Smooth Magic casting behavior as the default transition.
3. Add optional Dynamic Animation Casting configuration after the native slot switching is stable.

## Files

- `RMAppSlots.esp`: quest, lesser power, magic effect, globals, and startup wiring.
- `Scripts/ras_AppearanceSlotsMCM.pex`: MCM and slot save/apply runtime.
- `Scripts/ras_ToggleSlotEffect.pex`: lesser-power effect that calls the MCM quest.
- `Source/Scripts/*.psc`: matching Papyrus source.
- `SKSE/Plugins/RaceMenuAppearanceSlots/`: runtime notes folder. PapyrusUtil JSON saves under `Data\SKSE\Plugins\RaceMenuAppearanceSlots` via `StorageUtilData\..\RaceMenuAppearanceSlots`.

## Load Order

Enable after RaceMenu, SkyUI, PapyrusUtil, and powerofthree's Papyrus Extender.

If the MCM does not appear on an existing save, use SkyUI's normal config refresh:

```text
setstage SKI_ConfigManagerInstance 1
```
