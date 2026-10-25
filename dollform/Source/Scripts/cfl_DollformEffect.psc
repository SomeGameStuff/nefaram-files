Scriptname cfl_DollformEffect extends ActiveMagicEffect

Import NiOverride

GlobalVariable Property cfl_DollformMarkTier Auto
GlobalVariable Property cfl_BodymorphActiveForm Auto
GlobalVariable Property cfl_DollformUseSeconds Auto
GlobalVariable Property cfl_BodymorphMorphScale Auto
GlobalVariable Property cfl_BodymorphProgressionScale Auto
Spell Property cfl_SpellDollform Auto
Spell Property cfl_DollformEnemyDistractSpell Auto
ColorForm Property cfl_DollformHairColor Auto
Actor Property PlayerRef Auto

Float Property UpdateSeconds = 6.0 Auto
Float Property AuraRadius = 1400.0 Auto
Float Property CooldownSeconds = 45.0 Auto
Int Property MaxActorsPerPulse = 3 Auto
Int Property SampleAttempts = 8 Auto
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
Actor[] _cooldownActors
Float[] _cooldownTimes

Float _breasts
Float _butt
Float _hips
Float _thighs
Float _waist
Float _arms
Float _abs
Float _muscleArms
Float _muscleLegs
Float _nippleSize
Float _areolaSize
ColorForm _previousHairColor

Float _armorMod
Float _speechMod
Float _speedMod
Float _magickaRateMod
Float _attackDamageMod
Float _startedAt

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
		If activeForm == 1
			Debug.Notification("Dollform fades.")
			PlayerRef.DispelSpell(cfl_SpellDollform)
			Return
		EndIf
		Debug.Notification("Another bodymorph alteration is already active.")
		Dispel()
		Return
	EndIf

	_transitioning = true
	_running = true
	_ownsForm = true
	_startedAt = Utility.GetCurrentRealTime()
	_startupRefreshes = 0
	_lastElapsed = GetTimeElapsed()
	_elapsedClockReady = true
	If !BeginActiveForm(1)
		_running = false
		_ownsForm = false
		_transitioning = false
		Dispel()
		Return
	EndIf
	_tier = PapyrusUtil.ClampInt(cfl_DollformMarkTier.GetValueInt(), 0, 4)
	_cooldownActors = New Actor[32]
	_cooldownTimes = New Float[32]

	EnsureMCMQuestStarted()
	SaveMorphs(PlayerRef)
	SaveHairColor(PlayerRef)
	ApplyDollMorphs(PlayerRef)
	ApplyHairColor(PlayerRef)
	ApplyActorValueChanges(PlayerRef)
	ApplyProgressTattoo(PlayerRef)
	ApplyCosmetics(PlayerRef)
	EnforceClothingRules(PlayerRef)

	Debug.Notification("Your body smooths into Dollform.")
	CompleteTransition(UpdateSeconds)
EndEvent

Event OnUpdate()
	If !_running
		Return
	EndIf
	If !IsActiveInstance(1)
		FinishForm()
		Dispel()
		Return
	EndIf
	If _transitioning
		Return
	EndIf
	_transitioning = true

	EnforceClothingRules(PlayerRef)

	If cfl_DollformUseSeconds
		cfl_DollformUseSeconds.SetValue(cfl_DollformUseSeconds.GetValue() + ElapsedUseSeconds())
		CheckProgression(PlayerRef)
	EndIf

	PulseAura()
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
	If IsActiveInstance(1)
		RestoreMorphs(PlayerRef)
		RestoreHairColor(PlayerRef)
		RemoveCosmetics(PlayerRef)
		If IsActiveInstance(1)
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
	If cfl_DollformHairColor
		PO3_SKSEFunctions.SetHairColor(akActor, cfl_DollformHairColor)
	EndIf
EndFunction

Function RestoreHairColor(Actor akActor)
	If _previousHairColor
		PO3_SKSEFunctions.SetHairColor(akActor, _previousHairColor)
	EndIf
EndFunction

Function ApplyDollMorphs(Actor akActor)
	Float scale = (1.0 + (_tier * 0.25)) * MorphScale()

	SetMorph(akActor, "Breasts", 0.70 * scale)
	SetMorph(akActor, "DoubleMelon", 0.35 * scale)
	SetMorph(akActor, "Butt", 0.50 * scale)
	SetMorph(akActor, "BigButt", 0.25 * scale)
	SetMorph(akActor, "Hips", 0.40 * scale)
	SetMorph(akActor, "HipUpperWidth", 0.25 * scale)
	SetMorph(akActor, "Thighs", 0.30 * scale)
	SetMorph(akActor, "Waist", -0.35 * scale)
	SetMorph(akActor, "Arms", -0.18 * scale)
	SetMorph(akActor, "MuscleAbs", -0.45 * scale)
	SetMorph(akActor, "MuscleArms", -0.40 * scale)
	SetMorph(akActor, "MuscleLegs", -0.30 * scale)

	If _tier >= 1
		SetMorph(akActor, "NippleSize", 0.20 * scale)
		SetMorph(akActor, "AreolaSize", 0.16 * scale)
	EndIf

	ApplyDirectDollMorphs(akActor, scale)
	RefreshAppearance(akActor)
EndFunction

Function RestoreMorphs(Actor akActor)
	NiOverride.ClearBodyMorphKeys(akActor, MorphKey)
	NiOverride.ClearBodyMorphKeys(akActor, VisibleMorphKey)
	RefreshAppearance(akActor)
EndFunction

Function ApplyDirectDollMorphs(Actor akActor, Float afScale)
	SetDirectMorph(akActor, "Breasts", _breasts, 1.00 * afScale)
	SetDirectMorph(akActor, "Butt", _butt, 0.75 * afScale)
	SetDirectMorph(akActor, "Hips", _hips, 0.55 * afScale)
	SetDirectMorph(akActor, "Thighs", _thighs, 0.45 * afScale)
	SetDirectMorph(akActor, "Waist", _waist, -0.45 * afScale)
	SetDirectMorph(akActor, "Arms", _arms, -0.25 * afScale)
	SetDirectMorph(akActor, "MuscleAbs", _abs, -0.45 * afScale)
	SetDirectMorph(akActor, "MuscleArms", _muscleArms, -0.35 * afScale)
	SetDirectMorph(akActor, "MuscleLegs", _muscleLegs, -0.25 * afScale)
	If _tier >= 1
		SetDirectMorph(akActor, "NippleSize", _nippleSize, 0.25 * afScale)
		SetDirectMorph(akActor, "AreolaSize", _areolaSize, 0.20 * afScale)
	EndIf
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
	Int newTier = TierForUseSeconds(cfl_DollformUseSeconds.GetValue())
	If newTier <= _tier
		Return
	EndIf

	_tier = newTier
	cfl_DollformMarkTier.SetValue(newTier)
	ApplyActorValueChanges(akActor)
	ApplyDollMorphs(akActor)
	ApplyProgressTattoo(akActor)
	ApplyCosmetics(akActor)
	EnforceClothingRules(akActor)
	Game.AdvanceSkill("Alteration", 35.0 + (newTier * 20.0))
	Debug.Notification("Dollform deepens to tier " + newTier + ".")
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
	SlaveTats.simple_remove_tattoo(akActor, "Dollform", "Dollform Attunement", false, true)
	SlaveTats.simple_add_tattoo(akActor, "Dollform", "Dollform Attunement", 0xFFFFD6EE, false, true, alpha)
EndFunction

Function ApplyCosmetics(Actor akActor)
	; These are Dollform-owned SlaveTats aliases so removal does not target the user's normal makeup entries.
	RemoveCosmetics(akActor, false)
	SlaveTats.simple_add_tattoo(akActor, "Dollform Cosmetics", "Doll Foot Polish", 0xFFFF66AA, false, true, 0.85)

	SlaveTats.synchronize_tattoos(akActor, true)
EndFunction

Function RemoveCosmetics(Actor akActor, Bool abSynchronize = true)
	SlaveTats.simple_remove_tattoo(akActor, "Dollform Cosmetics", "Doll Blush", false, true)
	SlaveTats.simple_remove_tattoo(akActor, "Dollform Cosmetics", "Doll Hand Polish", false, true)
	SlaveTats.simple_remove_tattoo(akActor, "Dollform Cosmetics", "Doll Foot Polish", false, true)
	SlaveTats.simple_remove_tattoo(akActor, "Dollform Cosmetics", "Doll Mascara", false, true)
	If abSynchronize
		SlaveTats.synchronize_tattoos(akActor, true)
	EndIf
EndFunction

Function ApplyActorValueChanges(Actor akActor)

	akActor.ModActorValue("DamageResist", (60.0 + (_tier * 12.0)) - _armorMod)
	_armorMod = 60.0 + (_tier * 12.0)
	akActor.ModActorValue("Speechcraft", (10.0 + (_tier * 3.0)) - _speechMod)
	_speechMod = 10.0 + (_tier * 3.0)
	akActor.ModActorValue("SpeedMult", (-12.0 - (_tier * 3.0)) - _speedMod)
	_speedMod = -12.0 - (_tier * 3.0)
	akActor.ModActorValue("MagickaRateMult", (-15.0 - (_tier * 4.0)) - _magickaRateMod)
	_magickaRateMod = -15.0 - (_tier * 4.0)
	akActor.ModActorValue("MeleeDamage", (-10.0 - (_tier * 3.0)) - _attackDamageMod)
	_attackDamageMod = -10.0 - (_tier * 3.0)
EndFunction

Function RestoreActorValueChanges(Actor akActor)
	akActor.ModActorValue("DamageResist", -_armorMod)
	_armorMod = 0.0
	akActor.ModActorValue("Speechcraft", -_speechMod)
	_speechMod = 0.0
	akActor.ModActorValue("SpeedMult", -_speedMod)
	_speedMod = 0.0
	akActor.ModActorValue("MagickaRateMult", -_magickaRateMod)
	_magickaRateMod = 0.0
	akActor.ModActorValue("MeleeDamage", -_attackDamageMod)
	_attackDamageMod = 0.0
EndFunction

Function EnforceClothingRules(Actor akActor)
	If _tier >= 1
		SafeUnequipSlot(akActor, 32)
	EndIf

	If _tier >= 3
		SafeUnequipSlot(akActor, 30)
		SafeUnequipSlot(akActor, 31)
		SafeUnequipSlot(akActor, 33)
		SafeUnequipSlot(akActor, 37)
	EndIf
EndFunction

Function PulseAura()
	Int applied = 0
	Int attempts = 0

	While attempts < SampleAttempts && applied < MaxActorsPerPulse
		Actor candidate = Game.FindRandomActorFromRef(PlayerRef, AuraRadius)
		If IsValidAuraTarget(candidate)
			If !IsOnCooldown(candidate)
				ApplyAuraEffect(candidate)
				MarkCooldown(candidate)
				applied += 1
			EndIf
		EndIf
		attempts += 1
	EndWhile
EndFunction

Bool Function IsValidAuraTarget(Actor akActor)
	If !akActor
		Return false
	EndIf

	If akActor == PlayerRef || akActor.IsDead() || akActor.IsChild()
		Return false
	EndIf

	If !akActor.IsHostileToActor(PlayerRef) && akActor.GetCombatTarget() != PlayerRef
		Return false
	EndIf

	If !akActor.HasLOS(PlayerRef)
		Return false
	EndIf

	Return true
EndFunction

Function ApplyAuraEffect(Actor akActor)
	Int roll = Utility.RandomInt(1, 100)
	Int staggerChance = 20 + (_tier * 4)
	Int distractChance = 35 + (_tier * 5)

	If roll <= staggerChance
		PlayerRef.PushActorAway(akActor, 0.35)
	ElseIf roll <= staggerChance + distractChance
		If cfl_DollformEnemyDistractSpell
			cfl_DollformEnemyDistractSpell.Cast(PlayerRef, akActor)
		EndIf
	EndIf

	OArousedScript aroused = OArousedScript.GetOAroused()
	If aroused
		aroused.ModifyArousal(akActor, 2.0 + (_tier * 1.5))
	EndIf
EndFunction

Bool Function IsOnCooldown(Actor akActor)
	Float now = GetTimeElapsed()
	Int i = 0
	While i < _cooldownActors.Length
		If _cooldownActors[i] == akActor
			; Old saves stored application uptime, which resets on restarting Skyrim.
			If now < _cooldownTimes[i]
				Return false
			EndIf
			If now - _cooldownTimes[i] < CooldownSeconds
				Return true
			EndIf
			Return false
		EndIf
		i += 1
	EndWhile
	Return false
EndFunction

Function MarkCooldown(Actor akActor)
	Float now = GetTimeElapsed()
	Int emptyIndex = -1
	Int oldestIndex = 0
	Float oldestTime = now
	Int i = 0

	While i < _cooldownActors.Length
		If _cooldownActors[i] == akActor
			_cooldownTimes[i] = now
			Return
		EndIf

		If !_cooldownActors[i] && emptyIndex < 0
			emptyIndex = i
		EndIf

		If _cooldownTimes[i] < oldestTime
			oldestTime = _cooldownTimes[i]
			oldestIndex = i
		EndIf

		i += 1
	EndWhile

	If emptyIndex >= 0
		_cooldownActors[emptyIndex] = akActor
		_cooldownTimes[emptyIndex] = now
	Else
		_cooldownActors[oldestIndex] = akActor
		_cooldownTimes[oldestIndex] = now
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
