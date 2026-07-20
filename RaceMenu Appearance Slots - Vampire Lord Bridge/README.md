# RaceMenu Appearance Slots - Vampire Lord Bridge

Loose-script patch for Humanoid Vampire Lords.

## Behavior

- Keeps Humanoid Vampire Lords' existing gear behavior.
- Captures the current mortal RaceMenu Appearance Slots state before entering Vampire Lord form.
- Applies RaceMenu Appearance Slots Slot 2 after entering Vampire Lord form.
- Restores the captured mortal snapshot after reverting from Vampire Lord form. If no snapshot exists yet, Slot 1 is used as a fallback.
- If `RMAppSlots.esp` is disabled or missing, the bridge silently skips appearance changes.

## Requirements

- `[NoDelete] 010 Humanoid Vampire Lords - reinstall if changing race`
- `RaceMenu Appearance Slots`
- `RMAppSlots.esp` enabled

## Setup

1. Save a fallback mortal look to RaceMenu Appearance Slots Slot 1.
2. Save your Vampire Lord look to RaceMenu Appearance Slots Slot 2.
3. Transform into Vampire Lord and revert normally.

This patch controls the runtime values supported by RaceMenu Appearance Slots, including its RaceMenu/CharGen preset save path, tracked body morphs, hair color, and scale.

## Load Order

Place this mod after Humanoid Vampire Lords so its loose `Scripts/HNVVampLord.pex` wins.
