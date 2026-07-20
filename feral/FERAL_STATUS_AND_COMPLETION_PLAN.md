# Feral v12 implementation status

Updated 2026-07-19. Project source is `C:\Users\antho\nefaram-files\feral`; MO2 runtime is `C:\Games\nefaram\mods\Feral - Bodymorph Addon`.

## Implemented

- Save-compatible v12 MCM migration plus the existing mastery, visual, milestone, human-response, passive, and duration migrations.
- Automatic event-driven essence harvesting with early rejection of disabled/non-player kills and no retained corpse references.
- Independent levels 1-100 for every family, rising per-level costs, rarity-weighted harvest mastery, and continuous 25%-100% expression growth.
- Low-overhead shape-use progression calculated once on effect finish rather than by polling.
- Eight situational full combat kits, native 2/5/10/15/20-minute duration tiers, and 15-second shared fatigue.
- Permanent family passive ranks at mastery 25/50/75, with only the highest family rank active and all earned families stacking.
- Level-25 and level-75 shape traits, eight level-50 techniques, level-100 apex upgrades, and 60-second family cooldowns.
- Expanded 10-12 slider feral-glamour silhouettes with per-save family multipliers, individual MCM values, and live Feral-key diagnostics.
- One continuously opacity-scaled detailed 2K body marking per family; older staged assets remain packaged for save compatibility.
- Transformation shader, sound, camera feedback, exact-owner cleanup, and Bodymorph mutual exclusion.
- Per-cast transformation ownership tokens; a late `OnEffectFinish` cannot clear a newer shape, and MCM cleanup defers to the live effect before broad stale-state recovery.
- Legacy cosmetic ownership cleanup and JSON adapter data retained safely; discrete cosmetics are reserved for future milestone powers.
- Off, Balanced, and Hardcore Experience modes with exact reversible snapshots.
- Off, Reactions, and Full human-response modes with lazily decaying notoriety, witnessed fear, guard bounty pressure, and bounded exterior hunter groups.
- A separate hash-pinned Sex Grants Experience 1.8.0 integration with shape-gated XP, matching-family scene mastery, and an MCM-detectable JSON marker.
- Six-page MCM reporting for overview, complete progression rules, family details, friendly/live morph values, human-response thresholds, and settings.
- Generated plugin validation, marking validation, and nine zero-warning Papyrus compilations.

## Confirmed in game before v12

- The Feral MCM registers and opens.
- Player-kill detection and automatic Skeever harvesting work. The v12 page repair, full progression display, scene integration, human response, and long-duration visual cleanup still need confirmation.

## Remaining validation

- Run the consolidated v12 in-game playtest in `FERAL_FINAL_PLAYTEST.md`.
- Specifically repeat rapid cast/end, natural expiration, save/reload, and Feral-versus-Bodymorph exclusion tests. Static validation confirms token ownership and cleanup structure, but only Skyrim can prove NiOverride timing and actor-value restoration.
- Replace or localize markings that read as whole-body material noise. Offline alpha inspection found detailed-texture UV coverage of approximately 53% (Sabre) to 93% (Stag); front/side/back screenshots are required before calling the visual set final.
- Tune individual slider and overlay intensity from screenshots if the user's body preset exposes clipping or excessive coverage.
- Tune milestone magnitudes after playtesting; several traits use safe actor-value approximations where Skyrim has no reliable script-free equivalent.
- Add fully conditioned NPC dialogue and purpose-built hunter NPCs after the event-driven response framework is proven. v12 currently uses threshold notifications and vanilla bandit templates.
- Rebuild the optional Sex Grants Experience integration whenever its pinned upstream source hashes change.

## Durable project knowledge

- `DEVELOPMENT_NOTES.md` records the MCM-registration incident, MO2 deployment rules, morph ownership invariants, offline test boundary, and texture findings from the 2026-07-19 work session.
- The repository build is authoritative. Runtime deployment must copy the whole validated `build-output` tree; replacing only `Feral.esp` can leave stale scripts, JSON, or textures.
- The 142-menu red SkyUI total observed during diagnosis was not the root cause. The actual fix was a fresh start-game MCM quest at local FormID `0x950`, a matching compiled `cfl_FeralMCM.pex`, and a valid `SEQ\Feral.seq`; `setstage SKI_ConfigManagerInstance 1` is only an existing-save refresh fallback.
- v12's hot-path rule is explicit: kill handling rejects irrelevant events early; active shapes and techniques never register updates; visual growth and morph overrides are calculated only on cast; human response uses bounded event-time queries only; integration detection runs only while building the MCM.
