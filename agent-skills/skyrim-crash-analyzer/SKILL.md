---
name: skyrim-crash-analyzer
description: Analyze Skyrim Special Edition/Anniversary Edition crash logs in Mod Organizer 2 setups, especially Crash Logger SSE AE VR logs under Documents\My Games\Skyrim Special Edition\SKSE. Use when asked to investigate a Skyrim crash, "my game crashed", CTD, crash log, exception, native DLL crash, SKSE plugin crash, or to correlate crash objects with MO2 profiles, plugins.txt, modlist.txt, saves, and SKSE logs.
---

# Skyrim Crash Analyzer

## Workflow

Start read-only. Do not edit saves, plugins, modlist, INI files, or mod folders unless the user explicitly asks for a mitigation after the diagnosis.

1. Find the newest crash report:
   - Prefer `Documents\My Games\Skyrim Special Edition\SKSE\crash-*.log`.
   - Also check MO2 `crashDumps`, `overwrite`, profile logs, and `Documents\My Games\Skyrim Special Edition\Logs` if no Crash Logger report exists.
2. Identify the active MO2 profile:
   - In NEFARAM, default to `C:\games\nefaram\profiles\NEFARAM`.
   - Otherwise inspect `ModOrganizer.ini`, `profiles\`, and recent `settings.ini`.
3. Resolve this skill's directory from the loaded `SKILL.md` path, then run the bundled analyzer script to get a first-pass summary:

```powershell
$skillDir = "<directory-containing-this-SKILL.md>"
python (Join-Path $skillDir "scripts\analyze_skyrim_crash.py") --mo2-root C:\games\nefaram --profile NEFARAM
```

Use `--crash-log <path>` when the user provides a specific report.

4. Read the actual crash log sections before concluding:
   - Exception line and crash address.
   - `POSSIBLE RELEVANT OBJECTS`.
   - Top probable call stack and stack scan DLLs.
   - Expanded stack entries for named actors, cells, forms, files, and modified-by chains.
   - Module list and SKSE plugin versions.
5. Correlate:
   - Map plugin names to active `plugins.txt` entries and MO2 `mods\` folders.
   - Compare the crash time with the newest save in `profiles\<profile>\saves`.
   - Check implicated SKSE plugin logs under the SKSE documents folder.
6. Separate signal from noise:
   - Treat `EngineFixes.dll` allocator frames as possible aftermath unless it is the actual exception module or repeats as the top crashing module.
   - Treat `KERNELBASE`, `ntdll`, and `SkyrimSE.exe` as context until relevant objects or DLL hooks identify a narrower subsystem.
   - Do not blame the last plugin in a "Modified by" chain by default; explain it as one contributor among record overrides unless the object/form evidence is specific.
   - Papyrus logs rarely explain native `EXCEPTION_ACCESS_VIOLATION` or `EXCEPTION_STACK_OVERFLOW` crashes, but they can explain script-driven reproducible setup before the crash.

## Report Shape

Lead with the likely category and confidence. Include concrete evidence from local files.

Good summary:

```text
Latest crash: crash-2026-06-27-18-06-28.log
Exception: EXCEPTION_STACK_OVERFLOW at SkyrimSE.exe+07D4C4B
Likely category: native Havok/actor collision, not Papyrus
Relevant objects: bhkWorld, bhkCharRigidBodyController, MovementControllerNPC
Named actors/forms: Marcurio [000B9986], Senna [000263CD]
DLL signal: Precision.dll in stack scan; EngineFixes appears in allocator frames
Context: latest save was MarkarthWorld five minutes earlier
Next test: reproduce near the same cell/NPCs; if repeatable, disable Precision attack collisions as a reversible test
```

Avoid vague conclusions such as "mod conflict" or "bad save" unless the evidence supports them.

## Script Notes

`scripts/analyze_skyrim_crash.py` is a read-only helper. It parses Crash Logger text, active profile files, recent saves, and nearby SKSE logs. It does not replace judgment; use it to avoid redoing path discovery and extraction by hand.

Useful options:

```powershell
python (Join-Path $skillDir "scripts\analyze_skyrim_crash.py") --mo2-root C:\games\nefaram --profile NEFARAM
python (Join-Path $skillDir "scripts\analyze_skyrim_crash.py") --crash-log "C:\path\crash.log" --mo2-root C:\games\nefaram --profile NEFARAM --json
```

If the script cannot resolve paths, manually inspect with `Get-ChildItem` and `Select-String`; then continue the same workflow.

## Safety

- Never overwrite or clean `.ess` saves during crash analysis.
- Do not disable mods or edit load order as a diagnostic unless the user explicitly asks.
- Prefer reversible MCM/config tests before plugin removal.
- For repeatable crashes, ask for reproduction context: location, action, combat state, nearby NPCs, last fast travel/load door, and whether the crash happens from a prior save.
