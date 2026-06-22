# Bodymorph Alterations Plan

This document expands `Dollform` into a broader Alteration spell family built around temporary RaceMenu/NiOverride bodymorph forms, visible cosmetic changes, gameplay tradeoffs, and optional integrations with installed NSFW systems.

The implementation should stay as a separate MO2 add-on under `mods/Dollform` unless renamed later. Base mods should not be edited directly.

## Design Goals

- Add several self-cast Alteration forms with strong visual identity and mechanical tradeoffs.
- Keep runtime load low: no constant cloaks, no broad scans, no animation starts by default.
- Preserve save safety: save/restore touched morphs, hair color, temporary cosmetics, and actor value changes.
- Make integrations soft where practical: if Milk Mod Economy or Fertility Mode APIs are missing or unsafe, the base form still works.
- Let trainer/tome progression unlock stronger tiers.
- Prevent major form stacking. Only one Bodymorph Alteration form should be active at a time.

## Core Framework

Every form should follow the same runtime pattern:

```text
OnEffectStart:
  verify target is player
  dispel other bodymorph forms
  read current form tier
  save touched morphs/appearance
  apply morph preset
  apply hair/cosmetic overlays
  apply actor value changes
  apply form-specific restrictions
  start slow update pulse if needed

OnUpdate:
  enforce equipment/restriction rules
  run low-frequency form effect, if any
  register next update

OnEffectFinish:
  stop updates
  restore saved morphs/appearance
  remove temporary cosmetics/items
  restore actor value changes
  synchronize SlaveTats if cosmetics changed
```

Shared state:

```text
cfl_BodymorphActiveForm: global or quest variable
0 = none
1 = Dollform
2 = Horseform
3 = Cowform
4 = Rabbitform
```

If a new form starts while another form is active, the old form should be dispelled first. Avoid trying to merge morph presets.

## Current Dollform Baseline

Dollform is already implemented and should become the reference form.

Current duration:

```text
420 seconds / 7 minutes
```

Current tier progression:

```text
Tier 1: Porcelain Lines
Tier 2: Joint Seals
Tier 3: Display Sigil
Tier 4: Perfect Doll Brand
```

Current mechanics:

```text
Morphs: breasts, butt, hips, thighs, waist, arms, muscle sliders, nipples/areola at tier 1+
Stats: armor/speech up, speed/magicka regen/melee down
Cosmetics: pink hair, blush, nail polish, tier 1+ mascara
Aura: low-frequency enemy stagger/distract/arousal pulse
Restrictions: torso clothing at tier 1+, head/hands/feet at tier 3+
```

Known follow-up:

- Add a cleanup/debug power to remove temporary Dollform cosmetics and reset hair/morphs if a previous version left stale state.
- Consider renaming the add-on later if it grows beyond Dollform.

## Form 1: Horseform

Theme: powerful lower body, speed, stamina, carry strength, but hands become useless.

Base gameplay:

```text
SpeedMult: large bonus
Stamina: large bonus
StaminaRateMult: bonus
CarryWeight: bonus
MeleeDamage or UnarmedDamage: modest bonus
MagickaRateMult: penalty
Weapon/spell usability: restricted
```

Morph direction:

```text
Thighs: very large increase
MuscleLegs: large increase
Butt: moderate increase
Hips: moderate increase
Waist: slight decrease
Breasts: neutral or slight decrease
Arms: slight decrease
```

Suggested tier scaling:

```text
Tier 1:
  +20 SpeedMult
  +50 Stamina
  +25 StaminaRateMult
  unequip weapons on pulse

Tier 2:
  stronger leg/butt morphs
  +30 SpeedMult
  +75 Stamina
  +50 CarryWeight
  unequip weapons and shields

Tier 3:
  +40 SpeedMult
  +100 Stamina
  +100 CarryWeight
  block weapons/shields/gloves/boots while active

Tier 4:
  +50 SpeedMult
  +150 Stamina
  +150 CarryWeight
  stronger unarmed bonus
  severe hand-use restriction
```

Restrictions:

- Slow pulse every 5-6 seconds.
- Unequip right-hand weapon, left-hand weapon, and shield.
- Optionally block gloves/boots at higher tiers.
- Do not constantly poll every frame.

Visual ideas:

- Brown/black/blonde hair color variants.
- Hoof/leg tattoos if suitable assets exist.
- Horse ears/tail only if installed assets can be found and equipped safely.

Implementation status:

Horseform v1 is implemented.

## Form 2: Cowform

Theme: heavy dairy transformation. Strong chest morphs, slower movement, durability, and Milk Mod Economy synergy.

Base gameplay:

```text
Breasts: very large increase
NippleSize: increase
AreolaSize: increase
Belly: moderate increase
Butt/Hips: moderate increase
SpeedMult: penalty
DamageResist: bonus
Health: bonus
StaminaRateMult: mild penalty
```

Suggested tier scaling:

```text
Tier 1:
  breast/nipple morphs
  small armor/health bonus
  small speed penalty

Tier 2:
  stronger breast/belly morphs
  cow spot overlay
  Milk Mod soft integration starts

Tier 3:
  torso clothing restriction
  high milk production multiplier
  stronger durability
  larger movement penalty

Tier 4:
  extreme dairy form
  strongest milk production
  torso/hands/feet restrictions
  major speed penalty
```

Milk Mod Economy integration:

Implemented in Cowform v1:

- Looks up `MME_MilkQUEST` with `Game.GetFormFromFile(0x00E209, "MilkModNEW.esp")`.
- Calls `AssignSlot` if the player is not already a milkmaid or milkslave.
- Pulses `MME_Storage.changeMilkCurrent` every 30 seconds with max enforcement.
- Adds small lactacid pulses at tier 2+.
- Calls `CurrentSize` after each pulse so MME refreshes its body state.
- Does not remove milkmaid status on fade because MME registration is persistent progression state.

Visual ideas:

- Cow spot SlaveTats overlay.
- White/black or pale cream hair color.
- Horns if a safe equipped item or asset exists.
- Bell/collar optional, but avoid Devious Devices dependency in v1.

## Form 3: Rabbitform

Theme: fast, fragile, fertile. Strong mobility and fertility output with low health/defense.

Base gameplay:

```text
SpeedMult: large bonus
StaminaRateMult: bonus
Health: penalty
DamageResist: penalty
Sneak: bonus
Hips/Butt/Thighs: increased
Breasts: small/moderate increase
```

Suggested tier scaling:

```text
Tier 1:
  small hips/butt/thigh morphs
  +20 SpeedMult
  -25 Health

Tier 2:
  stronger speed/stamina
  fertility integration starts
  stronger fragility

Tier 3:
  large fertility multiplier
  larger hip/butt morphs
  low armor/health

Tier 4:
  extreme fertility form
  strongest speed
  severe health/defense penalty
```

Fertility Mode integration:

Needs inspection before implementation. Preferred approach:

- Read Fertility Mode source scripts.
- Find safe APIs or globals for fertility chance, ovulation/fertile window, gem/offspring output.
- Prefer temporary multipliers while active.
- Avoid direct cycle rewrites unless the mod API clearly supports it.

Safe fallback if Fertility Mode API is unclear:

- Rabbitform still applies morphs/stats/cosmetics.
- Add no fertility state changes until the API is understood.

Visual ideas:

- Pink/white hair.
- Blush/nail cosmetics.
- Rabbit ears/tail if safe assets exist.
- Lightweight arousal pulse optional.

## Trainer and Tome Progression

Current Dollform uses CID-distributed spell tomes. Reuse this pattern for other forms unless custom dialogue is later worth the record complexity.

Suggested distribution:

```text
Tier 1:
  broad spell vendors and relevant trainers

Tier 2:
  relevant trainers and stronger court/College mages

Tier 3:
  specialist trainers

Tier 4:
  one master trainer or a small set of master-tier sources
```

Trainer flavor:

```text
Dollform: Tolfdir and Alteration trainers
Horseform: stamina/combat trainers plus Alteration trainers
Cowform: Alteration trainers plus MME-adjacent acquisition later
Rabbitform: Alteration trainers plus fertility-themed acquisition later
```

## Planned Hybrid Progression Gates

Current implemented progression is active-use time: each form increments a use-seconds global while active and tiers up when the threshold is reached.

Keep active time as the baseline so every form can progress reliably without hard external dependencies. Later progression should add one themed secondary gate per tier, checked alongside the time threshold. The goal is to make tiering feel earned without making saves brittle if an optional integration is missing.

Suggested structure:

```text
Tier 1:
  active-use time only

Tier 2:
  active-use time plus one easy form-themed action

Tier 3:
  active-use time plus a stronger form-themed action or integration event

Tier 4:
  active-use time plus a master condition, preferably tied to the form's identity
```

Per-form gate ideas:

```text
Dollform:
  public exposure time
  successful speech checks or persuasion-style interactions while transformed
  enemy aura stagger/distract/arousal procs

Horseform:
  sprint distance or time spent sprinting
  stamina spent/recovered while transformed
  carrying heavy load or wearing heavy restraints
  optional Fill Her Up / SexLab horse semen condition if a reliable API/global is found

Cowform:
  milk produced through Milk Mod Economy while transformed
  lactacid gained while transformed
  number of milking events
  supplying Tolfdir or another trainer with bottles of the player's milk

Rabbitform:
  sprint/jump activity while transformed
  time spent in fertile window, if Fertility Mode exposes a safe API
  pregnancy/gem/output events, if reliably detectable
  fragile survival condition such as spending time in combat without armor
```

Implementation notes:

- Store secondary counters in new globals or a small quest script, not in local active-effect variables.
- Keep each gate optional or fallback-safe when it depends on another mod.
- Show gate progress in the MCM diagnostics/status page before enforcing it.
- Add debug controls to reset secondary counters.
- Do not poll external mods every frame; update on the existing 5-6 second form pulse or on explicit events.

## Mod Integration Strategy

Do not hard require extra mods unless absolutely necessary.

Recommended structure:

```text
cfl_BodymorphFormEffect.psc
  shared save/restore helpers

cfl_DollformEffect.psc
  Dollform-specific behavior

cfl_HorseformEffect.psc
  Horseform-specific behavior

cfl_CowformEffect.psc
  Cowform-specific behavior

cfl_RabbitformEffect.psc
  Rabbitform-specific behavior

cfl_MMEAdapter.psc
  optional Milk Mod calls

cfl_FertilityAdapter.psc
  optional Fertility Mode calls
```

Adapters should:

- Use `Game.GetFormFromFile` or optional script casts carefully.
- Fail silently if the target mod is absent.
- Avoid adding compile stubs to the packaged mod.

## Safety Rules

- Never reset all morphs globally. Save/restore only the exact morphs touched by the active form.
- Never run broad actor scans every frame.
- Keep update pulses at 5-10 seconds unless there is a strong reason.
- Do not auto-reequip gear by default.
- Cosmetics must be Dollform/Bodymorph-owned aliases so cleanup does not remove the player's normal tattoos.
- Call `SlaveTats.synchronize_tattoos` after applying/removing temporary overlays.
- Hair color must save from actor base or a known stable prior color, then restore on finish.
- Add a debug cleanup power before adding several more forms.

## Suggested Implementation Phases

### Phase 1: Stabilize Framework

- Add shared active-form global.
- Add a debug cleanup power:
  - remove temporary Bodymorph cosmetics;
  - restore hair color to actor base;
  - clear active-form global;
  - optionally reset only known Bodymorph morph keys.
- Make Dollform respect the active-form global.

### Phase 2: Horseform

- Status: implemented as v1.
- Added Horseform spell, four initiation tiers, four tomes, and CID distribution.
- Added morph/stat/restriction script.
- No external mod integration.
- Weapons/shields are unequipped on slow pulse by tier.

### Phase 3: Cowform Base

- Status: implemented as v1.
- Added Cowform spell, four initiation tiers, four tomes, and CID distribution.
- Added morph/stat/cosmetic behavior.
- Added temporary cow cosmetics and cream hair color.

### Phase 4: Milk Mod Integration

- Status: implemented as direct Cowform v1 hooks.
- Inspected MME scripts and found stable `MilkQUEST` and `MME_Storage` calls.
- Used compile-only stubs instead of the full MME source tree.
- Added bounded milk/lactacid pulses while Cowform is active.

### Phase 5: Rabbitform Base

- Add Rabbitform spell, tiers, tomes.
- Add morph/stat/cosmetic behavior.
- No Fertility Mode integration yet.

### Phase 6: Fertility Integration

- Inspect Fertility Mode scripts.
- Implement `cfl_FertilityAdapter.psc`.
- Add temporary fertility multipliers/output behavior only after API is confirmed.

## First Pick

Recommended next implementation target: `Rabbitform`.

Reason:

- Horseform and Cowform now cover the non-integration and Milk Mod integration cases.
- Rabbitform is the next integration pattern to test against Fertility Mode.
- Fertility should be inspected before touching cycle or output state.
