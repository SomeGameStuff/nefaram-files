# Feral implementation status

Updated 2026-07-19. Project source is `C:\Users\antho\nefaram-files\feral`; MO2 runtime is `C:\Games\nefaram\mods\Feral - Bodymorph Addon`.

## Implemented

- Clean generated `Feral.esp` with a fresh start-game MCM quest at local FormID `0x950`; legacy `0x81E` remains inert for saves.
- Working SkyUI MCM with Status, Instincts, and Settings pages.
- Player-kill detection for eight official/customizable creature families and single-use corpse claims.
- Configurable 60–300 real-second claim window, default 180.
- Persistent ranks at 3/10/25 claims and eight family-specific rank-replaced lesser powers.
- Transform-only benefits at 50/75/100% strength for ranks 1/2/3; no hidden permanent stat bonuses.
- Eight reversible RaceMenu silhouettes, temporary SlaveTats family marks, visible Active Effects, and 120-second duration.
- Shared Bodymorph transformation lock using reserved Feral values 101–108, exact-owner cleanup, Return to Self, and MCM recovery.
- Version-4 migration preserving counts/ranks while removing legacy passive abilities and generic Feral Act.
- Optional Feral Path with reversible Experience setting snapshots and 25/35/50 native XP rewards.
- Official Skyrim/Dawnguard/Dragonborn race mappings plus PapyrusUtil JSON custom mappings.
- Developer tools for rank-threshold, claim, transformation, and XP testing.
- Generated plugin/SEQ validation, eight zero-warning Papyrus compilations, and deterministic generation of eight DDS marking textures.

## Confirmed in game

- The corrected MCM registers and opens on the active save.
- Player-kill detection and Skeever essence claiming work.

## Remaining validation

- Run the consolidated v4 playtest in `FERAL_FINAL_PLAYTEST.md` after deployment.
- Tune individual body slider values and marking placement based on screenshots rather than changing the progression architecture.
- Add owned custom accessory meshes family-by-family: ears/tails/claws, equine pieces, mudcrab shell/pincers, and spider appendages.

The next user test should happen only after the validated v4 build is installed. Accessory modeling is deliberately staged and does not block testing the complete hunt/progression/transformation loop.
