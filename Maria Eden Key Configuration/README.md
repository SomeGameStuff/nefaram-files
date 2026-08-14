# Maria Eden Key Configuration

A standalone SkyUI MCM add-on for Maria Eden Prostitution. It fixes the shipped direct-pose key conflicts without modifying Maria Eden's plugin or scripts.

## What it does

- Replaces Maria Eden's shipped `Q = Action menu` shortcut with `Numpad Enter`, assigns the pose menu to `Numpad Decimal`, and unbinds all 13 direct keyboard pose shortcuts by default, including `S = Surrender`.
- Keeps Maria Eden's action and pose menus available.
- Adds a plain-language SkyUI MCM with Start and Presets, Menu Keys, and Pose Keys pages.
- Saves settings through PapyrusUtil JSON.
- Reloads pose-menu and direct-pose registrations immediately through Maria Eden's existing `MariaAnimationManager.LoadAnimations(true)` API.
- Shows the complete optional numpad layout in the MCM before it is applied.
- Reports whether Maria Eden's core framework is ready and offers a safe initializer only when it has not started.
- Uses English names and groups in its 13 pose JSON overrides so it remains compatible with an English data-translation mod at higher MO2 priority.

Action Menu, Camera, and Body Control changes apply after the next save reload. Pose Menu, Return to Normal Pose, Mouth, Eyes, and all direct poses apply immediately.

Maria Eden's core framework starts automatically. New-game story scenarios are selected through Maria Eden's Skyrim Unbound starts; the MCM does not force those scenario quests into an existing game.

## Requirements

- Skyrim SE/AE 1.6.1170-compatible setup
- Maria Eden Prostitution (tested against `d2026.8.9` / `MariaProstitution 1.1`)
- SkyUI
- PapyrusUtil
- powerofthree's Papyrus Extender (for `Quest.GetQuest`)

## Installation

Install as a separate MO2 mod after Maria Eden Prostitution. Enable `MariaEdenKeyConfig.esp`. Do not merge its JSON files into the installed Maria Eden folder.

The plugin is ESL-flagged and contains only a start-enabled MCM quest.

## Default behavior

The two main menus have safe numpad defaults, while all direct pose hotkeys remain unmapped until the optional preset is applied:

- Action menu: `Numpad Enter`
- Pose menu: `Numpad Decimal`

The MCM includes this optional numpad preset:

- `Numpad 1`: Surrender
- `Numpad 2`: Kneel
- `Numpad 3`: All fours
- `Numpad 4`: Present vagina
- `Numpad 5`: Ready stance
- `Numpad 6`: Present rear
- `Numpad 7`: Crawl
- `Numpad 8`: Striptease
- `Numpad 9`: Masturbate
- `Numpad 0`: Lie down

Spread, gulp/cough, and offer cane remain unbound.

## Build

Run:

```powershell
.\Build.ps1 -Package
```

The build compiles Papyrus, generates and validates the ESL-flagged plugin with Mutagen, checks every JSON override, and writes the distributable ZIP to the repository `artifacts` directory.
