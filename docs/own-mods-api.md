# Own Mods — API & Entry Points

What an agent needs to integrate with our mods without guessing. Fill in FormIDs and
quest names when you touch a mod; never invent them — read the plugin/source.

## Lola Expanded Addons (`lola-expanded-addons` → `[NoDelete] 360 Lola Expanded Addons`)

- Plugin: `LolaExpandedAddons.esp` (added after the pluginless era — treat as required)
- Config: `SKSE\Plugins\LolaExpandedAddons\Config.json`, `HairPool.json`
  (regenerate hair pool with `tools/generate-hair-pool.mjs`)
- Key scripts: `cfl_LolaMonitor` (main loop), `cfl_Drugs`, `cfl_MCM`, `cfl_Missives`,
  overrides of upstream `vkjPlayerAliasScript`, `vkjarmorrestriction`, `vkjshavehead`
- Features: forced tasks, body potion routines, fertility, milk economy glue, hair pool
- Build: Papyrus compile against Submissive Lola Resubmission + cfl_LolaAddon sources
  (stubs in `build-stubs\`); `Build\Program.cs` for plugin work

## Bodymorph Alterations (`dollform` → `[NoDelete] Bodymorph Alterations`)

- Plugin: `Dollform.esp`; facegen-ish INI: `Dollform_CID.ini`; SEQ for dialogue
- Self-cast Alteration transformation powers: Dollform, Cowform, Horseform, Rabbitform,
  Trollform (`cfl_<X>Effect.psc`), progression via `cfl_BodymorphMarkEffect`
- MCM: `cfl_DollformMCM`; on old saves run `bat BodymorphStartMCM` once if MCM missing
- Overlays: SlaveTats textures under `Textures/.../slavetats`
- Build/validate: `Build-And-Validate.ps1`

## Feral (`feral` → `Feral - Bodymorph Addon`)

- Plugin: `Feral.esp` (in `build-output/`; build via `build/`)
- Bodymorph add-on: `cfl_FeralAspectEffect`, `cfl_FeralShapeEffect`,
  `cfl_FeralClaimEffect`, `cfl_FeralPassiveEffect`, `cfl_FeralRevertEffect`,
  MCM `cfl_FeralMCM` (+`xxx` variant)
- Status: v5 progression complete (2026-07); playtest notes in `FERAL_FINAL_PLAYTEST.md`

## RaceMenu Appearance Slots (`RaceMenu Appearance Slots`)

- Plugin: `RMAppSlots.esp`; MCM script `ras_AppearanceSlotsMCM`
- Two player-authored RaceMenu slots, toggle via MCM/hotkey
- Deps: RaceMenu (NiOverride), SkyUI, PapyrusUtil, PO3 Papyrus Extender
- Bridge mod: applies slot 2 on Vampire Lord transform, slot 1 on revert
  (overrides upstream `HNVVampLord.pex` — must win priority over HVL)

## Spatial Storage Rings (`Spatial Storage Rings Work` → `[NoDelete] 500 ...`)

- Plugin: `Spatial Storage Rings.esp`; scripts `SSR_*` (ring effects + shared container)
- Tiered item limits across rings; one shared container
- Rebuild: `Build-CompilePapyrus.ps1`; plugin regen via `ssr-mutagen-build` (Mutagen)
  or the SSEEdit `.pas` script in `SSEEdit Scripts/`

## Lola Transformative Elixirs (`lola-transformative-elixirs`)

- Pluginless patch around upstream `TransformativeElixirs.esp`
- FormID example: record `0x05000806` → `Game.GetFormFromFile(0x000806, "TransformativeElixirs.esp")`
- xEdit form dump tool: `tools\DumpTransformativeElixirsForms.pas`

## Lola Milk Economy (`lola-milk-economy`)

- Pluginless; config `SKSE\Plugins\LolaMilkEconomy\Config.json`

## Small patches (all installed, `[NoDelete] 6xx` block)

- `Lola DOM Handler Patch` — has ESP (`Lola DOM Handler Patch.esp`); DOM/submission
  handler integration; source export scripts in repo
- `LolaOutfitGracePatch` (611) — pluginless script patch; outfit zone grace period
- `LolaVampireLordClothingRestrictionPatch` (612) — pluginless; overrides
  `vkjarmorrestriction.pex` so VL form skips clothing restriction
- ⚠ `[NoDelete] 610 Lola Vampire Lord Outfit Task Patch` — installed, **no repo
  source found**; locate or recreate before any change

## Not installed / docs only

- `ToH Typo Patch` — `ToH Typo Patch.esp`, packaged zip in repo root; verify install state
- `MCM Recorder Hard Mode` — recorder preset documentation (`HARD MODE (FEMALE ONLY)`)
- `cfl-lolaaddon-outfits` — outfit configuration notes for upstream cfl_LolaAddon
