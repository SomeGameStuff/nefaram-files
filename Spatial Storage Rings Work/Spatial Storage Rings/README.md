# Spatial Storage Rings

Standalone Skyrim Special Edition mod that adds spatial storage rings. Equipping a ring grants the `Open Spatial Storage` Lesser Power, which opens one shared storage container without requiring Alteration.

The plugin is an ESL-flagged ESP and only depends on `Skyrim.esm`.

## Rings

- `Spatial Storage Ring - Lesser`: 100 item capacity, 100 gold base value.
- `Spatial Storage Ring - Greater`: 300 item capacity, 1,000 gold base value.
- `Spatial Storage Ring - Grand`: 1,000 item capacity, 5,000 gold base value.
- `Spatial Storage Ring - Infinite`: 3,000 item capacity, 20,000 gold base value.

All tiers access the same storage. Higher tiers only raise the maximum tracked item count.

## Installation

### Mod Organizer 2

1. Copy the `Spatial Storage Rings` folder into your MO2 `mods` directory.
2. Enable `Spatial Storage Rings` in MO2's left pane.
3. Enable `Spatial Storage Rings.esp` in the right-pane Plugins tab.
4. Place it anywhere after `Skyrim.esm`; it has no other plugin masters.
5. Launch the game through MO2.

For Nefaram, the expected installed path is:

`C:\Games\nefaram\mods\Spatial Storage Rings`

### Manual Install

Copy these files into your Skyrim `Data` folder:

- `Spatial Storage Rings.esp`
- `Scripts\SSR_*.pex`

The `Source\Scripts` folder is optional and only needed if you want to inspect or rebuild the Papyrus source.

## Finding Rings In Game

The rings are added to common miscellaneous and jewelry vendor leveled lists. Merchants such as general goods vendors and jewelry vendors can stock them after their inventory is generated or restocked, but the lesser ring is not guaranteed to appear at every vendor.

For testing, use the console:

```text
help "spatial" 0
player.additem <ring form id> 1
```

Equip a ring, then use the `Open Spatial Storage` Lesser Power.

## Build Notes

The shipped `.pex` scripts are already compiled. To rebuild them, run `Build-CompilePapyrus.ps1` from the mod folder.

The build script expects:

- Papyrus compiler: `C:\Games\steamapps\common\Skyrim Special Edition\Papyrus Compiler\PapyrusCompiler.exe`
- Vanilla script sources: `C:\tmp\skyrim-scripts-source\Source\Scripts`

The ESP was generated with the Mutagen builder kept in:

`C:\Users\antho\nefaram-files\Spatial Storage Rings Work\ssr-mutagen-build`
