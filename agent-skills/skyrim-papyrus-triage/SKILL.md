---
name: skyrim-papyrus-triage
description: Diagnose and mitigate Skyrim Special Edition modlist script lag, Papyrus backlog, suspended stacks, ReSaver/Fallrim save issues, SKSE co-save questions, and targeted loose-script patching. Use when asked to inspect Skyrim saves, Papyrus logs, ReSaver output, script lag, active scripts, suspended stacks, unattached or undefined scripts, or mod scripts such as .psc, .pex, .bsa, and .esp that may cause save bloat or VM backlog.
---

# Skyrim Papyrus Triage

Use this skill to diagnose Skyrim SE/AE Papyrus script lag and build targeted mitigations. Prefer evidence from saves/logs/source over modlist folklore.

## Workflow

1. Identify the active profile, save folder, latest `.ess`, and matching `.skse` co-save.
2. Inspect save health read-only first:
   - File sizes and save chronology.
   - Papyrus logging state in profile `Skyrim.ini`.
   - ReSaver/Fallrim availability.
   - Active scripts, suspended stacks, function messages, unattached instances, and undefined elements.
3. Find the repeating script names before proposing cleanup. Thousands of active scripts or suspended stacks usually point to a specific script, not generic "too many mods".
4. Identify script ownership:
   - Search loose files first with `rg`/`Get-ChildItem`.
   - Search binary text with `rg -a` for `.esp`, `.bsa`, `.pex`, `.dll` when needed.
   - Extract `.psc`/`.pex` from BSA if the owner is archived.
   - Do not assume prefixes. Example: `SPEWeaponSpeedScript` was SPERG, not Scrab's Papyrus Extender or CASP.
5. Patch the source cause before cleaning a save. Cleaning without stopping the source only lets the queue rebuild.
6. For existing saves, clean only the verified backlog items. Avoid mass-deleting unrelated active scripts, script instances, quests, references, plugins, or random unattached scripts unless the user explicitly asks and accepts the risk.
7. Verify the cleaned copy with a second read-only inspection before telling the user to load it.

## ReSaver Helpers

This skill bundles Java helpers that use ReSaver's own parser:

- `scripts/SaveScriptLagInspector.java`: read-only summary of Papyrus counts and top queued scripts.
- `scripts/SaveBacklogCleaner.java`: targeted cleaner for queued `SPEWeaponSpeedScript` / `SPEOnHitEvent` work items. Treat as an example pattern; adapt names before use on other cases.

Compile with the local ReSaver jar:

```powershell
javac -cp 'C:\Games\nefaram\tools\ReSaver\target\ReSaver.jar' .\SaveScriptLagInspector.java
java -cp '.;C:\Games\nefaram\tools\ReSaver\target\ReSaver.jar' SaveScriptLagInspector '<save.ess>'
```

For other modlists, locate `ReSaver.jar` first. If ReSaver is only available as a GUI, inspect manually or adapt from its source if present.

## Targeted Save Cleanup

Before writing a cleaned save:

- Copy to a new filename; never overwrite the original.
- Preserve the matching `.skse` co-save.
- Remove only queue objects whose `toString()`/message clearly matches the verified culprit.
- Re-run the inspector on the cleaned save.
- Tell the user exactly what counts changed.

Good cleanup report:

```text
Active scripts: 8646 -> 21
Suspended stacks: 8631 -> 7
Removed only SPEWeaponSpeedScript / SPEOnHitEvent queued work.
```

Bad cleanup report:

```text
Cleaned scripts.
```

## Patch Mod Pattern

For Papyrus script causes:

1. Extract original `.psc` if available; otherwise decompile `.pex` only if necessary.
2. Make the smallest behavior-preserving source change.
3. Compile a loose `.pex` override.
4. Create a tiny MO2 mod with:

```text
Patch Mod/
  scripts/
    CulpritScript.pex
  source/
    scripts/
      CulpritScript.psc
```

5. Place the patch after/below the original mod in MO2 left-pane priority so the loose `.pex` wins over the BSA copy.

Remember: MO2 `modlist.txt` order can appear reversed from the UI. Verify in MO2 or with the user's observed left-pane order after editing.

## SPERG Lesson

In the NEFARAM case, `SPEWeaponSpeedScript.OnMagicEffectApply` scheduled `RegisterForSingleUpdate(0)` for every non-Elemental-Fury magic effect applied to the player. In a large modlist, frequent effects from overlays, survival, arousal, combat, monitors, and cloak systems created thousands of suspended stacks.

The conservative patch changed:

```papyrus
Else
	RegisterForSingleUpdate(0)
```

to:

```papyrus
ElseIf akEffect == SPERaceKhajiitSkoomaEffect || akEffect == SPEPerkCounterattackHasteEffect || akEffect == SPEPerkRiposteEffect
	RegisterForSingleUpdate(0)
```

This kept SPERG's relevant speed-effect refreshes and Elemental Fury behavior while preventing arbitrary magic effects from flooding the VM.

## Safety Notes

- Treat `.ess` editing as high-risk. Always produce a copy and keep the original.
- Script instances are state, not necessarily queue backlog. Do not delete them just because a script name is common.
- Unattached instances are not automatically the cause of lag. Small unattached counts are normal-ish in heavy lists.
- Papyrus INI tweaks may mask symptoms but do not fix a script that continuously schedules work.
- If source and save evidence disagree, trust the save evidence first and keep investigating ownership.
