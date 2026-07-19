# Feral - Bodymorph Alterations add-on

Feral v7 turns hunting and transformation use into eight long-form mastery paths. Personally kill supported creatures to absorb their essence automatically, then spend time in the unlocked shape to deepen it from mastery level 1 to 100. Combat bonuses exist only while transformed.

## Requirements

Skyrim SE/AE, SKSE, SkyUI, PapyrusUtil, powerofthree's Papyrus Extender, Experience, RaceMenu/NiOverride, SlaveTats NG, and Bodymorph Alterations (`Dollform.esp`). Load `Feral.esp` after `Dollform.esp`.

Install the complete **Feral - Bodymorph Addon** folder as one MO2 mod; do not install only the ESP. On an existing save, wait for SkyUI registration before opening Mod Configuration. Feral normally registers automatically. If **Feral** alone is missing after a minute, run `setstage SKI_ConfigManagerInstance 1` once in the console, close the menus, and wait for SkyUI's registration notification. A large red `Total MCM` number is the number of registered menus, not by itself a Feral error.

## Hunting and mastery

1. Enable Feral hunting in the **Feral** MCM.
2. Personally kill any supported wolf, sabre cat, bear, skeever, spider, mudcrab, deer/stag, or troll.
3. The matching essence is absorbed immediately. There is no Claim Soul cast, expiration window, corpse queue, or retained corpse reference.
4. Hunting grants family mastery according to rarity. While transformed, every completed 10 seconds grants another mastery point, capped at 12 per 120-second cast.
5. Every family has mastery levels 1-100. The cost of the next level is `5 + ceil(current level × 0.45)`, rising from 5 points to 50; reaching level 100 takes 2,775 total mastery points.

| Family | Mastery per harvest | Feral Path character XP | Full-expression transformed benefits |
|---|---:|---:|---|
| Wolf | 10 | 30 | +12% speed, +35% stamina regeneration, +15 unarmed damage |
| Sabre Cat | 18 | 45 | +25 Sneak, +25 unarmed damage, +10% attack speed |
| Bear | 28 | 70 | +100 armor, +50 Health, +25 stagger resistance |
| Skeever | 10 | 30 | +60% poison/disease resistance, +20 Sneak, +30 carry weight |
| Spider | 10 | 30 | +80% poison resistance, +30 unarmed damage, +15% speed |
| Mudcrab | 10 | 30 | +140 armor, +20 Block, +30 stagger resistance, -8% speed |
| Stag | 18 | 45 | +15% speed, +80 Stamina, +20 Archery |
| Troll | 28 | 70 | +2 Health regeneration, +25 melee damage, +60 Health, -40% fire resistance, -8% speed |

One common-family path takes about 278 harvests if trained only through hunting; uncommon paths take about 155 and rare paths about 100. Actual totals are lower when the shape is used. Shapes last 120 seconds, followed by 15 seconds of fatigue. **Return to Self** ends a shape early. Feral and Bodymorph Alterations share one transformation lock and cannot overwrite each other.

## Visual progression

Every family has a default 10-12 slider silhouette, a detailed 2K SlaveTats body marking, a transformation shader, sound, and camera pulse. There are no visual stage boundaries: body proportions, combat effects, and marking opacity all grow at every mastery level. Expression begins at 25% on level 1 and increases linearly to 100% at level 100. Each family uses one transformation power from level 1 onward, leaving later milestone levels available for genuinely new powers instead of replacement copies of the same morph.

| Family | Default silhouette at full expression | Marking |
|---|---|---|
| Wolf | Muscular thighs, calves, and rear; narrower waist; modest shoulders | Blue-gray directional pelt |
| Sabre Cat | Fuller thighs, hips, and rear; strongly narrowed waist; lighter arms | Tawny horizontal stripes |
| Bear | Very large muscular arms and shoulders; thick legs, waist, and torso | Dark brown heavy-fur mantle |
| Skeever | Small wiry arms, shoulders, thighs, waist, and rear; slightly stronger calves | Gray-brown scarred mottle |
| Spider | Very narrow waist; broad hips and rear; moderately stronger arms | Dark plum chitin webbing |
| Mudcrab | Broad shoulders, arms, waist, hips, thighs, and calves | Rust-orange carapace plates |
| Stag | Powerful muscular thighs and calves; athletic rear; narrow waist and lighter arms | Warm brown dappling |
| Troll | Largest arms and shoulders; strong abs and legs; thick waist and torso | Gray-green rough hide |

The source atlas shows the intended creature identities:

![Feral source pattern atlas](assets/FeralPatternAtlas-v5.png)

This transparency contact sheet shows the three source densities retained for save compatibility and art comparison. Normal v7 transformations use the most detailed texture and scale its opacity continuously. This is a flat UV/art preview, not an in-game body screenshot; checkerboard areas are transparent:

![Feral marking stages](assets/FeralMarkingStages-v5.png)

Actual proportions depend on the installed RaceMenu/3BA slider set and the player's preset. The current markings are pre-release art and still require front/side/back in-game screenshots to judge seams, stretching, and body coverage honestly. Discrete horns, ears, tails, and similar armor cosmetics are no longer attached to visual stages; they are reserved for future milestone powers because Skyrim cannot continuously scale ordinary equipped armor.

## MCM and Experience

- **Status:** automatic harvesting, fatigue, XP mode, active expression, and harvest/mastery totals for all eight families.
- **Instincts:** level progress, continuous expression and marking opacity, harvest value, shape-use rate, exact combat kit, morph direction, and future-power status.
- **Settings:** repair/cleanup, config reload, Experience restoration, and developer mastery milestones.

Feral Path has three modes:

- **Off:** ordinary Experience behavior.
- **Balanced:** automatic harvests award 30/45/70 XP by rarity; quest, discovery, and clearing XP remain, while normal kill and skill XP are suppressed.
- **Hardcore:** only Feral harvest and shape-use XP remains.

The exact prior Experience settings are snapshotted and restored when the path is disabled. Shape use grants one character XP per mastery point—up to 12 XP for a full cast—when either Feral Path mode is active.

## Activity and adult-mod integrations

Feral exposes `AddActivityMastery(family, points, source)` on its controller for small optional adapters. The installed **Sex Grants Experience** mod continues to control ordinary sex-scene character XP; Feral does not currently intercept it or grant family mastery from scenes. A correct future adapter must inspect actual SexLab participants, require the player to be in the matching Feral shape, and map the creature actor's race to that same family. The common Sex Grants Experience API exposes only a `hasCreature` flag, which is not enough to award the correct path safely.

## Human fear and hunting

There is not yet a human fear or hunter-response system. It should not be implemented as a cloak, frequent nearby-actor scan, or repeated relationship update. The planned low-overhead design is a persistent notoriety value updated only when mastery changes, dialogue/AI conditions that read it when already evaluating an NPC, and discrete Story Manager hunter encounters at high thresholds. This remains design work rather than a claimed feature.

## Runtime cost

- One `OnActorKilled` event listener; non-player kills and disabled state return before any race or JSON matching.
- No polling loop, corpse queue, claim-window scan, or stored corpse references.
- Shape-use mastery is calculated once from the active effect's elapsed time when it finishes; it does not tick every ten seconds.
- RaceMenu morph rebuilding and SlaveTats synchronization occur only on transformation entry and exit.
- No NPC fear scans or background faction processing are active.

## Save compatibility and custom content

Version 7 preserves all historical harvest counts and mastery, converts family slot 7 Horse progress into Stag progress on older saves, removes Claim Soul, clears old pending-corpse references, replaces staged powers with one continuously scaling power per family, and keeps legacy records inert for save compatibility. Custom races belong in `SKSE\Plugins\Feral\Races.json`. The existing cosmetic configuration is retained as future adapter data but is not automatically equipped by the base shape.

## Transformation safety

Feral owns only the `Feral.Shapes` and `Feral.Shapes.Visible` RaceMenu keys. A per-cast ownership token is stored in the shared Bodymorph lock, so an old effect finishing late cannot clear a newer transformation. Normal expiration and **Return to Self** both use the active effect's single cleanup path: statistics are reversed once, Feral morph keys and the active tattoo are cleared, the model is refreshed once, owned cosmetics are restored, and then the lock is released. The MCM cleanup action performs broad recovery only when no live Feral effect can be dispelled.
