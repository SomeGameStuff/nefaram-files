# cfl_LolaAddon Outfit JSON Changes

## What changed

The default outfit task JSONs for `cfl_LolaAddon` were replaced with curated outfit lists that better match the mod's slave/slutty outfit theme.

Original target folder:

```text
C:\Games\nefaram\mods\[NoDelete] cfl_LolaAddon_\SKSE\Plugins\cfe_Lola\Outfits\Default
```

Packaged replacement folder:

```text
Outfits\Default
```

## Why

The Lola add-on's outfit task uses location-and-level JSON files such as:

```text
Adventuring_0.json
Adventuring_1.json
Adventuring_2.json
Capital_0.json
...
PlayerHome_2.json
```

The suffix `_0`, `_1`, and `_2` maps to the three outfit levels. The old/default files were mostly bland vanilla clothing, while only some capital entries had the Pharaoh outfit. These replacements fill every location and level with curated outfit sets from active NEFARAM plugins.

## How the JSON works

Each JSON contains whole outfit entries. The mod chooses one outfit entry from `intList.ids`, then equips every form in that entry's `formList`.

Example:

```json
"formList": {
  "1": [
    "0x849|[Caenarvon] Pharaoh Slave.esp",
    "0x84b|[Caenarvon] Pharaoh Slave.esp"
  ]
},
"intList": {
  "ids": [1]
},
"string": {
  "1": "pharaoh slave"
}
```

This means the outfits are not random mix-and-match pools. They are whole outfit options.

## Outfit design

The files now use three curated options per location/level.

Level `0` is suggestive, stylish, or slave-coded but relatively wearable.

Level `1` is more revealing.

Level `2` is the most explicit/slutty/slave-themed.

## Plugins used

All selected plugins were active in `C:\Games\nefaram\profiles\NEFARAM\plugins.txt` when the files were generated:

```text
[Caenarvon] Pharaoh Slave.esp
[Ashtoreth] Spartacus Slave.esp
[COCO] Succubus.esp
[COCO] Scarlet Rose.esp
[COCO]BattleAngels.esp
[COCO]Goddess War v2.esp
[COCO] RONIN.esp
[COCO] Mulan.esp
[COCO] 2B Wedding Outfit.esp
```

## Current location layout

Adventuring:

```text
0: COCO RONIN, COCO Goddess War V2, COCO Mulan Dress
1: Pharaoh General, COCO Battle Angels, COCO RONIN Red
2: Pharaoh Slave, COCO Succubus Black, Spartacus Slave Half-Top
```

Capital:

```text
0: Pharaoh General, COCO Mulan Dress, COCO 2B Wedding Black
1: Pharaoh Slave, COCO Scarlet Rose, COCO Battle Angels
2: COCO Scarlet Rose Bare, COCO Succubus, Spartacus Slave Half-Top
```

Inn:

```text
0: COCO 2B Wedding Black, COCO Mulan Dress, COCO Scarlet Rose
1: COCO Scarlet Rose Alt, Pharaoh General, COCO Battle Angels Bare
2: COCO Succubus, Pharaoh Slave, COCO Scarlet Rose Bare
```

Settlement:

```text
0: COCO Mulan Dress, COCO RONIN, COCO 2B Wedding White
1: Spartacus Slave, COCO Scarlet Rose, COCO Goddess War Bare
2: Pharaoh Slave, COCO Succubus Black, COCO Battle Angels Bare
```

PlayerHome:

```text
0: COCO 2B Wedding White, COCO Mulan Skimpy, COCO Scarlet Rose
1: COCO Scarlet Rose Bare, Pharaoh General, Spartacus Slave
2: COCO Succubus Black, Pharaoh Slave, Spartacus Slave Half-Top
```

## Applying or restoring

To apply these files, copy the packaged `Outfits\Default\*.json` files into:

```text
C:\Games\nefaram\mods\[NoDelete] cfl_LolaAddon_\SKSE\Plugins\cfe_Lola\Outfits\Default
```

The originals from before this edit were backed up in the Codex workspace:

```text
C:\Users\antho\Documents\Codex\2026-06-06\in-e-modlists-n-y-a\backup-original-cfe-lola-outfits
```

In an existing save, Lola may have already cached selected outfit IDs. Use the Lola add-on MCM or in-game configurator to request new outfit sets or force-start/request a new outfit task if the old choices persist.
