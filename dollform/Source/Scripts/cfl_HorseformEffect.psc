Scriptname cfl_HorseformEffect extends ActiveMagicEffect

Import NiOverride

GlobalVariable Property cfl_HorseformMarkTier Auto
GlobalVariable Property cfl_BodymorphActiveForm Auto
ColorForm Property cfl_HorseformHairColor Auto
Actor Property PlayerRef Auto

Float Property UpdateSeconds = 5.0 Auto

Bool _running = false
Int _tier = 0

Float _breasts
Float _butt
Float _hips
Float _thighs
Float _waist
Float _arms
Float _belly
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

	If cfl_BodymorphActiveForm.GetValueInt() != 0
		Debug.Notification("Another bodymorph alteration is already active.")
		Dispel()
		Return
	EndIf

	_running = true
	cfl_BodymorphActiveForm.SetValue(2)
	_tier = cfl_HorseformMarkTier.GetValueInt()

	SaveMorphs(PlayerRef)
	SaveHairColor(PlayerRef)
	ApplyHorseMorphs(PlayerRef)
	ApplyHairColor(PlayerRef)
	ApplyCosmetics(PlayerRef)
	ApplyActorValueChanges(PlayerRef)
	EnforceRestrictions(PlayerRef)

	Debug.Notification("Your body surges into Horseform.")
	RegisterForSingleUpdate(UpdateSeconds)
EndEvent

Event OnUpdate()
	If !_running
		Return
	EndIf

	EnforceRestrictions(PlayerRef)
	RegisterForSingleUpdate(UpdateSeconds)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	_running = false
	UnregisterForUpdate()

	If akTarget == PlayerRef
		RestoreMorphs(PlayerRef)
		RestoreHairColor(PlayerRef)
		RemoveCosmetics(PlayerRef)
		RestoreActorValueChanges(PlayerRef)
		If cfl_BodymorphActiveForm.GetValueInt() == 2
			cfl_BodymorphActiveForm.SetValue(0)
		EndIf
		Debug.Notification("Your Horseform fades.")
	EndIf
EndEvent

Function SaveMorphs(Actor akActor)
	_breasts = NiOverride.GetMorphValue(akActor, "Breasts")
	_butt = NiOverride.GetMorphValue(akActor, "Butt")
	_hips = NiOverride.GetMorphValue(akActor, "Hips")
	_thighs = NiOverride.GetMorphValue(akActor, "Thighs")
	_waist = NiOverride.GetMorphValue(akActor, "Waist")
	_arms = NiOverride.GetMorphValue(akActor, "Arms")
	_belly = NiOverride.GetMorphValue(akActor, "Belly")
	_muscleButt = NiOverride.GetMorphValue(akActor, "MuscleButt")
	_muscleLegs = NiOverride.GetMorphValue(akActor, "MuscleLegs")
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
	Float scale = 1.0 + (_tier * 0.22)

	SetMorph(akActor, "Thighs", _thighs + (0.65 * scale))
	SetMorph(akActor, "MuscleLegs", _muscleLegs + (0.55 * scale))
	SetMorph(akActor, "MuscleButt", _muscleButt + (0.35 * scale))
	SetMorph(akActor, "Butt", _butt + (0.35 * scale))
	SetMorph(akActor, "Hips", _hips + (0.20 * scale))
	SetMorph(akActor, "Waist", _waist - (0.10 * scale))
	SetMorph(akActor, "Arms", _arms - (0.10 * scale))
	SetMorph(akActor, "Belly", _belly - (0.08 * scale))
	SetMorph(akActor, "Breasts", _breasts - (0.08 * scale))

	NiOverride.UpdateModelWeight(akActor)
EndFunction

Function RestoreMorphs(Actor akActor)
	SetMorph(akActor, "Breasts", _breasts)
	SetMorph(akActor, "Butt", _butt)
	SetMorph(akActor, "Hips", _hips)
	SetMorph(akActor, "Thighs", _thighs)
	SetMorph(akActor, "Waist", _waist)
	SetMorph(akActor, "Arms", _arms)
	SetMorph(akActor, "Belly", _belly)
	SetMorph(akActor, "MuscleButt", _muscleButt)
	SetMorph(akActor, "MuscleLegs", _muscleLegs)
	NiOverride.UpdateModelWeight(akActor)
EndFunction

Function SetMorph(Actor akActor, String asMorph, Float afValue)
	NiOverride.ClearMorphValue(akActor, asMorph)
	NiOverride.SetMorphValue(akActor, asMorph, PapyrusUtil.ClampFloat(afValue, -2.0, 3.0))
EndFunction

Function ApplyCosmetics(Actor akActor)
	RemoveCosmetics(akActor)
	SlaveTats.simple_add_tattoo(akActor, "Horseform Cosmetics", "Horse Hand Mark", 0xFF5A351E, true, true, 0.60)
	SlaveTats.simple_add_tattoo(akActor, "Horseform Cosmetics", "Horse Hoof Tint", 0xFF2A160B, true, true, 0.55)
	If _tier >= 2
		SlaveTats.simple_add_tattoo(akActor, "Horseform Cosmetics", "Horse Body Mark", 0xFF5A351E, true, true, 0.45)
	EndIf
	If _tier >= 3
		SlaveTats.simple_add_tattoo(akActor, "Horseform Cosmetics", "Horse Stride Mark", 0xFF7A4A24, true, true, 0.45)
	EndIf
	SlaveTats.synchronize_tattoos(akActor, true)
EndFunction

Function RemoveCosmetics(Actor akActor)
	SlaveTats.simple_remove_tattoo(akActor, "Horseform Cosmetics", "Horse Hand Mark", true, true)
	SlaveTats.simple_remove_tattoo(akActor, "Horseform Cosmetics", "Horse Hoof Tint", true, true)
	SlaveTats.simple_remove_tattoo(akActor, "Horseform Cosmetics", "Horse Body Mark", true, true)
	SlaveTats.simple_remove_tattoo(akActor, "Horseform Cosmetics", "Horse Stride Mark", true, true)
	SlaveTats.synchronize_tattoos(akActor, true)
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
