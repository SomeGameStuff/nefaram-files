# Spatial Storage Rings Source Folder

This folder contains the clean source/work area for Spatial Storage Rings.

## Purpose

Adds four enchanted ring tiers that grant a lesser power for opening one shared spatial storage container. Higher tiers raise the tracked item capacity.

## Source

- `Spatial Storage Rings/Source/Scripts/*.psc`: Papyrus source for the shipped scripts.
- `Spatial Storage Rings/Spatial Storage Rings.esp`: current ESL-flagged plugin.
- `SSEEdit Scripts/Codex_Create_SpatialStorageRings.pas`: SSEEdit record-generation script.
- `ssr-mutagen-build/Program.cs`: Mutagen-based plugin builder source.

## Build

Run `Spatial Storage Rings/Build-CompilePapyrus.ps1` from the packaged mod directory to rebuild the Papyrus scripts.

If plugin records change, rebuild the ESP with either the SSEEdit script or the Mutagen project in `ssr-mutagen-build`.

## Install

Copy the nested `Spatial Storage Rings` folder into the MO2 `mods` directory, enable it in the left pane, and enable `Spatial Storage Rings.esp` in the Plugins tab.

See `Spatial Storage Rings/README.md` for gameplay details and the exact compiler paths used by the existing build script.
