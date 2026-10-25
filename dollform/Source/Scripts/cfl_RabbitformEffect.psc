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
Float _belly
Float _calves
ColorForm _previousHairColor

Float _speedMod
Float _staminaMod
Float _staminaRateMod
Float _healthMod
Float _carryWeightMod
Float _magickaRateMod
Float _sneakMod
Float _damageResistMod

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
		If activeForm == 4
			Debug.Notification("Rabbitform fades.")
			PlayerRef.DispelSpell(cfl_SpellRabbitform)
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
	If !BeginActiveForm(4)
		_running = false
		_ownsForm = false
		_transitioning = false
		Dispel()
		Return
	EndIf
	_tier = PapyrusUtil.ClampInt(cfl_RabbitformMarkTier.GetValueInt(), 0, 4)

	EnsureMCMQuestStarted()
	SaveMorphs(PlayerRef)
	SaveHairColor(PlayerRef)
	ApplyRabbitMorphs(PlayerRef)
	ApplyHairColor(PlayerRef)
	ApplyActorValueChanges(PlayerRef)
	ApplyProgressTattoo(PlayerRef)
	ApplyCosmetics(PlayerRef)
	DetectFertilityMode()

	Debug.Notification("Your body quickens into Rabbitform.")
	CompleteTransition(UpdateSeconds)
EndEvent

Event OnUpdate()
	If !_running
		Return
	EndIf
	If !IsActiveInstance(4)
		FinishForm()
		Dispel()
		Return
	EndIf
	If _transitioning
		Return
	EndIf
	_transitioning = true


	If cfl_RabbitformUseSeconds
		cfl_RabbitformUseSeconds.SetValue(cfl_RabbitformUseSeconds.GetValue() + ElapsedUseSeconds())
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
	If IsActiveInstance(4)
		RestoreMorphs(PlayerRef)
		RestoreHairColor(PlayerRef)
		RemoveCosmetics(PlayerRef)
		If IsActiveInstance(4)
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
	Float scale = (1.0 + (_tier * 0.20)) * MorphScale()

	SetMorph(akActor, "Hips", 0.55 * scale)
	SetMorph(akActor, "HipUpperWidth", 0.35 * scale)
	SetMorph(akActor, "Butt", 0.50 * scale)
	SetMorph(akActor, "BigButt", 0.20 * scale)
	SetMorph(akActor, "Thighs", 0.38 * scale)
	SetMorph(akActor, "ChubbyLegs", 0.12 * scale)
	SetMorph(akActor, "CalfSize", 0.48 * scale)
	SetMorph(akActor, "CalfFBThicc_v2", 0.42 * scale)
	SetMorph(akActor, "Waist", -0.32 * scale)
	SetMorph(akActor, "Belly", -0.22 * scale)
	SetMorph(akActor, "Breasts", 0.10 * scale)

	SetDirectMorph(akActor, "Hips", _hips, 0.65 * scale)
	SetDirectMorph(akActor, "Butt", _butt, 0.55 * scale)
	SetDirectMorph(akActor, "Thighs", _thighs, 0.42 * scale)
	SetDirectMorph(akActor, "CalfSize", _calves, 0.62 * scale)
	SetDirectMorph(akActor, "Waist", _waist, -0.35 * scale)
	SetDirectMorph(akActor, "Belly", _belly, -0.22 * scale)
	SetDirectMorph(akActor, "Breasts", _breasts, 0.10 * scale)

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
	Int newTier = TierForUseSeconds(cfl_RabbitformUseSeconds.GetValue())
	If newTier <= _tier
		Return
	EndIf

	_tier = newTier
	cfl_RabbitformMarkTier.SetValue(newTier)
	ApplyActorValueChanges(akActor)
	ApplyRabbitMorphs(akActor)
	ApplyProgressTattoo(akActor)
	ApplyCosmetics(akActor)
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
	SlaveTats.simple_remove_tattoo(akActor, "Rabbitform", "Rabbitform Moon Mark", false, true)
	SlaveTats.simple_add_tattoo(akActor, "Rabbitform", "Rabbitform Moon Mark", 0xFFE8E2F6, false, true, alpha)
EndFunction

Function ApplyCosmetics(Actor akActor)
	RemoveCosmetics(akActor, false)
	SlaveTats.simple_add_tattoo(akActor, "Rabbitform Cosmetics", "Rabbit Hip Mark", 0xFFE8E2F6, false, true, 0.45)
	If _tier >= 2
		SlaveTats.simple_add_tattoo(akActor, "Rabbitform Cosmetics", "Rabbit Leap Mark", 0xFFFFFFFF, false, true, 0.40)
	EndIf
	SlaveTats.synchronize_tattoos(akActor, true)
EndFunction

Function RemoveCosmetics(Actor akActor, Bool abSynchronize = true)
	SlaveTats.simple_remove_tattoo(akActor, "Rabbitform Cosmetics", "Rabbit Hip Mark", false, true)
	SlaveTats.simple_remove_tattoo(akActor, "Rabbitform Cosmetics", "Rabbit Leap Mark", false, true)
	If abSynchronize
		SlaveTats.synchronize_tattoos(akActor, true)
	EndIf
EndFunction

Function ApplyActorValueChanges(Actor akActor)

	akActor.ModActorValue("SpeedMult", (30.0 + (_tier * 7.0)) - _speedMod)
	_speedMod = 30.0 + (_tier * 7.0)
	akActor.ModActorValue("Stamina", (25.0 + (_tier * 10.0)) - _staminaMod)
	_staminaMod = 25.0 + (_tier * 10.0)
	akActor.ModActorValue("StaminaRateMult", (55.0 + (_tier * 15.0)) - _staminaRateMod)
	_staminaRateMod = 55.0 + (_tier * 15.0)
	akActor.ModActorValue("Health", (-35.0 - (_tier * 12.0)) - _healthMod)
	_healthMod = -35.0 - (_tier * 12.0)
	akActor.ModActorValue("CarryWeight", (-35.0 - (_tier * 10.0)) - _carryWeightMod)
	_carryWeightMod = -35.0 - (_tier * 10.0)
	akActor.ModActorValue("MagickaRateMult", (-5.0 - (_tier * 2.0)) - _magickaRateMod)
	_magickaRateMod = -5.0 - (_tier * 2.0)
	akActor.ModActorValue("Sneak", (15.0 + (_tier * 5.0)) - _sneakMod)
	_sneakMod = 15.0 + (_tier * 5.0)
	akActor.ModActorValue("DamageResist", (-25.0 - (_tier * 8.0)) - _damageResistMod)
	_damageResistMod = -25.0 - (_tier * 8.0)
EndFunction

Function RestoreActorValueChanges(Actor akActor)
	akActor.ModActorValue("SpeedMult", -_speedMod)
	_speedMod = 0.0
	akActor.ModActorValue("Stamina", -_staminaMod)
	_staminaMod = 0.0
	akActor.ModActorValue("StaminaRateMult", -_staminaRateMod)
	_staminaRateMod = 0.0
	akActor.ModActorValue("Health", -_healthMod)
	_healthMod = 0.0
	akActor.ModActorValue("CarryWeight", -_carryWeightMod)
	_carryWeightMod = 0.0
	akActor.ModActorValue("MagickaRateMult", -_magickaRateMod)
	_magickaRateMod = 0.0
	akActor.ModActorValue("Sneak", -_sneakMod)
	_sneakMod = 0.0
	akActor.ModActorValue("DamageResist", -_damageResistMod)
	_damageResistMod = 0.0
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
