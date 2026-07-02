# RaceMenu Appearance Slots - Vampire Lord Bridge

Loose-script patch for Humanoid Vampire Lords.

## Behavior

- Keeps Humanoid Vampire Lords' existing gear behavior.
- Applies RaceMenu Appearance Slots Slot 2 after entering Vampire Lord form.
- Applies RaceMenu Appearance Slots Slot 1 after reverting from Vampire Lord form.
- If `RMAppSlots.esp` is disabled or missing, the bridge silently skips appearance changes.

## Requirements

- `[NoDelete] 010 Humanoid Vampire Lords - reinstall if changing race`
- `RaceMenu Appearance Slots`
- `RMAppSlots.esp` enabled

## Setup

1. Save your mortal look to RaceMenu Appearance Slots Slot 1.
2. Save your Vampire Lord look to RaceMenu Appearance Slots Slot 2.
3. Transform into Vampire Lord and revert normally.

This patch only controls the runtime values supported by RaceMenu Appearance Slots: tracked body morphs, hair color, and scale. It does not load full RaceMenu `.jslot` presets.

## Load Order

Place this mod after Humanoid Vampire Lords so its loose `Scripts/HNVVampLord.pex` wins.

## Source, Build, and Install

- Purpose: bridge Humanoid Vampire Lords transform/revert events into RaceMenu Appearance Slots.
- Source: `Source/Scripts/HNVVampLord.psc` plus the packaged loose override `Scripts/HNVVampLord.pex`.
- Build: compile the patched `HNVVampLord.psc` against vanilla, Humanoid Vampire Lords, and RaceMenu Appearance Slots sources.
- Install: copy this folder to MO2 `mods`, enable it, and keep it after Humanoid Vampire Lords in the left pane.
