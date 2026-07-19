# Feral - Bodymorph Alterations add-on

Feral turns hunting into a transformation progression. Personally kill a supported creature, claim its essence, and build permanent family ranks. Ranks unlock and strengthen temporary animal transformations; combat bonuses now exist only while transformed.

## Requirements

Skyrim SE/AE, SKSE, SkyUI, PapyrusUtil, powerofthree's Papyrus Extender, Experience, RaceMenu/NiOverride, SlaveTats NG, and Bodymorph Alterations (`Dollform.esp`). Load `Feral.esp` after `Dollform.esp`.

## Hunting and progression

1. Enable Feral hunting in the **Feral** MCM.
2. Personally kill a supported wolf, sabre cat, bear, skeever, spider, mudcrab, horse, or troll.
3. Cast **Claim Soul** before the trail expires. The default window is 180 real seconds and can be set from 60–300 seconds in the MCM.
4. Ranks unlock at 3, 10, and 25 claims.

At rank 1, the matching **Feral Shape** lesser power is learned. Rank 2 replaces it with a stronger version; rank 3 replaces it with the full expression. Only one transformation system can be active at once, including Bodymorph Alterations forms. Use **Return to Self** or the MCM cleanup action to end a Feral shape early.

| Shape | Rank-3 benefit while transformed | Visual direction |
|---|---|---|
| Wolf | +15 SpeedMult, +25 StaminaRateMult | Lean athletic legs and gray pelt mark |
| Sabre Cat | +15 Sneak, +15 UnarmedDamage | Lithe feline body and tawny stripes |
| Bear | +80 DamageResist, +40 Health | Broad heavy muscle and bear mantle |
| Skeever | +50 PoisonResist, +50 DiseaseResist | Compact wiry body and mottled mark |
| Spider | +75 PoisonResist | Narrow waist, expanded hips, chitin mark |
| Mudcrab | +65 DamageResist | Squat broad body and carapace mark |
| Horse | +20 SpeedMult, +60 Stamina | Powerful lower body and stride mark |
| Troll | +2 HealRate, -35 FireResist | Large arms/shoulders and gray-hide mark |

Rank 1 applies 50% of the listed benefit and morph intensity; rank 2 applies 75%; rank 3 applies 100%. Shapes last 120 seconds. The spell and Active Effects descriptions identify the current rank and values.

## MCM

- **Status:** hunting/Feral Path state, live claim window, active transformation, and all family totals.
- **Instincts:** cycle through a family to see rank, next threshold, learned power, current combat effect, and body expression.
- **Settings:** claim-window slider, repair/cleanup actions, Experience restoration, race-config reload, and developer tools.

The MCM repair action rebuilds transformation powers from saved ranks. Developer tools can set the selected test family to 2, 9, or 24 claims and simulate the next claim.

## Feral Path

Feral Path is optional and disabled by default. While active it suppresses ordinary Experience rewards without modifying the global Experience INI. Successful claims grant native character XP: 25 for wolf/skeever/mudcrab, 35 for sabre cat/spider, and 50 for bear/horse/troll. Disabling Feral Path restores the exact captured Experience settings.

## Custom creature races

Official Skyrim, Dawnguard, and Dragonborn variants are built in. Add modded races through `SKSE\Plugins\Feral\Races.json`; each family uses parallel `Plugins` and decimal plugin-local `FormIDs` arrays.

## Save migration and visual roadmap

Version 4 preserves all claim totals and ranks, removes legacy permanent passive bonuses and the generic Feral Act, then grants the correct transformation powers. The old quest and magic records remain inert for save compatibility.

The current visual stage includes distinct body morphs and temporary family markings for all eight shapes. Dedicated custom ears, tails, claws, hooves, shell/pincers, and spider appendages remain a staged family-by-family asset upgrade; no unrelated installed assets are redistributed.
