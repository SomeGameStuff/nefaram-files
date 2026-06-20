Scriptname cfl_CowformEffect extends ActiveMagicEffect

Import NiOverride

GlobalVariable Property cfl_CowformMarkTier Auto
GlobalVariable Property cfl_BodymorphActiveForm Auto
ColorForm Property cfl_CowformHairColor Auto
Actor Property PlayerRef Auto

Float Property UpdateSeconds = 6.0 Auto
Int Property MilkPulseUpdates = 5 Auto

Bool _running = false
Int _tier = 0
Int _milkPulseCounter = 0

Float _breasts
Float _butt
Float _hips
Float _thighs
Float _waist
Float _arms
Float _belly
Float _nippleSize
Float _areolaSize
ColorForm _previousHairColor

Float _healthMod
Float _staminaMod
Float _carryWeightMod
Float _speedMod
Float _magickaRateMod

MilkQUEST _milkQuest
Armor _cowHorns
Bool _addedCowHorns = false

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
	cfl_BodymorphActiveForm.SetValue(3)
	_tier = cfl_CowformMarkTier.GetValueInt()

	SaveMorphs(PlayerRef)
	SaveHairColor(PlayerRef)
	ApplyCowMorphs(PlayerRef)
	ApplyHairColor(PlayerRef)
	ApplyCosmetics(PlayerRef)
	ApplyHorns(PlayerRef)
	ApplyActorValueChanges(PlayerRef)
	SetupMilkMod(PlayerRef)
	EnforceRestrictions(PlayerRef)

	Debug.Notification("Your body softens into Cowform.")
	RegisterForSingleUpdate(UpdateSeconds)
EndEvent

Event OnUpdate()
	If !_running
		Return
	EndIf

	EnforceRestrictions(PlayerRef)
	_milkPulseCounter += 1
	If _milkPulseCounter >= MilkPulseUpdates
		_milkPulseCounter = 0
		PulseMilkMod(PlayerRef)
	EndIf

	RegisterForSingleUpdate(UpdateSeconds)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	_running = false
	UnregisterForUpdate()

	If akTarget == PlayerRef
		RestoreMorphs(PlayerRef)
		RestoreHairColor(PlayerRef)
		RemoveHorns(PlayerRef)
		RemoveCosmetics(PlayerRef)
		RestoreActorValueChanges(PlayerRef)
		If cfl_BodymorphActiveForm.GetValueInt() == 3
			cfl_BodymorphActiveForm.SetValue(0)
		EndIf
		Debug.Notification("Your Cowform fades.")
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
	_nippleSize = NiOverride.GetMorphValue(akActor, "NippleSize")
	_areolaSize = NiOverride.GetMorphValue(akActor, "AreolaSize")
EndFunction

Function SaveHairColor(Actor akActor)
	_previousHairColor = akActor.GetActorBase().GetHairColor()
	If !_previousHairColor
		_previousHairColor = PO3_SKSEFunctions.GetHairColor(akActor)
	EndIf
EndFunction

Function ApplyHairColor(Actor akActor)
	If cfl_CowformHairColor
		PO3_SKSEFunctions.SetHairColor(akActor, cfl_CowformHairColor)
	EndIf
EndFunction

Function RestoreHairColor(Actor akActor)
	If _previousHairColor
		PO3_SKSEFunctions.SetHairColor(akActor, _previousHairColor)
	EndIf
EndFunction

Function ApplyCowMorphs(Actor akActor)
	Float scale = 1.0 + (_tier * 0.25)

	SetMorph(akActor, "Breasts", _breasts + (0.75 * scale))
	SetMorph(akActor, "NippleSize", _nippleSize + (0.20 * scale))
	SetMorph(akActor, "AreolaSize", _areolaSize + (0.18 * scale))
	SetMorph(akActor, "Belly", _belly + (0.22 * scale))
	SetMorph(akActor, "Hips", _hips + (0.22 * scale))
	SetMorph(akActor, "Butt", _butt + (0.15 * scale))
	SetMorph(akActor, "Waist", _waist + (0.08 * scale))
	SetMorph(akActor, "Arms", _arms + (0.08 * scale))
	SetMorph(akActor, "Thighs", _thighs + (0.10 * scale))

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
	SetMorph(akActor, "NippleSize", _nippleSize)
	SetMorph(akActor, "AreolaSize", _areolaSize)
	NiOverride.UpdateModelWeight(akActor)
EndFunction

Function SetMorph(Actor akActor, String asMorph, Float afValue)
	NiOverride.ClearMorphValue(akActor, asMorph)
	NiOverride.SetMorphValue(akActor, asMorph, PapyrusUtil.ClampFloat(afValue, -2.0, 3.0))
EndFunction

Function ApplyCosmetics(Actor akActor)
	RemoveCosmetics(akActor)
	SlaveTats.simple_add_tattoo(akActor, "Cowform Cosmetics", "Cow Body Spots", 0xFFFFFFFF, true, true, 0.55)
	SlaveTats.simple_add_tattoo(akActor, "Cowform Cosmetics", "Cow Udder Mark", 0xFFE8D9C4, true, true, 0.50)
	If _tier >= 1
		SlaveTats.simple_add_tattoo(akActor, "Cowform Cosmetics", "Cow Face Mark", 0xFF2A1A10, true, true, 0.35)
	EndIf
	If _tier >= 2
		SlaveTats.simple_add_tattoo(akActor, "Cowform Cosmetics", "Cow Hand Mark", 0xFF2A1A10, true, true, 0.45)
		SlaveTats.simple_add_tattoo(akActor, "Cowform Cosmetics", "Cow Hoof Tint", 0xFF1D120D, true, true, 0.50)
	EndIf
	If _tier >= 3
		SlaveTats.simple_add_tattoo(akActor, "Cowform Cosmetics", "Cow Heavy Spots", 0xFF1B120D, true, true, 0.40)
	EndIf
	SlaveTats.synchronize_tattoos(akActor, true)
EndFunction

Function RemoveCosmetics(Actor akActor)
	SlaveTats.simple_remove_tattoo(akActor, "Cowform Cosmetics", "Cow Body Spots", true, true)
	SlaveTats.simple_remove_tattoo(akActor, "Cowform Cosmetics", "Cow Udder Mark", true, true)
	SlaveTats.simple_remove_tattoo(akActor, "Cowform Cosmetics", "Cow Face Mark", true, true)
	SlaveTats.simple_remove_tattoo(akActor, "Cowform Cosmetics", "Cow Hand Mark", true, true)
	SlaveTats.simple_remove_tattoo(akActor, "Cowform Cosmetics", "Cow Hoof Tint", true, true)
	SlaveTats.simple_remove_tattoo(akActor, "Cowform Cosmetics", "Cow Heavy Spots", true, true)
	SlaveTats.synchronize_tattoos(akActor, true)
EndFunction

Function ApplyHorns(Actor akActor)
	If _tier < 1
		Return
	EndIf

	_cowHorns = Game.GetFormFromFile(0x0012E5, "TDNEquipableHorns.esp") as Armor
	If !_cowHorns
		Return
	EndIf

	If akActor.GetItemCount(_cowHorns) <= 0
		akActor.AddItem(_cowHorns, 1, true)
		_addedCowHorns = true
	EndIf
	akActor.EquipItem(_cowHorns, false, true)
EndFunction

Function RemoveHorns(Actor akActor)
	If !_cowHorns
		Return
	EndIf

	If akActor.IsEquipped(_cowHorns)
		akActor.UnequipItem(_cowHorns, false, true)
	EndIf
	If _addedCowHorns
		akActor.RemoveItem(_cowHorns, 1, true)
	EndIf
	_addedCowHorns = false
EndFunction

Function ApplyActorValueChanges(Actor akActor)
	_healthMod = 25.0 + (_tier * 15.0)
	_staminaMod = 25.0 + (_tier * 10.0)
	_carryWeightMod = 30.0 + (_tier * 20.0)
	_speedMod = -8.0 - (_tier * 2.0)
	_magickaRateMod = -10.0 - (_tier * 4.0)

	akActor.ModActorValue("Health", _healthMod)
	akActor.ModActorValue("Stamina", _staminaMod)
	akActor.ModActorValue("CarryWeight", _carryWeightMod)
	akActor.ModActorValue("SpeedMult", _speedMod)
	akActor.ModActorValue("MagickaRateMult", _magickaRateMod)
EndFunction

Function RestoreActorValueChanges(Actor akActor)
	akActor.ModActorValue("Health", -_healthMod)
	akActor.ModActorValue("Stamina", -_staminaMod)
	akActor.ModActorValue("CarryWeight", -_carryWeightMod)
	akActor.ModActorValue("SpeedMult", -_speedMod)
	akActor.ModActorValue("MagickaRateMult", -_magickaRateMod)
EndFunction

Function SetupMilkMod(Actor akActor)
	_milkQuest = Game.GetFormFromFile(0x00E209, "MilkModNEW.esp") as MilkQUEST
	If !_milkQuest
		Return
	EndIf

	If _milkQuest.MilkMaid.Find(akActor) == -1 && _milkQuest.MilkSlave.Find(akActor) == -1
		_milkQuest.AssignSlot(akActor)
	EndIf

	PulseMilkMod(akActor)
EndFunction

Function PulseMilkMod(Actor akActor)
	If !_milkQuest
		Return
	EndIf

	If _milkQuest.MilkMaid.Find(akActor) == -1 && _milkQuest.MilkSlave.Find(akActor) == -1
		Return
	EndIf

	Float milkBoost = 0.20 + (_tier * 0.12)
	MME_Storage.changeMilkCurrent(akActor, milkBoost, true)
	If _tier >= 2
		MME_Storage.changeLactacidCurrent(akActor, 0.10 + (_tier * 0.05))
	EndIf
	_milkQuest.CurrentSize(akActor)
EndFunction

Function EnforceRestrictions(Actor akActor)
	If _tier >= 1
		SafeUnequipSlot(akActor, 32)
	EndIf

	If _tier >= 3
		SafeUnequipSlot(akActor, 30)
		SafeUnequipSlot(akActor, 31)
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
