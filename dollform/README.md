# Dollform

Standalone MO2 add-on for a self-cast NSFW Alteration transformation.

## Files

- `Dollform.esp`: spells, magic effects, and the tattoo tier global.
- `Scripts/cfl_DollformEffect.pex`: active Dollform runtime.
- `Scripts/cfl_DollformMarkEffect.pex`: permanent initiation mark runtime.
- `Source/Scripts/*.psc`: matching Papyrus source.
- `Textures/Actors/Character/slavetats/dollform.json`: SlaveTats metadata for the Dollform mark.
- `SKSE/Plugins/Dollform/Config.json`: notes/current tuning reference. Runtime values are currently set in the ESP/Papyrus defaults.

## How to Use

The plugin gives the player the base Dollform spell and the first initiation power as start spells/powers:

- `Dollform`: self-cast Alteration spell.
- `Dollform Initiation`: lesser power that applies the first permanent SlaveTats mark and sets the internal Dollform mark tier to 1.

Tiered initiation is also available through spell tomes distributed by `Dollform_CID.ini` to Alteration trainer and spell vendor chests.

Trainer/vendor tome distribution:

```text
Tier 1: Tolfdir, Dravynea, Wylandriah, Farengar, Calcelmo/Markarth wizard chest, Wuunferth, Sybille, Falion, Madena
Tier 2: Tolfdir, Dravynea, Wylandriah, Farengar, Markarth wizard chest
Tier 3: Tolfdir, Dravynea, Wylandriah
Tier 4: Tolfdir
```

The tomes teach:

```text
Dollform Initiation 1: Porcelain Lines
Dollform Initiation 2: Joint Seals
Dollform Initiation 3: Display Sigil
Dollform Initiation 4: Perfect Doll Brand
```

Horseform is also implemented as the first Bodymorph Alteration expansion. It has the same four-tier tome pattern:

```text
Horseform Initiation 1: Strong Legs
Horseform Initiation 2: Burdened Hands
Horseform Initiation 3: Hoofbound Stride
Horseform Initiation 4: Perfect Courser
```

Horseform tome distribution:

```text
Tier 1: Tolfdir, Dravynea, Wylandriah, Farengar, Eorlund, Solitude Fletcher, Markarth wizard chest
Tier 2: Tolfdir, Dravynea, Wylandriah, Eorlund
Tier 3: Tolfdir, Dravynea, Wylandriah
Tier 4: Tolfdir
```

Cowform is implemented as the second Bodymorph Alteration expansion. It has the same four-tier tome pattern:

```text
Cowform Initiation 1: First Letdown
Cowform Initiation 2: Full Udder
Cowform Initiation 3: Barn Brand
Cowform Initiation 4: Perfect Dairy Cow
```

Cowform tome distribution:

```text
Tier 1: Tolfdir, Dravynea, Wylandriah, Farengar, Arcadia, Angeline, Markarth wizard chest
Tier 2: Tolfdir, Dravynea, Wylandriah, Arcadia
Tier 3: Tolfdir, Dravynea, Wylandriah
Tier 4: Tolfdir
```

## Duration and Magicka

- `Dollform`, `Horseform`, and `Cowform` last 420 seconds, or 7 minutes.
- The ESP base cost is 140 magicka.
- It does not continuously drain magicka after casting.
- While active, it reduces magicka regeneration by `15 + tier * 4`.

At current progression:

- Tier 0: `-15` magicka regen multiplier.
- Tier 1, after initiation: `-19` magicka regen multiplier.

## Body Morphs

Dollform saves the current RaceMenu/NiOverride morph values it touches, applies temporary changes, then restores those saved values when the effect ends. It does not reset every morph to zero.

Morph scale is:

```text
1.00 at tier 0
+0.18 per mark tier
```

Current tier 0 changes:

```text
Breasts: +0.50
Butt: +0.35
Hips: +0.25
Thighs: +0.20
Waist: -0.25
Arms: -0.12
MuscleAbs: -0.40
MuscleArms: -0.35
MuscleLegs: -0.25
```

At tier 1, those are multiplied by 1.18, and these are also applied:

```text
NippleSize: +0.12 * scale
AreolaSize: +0.10 * scale
```

All changed morphs are clamped between `-2.0` and `3.0`.

## Temporary Cosmetics

Dollform applies temporary SlaveTats cosmetics when the spell starts and removes those exact Dollform-owned cosmetic entries when the spell ends. Before applying, it also removes any leftover entries with the same Dollform cosmetic names so repeated casts do not stack duplicates. The script calls `SlaveTats.synchronize_tattoos` after both apply and remove so the overlay state is pushed immediately.

It also changes the player's hair color while active using `PO3_SKSEFunctions.GetHairColor` / `SetHairColor`, the same live-actor style of approach used by mods that rely on powerofthree's Papyrus Extender for appearance changes. The previous hair color is saved on cast and restored when Dollform ends.

Current hair color:

```text
Record: cfl_DollformPorcelainPinkHair
RGB: 255, 182, 216
Hex-style color: #FFB6D8
```

Current cosmetics:

```text
Doll Blush
Section: Dollform Cosmetics
Area: Face
Texture: DoMBlush\blush_cheeks_1.dds
Color: light pink
Alpha: 0.55

Doll Hand Polish
Section: Dollform Cosmetics
Area: Hands
Texture: makeup\both_hands_nails.dds
Color: pink
Alpha: 0.85

Doll Foot Polish
Section: Dollform Cosmetics
Area: Feet
Texture: makeup\both_feet_nails.dds
Color: pink
Alpha: 0.85

Doll Mascara
Section: Dollform Cosmetics
Area: Face
Texture: makeup\right_cheek_tears.dds
Color: dark plum
Alpha: 0.40
Tier: 1+
```

The cosmetic entries are declared in this mod's `slavetats/dollform.json`, but they reuse texture assets already present in the active modlist from Apropos2 and Diary of Mine.

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
scale = 1.0 + tier * 0.22
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
  Horse Hand Mark
  Horse Hoof Tint
  Horse Body Mark at tier 2+
  Horse Stride Mark at tier 3+
```

Like Dollform cosmetics, Horseform temporary cosmetics are removed on fade and synchronized through SlaveTats.

## Cowform

`Cowform` is a 420 second self-cast Alteration spell focused on breasts, endurance, slower movement, and Milk Mod Economy synergy. It uses the shared bodymorph active-form lockout, so it cannot be cast while Dollform, Horseform, or another bodymorph form is active.

Morph scale:

```text
scale = 1.0 + tier * 0.25
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
  Cow Body Spots
  Cow Udder Mark
  Cow Face Mark at tier 1+
  Cow Hand Mark at tier 2+
  Cow Hoof Tint at tier 2+
  Cow Heavy Spots at tier 3+
```

Like the other forms, Cowform temporary cosmetics are removed on fade and synchronized through SlaveTats.
Cow horns are added silently only if the player does not already have the item, equipped while Cowform is active, and removed on fade only if Cowform added them.

## Clothing Restrictions

Dollform checks clothing on start and every 6 seconds while active.

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

## SlaveTats Mark

Initiation applies permanent Dollform marks:

```text
Tier 1: Porcelain Lines, Body, basic\right_breast_princess.dds
Tier 2: Joint Seals, Hands, basic\left_hand_slave.dds
Tier 3: Display Sigil, Body, basic\belly_slave_zqzqz.dds
Tier 4: Perfect Doll Brand, Face, basic\forehead_slave.dds
```

The tattoos are permanent until removed through SlaveTats or a future removal/debug feature. The tattoos themselves run no scripts. The active Dollform spell reads the internal tier global when cast.

## Current Limitations

- No Alteration trainer dialogue yet.
- Trainer access is currently done through spell tomes in trainer/vendor inventories, not custom dialogue topics.
- Four Dollform tattoo tiers, four Horseform tattoo tiers, and four Cowform tattoo tiers are implemented.
- No custom tattoo DDS art yet; it reuses an existing SlaveTats texture.
- Nail color, blush, and tier-1 mascara are implemented as temporary SlaveTats cosmetics.
- Hair color is implemented as a temporary po3 Papyrus Extender color swap.
- No lip color or eye color changes yet.
- No MCM yet.
- No SexLab animation starts yet.
- Active-form lockout currently blocks casting a second bodymorph form while one is active. It does not automatically dispel the old form yet.
- `Config.json` documents tuning but is not currently read by the script.

## Expansion Ideas

Good next additions:

- Trainer dialogue for Alteration trainers that applies mark tiers.
- More tattoo tiers with stronger Dollform effects and stronger clothing restrictions.
- Custom doll sigil SlaveTats textures.
- Custom cow spot DDS assets instead of reused generic SlaveTats textures.
- An optional debug spell to unregister Cowform-created milkmaid status, gated behind a confirmation.
- Optional SlaveTats overlays for lip color, blush, eyeliner, nail polish, and glossy doll joints.
- Hair color shift through RaceMenu/NiOverride if the installed API supports a stable color override path.
- Sustained magicka drain or periodic magicka damage while Dollform is active.
- Optional out-of-combat masturbation proc, gated behind a long cooldown and only when SexLab is idle enough to start an animation safely.
- MCM or JSON-backed tuning for aura radius, cooldowns, morph strength, and clothing rules.
