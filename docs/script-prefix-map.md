# Script Prefix Ownership Map

Prefix identifies the **origin mod family** of a script name. Loose `.pex` overrides
keep the original name, so the winner in MO2 priority may be one of our patch mods —
always check which mod folder supplies the winning file before editing.

Search loose files first; use `rg -a` (binary text) over `.pex`/`.bsa`/`.esp` when the
owner is archived. Do not guess from the prefix alone.

## Our ecosystem

| Prefix | Owner | Notes |
|---|---|---|
| `cfl_` | **Shared**: upstream `cfl_LolaAddon_` (Custom Framework Lola Addon) **and** our own CFL-ecosystem mods | Our mods (`dollform`, `feral`, `lola-expanded-addons`) use `cfl_` for their own scripts (e.g. `cfl_FeralMCM`, `cfl_DollformEffect`) AND ship overrides of upstream `cfl_` scripts (`cfl_Drugs`, `cfl_LolaMonitor`, `cfl_MCM`, `cfl_Missives`). Prefix does not disambiguate here — check the mod folder. |
| `TIF_cfl_` | Our mods | Topic-info fragment scripts (dollform) |
| `ras_` | RaceMenu Appearance Slots (ours) | |
| `SSR_` | Spatial Storage Rings (ours) | |
| `vkj_` | **Upstream** SubmissiveLolaResubmission | Our patches override some (`vkjarmorrestriction`, `vkjPlayerAliasScript`, `vkjshavehead`) in LEA and patch 612 |

## Upstream (do not edit source; patch via override)

| Prefix | Owner | Gotcha |
|---|---|---|
| `SPE` | SPERG (perk overhaul) | **Not** Scrab's Papyrus Extender, not CASP. Verified 2026-06 during the script-lag hunt. |
| `HNV` | Humanoid Vampire Lords | Bridge mod overrides `HNVVampLord.pex` |
| `ssl` | SexLab Framework | Female-player VL patch overrides `sslActorLibrary.pex` |
| `PAH` | Paradise Halls / And You Get A Slave family | DOM Handler patch territory |
| `mme` / Milk Mod Economy scripts | Milk Mod Economy (upstream) | Distinct from our `lola-milk-economy` |

Add rows when a new prefix costs you time to identify.
