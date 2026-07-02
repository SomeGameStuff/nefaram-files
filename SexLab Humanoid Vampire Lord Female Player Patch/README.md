# SexLab Humanoid Vampire Lord Female Player Patch

Loose-script override for `sslActorLibrary`.

When the player is in `DLC1VampireBeastRace`, SexLab now treats the player as a normal female humanoid actor instead of a creature. This is intended for Humanoid Vampire Lords setups where the transformed player should use humanoid SexLab scenes and female positioning.

Scope:
- Player only.
- Vampire lord race only.
- No plugin and no changes to Humanoid Vampire Lords or SexLab records.
- Other vampire lords still use SexLab's normal creature classification.

The patch must have higher MO2 priority than `SexLab Framework` so `Scripts\sslActorLibrary.pex` wins.

## Source, Build, and Install

- Purpose: keep the transformed female player on humanoid SexLab handling when using Humanoid Vampire Lords.
- Source: `Scripts/Source/sslActorLibrary.psc`; this mirrors SexLab's source layout for the overridden script.
- Build: compile `sslActorLibrary.psc` against SexLab Framework and vanilla sources, producing `Scripts/sslActorLibrary.pex`.
- Install: copy this folder to MO2 `mods` and place it after SexLab Framework so the loose script override wins.
