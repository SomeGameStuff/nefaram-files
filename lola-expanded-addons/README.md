# Lola Expanded Addons

Merged NEFARAM add-on for Submissive Lola integrations.

This mod replaces the separate Lola addon mods previously built for this list:

- Lola Transformative Elixirs
- Lola Fertility Mode Addon
- Lola Milk Economy
- Lola Body Potion Routine

It ships the two loose-script overrides needed by those features:

- `Scripts/cfl_Drugs.pex`
- `Scripts/cfl_LolaMonitor.pex`
- `Scripts/cfl_MCM.pex`

## Features

- Lola's rare drug trick can use Transformative Elixirs.
- Lola's rare drug trick can also trigger Fertility Mode insemination.
- Lola ownership can schedule Milk Mod Economy lactacid/milk quota events.
- Lola ownership can schedule recurring Transformative Elixirs body potion events.

All settings live in:

`SKSE/Plugins/LolaExpandedAddons/Config.json`

Most settings are also exposed in the Submissive Lola Extension MCM under the
`Addons` page.

## Body Potion Mode

- `body.mode`: `0` bigger, `1` smaller, `2` random.

## Notes

This is pluginless. If an optional integration mod is missing, its related event
should quietly skip at runtime.

Place this mod above `[NoDelete] cfl_LolaAddon_` so both loose-script overrides
win their conflicts. The old separate add-on mods can be disabled once this mod
is enabled.
