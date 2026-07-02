# Bodymorph Alterations

Standalone MO2 add-on for self-cast NSFW Alteration bodymorph transformations.

The MO2 mod folder and user-facing MCM name are `Bodymorph Alterations`. The plugin remains `Dollform.esp` for save compatibility with existing test saves and Papyrus properties.

## Purpose, Source, and Build

- Purpose: provide self-cast bodymorph transformation powers with progression, MCM repair/debugging, and SlaveTats overlays.
- Source: `Source/Scripts/*.psc`, `Dollform.esp`, `Textures/Actors/Character/slavetats`, `SKSE/Plugins/Dollform/Config.json`, and the included planning/modding notes.
- Build: compile Papyrus sources against vanilla, SkyUI, RaceMenu/NiOverride, PapyrusUtil, powerofthree's Papyrus Extender, and SlaveTats sources. Use xEdit or Creation Kit for plugin record changes.
- Install: use the installation steps below.

## Installation

Install this as a normal Mod Organizer 2 mod.

1. Copy or extract the package folder into the MO2 `mods` directory as `Bodymorph Alterations`.
2. Enable `Bodymorph Alterations` in the active MO2 profile.
3. Enable `Dollform.esp` in the plugin load order.
4. Keep this mod after RaceMenu, SkyUI, PapyrusUtil, powerofthree's Papyrus Extender, SlaveTats, and Container Item Distributor.
5. For existing saves, open the console once after loading and run:

```text
bat BodymorphStartMCM
```

This refreshes SkyUI's MCM registration for the included `Bodymorph Alterations CURRENT` menu.

## Files

- `Dollform.esp`: compatibility plugin name containing powers, magic effects, tier/use globals, and the MCM quest.
- `BodymorphStartMCM.txt`: console repair batch for existing saves where SkyUI did not register the MCM.
- `Scripts/cfl_DollformEffect.pex`: active Dollform runtime.
- `Scripts/cfl_HorseformEffect.pex`: active Horseform runtime.
- `Scripts/cfl_CowformEffect.pex`: active Cowform runtime.
- `Scripts/cfl_RabbitformEffect.pex`: active Rabbitform runtime.
- `Scripts/cfl_TrollformEffect.pex`: active Trollform runtime.
- `Scripts/cfl_DollformMCM.pex`: SkyUI MCM debug/status menu.
- `Scripts/cfl_TolfdirGrantPower.pex` and `Scripts/TIF_cfl_TolfdirGrant*Info.pex`: inactive Tolfdir dialogue fragments kept for the planned trainer flow.
- `Scripts/cfl_DollformMarkEffect.pex`: permanent initiation mark runtime.
- `Scripts/cfl_BodymorphMarkEffect.pex`: shared Horseform/Cowform initiation mark runtime.
- `SEQ/Dollform.seq`: startup sequence for the SkyUI MCM quest.
- `SEQ/Dollform.seq.disabled`: old disabled startup sequence from the trainer-dialogue experiment. It is retained only as a note/artifact and is not used.
- `Source/Scripts/*.psc`: matching Papyrus source.
- `Textures/Actors/Character/slavetats/dollform.json`: SlaveTats metadata for permanent marks and temporary form cosmetics.
- `Textures/Actors/Character/slavetats/BodymorphAlterations/*.dds`: custom transparent DDS overlays for Dollform, Horseform, Cowform, Rabbitform, and Trollform marks.
- `SKSE/Plugins/Dollform/Config.json`: notes/current tuning reference. Runtime values are currently set in the ESP/Papyrus defaults.

## How to Use

The five base forms are Lesser Powers:

```text
Dollform
Horseform
Cowform
Rabbitform
Trollform
```

They are still self-cast and last 420 seconds. Reusing the same active form now reports that it is already active instead of toggling it off. Casting a different bodymorph form while one is active is still blocked.

Current acquisition is through Tolfdir's normal barter dialogue at the College of Winterhold. `Dollform_CID.ini` adds five base tomes to `MerchantWCollegeTolfdirChest`:

```text
Spell Tome: Dollform
Spell Tome: Horseform
Spell Tome: Cowform
Spell Tome: Rabbitform
Spell Tome: Trollform
```

Reading a tome teaches the matching Lesser Power. The MCM debug page can also re-grant the base powers if a save needs repair.

The Tolfdir trainer dialogue experiment is disabled in this build because the generated dialogue/SEQ records caused a launch crash. The planned trainer flow remains documented below, but it should be rebuilt through a safer xEdit/Creation Kit style workflow before being re-enabled.

Using a form now levels that form over time. Each form has persistent accumulated-use seconds, visible in the MCM, and automatically raises its tier at these thresholds:

```text
Tier 1: 120 seconds
Tier 2: 360 seconds
Tier 3: 900 seconds
Tier 4: 1800 seconds
```

When a tier increases while the form is active, the script immediately reapplies morphs, stats, restrictions, and cosmetics at the new tier. It also refreshes that form's persistent progression tattoo at a stronger alpha.

Progression tattoos:

```text
Dollform: Dollform Attunement, BodymorphAlterations\doll_attunement.dds
Horseform: Horseform Seed Brand, BodymorphAlterations\horse_seed_brand.dds
Cowform: Cowform Milk Drops, BodymorphAlterations\cow_milk_drops.dds
Rabbitform: Rabbitform Moon Mark, BodymorphAlterations\rabbit_moon_mark.dds
Trollform: Trollform Grayhide Brand, BodymorphAlterations\horse_hoofbound_stride.dds
```

## MCM Debug Menu

The mod includes a SkyUI MCM named `Bodymorph Alterations`. It is backed by a start-game-enabled quest, `cfl_DollformMCMQuest`.

If an existing save does not show the MCM, open the console and run:

```text
bat BodymorphStartMCM
```

This stops and restarts `cfl_DollformMCMQuest` around SkyUI config-manager refreshes. Use it if the MCM is missing or if SkyUI cached duplicate Bodymorph Alterations entries after an earlier repair attempt. Casting any Bodymorph Alteration form also attempts to start the MCM quest if it is not already running.

Status page:

```text
Active form global
Dollform / Horseform / Cowform / Rabbitform / Trollform tier globals
Dollform / Horseform / Cowform / Rabbitform / Trollform accumulated use time
Whether the player knows each base form power
```

Debug page:

```text
Cycle each form tier through 0, 1, and 4
Grant all base form powers
Clear the shared active-form lock
Clear this mod's RaceMenu BodyMorph key
Apply Dollform morph test
Apply Cowform morph test
Remove temporary form cosmetics
Remove Bodymorph Alterations progression tattoos
Equip TDN cow horns for testing
Unequip TDN cow horns
Reset form-use counters
```

Diagnostics page:

```text
Active form
TDN cow horn availability/equipped state
Milk Mod Economy availability
Fertility Mode fixes plugin availability
Current Bodymorph Alterations keyed BodyMorph values for the main and visibility layers
Direct RaceMenu morph values for the same major sliders
Selected CBBE 3BA alias values, including BreastsNewSH and PregnancyBelly
```

Tuning page:

```text
Morph strength: cycles 0.5x, 1.0x, 1.5x, 2.0x
Progression time: cycles 0.5x, 1.0x, 2.0x, 4.0x
```

These tuning globals are read by all four form scripts. Lower progression time means faster tiering; higher means slower tiering.

The MCM cleanup buttons are intentionally scoped to this mod's own morph key and temporary cosmetic names. They do not remove permanent initiation marks.

Base tome distribution is enabled for Tolfdir in `Dollform_CID.ini`. The old initiation tome/spell records are no longer generated in the ESP.

Horseform is implemented as the first Bodymorph Alteration expansion.

Its tier identity comes from use-based progression, not buying separate tomes.

Cowform is implemented as the second Bodymorph Alteration expansion. Its tier identity also comes from use-based progression. Its morph application now follows the local Milk Mod Economy/CBBE 3BA pattern by setting several aliases for the same body region, including `BreastsSH`, `BreastsNewSH`, `BreastGravity`, `BreastGravity2`, `NippleAreola`, `AreolaSize`, `PregnancyBelly`, and CBBE 3BA belly `_v2` morphs.

Rabbitform is implemented as the third Bodymorph Alteration expansion. Its tier identity also comes from use-based progression.

Trollform is implemented as the fourth Bodymorph Alteration expansion. Its tier identity also comes from use-based progression.

## Duration and Magicka

- `Dollform`, `Horseform`, `Cowform`, `Rabbitform`, and `Trollform` last 420 seconds, or 7 minutes.
- The self magic effects are explicitly flagged as recoverable duration effects so ActiveMagicEffect cleanup should not run immediately after casting.
- The ESP base cost is 0 because these are Lesser Powers.
- It does not continuously drain magicka after casting.
- While active, each form still reduces magicka regeneration to preserve the Alteration tradeoff.

At current progression:

- Tier 0: `-15` magicka regen multiplier.
- Tier 1: `-19` magicka regen multiplier.

Each form now tracks accumulated active use time in a global:

```text
cfl_DollformUseSeconds
cfl_HorseformUseSeconds
cfl_CowformUseSeconds
cfl_RabbitformUseSeconds
cfl_TrollformUseSeconds
```

These counters are visible in the MCM and now drive automatic tier progression. On each tier increase, the script also calls `Game.AdvanceSkill("Alteration", 35 + tier * 20)` so the powers still contribute to Alteration growth.

Planned progression expansion:

```text
Keep active-use time as the baseline.
Add one themed secondary gate per tier after the form has enough telemetry/debug support.
Dollform: public exposure, speech/social actions, aura procs.
Horseform: sprinting, stamina use, heavy load, optional horse-fill condition if reliable.
Cowform: Milk Mod milk/lactacid output and milking events.
Rabbitform: sprint/jump activity and Fertility Mode events if a safe API is confirmed.
```

Secondary gates should be shown in the MCM before they become required.

## Body Morphs

Dollform applies temporary changes through this mod's own RaceMenu/NiOverride BodyMorph keys, then clears only those keys when the effect ends. It uses a main BodyMorph key plus a stronger visibility BodyMorph key for the most visible sliders, so the shape change should be easier to see in-game without overwriting the player's global RaceMenu slider values. The visibility layer applies at 1.75x the listed visible deltas.

Morph scale is:

```text
1.00 at tier 0
+0.25 per mark tier
```

Current tier 0 changes use RaceMenu/NiOverride BodyMorph keys under this mod's own morph key, so they do not clear the player's RaceMenu slider values:

```text
Breasts: +0.70
DoubleMelon: +0.35
Butt: +0.50
BigButt: +0.25
Hips: +0.40
HipUpperWidth: +0.25
Thighs: +0.30
Waist: -0.35
Arms: -0.18
MuscleAbs: -0.45
MuscleArms: -0.40
MuscleLegs: -0.30
```

At tier 1+, those are multiplied by the tier scale, and these are also applied:

```text
NippleSize: +0.20 * scale
AreolaSize: +0.16 * scale
```

All form-owned changed morphs are clamped between `-2.0` and `3.0`, then cleared when the form fades.

## Temporary Cosmetics

Dollform applies temporary SlaveTats cosmetics when the power starts and removes those exact Dollform-owned cosmetic entries when the power ends. Before applying, it also removes any leftover entries with the same Dollform cosmetic names so repeated uses do not stack duplicates. The script calls `SlaveTats.synchronize_tattoos` after both apply and remove so the overlay state is pushed immediately.

It also changes the player's hair color while active using `PO3_SKSEFunctions.GetHairColor` / `SetHairColor`, the same live-actor style of approach used by mods that rely on powerofthree's Papyrus Extender for appearance changes. The previous hair color is saved on cast and restored when Dollform ends.

Current hair color:

```text
Record: cfl_DollformPorcelainPinkHair
RGB: 255, 182, 216
Hex-style color: #FFB6D8
```

Current cosmetics:

```text
Doll Foot Polish
Section: Dollform Cosmetics
Area: Feet
Texture: makeup\both_feet_nails.dds
Color: pink
Alpha: 0.85
```

The cosmetic entries are declared in this mod's `slavetats/dollform.json`. Active form cosmetics no longer use Face or Hands slots, to avoid displacing existing RaceMenu/SlaveTats face and hand overlays.

Lip color is not implemented yet because I did not find a clean lip-color SlaveTats asset in the current catalogs.

## Stat Effects

While active:

```text
DamageResist: +60 + tier * 12
Speechcraft: +10 + tier * 3
SpeedMult: -12 - tier * 3
MagickaRateMult: -15 - tier * 4
MeleeDamage: -10 - tier * 3
```

At tier 0:

```text
+60 armor rating
+10 Speech
-12 movement speed multiplier
-15 magicka regen multiplier
-10 melee damage
```

At tier 1:

```text
+72 armor rating
+13 Speech
-15 movement speed multiplier
-19 magicka regen multiplier
-13 melee damage
```

## Horseform

`Horseform` is a 420 second self-cast Alteration spell focused on lower-body power, speed, stamina, and hand-use restrictions. It uses the shared bodymorph active-form lockout, so it cannot be cast while Dollform or another bodymorph form is active.

Morph scale:

```text
scale = 1.0 + tier * 0.30
```

Touched morphs:

```text
Thighs: +0.65 * scale
MuscleLegs: +0.55 * scale
MuscleButt: +0.35 * scale
Butt: +0.35 * scale
Hips: +0.20 * scale
Waist: -0.10 * scale
Arms: -0.10 * scale
Belly: -0.08 * scale
Breasts: -0.08 * scale
```

Stats:

```text
SpeedMult: +20 + tier * 10
Stamina: +50 + tier * 25
StaminaRateMult: +25 + tier * 10
CarryWeight: +tier * 50
UnarmedDamage: +tier * 5
MagickaRateMult: -10 - tier * 4
```

Restrictions:

```text
Tier 0+: unequips right-hand weapon every 5 seconds
Tier 2+: also unequips left-hand weapon and shield
Tier 3+: also unequips hands slot 33 and feet slot 37 unless the worn item is a Devious Devices lockable item
```

Cosmetics:

```text
Hair: chestnut, RGB 120, 72, 32
Temporary Horseform Cosmetics:
  Horse Hoof Tint
  Horse Body Mark at tier 2+
  Horse Stride Mark at tier 3+
```

Like Dollform cosmetics, Horseform temporary cosmetics are removed on fade and synchronized through SlaveTats.
Horseform forces a model/node refresh immediately and twice more during the first two seconds after casting, so RaceMenu morphs have more than one chance to become visible if the first update lands during other appearance work.

## Cowform

`Cowform` is a 420 second self-cast Alteration spell focused on breasts, endurance, slower movement, and Milk Mod Economy synergy. It uses the shared bodymorph active-form lockout, so it cannot be cast while Dollform, Horseform, or another bodymorph form is active.

Morph scale:

```text
scale = 1.0 + tier * 0.30
```

Touched morphs:

```text
Breasts: +0.75 * scale
NippleSize: +0.20 * scale
AreolaSize: +0.18 * scale
Belly: +0.22 * scale
Hips: +0.22 * scale
Butt: +0.15 * scale
Waist: +0.08 * scale
Arms: +0.08 * scale
Thighs: +0.10 * scale
```

Stats:

```text
Health: +25 + tier * 15
Stamina: +25 + tier * 10
CarryWeight: +30 + tier * 20
SpeedMult: -8 - tier * 2
MagickaRateMult: -10 - tier * 4
```

Restrictions:

```text
Tier 0: no clothing restriction
Tier 1+: unequips body slot 32 every 6 seconds unless the worn item is a Devious Devices lockable item
Tier 3+: also unequips head slot 30 and hair slot 31 unless the worn item is a Devious Devices lockable item
```

Milk Mod Economy integration:

```text
Quest lookup: MME_MilkQUEST, FormID 0x00E209 in MilkModNEW.esp
If the player is not already a milkmaid or milkslave, Cowform calls MME's AssignSlot on start.
Every 30 seconds while active, Cowform adds 0.20 + tier * 0.12 milk using MME_Storage.changeMilkCurrent with max enforcement.
At tier 2+, each pulse also adds 0.10 + tier * 0.05 lactacid using MME_Storage.changeLactacidCurrent.
Cowform then calls MME CurrentSize so MME refreshes its own breast-size state.
```

Cowform does not remove milkmaid status when it fades. That is deliberate: MME treats milkmaid membership as persistent progression, and removing it on a temporary spell fade would be more destructive than the integration needs.

Cosmetics:

```text
Hair: cream, RGB 235, 226, 205
Tier 1+: equips Cow horns from TDN Equipable Horns if `TDNEquipableHorns.esp` is active
Temporary Cowform Cosmetics:
  Cow Body Spots, using smaller body-safe spots that avoid the upper neck boundary
  Cow Udder Mark is currently disabled to avoid broad pale body overlays near the neck boundary
  Cow Hoof Tint at tier 2+
  Cow Heavy Spots at tier 3+, using the same smaller body-safe spot texture
```

Like the other forms, Cowform temporary cosmetics are removed on fade and synchronized through SlaveTats.
Cow horns use `aaaTDNCowHorns` from `TDNEquipableHorns.esp`, local FormID `0x0012E5`. Cowform tries to equip horns immediately before SlaveTats/MME work, then retries during the two startup refreshes. The horns are removed on fade only if Cowform added them.

## Rabbitform

`Rabbitform` is a 420 second self-cast Alteration power focused on speed, stamina regeneration, fragile health, and fertility-themed future integration. It uses the shared active-form lockout, so it cannot be cast while Dollform, Horseform, Cowform, or another bodymorph form is active.

Core effects:

```text
SpeedMult: +35 + tier * 8
Stamina: +35 + tier * 15
StaminaRateMult: +45 + tier * 15
Health: -30 - tier * 10
CarryWeight: -25 - tier * 10
MagickaRateMult: -8 - tier * 3
```

Touched morphs:

```text
Thighs, CalfSize, Hips, Butt, BigButt, Waist, Belly, Breasts
```

Cosmetics:

```text
Hair: silver, RGB 224, 220, 232
Progression mark: Rabbitform Moon Mark
Temporary cosmetics: Rabbit Hip Mark, Rabbit Leap Mark at tier 2+
```

Fertility Mode integration is detection-only in this build. The MCM diagnostics page reports whether `Fertility Mode 3 Fixes and Updates.esp` is present, but Rabbitform does not change fertility state until a reliable Papyrus API or stable global contract is confirmed.

## Trollform

`Trollform` is a 420 second self-cast Alteration power focused on brute melee survival. It uses the shared active-form lockout, so it cannot be cast while Dollform, Horseform, Cowform, Rabbitform, or another bodymorph form is active.

Core effects:

```text
250 + tier * 35 Health
+8 + tier * 1 HealRate
+40 + tier * 5 MeleeDamage
+20 + tier * 5 UnarmedDamage
+15 + tier * 5 TwoHanded skill
+60 + tier * 15 Stamina
+100 + tier * 15 CarryWeight
+40 + tier * 10 DamageResist
-20 - tier * 1 SpeedMult
-15 WeaponSpeedMult
-100 - tier * 10 Magicka
-80 MagickaRateMult
-100 FireResist
-90 Sneak
-40 Lockpicking
-40 Pickpocket
-30 Speechcraft
-50 Marksman
```

Trollform scales the player to `1.22x + tier * 0.03`, clamped to `1.45x` after the player's original scale. It also applies bulky arm, leg, shoulder, waist, and muscle morphs.

Fire hits with Skyrim's `MagicDamageFire` keyword suppress Trollform's regeneration for roughly 10 seconds. The form still carries the full fire-resistance penalty while active.

Cosmetics:

```text
Hair: slate gray, RGB 112, 116, 110
Progression mark: Trollform Grayhide Brand
Temporary cosmetics: Troll Grayhide Patches, Troll Stone Scars at tier 2+
```

## Clothing Restrictions

Dollform checks clothing on start and every 6 seconds while active. It now unequips ordinary body-slot clothing immediately so the tier 0 body morph is visible during testing.

Current rules:

- Tier 0: no clothing restriction.
- Tier 1+: unequips body slot 32.
- Tier 3+: additionally unequips head slot 30, hair slot 31, hands slot 33, and feet slot 37.

The script does not auto-reequip gear when Dollform ends. That avoids fighting Devious Devices, outfit managers, SexLab stripping, and other equipment systems.

## Enemy Aura

While Dollform is active, the script runs a lightweight pulse:

```text
Every 6 seconds
Radius: 1400 units
Samples: up to 8 random nearby actors
Max effects per pulse: 3 actors
Per-actor cooldown: 45 seconds for the current cast
```

A target must:

- be alive;
- not be the player;
- not be a child;
- be hostile to the player or have the player as combat target;
- have line of sight to the player.

Current aura rolls:

```text
Stagger chance: 20 + tier * 4 percent
Distract chance: 35 + tier * 5 percent
```

If stagger wins, the player applies a small `PushActorAway` stagger force. If distract wins, Dollform casts `Doll-Distracted`, a short hostile debuff that reduces melee damage by 15 for 12 seconds.

If SLO Aroused is available, the target also receives:

```text
Arousal exposure: +2.0 + tier * 1.5
```

The first pass intentionally does not start SexLab masturbation animations. That should be optional later because combat animation starts can conflict with AI, defeat mods, furniture/pathing, and SexLab queues.

## SlaveTats Marks

Use-based progression applies or refreshes one persistent progression tattoo per form. Its alpha increases as the form reaches higher tiers:

```text
Dollform: Dollform Attunement, Body, BodymorphAlterations\doll_attunement.dds
Horseform: Horseform Seed Brand, Body, BodymorphAlterations\horse_seed_brand.dds
Cowform: Cowform Milk Drops, Body, BodymorphAlterations\cow_milk_drops.dds
```

The active progression path uses the three form attunement marks above. The SlaveTats catalog has no Face entries, and active form cosmetics do not use Hands entries.

The persistent progression tattoos are permanent until removed through SlaveTats or a future removal/debug feature. The active form powers read the internal tier globals when cast.

## Current Limitations

- Custom Tolfdir topic dialogue is disabled for launch safety, but Tolfdir's normal barter dialogue sells the five base tomes.
- Legacy tier/initiation tomes are no longer generated. The MCM re-grant button remains as a debug/recovery path.
- Four Dollform tiers, four Horseform tiers, four Cowform tiers, four Rabbitform tiers, and four Trollform tiers are implemented through use-based progression.
- Custom DDS art is included for the main Dollform, Horseform, Cowform, and Rabbitform form marks. Trollform currently reuses existing overlay textures with gray tinting.
- Foot tint and body-form marks are implemented as temporary SlaveTats cosmetics. Face and hand cosmetics are intentionally disabled.
- Hair color is implemented as a temporary po3 Papyrus Extender color swap.
- No lip color or eye color changes yet.
- MCM status, debug, diagnostics, and basic tuning pages are implemented.
- Fertility Mode integration is detection-only until a safe API/global contract is confirmed.
- No SexLab animation starts yet.
- Recasting the same active form reports that it is already active instead of toggling it off. Casting a different bodymorph form while one is active is still blocked.
- `Config.json` documents older tuning notes; current morph/progression tuning is stored in ESP globals and controlled through MCM.

## Planned Trainer Progression Redesign

The long-term structure is to move away from spell tomes and make Tolfdir a transformation mentor:

```text
Tolfdir grants a base transformation power after a themed initiation.
Using a form earns form-specific experience while the form is active.
Each level brightens or strengthens that form's permanent tattoo instead of adding many separate marks.
Higher levels unlock stronger morphs, stronger cosmetics, and stronger restrictions.
```

Possible unlock requirements:

```text
Dollform: pay 100 gold plus a public-service style prerequisite from an installed adult quest mod, if a reliable global/quest stage can be detected.
Horseform: pay 100 gold plus a SexLab/Fill Her Up style condition proving the player is filled with horse semen, if a reliable API/global exists.
Cowform: pay 100 gold plus 5 bottles of the player's own Milk Mod Economy milk.
```

Initial implementation shape:

```text
Add a Tolfdir dialogue branch per form instead of trainer tomes.
Dialogue checks gold and the lightweight prerequisite.
On success, Tolfdir gives the base form power and applies the first permanent tattoo.
Active form scripts increment a form-use counter every fixed interval while active.
Counter thresholds raise tier 1 -> 4.
When tier rises, reapply the same permanent tattoo at higher alpha/color intensity and update the tier global.
```

Current progress toward that system:

```text
Done: form-use counters exist and increment while each form is active.
Done: counter thresholds automatically raise tiers 1 -> 4.
Done: tier-ups immediately reapply morphs, stats, restrictions, and cosmetics.
Done: tier-ups refresh a persistent progression tattoo at stronger alpha.
Done: tier-ups grant Alteration skill usage.
Done: MCM displays and can reset the use counters.
Done: MCM can manually set tiers for testing.
Paused: generated custom Tolfdir topic dialogue was backed out after a launch crash.
Done: base powers are no longer automatic start powers in new games.
Done: Tolfdir's normal barter dialogue sells the five base tomes through CID.
Next: rebuild custom Tolfdir topic acquisition through a safer dialogue-generation path, then add optional prerequisite checks for Public Whore, Fill Her Up, and Milk Mod Economy.
Done: old tome/initiation records are no longer generated in the ESP.
```

Candidate tattoo themes:

```text
Dollform: porcelain sigil and joint seams, brighter pink/white with each level.
Horseform: pelvic horse-themed mark plus burden/stride marks, darker brown/gold with each level.
Cowform: milk drops under the breasts plus body spots/udder marks, brighter white/cream with each level.
```

The runtime progression layer is implemented. Tolfdir barter acquisition is implemented; custom Tolfdir topic dialogue should be rebuilt only after the records can be validated without recreating the launch crash.

## Expansion Ideas

Good next additions:

- Tolfdir dialogue for base form unlocks and prerequisite checks.
- Replace start-power acquisition with Tolfdir acquisition once dialogue is ready.
- More detailed custom DDS variants for lip color, eyeliner, hoof marks, and higher-resolution brand designs.
- An optional debug spell to unregister Cowform-created milkmaid status, gated behind a confirmation.
- Optional SlaveTats overlays for lip color, blush, eyeliner, nail polish, and glossy doll joints.
- Hair color shift through RaceMenu/NiOverride if the installed API supports a stable color override path.
- Sustained magicka drain or periodic magicka damage while Dollform is active.
- Optional out-of-combat masturbation proc, gated behind a long cooldown and only when SexLab is idle enough to start an animation safely.
- MCM or JSON-backed tuning for aura radius, cooldowns, morph strength, and clothing rules.
