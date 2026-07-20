# Feral

Feral v13 turns hunting and transformation use into eight long-form mastery paths. Personally kill supported creatures to absorb their essence automatically, then spend time in the unlocked shape to deepen it from mastery level 1 to 100. Permanent family instincts, increasingly long transformations, continuous visuals, milestone traits, family techniques, creature kinship, and human notoriety make broad mastery increasingly valuable and consequential. The MO2 package is named **Feral - Bodymorph Addon**.

## Requirements

Skyrim SE/AE, SKSE, SkyUI, PapyrusUtil, powerofthree's Papyrus Extender, Experience, RaceMenu/NiOverride, SlaveTats NG, and Bodymorph Alterations (`Dollform.esp`). Load `Feral.esp` after `Dollform.esp`.

Install the complete **Feral - Bodymorph Addon** folder as one MO2 mod; do not install only the ESP. On an existing save, wait for SkyUI registration before opening Mod Configuration. Feral v13 rebuilds its six-page navigation whenever the MCM opens, so upgrading does not require a console command. If **Feral itself** is absent after a minute, `setstage SKI_ConfigManagerInstance 1` remains a one-time SkyUI registry fallback. A large red `Total MCM` number is the number of registered menus, not by itself a Feral error.

## Hunting and mastery

1. Enable Feral hunting in the **Feral** MCM.
2. Personally kill any supported wolf, sabre cat, bear, skeever, spider, mudcrab, deer/stag, or troll.
3. The matching essence is absorbed immediately. There is no Claim soul cast, expiration window, corpse queue, or retained corpse reference.
4. Hunting grants family mastery according to rarity. While transformed, every completed 10 seconds grants another mastery point, up to 120 for a full level-100 transformation.
5. Every family has mastery levels 1-100. The cost of the next level is `5 + ceil(current level × 0.45)`, rising from 5 points to 50; reaching level 100 takes 2,775 total mastery points.

| Family | Mastery per harvest | Feral Path character XP | Full-expression transformed benefits | Drawback |
|---|---:|---:|---|---|
| Wolf | 10 | 30 | +12% speed, +35% stamina regeneration, +15 unarmed damage | -15% magic resistance |
| Sabre Cat | 18 | 45 | +25 sneak, +25 unarmed damage, +10% attack speed | -25 health |
| Bear | 28 | 70 | +100 armor, +50 health, +25 stagger resistance | -20 sneak |
| Skeever | 10 | 30 | +60% poison/disease resistance, +20 sneak, +30 carry weight | -15% fire resistance |
| Spider | 10 | 30 | +80% poison resistance, +30 unarmed damage, +15% speed | -20% stamina regeneration |
| Mudcrab | 10 | 30 | +140 armor, +20 block, +30 stagger resistance | -8% speed |
| Stag | 18 | 45 | +15% speed, +80 stamina, +20 archery | -20 armor |
| Troll | 28 | 70 | +2 health regeneration, +25 melee damage, +60 health | -40% fire resistance, -8% speed |

One common-family path takes about 278 harvests if trained only through hunting; uncommon paths take about 155 and rare paths about 100. Actual totals are lower when the shape is used. Shape duration increases at mastery 1/25/50/75/100 through 2/5/10/15/20 minutes, followed by 15 seconds of fatigue. **Casting the same shape again ends it early.** Feral and Bodymorph Alterations share one transformation lock and cannot overwrite each other.

## Mastery milestones

Every path gains a permanent passive rank at levels 25, 50, and 75. Only its highest earned rank is applied, but passives earned from different families coexist and remain active outside transformations while Feral is enabled. These deliberately small legacy-derived bonuses stack with the stronger temporary shape kit. Every path also gains a shape-only trait at levels 25 and 75, one selectable family technique at level 50, and—except for the currently incomplete Spider apex—a stronger version of that technique at level 100.

The level-25 and level-75 traits below are temporary actor-value changes applied when the matching shape begins; they do not apply in human form and are removed when the shape ends. Techniques are lesser powers, require the matching active shape, use an independent 60-second real-time cooldown, and normally last 20 seconds where they provide a timed stat buff. Projectile, howl, invisibility, and slow-time behavior comes from the listed vanilla spell cast by the technique.

| Family | Level 25 shape trait | Level 50 technique | Level 75 shape trait | Level 100 apex |
|---|---|---|---|---|
| Wolf | **Tireless hunt:** +20% stamina regeneration | **Dread howl:** casts vanilla howl `000CF791` | **Blood scent:** +75 Detect Life Range; this changes the actor value but does not itself grant a Detect Life spell | Casts the stronger vanilla howl `000CF793` |
| Sabre Cat | **Soft step:** applies `-50.0` to `MovementNoiseMult`; this is probably mis-scaled (a 50% multiplier change would conventionally be `-0.5`) | **Vanish and pounce:** casts vanilla invisibility `00027EB6` and gives +25% attack damage for 20 seconds | **Ambush:** +25% attack damage | Technique attack damage increases to +50% |
| Bear | **Thick hide:** +50 armor | **Maul:** +50 unarmed damage and +50 stagger resistance for 20 seconds | **Unstoppable:** +100 stagger resistance | Technique increases to +80 unarmed damage and +100 stagger resistance |
| Skeever | **Filthborn:** +100% disease resistance | **Plague spit:** casts vanilla poison projectile `0004CCF9` | **Escape artist:** +20 Sneak and +10% movement speed | Casts the stronger vanilla poison projectile `0004CCFA` |
| Spider | **Venomous:** +10 unarmed damage and +20% poison resistance | **Web snare:** casts vanilla paralysis projectile `0005AD5F` | **Chitin reflex:** +15% magic resistance | **Not separately implemented:** currently casts the same `0005AD5F` spell as level 50, with no stronger effect |
| Mudcrab | **Arrow-shell:** +50 armor | **Fortress:** +300 armor and +50 Block, but -40% movement speed, for 20 seconds | **Counterclaw:** +20 Block and +20 stagger resistance | Technique becomes +500 armor, +75 Block, +25% magic resistance, and -30% movement speed |
| Stag | **Surefooted:** +25% stamina regeneration and 50% less fall damage | **Stampede:** +40% movement speed, +200% stamina regeneration, and +25 Archery for 20 seconds | **Keen flight:** +20 Archery | Technique increases to +60% movement speed, +300% stamina regeneration, and +40 Archery, and casts vanilla Slow Time `00048AD0` |
| Troll | **Mending flesh:** +1 health regeneration | **Monstrous regeneration:** +8 health regeneration and -50% fire resistance for 20 seconds | **Cornered monster:** +50 armor and +25 melee damage | Technique increases to +15 health regeneration and -75% fire resistance |

This table describes the current source and generated plugin wiring, not completed in-game balance validation. Spider's level-100 upgrade is a confirmed implementation gap. Sabre Cat's level-25 movement-noise value is probably mis-scaled. Wolf's level-75 trait only changes `DetectLifeRange`; whether that alone produces useful detection still needs an in-game test.

## Visual progression

Every family has a default 10-12 slider silhouette, a detailed 2K SlaveTats body marking that continues onto the feet and hands and fades out at the neckline, a transformation shader, sound, and camera pulse. There are no visual stage boundaries: body proportions, combat effects, and marking opacity all grow at every mastery level. Expression begins at 25% on level 1 and increases linearly to 100% at level 100. Duration-specific power variants preserve native Skyrim timers but all variants use the same continuously scaled morph and combat formulas.

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

This transparency contact sheet shows the three source densities retained for save compatibility and art comparison. Normal v13 transformations use the most detailed texture and scale its opacity continuously. This is a flat UV/art preview, not an in-game body screenshot; checkerboard areas are transparent:

![Feral marking stages](assets/FeralMarkingStages-v5.png)

Actual proportions depend on the installed RaceMenu/3BA slider set and the player's preset. The current markings are pre-release art and still require front/side/back in-game screenshots to judge seams, stretching, and body coverage honestly. Discrete horns, ears, tails, and similar armor cosmetics are no longer attached to visual stages; they are reserved for future milestone powers because Skyrim cannot continuously scale ordinary equipped armor.

## MCM and Experience

- **Overview:** enablement, active shape, fatigue, focused-family progress, Feral Path mode, optional sex-integration status, and current human response.
- **Progression:** every mastery source and award, the level-cost formula, 2,775-point total, expression curve, duration and power thresholds, and exact Off/Balanced/Hardcore Experience behavior.
- **Families:** harvest count, current and next mastery, expression, permanent instinct, transformed strengths and drawback, visual direction, duration, technique, and next milestone.
- **Morphs:** friendly slider labels, selected-family intensity, reset controls, and three-decimal live values for `Feral.Shapes` and `Feral.Shapes.Visible`. Highlight a slider to see its exact BodySlide key. Changes apply on the next transformation.
- **Human response:** mode differences, notoriety gains and decay, the 20/40/60/80/100 thresholds, guard bounty, hunter chances, and cooldown.
- **Settings:** repair/cleanup, config reload, Experience restoration, and developer testing controls.

Feral Path has three modes:

- **Off:** ordinary Experience behavior.
- **Balanced:** automatic harvests award 30/45/70 XP by rarity; quest, discovery, and clearing XP remain, while normal kill and skill XP are suppressed.
- **Hardcore:** only Feral harvest and shape-use XP remains.

The exact prior Experience settings are snapshotted and restored when the path is disabled. Shape use grants one character XP per mastery point—up to 120 XP for a full level-100 cast—when either Feral Path mode is active.

## Activity and adult-mod integrations

The base Feral mod contains no sex animations, animation selection, pregnancy, fertility, body-fluid, or adult dialogue. The separately packaged **Feral - Sex Grants Experience Integration** supplies scene progression and optional SexLab creature kinship. It requires the creature animations and framework support already present in the modlist; it does not create animations.

What the integration actually does:

- When a player-involved scene begins, it snapshots the active Feral family and checks the other starting participants with Feral's race-to-family mapping.
- Any active Feral shape permits ordinary Sex Grants Experience character XP for the scene. A matching creature is not required for that XP. If no shape was active at scene start, the adapter blocks that scene's ordinary Sex Grants Experience XP.
- When the scene ends, one matching participant grants **12 mastery points** to the snapshotted family. This is one award per scene, not per creature, orgasm, animation, or elapsed interval.
- The 12-mastery award is independent of Sex Grants Experience's scoring, orgasm requirement, victim handling, solo setting, multipliers, and cooldown. Those upstream rules still govern ordinary character XP, but the current adapter does not use their result to approve or reject Feral mastery.
- The start snapshot remains valid if the shape expires or is manually ended during the scene. Conversely, transforming after the scene starts does not qualify it. Partners who join later are not checked.
- Shape-duration mastery is separate: when the shape ends, it also grants one family mastery point per completed 10 seconds spent transformed. A qualifying scene can therefore produce both elapsed-shape mastery and the one-time +12 matching-scene award.

**Wolf example:** begin a SexLab scene while the Wolf shape is active with at least one participant whose race maps to the Wolf family. When the scene ends, Wolf receives +12 mastery even if the shape expired mid-scene. A vanilla wolf (`WolfRace`, `Skyrim.esm:0001320A`) matches. Dogs, werewolves, and custom wolf-like races do not match automatically; custom races must be added to `SKSE\Plugins\Feral\Races.json`. Starting in Bear shape with a wolf partner grants no matching-family mastery, although the active Bear shape still permits ordinary Sex Grants Experience XP and earns its normal elapsed-shape mastery.

### Creature kinship and consensual approaches

With `FeralCreatureKinship.esp` enabled, mastery level 10 in a family unlocks kinship while its matching shape is active. Matching loaded creatures within 4096 units have their current aggression temporarily reduced to zero and combat stopped. Their original aggression is restored when the shape ends. If the player or a player teammate attacks a specific creature, kinship breaks for that creature until the next transformation; Feral does not permanently change factions or relationships.

After **5 seconds** in a qualifying shape, the add-on checks every 15 seconds for a matching creature within 1200 units. The creature must be alive, loaded, in line of sight, out of combat, not commanded, not a teammate, not in a scene, and valid to SexLab. Candidate selection favors higher SLO Aroused NG arousal and then proximity. Arousal and elapsed checks produce a growing random chance; the default **Occasional** setting makes an approach plausible, not guaranteed, during a two-minute level-10 shape.

The creature walks toward the player and a message offers **Accept** or **Refuse**. Accept starts a consensual two-actor SexLab scene with hook `FeralKinship`; Refuse starts nothing. There is at most one prompt per transformation and, after an accepted scene, a six-game-hour cooldown for that family. If the shape ends during an accepted scene, that partner remains calm until the scene finishes. Feral's existing scene listener—not the kinship controller—awards the one-time +12 matching-family mastery, so an initiated scene cannot award it twice.

The Settings page independently controls neutral kinship, approaches, minimum mastery (default 10), Rare/Occasional/Likely frequency, accepted-scene cooldown (default 6 game hours), and emergency cleanup. Disabling neutral kinship immediately requests cleanup. These systems do not change creature arousal, guarantee an animation, bypass SexLab validation, or initiate OStim scenes.

Both SexLab and OStim reward hooks contain the matching-scene progression code. Sex Grants Experience 1.8.0 itself describes OStim as not supporting creature animations, so creature-family progression is practically a SexLab feature unless the installed OStim setup can actually provide a creature actor to its scene events. Kinship approaches themselves use SexLab only.

Feral also exposes `GetActiveFamily()`, `GetMasteryLevel(family)`, `GetFamily(actor)`, and `AddActivityMastery(family, points, source)` for other optional adapters. The integration's `SexIntegration.json` marker lets the Feral MCM report whether it and the configured mastery reward are installed.

## Human fear and hunting

Human response has **Off**, **Reactions**, and **Full** modes; Full is the default. A witnessed transformation adds 5 notoriety and a witnessed human kill while transformed adds 15. Notoriety decays by 2 per in-game day after one quiet day. At 20 people whisper, at 40 witnesses can flee, at 60 witnessing guards can add a 250-gold bounty once per day, and at 80 event-driven exterior-cell checks can launch a hunter group after a three-day cooldown. Level 100 notoriety raises the encounter chance and adds an elite hunter. Reactions mode keeps fear feedback but disables bounty and hunters.

Witness detection runs only when a shape begins or a relevant human dies: one nearest-actor query plus at most four bounded random candidates, each requiring line of sight. Hunter checks run only on PO3's cell-loaded event and retain at most one three-actor group. Fully voiced/conditioned NPC dialogue remains future content; v13 uses MCM status and threshold notifications. While the optional kinship plugin has a qualifying shape or accepted scene to manage, it performs a bounded high-process actor scan every 10 seconds and a lightweight two-second state/timeout update; both stop when inactive.

## Runtime cost

- One `OnActorKilled` event listener; non-player kills and disabled state return before any race or JSON matching.
- No polling loop, corpse queue, claim-window scan, or stored corpse references.
- Shape-use mastery is calculated once from the active effect's elapsed time when it finishes; it does not tick every ten seconds.
- RaceMenu morph rebuilding and SlaveTats synchronization occur only on transformation entry and exit.
- Human response uses bounded event-time witness queries and cell-load hunter checks only; no recurring fear scans or background faction processing are active.

## Save compatibility and custom content

Version 13 preserves all historical harvest counts, mastery, morph overrides, Experience snapshots, notoriety, and selected family. It also repairs blank or stale saved MCM page arrays every time the menu opens. Earlier migrations still convert family slot 7 Horse progress into Stag progress, retire Claim soul, clear pending-corpse references, restore permanent passive ranks, and select the correct native-duration power. Custom races belong in `SKSE\Plugins\Feral\Races.json`.

## Transformation safety

Feral owns only the `Feral.Shapes` and `Feral.Shapes.Visible` RaceMenu keys. A per-cast ownership token is stored in the shared Bodymorph lock, so an old effect finishing late cannot clear a newer transformation. Natural expiration and recasting the active shape both use the active effect's single cleanup path: statistics are reversed once, Feral morph keys and the active tattoos are cleared, the model is refreshed once, owned cosmetics are restored, and then the lock is released. Casting a shape while its state is stale (no live effect owns it) triggers the same broad recovery as the MCM cleanup action, so a lost finish event can never wedge the lock.
