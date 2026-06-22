# Modding Notes From Dollform / Bodymorph Alterations

These are practical notes learned while building the `Dollform` add-on in this NEFARAM MO2 setup.

## MO2 Layout

This instance is a portable Mod Organizer 2 setup rooted at:

```text
C:\Games\nefaram
```

Important paths:

```text
Mods: C:\Games\nefaram\mods
Active profile: C:\Games\nefaram\profiles\NEFARAM
Game data: C:\Games\nefaram\Game Root\Data
Papyrus compiler: C:\Games\nefaram\Game Root\Papyrus Compiler\PapyrusCompiler.exe
SSEEdit: C:\Games\nefaram\tools\SSEEdit\SSEEdit.exe
```

When enabling a new add-on:

```text
profiles\NEFARAM\modlist.txt needs +Mod Name
profiles\NEFARAM\plugins.txt needs *PluginName.esp
```

Always back up profile files before editing them manually.

## Packaging Pattern

Use a separate MO2 mod folder rather than editing base mods:

```text
mods\Bodymorph Alterations\
  Dollform.esp
  Scripts\
  Source\Scripts\
  SKSE\Plugins\Dollform\
  Textures\Actors\Character\slavetats\
  README.md
```

Do not package compile stubs, scratch generator projects, logs, or xEdit scripts unless they are intentionally part of the delivered mod.

## Papyrus Compilation

The vanilla source tree used for compilation is:

```text
C:\tmp\skyrim-scripts-source\Source\Scripts
```

Some installed runtime APIs are present as DLLs/PEX files but do not ship complete compile sources. For this project, compile-only stubs were useful for:

```text
NiOverride
PapyrusUtil
SlaveTats
OArousedScript
PO3_SKSEFunctions
ColorForm
ActorBase.GetHairColor
MilkQUEST
MME_Storage
```

Keep these stubs under:

```text
C:\Games\nefaram\__temp__\dollform-build\stubs
```

Do not package them into the MO2 mod.

Compile command pattern:

```powershell
& 'C:\Games\nefaram\Game Root\Papyrus Compiler\PapyrusCompiler.exe' '<source.psc>' `
  -f='TESV_Papyrus_Flags.flg' `
  -i='<mod source>;C:\Games\nefaram\__temp__\dollform-build\stubs;C:\tmp\skyrim-scripts-source\Source\Scripts' `
  -o='<mod Scripts folder>'
```

Target result should be:

```text
0 error(s), 0 warning(s)
```

## Plugin Generation

xEdit automation did not reliably reach the script body in this environment. Mutagen was more reliable for generating simple plugin records.

Local Mutagen assemblies are available via:

```text
C:\Games\nefaram\tools\PGPatcher\Mutagen.Bethesda.Core.dll
C:\Games\nefaram\tools\PGPatcher\Mutagen.Bethesda.Kernel.dll
C:\Games\nefaram\tools\PGPatcher\Mutagen.Bethesda.Skyrim.dll
```

The working scratch generator project lives at:

```text
C:\Games\nefaram\__temp__\DollformPluginGen
```

Useful Mutagen notes:

- `Global` is abstract; use `GlobalShort`, `GlobalInt`, or `GlobalFloat`.
- Skyrim color records are `ColorRecord`.
- The color group on `SkyrimMod` is `Colors`.
- New `Book` records can teach spells via `BookSpell`.
- Newly constructed `Book.Keywords` may be null in this Mutagen build; avoid relying on it unless explicitly initialized.
- Read-back validation after writing the ESP is valuable.

Example validation output:

```text
Globals=4 Colors=3 MagicEffects=16 Spells=16 Books=12
```

If `Dollform.esp` cannot be written, check whether Skyrim is running. `SkyrimSE.exe` can hold the plugin open.

## CID Distribution

Container Item Distributor is installed and active.

Simple CID syntax observed locally:

```ini
[General]
ContainerEditorID = ItemOrLeveledListEditorID|count
```

Example:

```ini
MerchantWCollegeTolfdirChest = cfl_BookHorseformInitiationT4|1
```

This is useful for adding spell tomes to vendor chests without editing vanilla records directly.

Current Bodymorph Alterations distribution file:

```text
mods\Bodymorph Alterations\Dollform_CID.ini
```

Existing saves may need vendor inventory reset/restock before new tomes appear.

## SlaveTats Behavior

Permanent initiation marks and temporary form cosmetics should be separate.

Permanent marks:

```text
Section: Dollform / Horseform / future form section
Applied by initiation powers
Expected to remain
```

Temporary cosmetics:

```text
Section: Dollform Cosmetics / Horseform Cosmetics / future form cosmetics
Applied when the form starts
Removed when the form ends
```

After adding or removing temporary cosmetics, call:

```papyrus
SlaveTats.synchronize_tattoos(akActor, true)
```

This reduces stale overlay problems.

Also remove known temporary aliases before applying them, so repeated casts do not stack duplicates.

## Hair Color

powerofthree's Papyrus Extender exposes:

```papyrus
PO3_SKSEFunctions.GetHairColor(Actor)
PO3_SKSEFunctions.SetHairColor(Actor, ColorForm)
```

Observed pitfall:

- Saving from the live hair color after a previous failed restore can capture the temporary color.

Safer restore pattern:

```papyrus
_previousHairColor = akActor.GetActorBase().GetHairColor()
If !_previousHairColor
    _previousHairColor = PO3_SKSEFunctions.GetHairColor(akActor)
EndIf
```

Then restore with:

```papyrus
PO3_SKSEFunctions.SetHairColor(akActor, _previousHairColor)
```

This fixed the pink-hair-stuck issue going forward.

## Body Morph Safety

Do not globally reset RaceMenu morphs or use unkeyed `SetMorphValue` for temporary form changes.

Local working examples:

- `CBBE 3BA\Scripts\Source\RaceMenuMorphsCBBE.psc` uses keyed `NiOverride.SetBodyMorph(actor, morphName, "RaceMenuMorphsCBBE.esp", value)` followed by `NiOverride.UpdateModelWeight(actor)`.
- `Milk Mod Economy\Scripts\Source\MME_BodyMod.psc` also uses keyed `SetBodyMorph`, and writes multiple aliases for one body region. Breast changes cover legacy and SE/3BA names such as `Breasts`, `BreastsSH`, `BreastsNewSH`, `BreastGravity`, `BreastGravity2`, `NippleAreola`, and `AreolaSize`. Belly changes use `PregnancyBelly`.
- Fertility Mode in this install only exposes compatibility source; its body morph implementation is not present as source here.

For each form:

- Apply form values through this mod's own BodyMorph keys.
- Use a separate visibility BodyMorph key when a stronger visible layer is needed.
- Clear only this mod's BodyMorph keys on fade or debug cleanup.
- Call `NiOverride.UpdateModelWeight(akActor)` after apply and restore.

Useful morph keys already used:

```text
Breasts
Butt
Hips
Thighs
Waist
Arms
Belly
MuscleAbs
MuscleArms
MuscleButt
MuscleLegs
NippleSize
AreolaSize
```

Clamp morph values to a sane range:

```papyrus
PapyrusUtil.ClampFloat(value, -2.0, 3.0)
```

## Active Form Lockout

Form stacking is risky. Current shared global:

```text
cfl_BodymorphActiveForm
0 = none
1 = Dollform
2 = Horseform
3 = Cowform
4 = Rabbitform
5 = Trollform
```

Current behavior:

- If another bodymorph form is active, new casts are blocked and dispelled.
- On effect finish, the form clears the global only if it owns the active form value.

Future improvement:

- Add a debug cleanup power.
- Optionally replace lockout with auto-dispel of the old form.

## Milk Mod Economy Integration

Milk Mod Economy is installed in this NEFARAM profile as:

```text
mods\Milk Mod Economy
Plugin: MilkModNEW.esp
Quest: MME_MilkQUEST, local FormID 0x00E209
```

Avoid compiling against the full MME source tree. It pulls many optional integration sources and SKSE symbols into the compile. Use minimal compile-only stubs for the symbols the patch calls, and let runtime bind to the real MME scripts.

Safe Cowform integration shape:

```text
Game.GetFormFromFile(0x00E209, "MilkModNEW.esp") as MilkQUEST
MilkQUEST.AssignSlot(player) only if player is not already MilkMaid or MilkSlave
MME_Storage.changeMilkCurrent(player, delta, true)
MME_Storage.changeLactacidCurrent(player, delta)
MilkQUEST.CurrentSize(player)
```

Do not automatically remove MME milkmaid status when a temporary form fades. MME treats registration as progression state, not a short-lived magic effect flag.

## Runtime Load Rules

Keep recurring logic slow and bounded.

Good patterns:

```text
RegisterForSingleUpdate(5.0 or 6.0)
Check only specific equipment slots
Sample a small number of nearby actors
Use per-actor cooldowns for aura effects
```

Avoid:

```text
Constant broad cloaks
Frame-like polling
Large actor scans
Animation starts during combat by default
Auto-reequipping gear
```

## Current Implemented Forms

Dollform:

```text
Self-cast spell
4 initiation tiers
Morph/stat/cosmetic package
Enemy aura
Clothing restrictions
Trainer/vendor tomes through CID
```

Horseform:

```text
Self-cast spell
4 initiation tiers
Lower-body morph/stat package
Weapon/shield/hands/feet restrictions by tier
Trainer/vendor tomes through CID
```

Cowform:

```text
Self-cast spell
4 initiation tiers
Breast/body morph and endurance package
Milk Mod Economy registration and bounded milk/lactacid pulses
TDN cow horns at tier 1+
Devious Devices lockable-item checks before forced slot unequip
Trainer/vendor tomes through CID
```

Rabbitform:

```text
Self-cast spell
4 initiation tiers
Speed/stamina package with fragile health and reduced carrying power
Fertility Mode detection-only status hook
Trainer/vendor tomes through CID
```

Trollform:

```text
Self-cast spell
4 initiation tiers
Large scale, bulky muscle morphs, high health, regeneration, armor, and melee damage
Major penalties to speed, weapon speed, magicka, fire resistance, stealth, lockpicking, pickpocket, speech, and archery
Fire hits suppress regeneration for roughly 10 seconds
Trainer/vendor tomes through CID
```

## Optional Asset Integrations

TDN Equipable Horns is active in this profile:

```text
Plugin: TDNEquipableHorns.esp
Cow horns: aaaTDNCowHorns, local FormID 0x0012E5
```

Cowform looks up that record dynamically and does not add `TDNEquipableHorns.esp` as an ESP master.

Devious Devices Assets is active in this profile:

```text
Plugin: Devious Devices - Assets.esm
Lock keyword: zad_Lockable, local FormID 0x003894
```

Horseform and Cowform use this keyword dynamically before forced slot unequip. If the worn armor in a restricted slot has `zad_Lockable`, the form leaves it alone. This avoids fighting locked DD gear while still letting ordinary equipment restrictions work.

## Next Best Work

Recommended next steps:

1. Add a debug cleanup power for stuck overlays/hair/active-form state.
2. Playtest Dollform/Horseform/Cowform in a save and tune morph/stat values.
3. Playtest Cowform in a save with MME active and tune milk pulse size.
4. Inspect Fertility Mode APIs before changing Rabbitform cycle/output state.
5. Playtest Trollform against fire mages and melee encounters to tune regeneration, scale, and fire weakness.
