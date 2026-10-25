Scriptname cfl_HorseformEffect extends ActiveMagicEffect

Import NiOverride

GlobalVariable Property cfl_HorseformMarkTier Auto
GlobalVariable Property cfl_BodymorphActiveForm Auto
GlobalVariable Property cfl_HorseformUseSeconds Auto
GlobalVariable Property cfl_BodymorphMorphScale Auto
GlobalVariable Property cfl_BodymorphProgressionScale Auto
Spell Property cfl_SpellHorseform Auto
ColorForm Property cfl_HorseformHairColor Auto
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

Float _breasts
Float _butt
Float _hips
Float _thighs
Float _waist
Float _arms
Float _belly
Float _calves
Float _muscleButt
Float _muscleLegs
ColorForm _previousHairColor

Float _speedMod
Float _staminaMod
Float _staminaRateMod
Float _carryWeightMod
Float _unarmedMod
Float _magickaRateMod

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
		If activeForm == 2
			Debug.Notification("Horseform fades.")
			PlayerRef.DispelSpell(cfl_SpellHorseform)
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
	If !BeginActiveForm(2)
		_running = false
		_ownsForm = false
		_transitioning = false
		Dispel()
		Return
	EndIf
	_tier = PapyrusUtil.ClampInt(cfl_HorseformMarkTier.GetValueInt(), 0, 4)

	EnsureMCMQuestStarted()
	SaveMorphs(PlayerRef)
	SaveHairColor(PlayerRef)
	ApplyHorseMorphs(PlayerRef)
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
	If !IsActiveInstance(2)
		FinishForm()
		Dispel()
		Return
	EndIf
	If _transitioning
		Return
	EndIf
	_transitioning = true

	EnforceRestrictions(PlayerRef)

	If cfl_HorseformUseSeconds
		cfl_HorseformUseSeconds.SetValue(cfl_HorseformUseSeconds.GetValue() + ElapsedUseSeconds())
		CheckProgression(PlayerRef)
	EndIf

	CompleteTransition(UpdateSeconds)
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
	If IsActiveInstance(2)
		RestoreMorphs(PlayerRef)
		RestoreHairColor(PlayerRef)
		RemoveCosmetics(PlayerRef)
		If IsActiveInstance(2)
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

Function ApplyHairColor(Actor akActor)
	If cfl_HorseformHairColor
		PO3_SKSEFunctions.SetHairColor(akActor, cfl_HorseformHairColor)
	EndIf
EndFunction

Function RestoreHairColor(Actor akActor)
	If _previousHairColor
		PO3_SKSEFunctions.SetHairColor(akActor, _previousHairColor)
	EndIf
EndFunction

Function ApplyHorseMorphs(Actor akActor)
	Float scale = (1.0 + (_tier * 0.15)) * MorphScale()

	SetMorph(akActor, "Thighs", 0.45 * scale)
	SetMorph(akActor, "ThighOutsideThicc_v2", 0.35 * scale)
	SetMorph(akActor, "ThighInsideThicc_v2", 0.25 * scale)
	SetMorph(akActor, "ThighFBThicc_v2", 0.35 * scale)
	SetMorph(akActor, "ChubbyLegs", 0.20 * scale)
	SetMorph(akActor, "CalfSize", 0.35 * scale)
	SetMorph(akActor, "CalfFBThicc_v2", 0.55 * scale)
	SetMorph(akActor, "MuscleLegs", 0.75 * scale)
	SetMorph(akActor, "MuscleMoreLegs_v2", 0.55 * scale)
	SetMorph(akActor, "MuscleButt", 0.55 * scale)
	SetMorph(akActor, "Butt", 0.45 * scale)
	SetMorph(akActor, "BigButt", 0.55 * scale)
	SetMorph(akActor, "RoundAss", 0.35 * scale)
	SetMorph(akActor, "Hips", 0.30 * scale)
	SetMorph(akActor, "HipUpperWidth", 0.25 * scale)
	SetMorph(akActor, "Waist", -0.20 * scale)
	SetMorph(akActor, "Arms", -0.18 * scale)
	SetMorph(akActor, "Belly", -0.15 * scale)
	SetMorph(akActor, "Breasts", -0.12 * scale)

	ApplyDirectHorseMorphs(akActor, scale)
	RefreshAppearance(akActor)
EndFunction

Function RestoreMorphs(Actor akActor)
	NiOverride.ClearBodyMorphKeys(akActor, MorphKey)
	NiOverride.ClearBodyMorphKeys(akActor, VisibleMorphKey)
	RefreshAppearance(akActor)
EndFunction

Function ApplyDirectHorseMorphs(Actor akActor, Float afScale)
	SetDirectMorph(akActor, "Thighs", _thighs, 0.55 * afScale)
	SetDirectMorph(akActor, "CalfSize", _calves, 0.42 * afScale)
	SetDirectMorph(akActor, "MuscleLegs", _muscleLegs, 0.75 * afScale)
	SetDirectMorph(akActor, "MuscleButt", _muscleButt, 0.55 * afScale)
	SetDirectMorph(akActor, "Butt", _butt, 0.65 * afScale)
	SetDirectMorph(akActor, "Hips", _hips, 0.35 * afScale)
	SetDirectMorph(akActor, "Waist", _waist, -0.20 * afScale)
	SetDirectMorph(akActor, "Arms", _arms, -0.18 * afScale)
	SetDirectMorph(akActor, "Belly", _belly, -0.15 * afScale)
	SetDirectMorph(akActor, "Breasts", _breasts, -0.15 * afScale)
EndFunction

Function SetDirectMorph(Actor akActor, String asMorph, Float afBaseValue, Float afDelta)
	NiOverride.SetBodyMorph(akActor, asMorph, VisibleMorphKey, PapyrusUtil.ClampFloat(afDelta * 1.75, -2.0, 3.0))
EndFunction

Function RestoreDirectMorph(Actor akActor, String asMorph, Float afValue)
	NiOverride.ClearBodyMorph(akActor, asMorph, VisibleMorphKey)
EndFunction

Function SetMorph(Actor akActor, String asMorph, Float afValue)
	NiOverride.SetBodyMorph(akActor, asMorph, MorphKey, PapyrusUtil.ClampFloat(afValue, -2.0, 3.0))
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
	Int newTier = TierForUseSeconds(cfl_HorseformUseSeconds.GetValue())
	If newTier <= _tier
		Return
	EndIf

	_tier = newTier
	cfl_HorseformMarkTier.SetValue(newTier)
	ApplyActorValueChanges(akActor)
	ApplyHorseMorphs(akActor)
	ApplyProgressTattoo(akActor)
	ApplyCosmetics(akActor)
	EnforceRestrictions(akActor)
	Game.AdvanceSkill("Alteration", 35.0 + (newTier * 20.0))
	Debug.Notification("Horseform deepens to tier " + newTier + ".")
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

Function ApplyProgressTattoo(Actor akActor)
	If _tier < 1
		Return
	EndIf

	Float alpha = PapyrusUtil.ClampFloat(0.35 + (_tier * 0.15), 0.35, 0.95)
	SlaveTats.simple_remove_tattoo(akActor, "Horseform", "Horseform Seed Brand", false, true)
	SlaveTats.simple_add_tattoo(akActor, "Horseform", "Horseform Seed Brand", 0xFF8A4F24, false, true, alpha)
EndFunction

Function ApplyCosmetics(Actor akActor)
	RemoveCosmetics(akActor, false)
	SlaveTats.simple_add_tattoo(akActor, "Horseform Cosmetics", "Horse Hoof Tint", 0xFF2A160B, false, true, 0.55)
	If _tier >= 2
		SlaveTats.simple_add_tattoo(akActor, "Horseform Cosmetics", "Horse Body Mark", 0xFF5A351E, false, true, 0.45)
	EndIf
	If _tier >= 3
		SlaveTats.simple_add_tattoo(akActor, "Horseform Cosmetics", "Horse Stride Mark", 0xFF7A4A24, false, true, 0.45)
	EndIf
	SlaveTats.synchronize_tattoos(akActor, true)
EndFunction

Function RemoveCosmetics(Actor akActor, Bool abSynchronize = true)
	SlaveTats.simple_remove_tattoo(akActor, "Horseform Cosmetics", "Horse Hand Mark", false, true)
	SlaveTats.simple_remove_tattoo(akActor, "Horseform Cosmetics", "Horse Hoof Tint", false, true)
	SlaveTats.simple_remove_tattoo(akActor, "Horseform Cosmetics", "Horse Body Mark", false, true)
	SlaveTats.simple_remove_tattoo(akActor, "Horseform Cosmetics", "Horse Stride Mark", false, true)
	If abSynchronize
		SlaveTats.synchronize_tattoos(akActor, true)
	EndIf
EndFunction

Function ApplyActorValueChanges(Actor akActor)

	akActor.ModActorValue("SpeedMult", (20.0 + (_tier * 10.0)) - _speedMod)
	_speedMod = 20.0 + (_tier * 10.0)
	akActor.ModActorValue("Stamina", (50.0 + (_tier * 25.0)) - _staminaMod)
	_staminaMod = 50.0 + (_tier * 25.0)
	akActor.ModActorValue("StaminaRateMult", (25.0 + (_tier * 10.0)) - _staminaRateMod)
	_staminaRateMod = 25.0 + (_tier * 10.0)
	akActor.ModActorValue("CarryWeight", (_tier * 50.0) - _carryWeightMod)
	_carryWeightMod = _tier * 50.0
	akActor.ModActorValue("UnarmedDamage", (_tier * 5.0) - _unarmedMod)
	_unarmedMod = _tier * 5.0
	akActor.ModActorValue("MagickaRateMult", (-10.0 - (_tier * 4.0)) - _magickaRateMod)
	_magickaRateMod = -10.0 - (_tier * 4.0)
EndFunction

Function RestoreActorValueChanges(Actor akActor)
	akActor.ModActorValue("SpeedMult", -_speedMod)
	_speedMod = 0.0
	akActor.ModActorValue("Stamina", -_staminaMod)
	_staminaMod = 0.0
	akActor.ModActorValue("StaminaRateMult", -_staminaRateMod)
	_staminaRateMod = 0.0
	akActor.ModActorValue("CarryWeight", -_carryWeightMod)
	_carryWeightMod = 0.0
	akActor.ModActorValue("UnarmedDamage", -_unarmedMod)
	_unarmedMod = 0.0
	akActor.ModActorValue("MagickaRateMult", -_magickaRateMod)
	_magickaRateMod = 0.0
EndFunction

Function EnforceRestrictions(Actor akActor)
	Weapon rightWeapon = akActor.GetEquippedWeapon(false)
	If rightWeapon
		akActor.UnequipItem(rightWeapon, false, true)
	EndIf

	If _tier >= 2
		Weapon leftWeapon = akActor.GetEquippedWeapon(true)
		If leftWeapon
			akActor.UnequipItem(leftWeapon, false, true)
		EndIf

		Armor shield = akActor.GetEquippedShield()
		If shield
			akActor.UnequipItem(shield, false, true)
		EndIf
	EndIf

	If _tier >= 3
		SafeUnequipSlot(akActor, 33)
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
