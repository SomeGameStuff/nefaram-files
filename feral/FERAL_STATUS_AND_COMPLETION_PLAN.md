# Feral v7 implementation status

Updated 2026-07-19. Project source is `C:\Users\antho\nefaram-files\feral`; MO2 runtime is `C:\Games\nefaram\mods\Feral - Bodymorph Addon`.

## Implemented

- Save-compatible v7 mastery/visual migration and Horse-to-Stag conversion.
- Automatic event-driven essence harvesting with early rejection of disabled/non-player kills and no retained corpse references.
- Independent levels 1-100 for every family, rising per-level costs, rarity-weighted harvest mastery, and continuous 25%-100% expression growth.
- Low-overhead shape-use progression calculated once on effect finish rather than by polling.
- Eight situational full combat kits, 120-second shapes, and 15-second shared fatigue.
- Expanded 10-12 slider feral-glamour silhouettes.
- One continuously opacity-scaled detailed 2K body marking per family; older staged assets remain packaged for save compatibility.
- Transformation shader, sound, camera feedback, exact-owner cleanup, and Bodymorph mutual exclusion.
- Per-cast transformation ownership tokens; a late `OnEffectFinish` cannot clear a newer shape, and MCM cleanup defers to the live effect before broad stale-state recovery.
- Legacy cosmetic ownership cleanup and JSON adapter data retained safely; discrete cosmetics are reserved for future milestone powers.
- Off, Balanced, and Hardcore Experience modes with exact reversible snapshots.
- MCM reporting for harvests, mastery level/progress, fatigue, continuous expression, marking opacity, and future-power status.
- Generated plugin validation, 24-texture validation, and eight zero-warning Papyrus compilations.

## Confirmed in game before v7

- The Feral MCM registers and opens.
- Player-kill detection and manual Skeever claiming worked in the pre-v6 build; v7 automatic harvest, mastery migration, and continuous visuals still need confirmation.

## Remaining validation

- Run the consolidated v7 in-game playtest in `FERAL_FINAL_PLAYTEST.md`.
- Specifically repeat rapid cast/end, natural expiration, save/reload, and Feral-versus-Bodymorph exclusion tests. Static validation confirms token ownership and cleanup structure, but only Skyrim can prove NiOverride timing and actor-value restoration.
- Replace or localize markings that read as whole-body material noise. Offline alpha inspection found detailed-texture UV coverage of approximately 53% (Sabre) to 93% (Stag); front/side/back screenshots are required before calling the visual set final.
- Tune individual slider and overlay intensity from screenshots if the user's body preset exposes clipping or excessive coverage.
- Design distinct family milestone powers after the continuous base transformations are proven. Discrete horns, ears, tails, or claws belong to those powers rather than visual-level replacement spells.
- Design human notoriety/fear as event-updated state plus conditional dialogue/Story Manager encounters. Do not add polling cloaks or nearby-NPC scans.
- Build family-aware adult-mod progression only as a separate optional adapter that inspects actual participants and requires a matching active shape. Do not patch Sex Grants Experience's generic `hasCreature` path directly.

## Durable project knowledge

- `DEVELOPMENT_NOTES.md` records the MCM-registration incident, MO2 deployment rules, morph ownership invariants, offline test boundary, and texture findings from the 2026-07-19 work session.
- The repository build is authoritative. Runtime deployment must copy the whole validated `build-output` tree; replacing only `Feral.esp` can leave stale scripts, JSON, or textures.
- The 142-menu red SkyUI total observed during diagnosis was not the root cause. The actual fix was a fresh start-game MCM quest at local FormID `0x950`, a matching compiled `cfl_FeralMCM.pex`, and a valid `SEQ\Feral.seq`; `setstage SKI_ConfigManagerInstance 1` is only an existing-save refresh fallback.
- v7's hot-path rule is explicit: `OnActorKilled` must reject disabled state and non-player killers before `GetFamily`; active shapes must not poll for mastery; visual growth must be calculated only on cast; fear systems must not scan actors.
