# Lola DOM Handler Patch

Text-only compatibility patch for Submissive Lola, Diary of Mine, PAH AYGAS, PAH HSH, and CFL Lola Addon.

## What it does

This patch reframes selected DOM/PAH slave-management dialogue so the player remains Lola, acting as Master's handler rather than an independent owner.

Examples of the new framing:

- "your slaves" becomes "Master's slaves" or "slaves in my charge"
- "slaver" menu text becomes "handler" where it refers to the player-facing control role
- CFL Lola slave-caravan text describes Lola as being assigned to handle Master's caravan

The patch is deliberately conservative:

- No scripts are included or overridden.
- No DOM, PAH, or Lola mechanics are changed.
- DOM slave NPC response banks are mostly left alone so DOM still works like DOM.

## Install

Copy the whole `Lola DOM Handler Patch` folder into MO2's `mods` folder:

```text
C:\Games\nefaram\mods\Lola DOM Handler Patch
```

Enable the mod in MO2.

Enable the plugin:

```text
Lola DOM Handler Patch.esp
```

## Load order

Load after:

- `DiaryOfMine.esm`
- `PAH_AndYouGetASlave.esp`
- `PAH_HomeSweetHome.esp`
- `submissivelola_est.esp`
- `cfl_LolaAddon.esp`

In the NEFARAM profile where this was created, the plugin was placed after `cfl_LolaAddon.esp`.

## Contents

- `Lola DOM Handler Patch.esp` - ESL-flagged text/dialogue override plugin
- `README.md` - this file
