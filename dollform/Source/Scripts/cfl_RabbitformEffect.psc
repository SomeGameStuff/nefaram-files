Scriptname cfl_RabbitformEffect extends ActiveMagicEffect

Import NiOverride

GlobalVariable Property cfl_RabbitformMarkTier Auto
GlobalVariable Property cfl_BodymorphActiveForm Auto
GlobalVariable Property cfl_RabbitformUseSeconds Auto
GlobalVariable Property cfl_BodymorphMorphScale Auto
GlobalVariable Property cfl_BodymorphProgressionScale Auto
Spell Property cfl_SpellRabbitform Auto
ColorForm Property cfl_RabbitformHairColor Auto
Actor Property PlayerRef Auto

Float Property UpdateSeconds = 5.0 Auto
String Property MorphKey = "Dollform.BodymorphAlterations" Auto
String Property VisibleMorphKey = "Dollform.BodymorphAlterations.Visible" Auto
Float Property Tier1Seconds = 120.0 Auto
Float Property Tier2Seconds = 360.0 Auto
Float Property Tier3Seconds = 900.0 Auto
Float Property Tier4Seconds = 1800.0 Auto

Bool _running = false
Int _tier = 0
Int _startupRefreshes = 0

Float _breasts
Float _butt
Float _hips
Float _thighs
Float _waist
Float _belly
Float _calves
ColorForm _previousHairColor

Float _speedMod
Float _staminaMod
Float _staminaRateMod
Float _healthMod
Float _carryWeightMod
Float _magickaRateMod

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If akTarget != PlayerRef
		Dispel()
		Return
	EndIf

	Int activeForm = cfl_BodymorphActiveForm.GetValueInt()
	If activeForm != 0
		If activeForm == 4
			Debug.Notification("Rabbitform is already active.")
			Dispel()
			Return
		EndIf
		Debug.Notification("Another bodymorph alteration is already active.")
		Dispel()
		Return
	EndIf

	_running = true
	_startupRefreshes = 2
	cfl_BodymorphActiveForm.SetValue(4)
	_tier = cfl_RabbitformMarkTier.GetValueInt()

	EnsureMCMQuestStarted()
	SaveMorphs(PlayerRef)
	SaveHairColor(PlayerRef)
	ApplyRabbitMorphs(PlayerRef)
	ApplyHairColor(PlayerRef)
	ApplyProgressTattoo(PlayerRef)
	ApplyCosmetics(PlayerRef)
	ApplyActorValueChanges(PlayerRef)
	DetectFertilityMode()

	Debug.Notification("Your body quickens into Rabbitform.")
	RegisterForSingleUpdate(1.0)
EndEvent

Event OnUpdate()
	If !_running
		Return
	EndIf

	If _startupRefreshes > 0
		RefreshAppearance(PlayerRef)
		_startupRefreshes -= 1
		RegisterForSingleUpdate(1.0)
		Return
	EndIf

	If cfl_RabbitformUseSeconds
		cfl_RabbitformUseSeconds.SetValue(cfl_RabbitformUseSeconds.GetValue() + UpdateSeconds)
		CheckProgression(PlayerRef)
	EndIf

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
		If cfl_BodymorphActiveForm.GetValueInt() == 4
			cfl_BodymorphActiveForm.SetValue(0)
		EndIf
		Debug.Notification("Your Rabbitform fades.")
	EndIf
EndEvent

Function SaveMorphs(Actor akActor)
	_breasts = NiOverride.GetMorphValue(akActor, "Breasts")
	_butt = NiOverride.GetMorphValue(akActor, "Butt")
	_hips = NiOverride.GetMorphValue(akActor, "Hips")
	_thighs = NiOverride.GetMorphValue(akActor, "Thighs")
	_waist = NiOverride.GetMorphValue(akActor, "Waist")
	_belly = NiOverride.GetMorphValue(akActor, "Belly")
	_calves = NiOverride.GetMorphValue(akActor, "CalfSize")
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
	If cfl_RabbitformHairColor
		PO3_SKSEFunctions.SetHairColor(akActor, cfl_RabbitformHairColor)
	EndIf
EndFunction

Function RestoreHairColor(Actor akActor)
	If _previousHairColor
		PO3_SKSEFunctions.SetHairColor(akActor, _previousHairColor)
	EndIf
EndFunction

Function ApplyRabbitMorphs(Actor akActor)
	Float scale = (1.0 + (_tier * 0.25)) * MorphScale()

	SetMorph(akActor, "Thighs", 0.55 * scale)
	SetMorph(akActor, "CalfSize", 0.35 * scale)
	SetMorph(akActor, "Hips", 0.30 * scale)
	SetMorph(akActor, "Butt", 0.45 * scale)
	SetMorph(akActor, "BigButt", 0.30 * scale)
	SetMorph(akActor, "Waist", -0.25 * scale)
	SetMorph(akActor, "Belly", -0.20 * scale)
	SetMorph(akActor, "Breasts", 0.18 * scale)

	SetDirectMorph(akActor, "Thighs", _thighs, 0.75 * scale)
	SetDirectMorph(akActor, "CalfSize", _calves, 0.45 * scale)
	SetDirectMorph(akActor, "Hips", _hips, 0.35 * scale)
	SetDirectMorph(akActor, "Butt", _butt, 0.60 * scale)
	SetDirectMorph(akActor, "Waist", _waist, -0.30 * scale)
	SetDirectMorph(akActor, "Belly", _belly, -0.20 * scale)
	SetDirectMorph(akActor, "Breasts", _breasts, 0.18 * scale)

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
	RestoreDirectMorph(akActor, "Belly", _belly)
	RestoreDirectMorph(akActor, "CalfSize", _calves)
	RefreshAppearance(akActor)
EndFunction

Function SetMorph(Actor akActor, String asMorph, Float afValue)
	NiOverride.ClearBodyMorph(akActor, asMorph, MorphKey)
	NiOverride.SetBodyMorph(akActor, asMorph, MorphKey, PapyrusUtil.ClampFloat(afValue, -2.0, 3.0))
EndFunction

Function SetDirectMorph(Actor akActor, String asMorph, Float afBaseValue, Float afDelta)
	NiOverride.ClearBodyMorph(akActor, asMorph, VisibleMorphKey)
	NiOverride.SetBodyMorph(akActor, asMorph, VisibleMorphKey, PapyrusUtil.ClampFloat(afDelta * 1.75, -2.0, 3.0))
EndFunction

Function RestoreDirectMorph(Actor akActor, String asMorph, Float afValue)
	NiOverride.ClearBodyMorph(akActor, asMorph, VisibleMorphKey)
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
	Int newTier = TierForUseSeconds(cfl_RabbitformUseSeconds.GetValue())
	If newTier <= _tier
		Return
	EndIf

	RestoreActorValueChanges(akActor)
	_tier = newTier
	cfl_RabbitformMarkTier.SetValue(newTier)
	ApplyRabbitMorphs(akActor)
	ApplyProgressTattoo(akActor)
	ApplyCosmetics(akActor)
	ApplyActorValueChanges(akActor)
	Game.AdvanceSkill("Alteration", 35.0 + (newTier * 20.0))
	Debug.Notification("Rabbitform deepens to tier " + newTier + ".")
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
	SlaveTats.simple_remove_tattoo(akActor, "Rabbitform", "Rabbitform Moon Mark", true, false)
	SlaveTats.simple_add_tattoo(akActor, "Rabbitform", "Rabbitform Moon Mark", 0xFFE8E2F6, true, false, alpha)
	SlaveTats.synchronize_tattoos(akActor, true)
EndFunction

Function ApplyCosmetics(Actor akActor)
	RemoveCosmetics(akActor)
	SlaveTats.simple_add_tattoo(akActor, "Rabbitform Cosmetics", "Rabbit Hip Mark", 0xFFE8E2F6, true, true, 0.45)
	If _tier >= 2
		SlaveTats.simple_add_tattoo(akActor, "Rabbitform Cosmetics", "Rabbit Leap Mark", 0xFFFFFFFF, true, true, 0.40)
	EndIf
	SlaveTats.synchronize_tattoos(akActor, true)
EndFunction

Function RemoveCosmetics(Actor akActor)
	SlaveTats.simple_remove_tattoo(akActor, "Rabbitform Cosmetics", "Rabbit Hip Mark", true, true)
	SlaveTats.simple_remove_tattoo(akActor, "Rabbitform Cosmetics", "Rabbit Leap Mark", true, true)
	SlaveTats.synchronize_tattoos(akActor, true)
EndFunction

Function ApplyActorValueChanges(Actor akActor)
	_speedMod = 35.0 + (_tier * 8.0)
	_staminaMod = 35.0 + (_tier * 15.0)
	_staminaRateMod = 45.0 + (_tier * 15.0)
	_healthMod = -30.0 - (_tier * 10.0)
	_carryWeightMod = -25.0 - (_tier * 10.0)
	_magickaRateMod = -8.0 - (_tier * 3.0)

	akActor.ModActorValue("SpeedMult", _speedMod)
	akActor.ModActorValue("Stamina", _staminaMod)
	akActor.ModActorValue("StaminaRateMult", _staminaRateMod)
	akActor.ModActorValue("Health", _healthMod)
	akActor.ModActorValue("CarryWeight", _carryWeightMod)
	akActor.ModActorValue("MagickaRateMult", _magickaRateMod)
EndFunction

Function RestoreActorValueChanges(Actor akActor)
	akActor.ModActorValue("SpeedMult", -_speedMod)
	akActor.ModActorValue("Stamina", -_staminaMod)
	akActor.ModActorValue("StaminaRateMult", -_staminaRateMod)
	akActor.ModActorValue("Health", -_healthMod)
	akActor.ModActorValue("CarryWeight", -_carryWeightMod)
	akActor.ModActorValue("MagickaRateMult", -_magickaRateMod)
EndFunction

Function DetectFertilityMode()
	Form fertilityQuest = Game.GetFormFromFile(0x000D62, "Fertility Mode 3 Fixes and Updates.esp")
	If fertilityQuest
		Debug.Notification("Rabbitform detected Fertility Mode; integration is status-only for now.")
	EndIf
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
