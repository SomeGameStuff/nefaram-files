# Skyrim NEFARAM Modding Notes

## Purpose

Use these notes when modifying a Mod Organizer 2 Skyrim list such as NEFARAM, especially when changing SKSE/PapyrusUtil JSON-driven mod data.

## Key observations

- NEFARAM is a Mod Organizer 2 portable instance under `C:\Games\nefaram`.
- The active profile inspected here was `C:\Games\nefaram\profiles\NEFARAM`.
- `plugins.txt` tells you which ESP/ESM/ESL plugins are active. Lines beginning with `*` are active plugins.
- `modlist.txt` tells you which MO2 mods are enabled. Lines beginning with `+` are enabled mods.
- Some personal or manually protected mods are under `[NoDelete]` folders.
- MO2 mod folders can contain data files directly, including `SKSE\Plugins\...` JSON files.

## cfl_LolaAddon outfit system

The Lola add-on inspected here lives at:

```text
C:\Games\nefaram\mods\[NoDelete] cfl_LolaAddon_
```

Its default outfit data lives at:

```text
SKSE\Plugins\cfe_Lola\Outfits\Default
```

The Papyrus source shows these config paths:

```text
_PathOutfitBase = ../cfe_Lola/Outfits/
OutfitProfile = default
PathActorOutfit = ../cfe_Lola/ActorOutfits/
```

The outfit files are named by location and level:

```text
Adventuring_0.json
Adventuring_1.json
Adventuring_2.json
Capital_0.json
Capital_1.json
Capital_2.json
Inn_0.json
Inn_1.json
Inn_2.json
Settlement_0.json
Settlement_1.json
Settlement_2.json
PlayerHome_0.json
PlayerHome_1.json
PlayerHome_2.json
```

Each file contains whole outfit entries. The randomizer picks an ID from `intList.ids` and equips the entire corresponding `formList` entry. Do not treat each `formList` array as a random pool unless you intentionally want mixed pieces in one outfit.

## PapyrusUtil form string format

The JSON uses strings like:

```text
0x849|[Caenarvon] Pharaoh Slave.esp
```

This means form `0x849` from `[Caenarvon] Pharaoh Slave.esp`.

For ESL-flagged plugins or compacted form IDs, keep the plugin-local form ID as stored in the plugin records, not a runtime load-order-expanded ID.

## Recommended workflow

1. Identify the active MO2 profile.
2. Check `plugins.txt` and `modlist.txt` before selecting forms from mods.
3. Read the mod's Papyrus source if available. Look for `JsonUtil`, `StorageUtil`, path constants, and load/save functions.
4. Back up original JSON files before editing.
5. Build replacement JSONs in a staging folder first.
6. Validate JSON syntax and active plugin names before copying into the live mod folder.
7. In an existing save, expect some scripts to cache selected IDs. Use the mod's MCM/configurator to refresh, request new sets, or restart the relevant task.

## Useful search patterns

```powershell
Select-String -LiteralPath 'C:\Games\nefaram\profiles\NEFARAM\plugins.txt' -Pattern 'PluginName'
rg -n -i "JsonUtil|StorageUtil|PathOutfit|LoadOutfit|SaveOutfit" 'C:\Games\nefaram\mods\Some Mod'
rg --files 'C:\Games\nefaram\mods\Some Mod' | rg -i '\.json$|SKSE|StorageUtil|Outfits'
```

## Caution

Do not edit the game's real `Data` folder when working with MO2 unless that is explicitly intended. Prefer editing the owning MO2 mod folder or creating a small override mod that wins conflicts.
