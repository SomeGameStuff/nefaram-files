---
name: skyrim-mo2-papyrus-modding
description: Build, patch, or package Skyrim Special Edition mods in a Mod Organizer 2 setup when the task involves Papyrus scripts, loose-script overrides, MO2 mod folders, SKSE/PapyrusUtil config files, xEdit/ESP inspection, or safe patching of installed mods without editing the original mod folders.
---

# Skyrim MO2 Papyrus Modding

## Overview

Use this skill for Skyrim SE modding work in an MO2-managed setup, especially when creating patch mods, loose-script overrides, Papyrus source/PEX files, SKSE plugin config files, or xEdit-assisted form lookup.

Prefer reversible add-on mods over editing installed base mods. Keep changes packaged in a new MO2 mod folder unless the user explicitly asks to alter the original mod.

## Workflow

1. Inspect the actual MO2 layout first:
   - Confirm the MO2 root, active profile, `mods/`, `profiles/<profile>/modlist.txt`, and `profiles/<profile>/plugins.txt`.
   - Find exact mod folder names and plugin names before planning dependencies.
   - Read source scripts from installed mods when available; do not guess APIs, quest names, or FormIDs.

2. Choose the smallest safe patch shape:
   - Use a new ESP/ESL patch when new quests, records, dialogue, aliases, scenes, or FormLists are required.
   - Use a loose-script override when an existing script hook already provides the needed behavior and a plugin would add unnecessary risk.
   - Use SKSE/PapyrusUtil JSON config for lightweight settings that do not require MCM records.

3. Package as a separate MO2 mod:
   - Create `C:\...\mods\<Patch Mod Name>\Scripts\` for compiled `.pex`.
   - Keep NEFARAM project source files under `C:\Users\antho\nefaram-files\<Project Name>\`, not only inside the MO2 mod folder.
   - For runtime MO2 mods, include compiled `.pex` and user-facing files; only ship `Source\Scripts\` when the user explicitly wants source packaged with the mod.
   - Put PapyrusUtil config at `SKSE\Plugins\<PatchModName>\Config.json`.
   - Include a short project `README.md` for user-facing settings and load-order notes.
   - Do not ship compile stubs, scratch scripts, logs, or generated inspection dumps.

4. Preserve modlist safety:
   - Back up the active profile `modlist.txt` before changing it.
   - Enable the new mod with `+<Patch Mod Name>`.
   - For loose-script overrides, place the patch mod with higher MO2 priority than the source mod so its loose file wins.
   - For plugin patches, ensure the plugin loads after its masters in `plugins.txt`/load order.

## Papyrus Compilation

- Prefer the installed game's `Papyrus Compiler\PapyrusCompiler.exe`.
- In this NEFARAM setup, check `C:\games\steamapps\common\Skyrim Special Edition\Papyrus Compiler\PapyrusCompiler.exe` before assuming the compiler is missing.
- Keep patch source, build notes, and any reusable compile-only stubs under `C:\Users\antho\nefaram-files\<Project Name>\`; compile output can target the MO2 patch mod's `Scripts\` folder.
- Include vanilla source scripts, commonly from an extracted `Scripts.zip`, such as `C:\tmp\skyrim-scripts-source\Source\Scripts`.
- Include only the source paths needed for the target script.
- If compiling against a mod's full source tree pulls in unrelated optional dependencies, create minimal local compile stubs for the external symbols used by the patch.
- Compile stubs must stay in `C:\Users\antho\nefaram-files\<Project Name>\build-stubs\` or another source/build folder outside the installed runtime mod, and must not be packaged into the installed mod.
- Verify compiler output reports `0 error(s), 0 warning(s)` when possible.

## Form and Plugin Inspection

- Avoid launching interactive SSEEdit/xEdit from automation unless the user explicitly wants the UI.
- xEdit command-line use may still open windows or use the real AppData plugin list instead of MO2's virtualized profile when not launched through MO2.
- For simple lookups, direct ESP parsing is acceptable:
  - `ALCH` records for potions.
  - `EDID` for editor IDs.
  - `FULL` for display names.
  - record FormIDs for `Game.GetFormFromFile`.
- When using `Game.GetFormFromFile`, use the plugin-local FormID without the load-order byte, e.g. record `0x05000806` becomes `0x000806` for `TransformativeElixirs.esp`.

## Patch Design Guidelines

- Keep base mods untouched unless explicitly asked.
- Preserve existing quest/dialogue flow when it already provides the right hook, such as an existing force-greet or potion-drinking path.
- Prefer deterministic FormID lists or JSON-configurable behavior over broad runtime scanning.
- Add hard dependencies only when the patch cannot function without them.
- Keep defaults conservative for body morphs, scripts, or save-affecting behavior.
- Always explain whether the result is a full ESP/quest patch, a pluginless loose-script override, or a hybrid.

## Validation Checklist

- Confirm installed file layout under the new MO2 mod folder.
- Confirm active profile modlist ordering.
- Confirm compiled `.pex` exists and differs from the original when overriding.
- Confirm no stubs or scratch files are shipped.
- Confirm config file path matches the runtime API's expected location.
- Summarize any behavior that differs from the original design because of tooling or risk constraints.
