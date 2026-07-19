# Known Issues and Fixes

Dated log of diagnosed problems so they never get re-diagnosed. Newest first.
Format: symptom → root cause → fix → where it lives.

## 2026-06 — SPERG Papyrus backlog flood (FIXED)

- **Symptom**: script lag; saves with ~8,600+ active scripts / suspended stacks.
- **Cause**: SPERG's `SPEWeaponSpeedScript.OnMagicEffectApply` called
  `RegisterForSingleUpdate(0)` for *every* non-Elemental-Fury magic effect on the
  player. In a big list (overlays, survival, arousal, combat monitors, cloaks) that
  flooded the VM.
- **Fix**: whitelisted the three effects that actually need the refresh
  (`SPERaceKhajiitSkoomaEffect`, `SPEPerkCounterattackHasteEffect`,
  `SPEPerkRiposteEffect`); loose-pex patch mod.
- **Lives in**: `SPERG-Script-Lag-Patch/` → installed as `[NoDelete] 390 SPERG Script Lag Patch`.
  Full write-up in `skyrim-papyrus-triage` skill ("SPERG Lesson").
- **Save cleanup**: `SaveBacklogCleaner.java` (in that skill) removed only the SPE
  queued work: active scripts 8646→21, suspended stacks 8631→7. Original saves kept.

## 2026-06 — Stack-overflow crash, Markarth area (diagnosed)

- **Symptom**: `EXCEPTION_STACK_OVERFLOW` in `SkyrimSE.exe`; crash
  `crash-2026-06-27-18-06-28.log`.
- **Evidence**: Havok/actor-collision frames (`bhkWorld`,
  `bhkCharRigidBodyController`, `MovementControllerNPC`); actors Marcurio, Senna;
  `Precision.dll` in stack scan. EngineFixes frames judged aftermath.
- **Status**: categorized as native collision, not Papyrus. Reversible test proposed:
  disable Precision attack collisions. Not confirmed fixed — recheck if it recurs.
- **Lives in**: example report embedded in `skyrim-crash-analyzer` skill.

## 2026-05 — Plugin count limit (worked around)

- **Symptom**: exceeded the 254 full-plugin limit (other list, `<other-mo2-instance>`).
- **Fix**: ESL-ification via headless SSEEdit script
  (`Codex_ESLify_GildPhoenixKatana.pas` pattern).
- **Relevance**: NEFARAM runs ~1,900 plugin lines — always prefer ESL-flagged or
  pluginless (script/JSON) patches for new local mods.

## Recurring traps (not bugs, but time sinks)

- **modlist.txt reversed vs MO2 UI** — see `docs/environment-quirks.md`.
- **Prefix misattribution** (`SPE`, `cfl_`, `vkj_`) — see `docs/script-prefix-map.md`.
- **xEdit outside MO2 sees the wrong Data dir** — pass `-D:` + explicit plugins.
