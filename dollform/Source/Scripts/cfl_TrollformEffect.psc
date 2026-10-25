Scriptname cfl_TrollformEffect extends ActiveMagicEffect

Import NiOverride

GlobalVariable Property cfl_TrollformMarkTier Auto
GlobalVariable Property cfl_BodymorphActiveForm Auto
GlobalVariable Property cfl_TrollformUseSeconds Auto
GlobalVariable Property cfl_BodymorphMorphScale Auto
GlobalVariable Property cfl_BodymorphProgressionScale Auto
Spell Property cfl_SpellTrollform Auto
ColorForm Property cfl_TrollformHairColor Auto
Actor Property PlayerRef Auto

Float Property UpdateSeconds = 5.0 Auto
String Property MorphKey = "Dollform.BodymorphAlterations" Auto
String Property VisibleMorphKey = "Dollform.BodymorphAlterations.Visible" Auto
Float Property Tier1Seconds = 120.0 Auto
Float Property Tier2Seconds = 360.0 Auto
Float Property Tier3Seconds = 900.0 Auto
Float Property Tier4Seconds = 1800.0 Auto

Bool _running = false
Bool _ownsForm = false
; Finish can arrive while a latent appearance operation is in progress.
Bool _transitioning = false
Bool _finishRequested = false
Bool _finished = false
Bool _elapsedClockReady = false
Float _lastElapsed = 0.0
Int _activeToken = 0
Int _tier = 0
Int _startupRefreshes = 0
Int _regenSuppressionUpdates = 0
Bool _regenSuppressed = false
Bool _pendingFire = false
Float _fireUntilElapsed = 0.0

Float _breasts
Float _butt
Float _hips
Float _thighs
Float _waist
Float _arms
Float _belly
Float _calves
Float _muscleArms
Float _muscleLegs
Float _muscleAbs
Float _previousScale = 1.0
ColorForm _previousHairColor

Float _healthMod
Float _healRateMod
Float _meleeDamageMod
Float _unarmedMod
Float _twoHandedMod
Float _staminaMod
Float _carryWeightMod
Float _damageResistMod
Float _speedMod
Float _weaponSpeedMod
Float _magickaMod
Float _magickaRateMod
Float _fireResistMod
Float _sneakMod
Float _lockpickMod
Float _pickpocketMod
Float _speechMod
Float _marksmanMod

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If akTarget != PlayerRef
		Dispel()
		Return
	EndIf

	If StorageUtil.GetIntValue(PlayerRef, "BodymorphAlterations.Recovering") != 0
		Debug.Notification("Bodymorph cleanup is still running.")
		Dispel()
		Return
	EndIf

	Int activeForm = ActiveFormId(cfl_BodymorphActiveForm.GetValueInt())
	If activeForm != 0
		If activeForm == 5
			Debug.Notification("Trollform fades.")
			PlayerRef.DispelSpell(cfl_SpellTrollform)
			Return
		EndIf
		Debug.Notification("Another bodymorph alteration is already active.")
		Dispel()
		Return
	EndIf

	_transitioning = true
	_running = true
	_ownsForm = true
	_startupRefreshes = 0
	_lastElapsed = GetTimeElapsed()
	_elapsedClockReady = true
	If !BeginActiveForm(5)
		_running = false
		_ownsForm = false
		_transitioning = false
		Dispel()
		Return
	EndIf
	_tier = PapyrusUtil.ClampInt(cfl_TrollformMarkTier.GetValueInt(), 0, 4)

	SaveMorphs(PlayerRef)
	SaveHairColor(PlayerRef)
	SaveScale(PlayerRef)
	EnsureMCMQuestStarted()
	ApplyTrollScale(PlayerRef)
	ApplyTrollMorphs(PlayerRef)
	ApplyHairColor(PlayerRef)
	ApplyActorValueChanges(PlayerRef)
	ApplyProgressTattoo(PlayerRef)
	ApplyCosmetics(PlayerRef)
	EnforceRestrictions(PlayerRef)

	CompleteTransition(UpdateSeconds)
EndEvent

Event OnUpdate()
	If !_running
		Return
	EndIf
	If !IsActiveInstance(5)
		FinishForm()
		Dispel()
		Return
	EndIf
	If _transitioning
		Return
	EndIf
	_transitioning = true

	EnforceRestrictions(PlayerRef)
	UpdateRegenSuppression(PlayerRef)

	If cfl_TrollformUseSeconds
		cfl_TrollformUseSeconds.SetValue(cfl_TrollformUseSeconds.GetValue() + ElapsedUseSeconds())
		CheckProgression(PlayerRef)
	EndIf

	CompleteTransition(UpdateSeconds)
EndEvent

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, Bool abPowerAttack, Bool abSneakAttack, Bool abBashAttack, Bool abHitBlocked)
	If !_running
		Return
	EndIf
	If !IsActiveInstance(5)
		Return
	EndIf

	If IsFireSource(akSource)
		_pendingFire = true
		_fireUntilElapsed = GetTimeElapsed() + 10.0
	EndIf
EndEvent

Event OnMagicEffectApply(ObjectReference akCaster, MagicEffect akEffect)
	If _running && IsActiveInstance(5) && akEffect
		If akEffect.HasKeywordString("MagicDamageFire")
			_pendingFire = true
			_fireUntilElapsed = GetTimeElapsed() + 10.0
		EndIf
	EndIf
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	_running = false
	_finishRequested = true
	; The native effect can already be unbound here. Do not call its natives.
	If !_transitioning
		FinishForm()
	EndIf
EndEvent

Function CompleteTransition(Float afDelay)
	_transitioning = false
	If _finishRequested || !_running
		FinishForm()
	Else
		RegisterForSingleUpdate(afDelay)
	EndIf
EndFunction

Function FinishForm()
	If _finished || !_ownsForm
		Return
	EndIf
	_finished = true
	_running = false
	_transitioning = true
	; These deltas belong to this instance even if a debug action changed the lock.
	RestoreActorValueChanges(PlayerRef)
	If IsActiveInstance(5)
		RestoreMorphs(PlayerRef)
		RestoreHairColor(PlayerRef)
		RestoreScale(PlayerRef)
		RemoveCosmetics(PlayerRef)
		If IsActiveInstance(5)
			cfl_BodymorphActiveForm.SetValue(0)
		EndIf
	EndIf
	_ownsForm = false
	_transitioning = false
EndFunction

Float Function ElapsedUseSeconds()
	; The effect clock follows actual effect time, including delayed VM updates,
	; and does not count time spent paused in menus. It survives save/load.
	Float elapsed = GetTimeElapsed()
	Float delta = 0.0
	If _elapsedClockReady
		delta = elapsed - _lastElapsed
	EndIf
	_lastElapsed = elapsed
	_elapsedClockReady = true
	Return PapyrusUtil.ClampFloat(delta, 0.0, 420.0)
EndFunction

Bool Function BeginActiveForm(Int aiFormId)
	cfl_DollformMCM controller = Game.GetFormFromFile(0x00081E, "Dollform.esp") as cfl_DollformMCM
	If !controller
		Debug.Notification("Bodymorph controller is unavailable.")
		Return false
	EndIf
	Int claimed = controller.ClaimActiveForm(aiFormId)
	If claimed == 0
		Debug.Notification("Another bodymorph transition is already in progress.")
		Return false
	EndIf
	_activeToken = ActiveToken(claimed)
	Return true
EndFunction

Bool Function IsActiveInstance(Int aiFormId)
	Int activeValue = cfl_BodymorphActiveForm.GetValueInt()
	Return ActiveFormId(activeValue) == aiFormId && ActiveToken(activeValue) == _activeToken
EndFunction

Int Function ActiveFormId(Int aiActiveValue)
	If aiActiveValue >= 100000
		Return aiActiveValue / 100000
	EndIf
	Return aiActiveValue
EndFunction

Int Function ActiveToken(Int aiActiveValue)
	If aiActiveValue >= 100000
		Return aiActiveValue - ((aiActiveValue / 100000) * 100000)
	EndIf
	Return 0
EndFunction

Function SaveMorphs(Actor akActor)
	NiOverride.ClearBodyMorphKeys(akActor, MorphKey)
	NiOverride.ClearBodyMorphKeys(akActor, VisibleMorphKey)
EndFunction

Function SaveHairColor(Actor akActor)
	_previousHairColor = akActor.GetActorBase().GetHairColor()
	If !_previousHairColor
		_previousHairColor = PO3_SKSEFunctions.GetHairColor(akActor)
	EndIf
EndFunction

Function SaveScale(Actor akActor)
	_previousScale = akActor.GetScale()
	If _previousScale <= 0.0
		_previousScale = 1.0
	EndIf
EndFunction

Function ApplyHairColor(Actor akActor)
	If cfl_TrollformHairColor
		PO3_SKSEFunctions.SetHairColor(akActor, cfl_TrollformHairColor)
	EndIf
EndFunction

Function RestoreHairColor(Actor akActor)
	If _previousHairColor
		PO3_SKSEFunctions.SetHairColor(akActor, _previousHairColor)
	EndIf
EndFunction

Function ApplyTrollScale(Actor akActor)
	Float scaleBoost = 1.22 + (_tier * 0.03)
	akActor.SetScale(PapyrusUtil.ClampFloat(_previousScale * scaleBoost, 0.75, 1.45))
EndFunction

Function RestoreScale(Actor akActor)
	akActor.SetScale(_previousScale)
EndFunction

Function ApplyTrollMorphs(Actor akActor)
	Float scale = (1.0 + (_tier * 0.25)) * MorphScale()

	SetMorph(akActor, "Arms", 0.85 * scale)
	SetMorph(akActor, "MuscleArms", 1.00 * scale)
	SetMorph(akActor, "ChubbyArms", 0.40 * scale)
	SetMorph(akActor, "MuscleAbs", 0.65 * scale)
	SetMorph(akActor, "MuscleLegs", 0.80 * scale)
	SetMorph(akActor, "ShoulderWidth", 0.75 * scale)
	SetMorph(akActor, "Back", 0.55 * scale)
	SetMorph(akActor, "Thighs", 0.45 * scale)
	SetMorph(akActor, "CalfSize", 0.40 * scale)
	SetMorph(akActor, "Waist", 0.25 * scale)
	SetMorph(akActor, "Belly", 0.20 * scale)
	SetMorph(akActor, "Hips", 0.15 * scale)
	SetMorph(akActor, "Butt", 0.10 * scale)
	SetMorph(akActor, "Breasts", -0.20 * scale)

	SetDirectMorph(akActor, "Arms", _arms, 1.10 * scale)
	SetDirectMorph(akActor, "MuscleArms", _muscleArms, 1.10 * scale)
	SetDirectMorph(akActor, "ChubbyArms", 0.0, 0.45 * scale)
	SetDirectMorph(akActor, "MuscleAbs", _muscleAbs, 0.75 * scale)
	SetDirectMorph(akActor, "MuscleLegs", _muscleLegs, 0.85 * scale)
	SetDirectMorph(akActor, "Thighs", _thighs, 0.55 * scale)
	SetDirectMorph(akActor, "CalfSize", _calves, 0.45 * scale)
	SetDirectMorph(akActor, "Waist", _waist, 0.25 * scale)
	SetDirectMorph(akActor, "Belly", _belly, 0.25 * scale)
	SetDirectMorph(akActor, "Hips", _hips, 0.15 * scale)
	SetDirectMorph(akActor, "Butt", _butt, 0.10 * scale)
	SetDirectMorph(akActor, "Breasts", _breasts, -0.20 * scale)

	RefreshAppearance(akActor)
EndFunction

Function RestoreMorphs(Actor akActor)
	NiOverride.ClearBodyMorphKeys(akActor, MorphKey)
	NiOverride.ClearBodyMorphKeys(akActor, VisibleMorphKey)
	RefreshAppearance(akActor)
EndFunction

Function SetMorph(Actor akActor, String asMorph, Float afValue)
	NiOverride.SetBodyMorph(akActor, asMorph, MorphKey, PapyrusUtil.ClampFloat(afValue, -2.0, 3.0))
EndFunction

Function SetDirectMorph(Actor akActor, String asMorph, Float afBaseValue, Float afDelta)
	NiOverride.SetBodyMorph(akActor, asMorph, VisibleMorphKey, PapyrusUtil.ClampFloat(afDelta * 1.75, -2.0, 3.0))
EndFunction

Function RestoreDirectMorph(Actor akActor, String asMorph, Float afValue)
	NiOverride.ClearBodyMorph(akActor, asMorph, VisibleMorphKey)
EndFunction

Function RefreshAppearance(Actor akActor)
	NiOverride.UpdateModelWeight(akActor)
EndFunction

Function EnsureMCMQuestStarted()
	Quest mcmQuest = Game.GetFormFromFile(0x00081E, "Dollform.esp") as Quest
	If mcmQuest && !mcmQuest.IsRunning()
		mcmQuest.Start()
	EndIf
EndFunction

Function CheckProgression(Actor akActor)
	Int newTier = TierForUseSeconds(cfl_TrollformUseSeconds.GetValue())
	If newTier <= _tier
		Return
	EndIf

	_tier = newTier
	cfl_TrollformMarkTier.SetValue(newTier)
	ApplyActorValueChanges(akActor)
	ApplyTrollScale(akActor)
	ApplyTrollMorphs(akActor)
	ApplyProgressTattoo(akActor)
	ApplyCosmetics(akActor)
	EnforceRestrictions(akActor)
	Game.AdvanceSkill("Alteration", 35.0 + (newTier * 20.0))
	Debug.Notification("Trollform deepens to tier " + newTier + ".")
EndFunction

Int Function TierForUseSeconds(Float afSeconds)
	Float scale = ProgressionScale()
	If afSeconds >= Tier4Seconds * scale
		Return 4
	ElseIf afSeconds >= Tier3Seconds * scale
		Return 3
	ElseIf afSeconds >= Tier2Seconds * scale
		Return 2
	ElseIf afSeconds >= Tier1Seconds * scale
		Return 1
	EndIf
	Return 0
EndFunction

Function ApplyProgressTattoo(Actor akActor)
	If _tier < 1
		Return
	EndIf

	Float alpha = PapyrusUtil.ClampFloat(0.35 + (_tier * 0.15), 0.35, 0.95)
	SlaveTats.simple_remove_tattoo(akActor, "Trollform", "Trollform Grayhide Brand", false, true)
	SlaveTats.simple_add_tattoo(akActor, "Trollform", "Trollform Grayhide Brand", 0xFF8A8F88, false, true, alpha)
EndFunction

Function ApplyCosmetics(Actor akActor)
	RemoveCosmetics(akActor, false)
	SlaveTats.simple_add_tattoo(akActor, "Trollform Cosmetics", "Troll Grayhide Patches", 0xFF7B817A, false, true, 0.50)
	If _tier >= 2
		SlaveTats.simple_add_tattoo(akActor, "Trollform Cosmetics", "Troll Stone Scars", 0xFFB8B9B0, false, true, 0.45)
	EndIf
	SlaveTats.synchronize_tattoos(akActor, true)
EndFunction

Function RemoveCosmetics(Actor akActor, Bool abSynchronize = true)
	SlaveTats.simple_remove_tattoo(akActor, "Trollform Cosmetics", "Troll Grayhide Patches", false, true)
	SlaveTats.simple_remove_tattoo(akActor, "Trollform Cosmetics", "Troll Stone Scars", false, true)
	If abSynchronize
		SlaveTats.synchronize_tattoos(akActor, true)
	EndIf
EndFunction

Function ApplyActorValueChanges(Actor akActor)

	akActor.ModActorValue("Health", (250.0 + (_tier * 35.0)) - _healthMod)
	_healthMod = 250.0 + (_tier * 35.0)
	If !_regenSuppressed
		akActor.ModActorValue("HealRate", (8.0 + (_tier * 1.0)) - _healRateMod)
	EndIf
	_healRateMod = 8.0 + (_tier * 1.0)
	akActor.ModActorValue("MeleeDamage", (40.0 + (_tier * 5.0)) - _meleeDamageMod)
	_meleeDamageMod = 40.0 + (_tier * 5.0)
	akActor.ModActorValue("UnarmedDamage", (20.0 + (_tier * 5.0)) - _unarmedMod)
	_unarmedMod = 20.0 + (_tier * 5.0)
	akActor.ModActorValue("TwoHanded", (15.0 + (_tier * 5.0)) - _twoHandedMod)
	_twoHandedMod = 15.0 + (_tier * 5.0)
	akActor.ModActorValue("Stamina", (60.0 + (_tier * 15.0)) - _staminaMod)
	_staminaMod = 60.0 + (_tier * 15.0)
	akActor.ModActorValue("CarryWeight", (100.0 + (_tier * 15.0)) - _carryWeightMod)
	_carryWeightMod = 100.0 + (_tier * 15.0)
	akActor.ModActorValue("DamageResist", (40.0 + (_tier * 10.0)) - _damageResistMod)
	_damageResistMod = 40.0 + (_tier * 10.0)
	akActor.ModActorValue("SpeedMult", (-20.0 - (_tier * 1.0)) - _speedMod)
	_speedMod = -20.0 - (_tier * 1.0)
	akActor.ModActorValue("WeaponSpeedMult", (-0.15) - _weaponSpeedMod)
	_weaponSpeedMod = -0.15
	akActor.ModActorValue("Magicka", (-100.0 - (_tier * 10.0)) - _magickaMod)
	_magickaMod = -100.0 - (_tier * 10.0)
	akActor.ModActorValue("MagickaRateMult", (-80.0) - _magickaRateMod)
	_magickaRateMod = -80.0
	akActor.ModActorValue("FireResist", (-100.0) - _fireResistMod)
	_fireResistMod = -100.0
	akActor.ModActorValue("Sneak", (-90.0) - _sneakMod)
	_sneakMod = -90.0
	akActor.ModActorValue("Lockpicking", (-40.0) - _lockpickMod)
	_lockpickMod = -40.0
	akActor.ModActorValue("Pickpocket", (-40.0) - _pickpocketMod)
	_pickpocketMod = -40.0
	akActor.ModActorValue("Speechcraft", (-30.0) - _speechMod)
	_speechMod = -30.0
	akActor.ModActorValue("Marksman", (-50.0) - _marksmanMod)
	_marksmanMod = -50.0
EndFunction

Function RestoreActorValueChanges(Actor akActor)
	akActor.ModActorValue("Health", -_healthMod)
	_healthMod = 0.0
	If !_regenSuppressed
		akActor.ModActorValue("HealRate", -_healRateMod)
	EndIf
	_healRateMod = 0.0
	_regenSuppressed = false
	_regenSuppressionUpdates = 0
	_pendingFire = false
	akActor.ModActorValue("MeleeDamage", -_meleeDamageMod)
	_meleeDamageMod = 0.0
	akActor.ModActorValue("UnarmedDamage", -_unarmedMod)
	_unarmedMod = 0.0
	akActor.ModActorValue("TwoHanded", -_twoHandedMod)
	_twoHandedMod = 0.0
	akActor.ModActorValue("Stamina", -_staminaMod)
	_staminaMod = 0.0
	akActor.ModActorValue("CarryWeight", -_carryWeightMod)
	_carryWeightMod = 0.0
	akActor.ModActorValue("DamageResist", -_damageResistMod)
	_damageResistMod = 0.0
	akActor.ModActorValue("SpeedMult", -_speedMod)
	_speedMod = 0.0
	akActor.ModActorValue("WeaponSpeedMult", -_weaponSpeedMod)
	_weaponSpeedMod = 0.0
	akActor.ModActorValue("Magicka", -_magickaMod)
	_magickaMod = 0.0
	akActor.ModActorValue("MagickaRateMult", -_magickaRateMod)
	_magickaRateMod = 0.0
	akActor.ModActorValue("FireResist", -_fireResistMod)
	_fireResistMod = 0.0
	akActor.ModActorValue("Sneak", -_sneakMod)
	_sneakMod = 0.0
	akActor.ModActorValue("Lockpicking", -_lockpickMod)
	_lockpickMod = 0.0
	akActor.ModActorValue("Pickpocket", -_pickpocketMod)
	_pickpocketMod = 0.0
	akActor.ModActorValue("Speechcraft", -_speechMod)
	_speechMod = 0.0
	akActor.ModActorValue("Marksman", -_marksmanMod)
	_marksmanMod = 0.0
EndFunction

Function SuppressRegeneration(Actor akActor)
	If _regenSuppressed
		Return
	EndIf

	akActor.ModActorValue("HealRate", -_healRateMod)
	_regenSuppressed = true
	Debug.Notification("Fire sears away your troll regeneration.")
EndFunction

Function UpdateRegenSuppression(Actor akActor)
	If _pendingFire
		_pendingFire = false
		SuppressRegeneration(akActor)
	EndIf
	If !_regenSuppressed
		Return
	EndIf

	; Migrate an already-suppressed effect from the old update-count timer.
	If _fireUntilElapsed <= 0.0
		_fireUntilElapsed = GetTimeElapsed() + 10.0
	EndIf
	If GetTimeElapsed() < _fireUntilElapsed
		Return
	EndIf

	akActor.ModActorValue("HealRate", _healRateMod)
	_regenSuppressed = false
	_fireUntilElapsed = 0.0
EndFunction

Bool Function IsFireSource(Form akSource)
	If !akSource
		Return false
	EndIf

	If akSource.HasKeywordString("MagicDamageFire")
		Return true
	EndIf
	Spell sourceSpell = akSource as Spell
	If sourceSpell
		Int i = 0
		While i < sourceSpell.GetNumEffects()
			MagicEffect effect = sourceSpell.GetNthEffectMagicEffect(i)
			If effect && effect.HasKeywordString("MagicDamageFire")
				Return true
			EndIf
			i += 1
		EndWhile
	EndIf
	Return false
EndFunction

Function EnforceRestrictions(Actor akActor)
	If _tier >= 1
		SafeUnequipSlot(akActor, 33)
	EndIf

	If _tier >= 3
		SafeUnequipSlot(akActor, 37)
	EndIf
EndFunction

Function SafeUnequipSlot(Actor akActor, Int aiSlot)
	Armor wornArmor = akActor.GetWornForm(Armor.GetMaskForSlot(aiSlot)) as Armor
	If !wornArmor
		Return
	EndIf
	If IsLockedArmor(wornArmor)
		Return
	EndIf
	akActor.UnequipItem(wornArmor, false, true)
EndFunction

Bool Function IsLockedArmor(Armor akArmor)
	Return akArmor.HasKeywordString("zad_Lockable") || akArmor.HasKeywordString("zad_DeviousDevice") || akArmor.HasKeywordString("zad_InventoryDevice")
EndFunction

Float Function MorphScale()
	If !cfl_BodymorphMorphScale
		Return 1.0
	EndIf
	Return PapyrusUtil.ClampFloat(cfl_BodymorphMorphScale.GetValue(), 0.25, 2.0)
EndFunction

Float Function ProgressionScale()
	If !cfl_BodymorphProgressionScale
		Return 1.0
	EndIf
	Return PapyrusUtil.ClampFloat(cfl_BodymorphProgressionScale.GetValue(), 0.25, 4.0)
EndFunction
