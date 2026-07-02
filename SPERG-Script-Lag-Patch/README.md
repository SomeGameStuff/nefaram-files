# SPERG Script Lag Patch for NEFARAM

## Summary

This is a tiny loose-script override for `SPERG - Skyrim Perk Enhancements and Rebalanced Gameplay SSE Port`.

It is intended to prevent severe Papyrus backlog caused by `SPEWeaponSpeedScript` repeatedly scheduling immediate weapon-speed updates whenever arbitrary magic effects are applied to the player.

In the affected save, ReSaver inspection showed:

- Active scripts before cleaning: `8646`
- Suspended stacks before cleaning: `8631`
- Main queued scripts: `SPEWeaponSpeedScript.OnUpdate`, `SPEWeaponSpeedScript.OnMagicEffectApply`, and `SPEOnHitEvent.OnMagicEffectApply`
- Active scripts after targeted queue cleanup: `21`
- Suspended stacks after targeted queue cleanup: `7`

## Cause

The original SPERG `SPEWeaponSpeedScript.psc` contains this block:

```papyrus
Event OnMagicEffectApply(ObjectReference akCaster, MagicEffect akEffect)
	If akEffect == VoiceElementalFury
		PlayerRef.RemoveSpell(SPEWeaponSpeedFixAb)
		RegisterForSingleUpdate(15)
	Else
		RegisterForSingleUpdate(0)
	EndIf
EndEvent
```

That means any non-Elemental-Fury magic effect applied to the player queues an immediate `OnUpdate`.

In a large modlist, the player may receive frequent magic effects from overlays, survival systems, arousal systems, cloak effects, UI/monitoring effects, combat effects, and other scripted mods. The result can be thousands of suspended `SPEWeaponSpeedScript` updates.

## Fix

The patched script keeps the Elemental Fury handling, but only schedules immediate weapon-speed updates for the SPERG effects that this script actually checks later:

- `SPERaceKhajiitSkoomaEffect`
- `SPEPerkCounterattackHasteEffect`
- `SPEPerkRiposteEffect`

Patched block:

```papyrus
Event OnMagicEffectApply(ObjectReference akCaster, MagicEffect akEffect)
	If akEffect == VoiceElementalFury
		PlayerRef.RemoveSpell(SPEWeaponSpeedFixAb)
		RegisterForSingleUpdate(15)
	ElseIf akEffect == SPERaceKhajiitSkoomaEffect || akEffect == SPEPerkCounterattackHasteEffect || akEffect == SPEPerkRiposteEffect
		RegisterForSingleUpdate(0)
	EndIf
EndEvent
```

## Install

Create a small MO2 mod with:

```text
SPERG Script Lag Patch/
  scripts/
    SPEWeaponSpeedScript.pex
  source/
    scripts/
      SPEWeaponSpeedScript.psc
```

Place it after SPERG in MO2's left pane so the loose `scripts/SPEWeaponSpeedScript.pex` overrides the copy inside `SPERG-SSE.bsa`.

No plugin is required.

## Source and Build

- Purpose: prevent SPERG from queuing weapon-speed recalculation for unrelated magic effects.
- Source: `SPEWeaponSpeedScript.psc`; `SPEWeaponSpeedScript-OnMagicEffectApply.patch` documents the focused code change.
- Build: compile the patched source against vanilla and SPERG sources, producing `SPEWeaponSpeedScript.pex`.
- Install: use the folder layout shown above and keep the MO2 mod after SPERG.

## Save Cleanup

This patch prevents the queue from quickly rebuilding, but it does not remove already-suspended Papyrus work from an existing save.

For an already-lagged save, use ReSaver or a targeted cleaner to remove only queued `SPEWeaponSpeedScript` / `SPEOnHitEvent` active scripts and suspended stacks. Do not mass-delete unrelated active scripts.

In the tested NEFARAM save, only queued work items were removed. Script instances, quest state, references, plugins, and normal Papyrus data were left intact.

## Caveats

This patch is conservative but still changes SPERG behavior. It assumes SPERG's weapon-speed fix only needs magic-effect-triggered refreshes for the named SPERG speed effects and Elemental Fury. Equipment changes and the `SPE_UpdateHaste` mod event still trigger recalculation as before.

If someone relies on another mod applying arbitrary magic effects solely to force SPERG weapon-speed recalculation, that behavior will no longer happen. In practice, that broad behavior is what caused the VM backlog.
