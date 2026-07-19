# Feral development notes

This file preserves implementation and troubleshooting knowledge that should survive chat history. Last updated 2026-07-19 for v5.

## Source, build, and deployment

- Authoritative project: `C:\Users\antho\nefaram-files\feral`.
- MO2 runtime: `C:\Games\nefaram\mods\Feral - Bodymorph Addon`.
- Run `build\Build-And-Validate.ps1` from the project. It builds and parses the ESP, regenerates all 24 staged DDS files, copies JSON configuration, writes the SEQ, compiles eight Papyrus scripts, and checks required controller/ownership features.
- Deploy the complete `build-output` tree plus user documentation. Never update only the ESP: a mismatched PEX, SlaveTats JSON, texture set, SKSE JSON, or SEQ can look like an engine/save problem.
- Compile stubs and `png-source` are development inputs and must not be shipped in the runtime mod.

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
- Apply and normal cleanup perform one `UpdateModelWeight` plus one `QueueNiNodeUpdate` per transition, not periodic updates. SlaveTats synchronization occurs only on entry/exit. There is no polling loop that rebuilds the body.

Static compilation can verify these branches and names, but only an engine test can prove SKSE callback ordering, visual latency, and exact actor-value restoration on the user's save. The regression test must include rapid end/recast after fatigue, same-family recast, different-family recast, natural expiration, save/reload, death, and Bodymorph mutual exclusion.

## Visual-art evaluation

The v5 atlas and 24 staged textures are original generated assets and are a clear improvement over placeholder line art, but they are not yet proven final body art. The contact sheet in `assets\FeralMarkingStages-v5.png` is a flat alpha/tint preview, not a 3D screenshot.

Offline sampled alpha coverage at rank 3 was approximately: Sabre 53%, Skeever 65%, Troll 73%, Spider 74%, Wolf 85%, Mudcrab 88%, Bear 90%, and Stag 93%. High coverage can read as a full-body material replacement rather than anatomically placed markings. Sabre is currently the clearest identity; Wolf/Bear and Spider/Mudcrab need special attention to avoid visual convergence.

Before calling visuals final, capture front/side/back screenshots on the actual player body for every rank. Judge UV seams, stretching, skin-tone contrast, anatomical placement, and whether stages feel like evolution rather than opacity alone. Prefer localized shoulders/spine/ribs/limbs masks when revising the art.

## Offline test boundary

Offline validation can prove plugin readability, required records, Papyrus compilation, generated-file counts, JSON shape, deployment hashes, expression formulas, and ownership-code invariants. xEdit **Check for Errors** and a Spriggit serialize/deserialize round trip are useful additional gates.

Offline tools cannot reproduce Skyrim's Papyrus scheduling, NiOverride application, SlaveTats synchronization, actor-value persistence, cosmetic equipment conflicts, or final rendering. A small automated SkyUnit/test-profile pass can reduce human testing time but still launches Skyrim. Do not describe engine behavior as confirmed until the consolidated playtest records it.
