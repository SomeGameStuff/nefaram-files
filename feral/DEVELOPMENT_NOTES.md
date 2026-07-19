# Feral development notes

This file preserves implementation and troubleshooting knowledge that should survive chat history. Last updated 2026-07-19 for v9.

## v7 foundation retained by v9

- Claim Soul was removed from normal play because it added a confirmation button without a targeting, risk, or choice mechanic. The legacy records remain inert for save compatibility.
- `OnActorKilled` is event-driven. It now returns before race/JSON matching unless Feral is enabled and the player is the killer, then grants mastery immediately. It never stores the victim.
- Each family has levels 1-100. The next level costs `5 + ceil(level × 0.45)` mastery, totaling 2,775 points. Common harvests grant 10, uncommon 18, and rare 28, producing roughly 278/155/100 hunting-only kills respectively.
- Expression is 25% at level 1 and grows linearly to 100% at level 100. BodyMorph values, statistics, and SlaveTats opacity are calculated from that expression once when a shape begins.
- Each family has one base transformation power from level 1 onward. Rank-2/rank-3 spell, effect, and texture records remain only for save compatibility and are removed from the player during v7 migration. The active marking always uses the detailed texture with continuously scaled opacity.
- Discrete armor cosmetics are not part of base visual progression because ordinary equipped models cannot be scaled continuously. Horns, ears, tails, claws, and genuinely new abilities should return as separately designed milestone powers after the base paths are tested.
- Shape use grants one mastery point per completed ten seconds, capped at twelve. The active effect reads elapsed time once in `OnEffectFinish`; there is no ten-second update loop.
- `AddActivityMastery(family, points, source)` is the supported hook for future optional integrations. Adult-scene progression must inspect actual participants and active family in a separate adapter; the generic Sex Grants Experience `hasCreature` boolean cannot identify a path.
- Human response is now implemented as bounded witness queries, lazy decay, guard bounty pressure, and cell-event hunter encounters. Fully conditioned dialogue remains future content; do not replace the current design with a cloak or periodic scan.

## Source, build, and deployment

- Authoritative project: `C:\Users\antho\nefaram-files\feral`.
- MO2 runtime: `C:\Games\nefaram\mods\Feral - Bodymorph Addon`.
- Run `build\Build-And-Validate.ps1` from the project. It builds and parses the ESP, regenerates all 24 staged DDS files, copies JSON configuration, writes the SEQ, compiles eight Papyrus scripts, and checks required controller/ownership features.
- Deploy the complete `build-output` tree plus user documentation. Never update only the ESP: a mismatched PEX, SlaveTats JSON, texture set, SKSE JSON, or SEQ can look like an engine/save problem.
- Compile stubs and `png-source` are development inputs and must not be shipped in the runtime mod.

## v9 milestone and integration architecture

- Family techniques occupy local spell IDs `0xA10`-`0xA17` and magic effects `0xA00`-`0xA07`. The level-50 spell remains stable at level 100; its script reads mastery at cast time and strengthens the same technique.
- Technique buffs hold their own actor-value deltas and reverse them in `OnEffectFinish`. Shape cleanup dispels the matching technique first so Return to Self cannot leave a temporary buff behind.
- Level-25/75 traits are snapshotted and applied once by the shape effect. They never update during a live transformation.
- Human response registers PO3's actor-killed and cell-fully-loaded events. Witness checks occur only on transformation/human-kill events, use bounded native actor queries, and require line of sight. Hunter groups use at most three owned placed actors and suppress new encounters while one remains alive.
- The Sex Grants Experience integration is a separate loose-script override mod. Compile-only API stubs remain under its `build-stubs`; only the two PEX overrides and README ship. Its build aborts unless upstream 1.8.0 source hashes match.

## MCM registration incident and fix

Symptoms were: Feral absent from Mod Configuration despite the plugin being enabled; a SkyUI refresh could report roughly 142 total MCMs in red; earlier attempts using the inherited/legacy quest state did not register reliably on the existing save.

The durable solution is:

1. Keep legacy quest/form records inert for save compatibility.
2. Use the fresh start-game-enabled MCM quest at plugin-local FormID `0x950`.
3. Attach the primary `cfl_FeralMCM` script and ship its matching compiled PEX.
4. Ship `SEQ\Feral.seq` containing `0x950` so the start-game quest initializes consistently.
5. Initialize `Pages` defensively in both config initialization and reload paths; do not assume saved script arrays match a newly compiled version.
6. For an existing save only, `setstage SKI_ConfigManagerInstance 1` requests one SkyUI registry refresh. The total-menu count is diagnostic context, not proof that SkyUI's menu limit caused the missing entry.

When diagnosing another missing MCM, verify the MO2-winning ESP, PEX, and SEQ hashes before changing scripts again. Confirm the quest FormID and attached VMAD script in the built plugin. Avoid renaming the live script repeatedly: save-bound script identity and stale loose files make the result harder to reason about.

## Morph and shared-state invariants

- Bodymorph Alterations and Feral share `cfl_BodymorphActiveForm` from `Dollform.esp`.
- Values 101-108 identify Feral families. The raw value is tokenized as `(formID * 100000) + token`; readers must decode it instead of comparing the raw global directly.
- Every Feral cast receives a monotonically increasing token stored under `Feral.LastShapeToken`. Only the effect instance matching both family and token may clear visuals, cosmetic state, StorageUtil active state, or the shared lock.
- Actor-value deltas are held by the active-effect instance and reversed once in `OnEffectFinish`. `_ownsShape` is cleared before cleanup to make repeated finish processing harmless.
- **Return to Self** and the MCM end action first dispel the live shape and let its `OnEffectFinish` own cleanup. Broad MCM recovery runs only if no active shape effect was actually dispelled. This prevents the controller from clearing morphs and lock state ahead of a queued finish event.
- Feral touches only `Feral.Shapes` and `Feral.Shapes.Visible` NiOverride keys. It never clears Bodymorph's keys or all morphs globally.
- Apply and normal cleanup perform one `UpdateModelWeight` per transition, not periodic updates. SlaveTats synchronization occurs only on entry/exit. There is no polling loop that rebuilds the body.

Static compilation can verify these branches and names, but only an engine test can prove SKSE callback ordering, visual latency, and exact actor-value restoration on the user's save. The regression test must include rapid end/recast after fatigue, same-family recast, different-family recast, natural expiration, save/reload, death, and Bodymorph mutual exclusion.

## Visual-art evaluation

The v5 atlas and 24 source/compatibility textures are original generated assets and are a clear improvement over placeholder line art, but they are not yet proven final body art. The contact sheet in `assets\FeralMarkingStages-v5.png` is a flat alpha/tint preview, not a 3D screenshot. v9 normally renders only the detailed texture and varies SlaveTats opacity by mastery.

Offline sampled alpha coverage at Stage III was approximately: Sabre 53%, Skeever 65%, Troll 73%, Spider 74%, Wolf 85%, Mudcrab 88%, Bear 90%, and Stag 93%. High coverage can read as a full-body material replacement rather than anatomically placed markings. Sabre is currently the clearest identity; Wolf/Bear and Spider/Mudcrab need special attention to avoid visual convergence.

Before calling visuals final, capture front/side/back screenshots on the actual player body at levels 1, 50, and 100, then spot-check levels 25 and 75. Judge UV seams, stretching, skin-tone contrast, anatomical placement, and whether continuous intensity feels like evolution rather than simple fading. Prefer localized shoulders/spine/ribs/limbs masks when revising the art.

## Offline test boundary

Offline validation can prove plugin readability, required records, Papyrus compilation, generated-file counts, JSON shape, deployment hashes, expression formulas, and ownership-code invariants. xEdit **Check for Errors** and a Spriggit serialize/deserialize round trip are useful additional gates.

Offline tools cannot reproduce Skyrim's Papyrus scheduling, NiOverride application, SlaveTats synchronization, actor-value persistence, cosmetic equipment conflicts, or final rendering. A small automated SkyUnit/test-profile pass can reduce human testing time but still launches Skyrim. Do not describe engine behavior as confirmed until the consolidated playtest records it.
