# Author handoff

This patch is intentionally small and upstream-friendly.

## Root cause addressed

Maria Eden loads every `MariaPoses/*.json` `hotkey` value and calls `RegisterForKey`. The current `surrender.json` uses DirectInput scan code `31`, which is the standard `S` movement key. Other pose files similarly use common gameplay keys. `MariaHotkeys.json` also ships the action menu on scan code `16` (`Q`), which conflicts with layouts that use `Q` for movement.

## Integration design

- `MEPK_MCM.psc` extends `SKI_ConfigBase`.
- It writes the same JSON keys Maria Eden already reads; it does not maintain a competing configuration format.
- It locates the existing `MariaMain` quest through `Quest.GetQuest`, casts its `MariaAnimationManager` script, and calls the public `LoadAnimations(true)` function.
- The add-on plugin has `MariaBase.esm` as a master only to guarantee ordering and communicate the hard dependency.
- No Maria Eden scripts or records are overridden.
- The status page reads the existing `MariaMain` stage. Its initializer only advances an uninitialized core framework to stage 1; it never force-starts Skyrim Unbound scenario quests.
- The implementation deliberately avoids persistent script arrays after live testing exposed Papyrus VM array initialization failures on an existing save.

## Suggested upstream changes

1. Ship the action-menu key and direct pose hotkeys as `0` by default.
2. Incorporate this MCM quest/script into Maria Eden, or expose a small public reload event for all cached key consumers.
3. Add reload functions for `MariaPlayerBase`, `MEP_MainAlias`, and other scripts that cache `MariaHotkeys.json` values so every General-page change can apply immediately.

## Source and build

The distributable includes `Source/Scripts/MEPK_MCM.psc`. The repository project also contains the Mutagen generator, compile-only stubs, and reproducible PowerShell build script. Compile-only stubs are not shipped in the runtime package.
