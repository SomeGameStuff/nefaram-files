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

	_running = true
	_ownsForm = true
	_startupRefreshes = 2
	BeginActiveForm(2)
	_tier = cfl_HorseformMarkTier.GetValueInt()

	EnsureMCMQuestStarted()
	SaveMorphs(PlayerRef)
	SaveHairColor(PlayerRef)
	ApplyHorseMorphs(PlayerRef)
	ApplyHairColor(PlayerRef)
	ApplyProgressTattoo(PlayerRef)
	ApplyCosmetics(PlayerRef)
	ApplyActorValueChanges(PlayerRef)
	EnforceRestrictions(PlayerRef)

	RegisterForSingleUpdate(1.0)
EndEvent

Event OnUpdate()
	If !_running
		Return
	EndIf
	If !IsActiveInstance(2)
		_running = false
		Return
	EndIf

	EnforceRestrictions(PlayerRef)
	If _startupRefreshes > 0
		RefreshAppearance(PlayerRef)
		_startupRefreshes -= 1
		RegisterForSingleUpdate(1.0)
		Return
	EndIf

	If cfl_HorseformUseSeconds
		cfl_HorseformUseSeconds.SetValue(cfl_HorseformUseSeconds.GetValue() + UpdateSeconds)
		CheckProgression(PlayerRef)
	EndIf

	RegisterForSingleUpdate(UpdateSeconds)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	_running = false
	UnregisterForUpdate()

	If akTarget == PlayerRef && _ownsForm
		Bool ownsActiveInstance = IsActiveInstance(2)
		If ownsActiveInstance
			RestoreMorphs(PlayerRef)
			RestoreHairColor(PlayerRef)
			RemoveCosmetics(PlayerRef)
			RestoreActorValueChanges(PlayerRef)
		EndIf
		If ownsActiveInstance
			cfl_BodymorphActiveForm.SetValue(0)
		EndIf
		_ownsForm = false
	EndIf
EndEvent

Function BeginActiveForm(Int aiFormId)
	_activeToken = StorageUtil.GetIntValue(Game.GetPlayer(), "BodymorphAlterations.LastFormToken") + 1
	If _activeToken > 90000
		_activeToken = 1
	EndIf
	StorageUtil.SetIntValue(Game.GetPlayer(), "BodymorphAlterations.LastFormToken", _activeToken)
	cfl_BodymorphActiveForm.SetValue((aiFormId * 100000) + _activeToken)
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
	_breasts = NiOverride.GetMorphValue(akActor, "Breasts")
	_butt = NiOverride.GetMorphValue(akActor, "Butt")
	_hips = NiOverride.GetMorphValue(akActor, "Hips")
	_thighs = NiOverride.GetMorphValue(akActor, "Thighs")
	_waist = NiOverride.GetMorphValue(akActor, "Waist")
	_arms = NiOverride.GetMorphValue(akActor, "Arms")
	_belly = NiOverride.GetMorphValue(akActor, "Belly")
	_calves = NiOverride.GetMorphValue(akActor, "CalfSize")
	_muscleButt = NiOverride.GetMorphValue(akActor, "MuscleButt")
	_muscleLegs = NiOverride.GetMorphValue(akActor, "MuscleLegs")
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
	RestoreDirectMorph(akActor, "Breasts", _breasts)
	RestoreDirectMorph(akActor, "Butt", _butt)
	RestoreDirectMorph(akActor, "Hips", _hips)
	RestoreDirectMorph(akActor, "Thighs", _thighs)
	RestoreDirectMorph(akActor, "Waist", _waist)
	RestoreDirectMorph(akActor, "Arms", _arms)
	RestoreDirectMorph(akActor, "Belly", _belly)
	RestoreDirectMorph(akActor, "CalfSize", _calves)
	RestoreDirectMorph(akActor, "MuscleButt", _muscleButt)
	RestoreDirectMorph(akActor, "MuscleLegs", _muscleLegs)
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
	NiOverride.ClearBodyMorph(akActor, asMorph, VisibleMorphKey)
	NiOverride.SetBodyMorph(akActor, asMorph, VisibleMorphKey, PapyrusUtil.ClampFloat(afDelta * 1.75, -2.0, 3.0))
EndFunction

Function RestoreDirectMorph(Actor akActor, String asMorph, Float afValue)
	NiOverride.ClearBodyMorph(akActor, asMorph, VisibleMorphKey)
EndFunction

Function SetMorph(Actor akActor, String asMorph, Float afValue)
	NiOverride.ClearBodyMorph(akActor, asMorph, MorphKey)
	NiOverride.SetBodyMorph(akActor, asMorph, MorphKey, PapyrusUtil.ClampFloat(afValue, -2.0, 3.0))
EndFunction

Function RefreshAppearance(Actor akActor)
	NiOverride.UpdateModelWeight(akActor)
	akActor.QueueNiNodeUpdate()
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

	RestoreActorValueChanges(akActor)
	_tier = newTier
	cfl_HorseformMarkTier.SetValue(newTier)
	ApplyHorseMorphs(akActor)
	ApplyProgressTattoo(akActor)
	ApplyCosmetics(akActor)
	ApplyActorValueChanges(akActor)
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
	SlaveTats.simple_remove_tattoo(akActor, "Horseform", "Horseform Seed Brand", true, false)
	SlaveTats.simple_add_tattoo(akActor, "Horseform", "Horseform Seed Brand", 0xFF8A4F24, true, false, alpha)
EndFunction

Function ApplyCosmetics(Actor akActor)
	RemoveCosmetics(akActor, false)
	SlaveTats.simple_add_tattoo(akActor, "Horseform Cosmetics", "Horse Hoof Tint", 0xFF2A160B, true, true, 0.55)
	If _tier >= 2
		SlaveTats.simple_add_tattoo(akActor, "Horseform Cosmetics", "Horse Body Mark", 0xFF5A351E, true, true, 0.45)
	EndIf
	If _tier >= 3
		SlaveTats.simple_add_tattoo(akActor, "Horseform Cosmetics", "Horse Stride Mark", 0xFF7A4A24, true, true, 0.45)
	EndIf
	SlaveTats.synchronize_tattoos(akActor, true)
EndFunction

Function RemoveCosmetics(Actor akActor, Bool abSynchronize = true)
	SlaveTats.simple_remove_tattoo(akActor, "Horseform Cosmetics", "Horse Hand Mark", true, true)
	SlaveTats.simple_remove_tattoo(akActor, "Horseform Cosmetics", "Horse Hoof Tint", true, true)
	SlaveTats.simple_remove_tattoo(akActor, "Horseform Cosmetics", "Horse Body Mark", true, true)
	SlaveTats.simple_remove_tattoo(akActor, "Horseform Cosmetics", "Horse Stride Mark", true, true)
	If abSynchronize
		SlaveTats.synchronize_tattoos(akActor, true)
	EndIf
EndFunction

Function ApplyActorValueChanges(Actor akActor)
	_speedMod = 20.0 + (_tier * 10.0)
	_staminaMod = 50.0 + (_tier * 25.0)
	_staminaRateMod = 25.0 + (_tier * 10.0)
	_carryWeightMod = _tier * 50.0
	_unarmedMod = _tier * 5.0
	_magickaRateMod = -10.0 - (_tier * 4.0)

	akActor.ModActorValue("SpeedMult", _speedMod)
	akActor.ModActorValue("Stamina", _staminaMod)
	akActor.ModActorValue("StaminaRateMult", _staminaRateMod)
	akActor.ModActorValue("CarryWeight", _carryWeightMod)
	akActor.ModActorValue("UnarmedDamage", _unarmedMod)
	akActor.ModActorValue("MagickaRateMult", _magickaRateMod)
EndFunction

Function RestoreActorValueChanges(Actor akActor)
	akActor.ModActorValue("SpeedMult", -_speedMod)
	akActor.ModActorValue("Stamina", -_staminaMod)
	akActor.ModActorValue("StaminaRateMult", -_staminaRateMod)
	akActor.ModActorValue("CarryWeight", -_carryWeightMod)
	akActor.ModActorValue("UnarmedDamage", -_unarmedMod)
	akActor.ModActorValue("MagickaRateMult", -_magickaRateMod)
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
	If IsDeviousLockedSlot(akActor, aiSlot)
		Return
	EndIf
	akActor.UnequipItemSlot(aiSlot)
EndFunction

Bool Function IsDeviousLockedSlot(Actor akActor, Int aiSlot)
	Armor wornArmor = akActor.GetWornForm(Armor.GetMaskForSlot(aiSlot)) as Armor
	If !wornArmor
		Return false
	EndIf

	Keyword lockable = Game.GetFormFromFile(0x003894, "Devious Devices - Assets.esm") as Keyword
	If lockable && wornArmor.HasKeyword(lockable)
		Return true
	EndIf
	Return false
EndFunction
