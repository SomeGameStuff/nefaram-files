# Feral v5 implementation status

Updated 2026-07-19. Project source is `C:\Users\antho\nefaram-files\feral`; MO2 runtime is `C:\Games\nefaram\mods\Feral - Bodymorph Addon`.

## Implemented

- Save-compatible v5 economy migration and Horse-to-Stag conversion.
- Rarity-weighted family thresholds with continuous per-claim expression growth.
- Persistent multi-kill pending-essence queue and one-cast batch claiming.
- Eight situational full combat kits, 120-second shapes, and 15-second shared fatigue.
- Expanded 10-12 slider feral-glamour silhouettes.
- Twenty-four staged 2K body markings generated from an original organic texture atlas.
- Transformation shader, sound, camera feedback, exact-owner cleanup, and Bodymorph mutual exclusion.
- Per-cast transformation ownership tokens; a late `OnEffectFinish` cannot clear a newer shape, and MCM cleanup defers to the live effect before broad stale-state recovery.
- Optional JSON cosmetic adapters with safe item ownership; Stag supports detected TDN elk horns.
- Off, Balanced, and Hardcore Experience modes with exact reversible snapshots.
- MCM reporting for pending essence, fatigue, expression, next-claim growth, markings, and cosmetics.
- Generated plugin validation, 24-texture validation, and eight zero-warning Papyrus compilations.

## Confirmed in game before v5

- The Feral MCM registers and opens.
- Player-kill detection and Skeever essence claiming work.

## Remaining validation

- Run the consolidated v5 in-game playtest in `FERAL_FINAL_PLAYTEST.md`.
- Specifically repeat rapid cast/end, natural expiration, save/reload, and Feral-versus-Bodymorph exclusion tests. Static validation confirms token ownership and cleanup structure, but only Skyrim can prove NiOverride timing and actor-value restoration.
- Replace or localize markings that read as whole-body material noise. Offline alpha inspection found rank-3 UV coverage of approximately 53% (Sabre) to 93% (Stag); front/side/back screenshots are required before calling the visual set final.
- Tune individual slider and overlay intensity from screenshots if the user's body preset exposes clipping or excessive coverage.
- Add more optional owned ear/tail/claw integrations when suitable compatible armor records are available.

## Durable project knowledge

- `DEVELOPMENT_NOTES.md` records the MCM-registration incident, MO2 deployment rules, morph ownership invariants, offline test boundary, and texture findings from the 2026-07-19 work session.
- The repository build is authoritative. Runtime deployment must copy the whole validated `build-output` tree; replacing only `Feral.esp` can leave stale scripts, JSON, or textures.
- The 142-menu red SkyUI total observed during diagnosis was not the root cause. The actual fix was a fresh start-game MCM quest at local FormID `0x950`, a matching compiled `cfl_FeralMCM.pex`, and a valid `SEQ\Feral.seq`; `setstage SKI_ConfigManagerInstance 1` is only an existing-save refresh fallback.
