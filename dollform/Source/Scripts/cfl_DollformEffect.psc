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

	Int activeForm = cfl_BodymorphActiveForm.GetValueInt()
	If activeForm != 0
		If activeForm == 1
			Debug.Notification("Dollform is already active.")
			Dispel()
			Return
		EndIf
		Debug.Notification("Another bodymorph alteration is already active.")
		Dispel()
		Return
	EndIf

	_running = true
	_startedAt = Utility.GetCurrentRealTime()
	_startupRefreshes = 2
	cfl_BodymorphActiveForm.SetValue(1)
	_tier = cfl_DollformMarkTier.GetValueInt()
	_cooldownActors = New Actor[32]
	_cooldownTimes = New Float[32]

	EnsureMCMQuestStarted()
	SaveMorphs(PlayerRef)
	SaveHairColor(PlayerRef)
	ApplyDollMorphs(PlayerRef)
	ApplyHairColor(PlayerRef)
	ApplyProgressTattoo(PlayerRef)
	ApplyCosmetics(PlayerRef)
	ApplyActorValueChanges(PlayerRef)
	EnforceClothingRules(PlayerRef)

	Debug.Notification("Your body smooths into Dollform.")
	RegisterForSingleUpdate(1.0)
EndEvent

Event OnUpdate()
	If !_running
		Return
	EndIf

	EnforceClothingRules(PlayerRef)
	If _startupRefreshes > 0
		RefreshAppearance(PlayerRef)
		_startupRefreshes -= 1
		RegisterForSingleUpdate(1.0)
		Return
	EndIf

	If cfl_DollformUseSeconds
		cfl_DollformUseSeconds.SetValue(cfl_DollformUseSeconds.GetValue() + UpdateSeconds)
		CheckProgression(PlayerRef)
	EndIf

	PulseAura()
	RegisterForSingleUpdate(UpdateSeconds)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	_running = false
	UnregisterForUpdate()

	If akTarget == PlayerRef
		If Utility.GetCurrentRealTime() - _startedAt < 10.0
			Debug.Notification("Dollform cleanup skipped because the effect ended immediately.")
			Return
		EndIf
		RestoreMorphs(PlayerRef)
		RestoreHairColor(PlayerRef)
		RemoveCosmetics(PlayerRef)
		RestoreActorValueChanges(PlayerRef)
		If cfl_BodymorphActiveForm.GetValueInt() == 1
			cfl_BodymorphActiveForm.SetValue(0)
		EndIf
		Debug.Notification("Your Dollform fades.")
	EndIf
EndEvent

Function SaveMorphs(Actor akActor)
	_breasts = NiOverride.GetMorphValue(akActor, "Breasts")
	_butt = NiOverride.GetMorphValue(akActor, "Butt")
	_hips = NiOverride.GetMorphValue(akActor, "Hips")
	_thighs = NiOverride.GetMorphValue(akActor, "Thighs")
	_waist = NiOverride.GetMorphValue(akActor, "Waist")
	_arms = NiOverride.GetMorphValue(akActor, "Arms")
	_abs = NiOverride.GetMorphValue(akActor, "MuscleAbs")
	_muscleArms = NiOverride.GetMorphValue(akActor, "MuscleArms")
	_muscleLegs = NiOverride.GetMorphValue(akActor, "MuscleLegs")
	_nippleSize = NiOverride.GetMorphValue(akActor, "NippleSize")
	_areolaSize = NiOverride.GetMorphValue(akActor, "AreolaSize")
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
	RestoreDirectMorph(akActor, "Breasts", _breasts)
	RestoreDirectMorph(akActor, "Butt", _butt)
	RestoreDirectMorph(akActor, "Hips", _hips)
	RestoreDirectMorph(akActor, "Thighs", _thighs)
	RestoreDirectMorph(akActor, "Waist", _waist)
	RestoreDirectMorph(akActor, "Arms", _arms)
	RestoreDirectMorph(akActor, "MuscleAbs", _abs)
	RestoreDirectMorph(akActor, "MuscleArms", _muscleArms)
	RestoreDirectMorph(akActor, "MuscleLegs", _muscleLegs)
	RestoreDirectMorph(akActor, "NippleSize", _nippleSize)
	RestoreDirectMorph(akActor, "AreolaSize", _areolaSize)
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
	Int newTier = TierForUseSeconds(cfl_DollformUseSeconds.GetValue())
	If newTier <= _tier
		Return
	EndIf

	RestoreActorValueChanges(akActor)
	_tier = newTier
	cfl_DollformMarkTier.SetValue(newTier)
	ApplyDollMorphs(akActor)
	ApplyProgressTattoo(akActor)
	ApplyCosmetics(akActor)
	ApplyActorValueChanges(akActor)
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
	SlaveTats.simple_remove_tattoo(akActor, "Dollform", "Dollform Attunement", true, false)
	SlaveTats.simple_add_tattoo(akActor, "Dollform", "Dollform Attunement", 0xFFFFD6EE, true, false, alpha)
	SlaveTats.synchronize_tattoos(akActor, true)
EndFunction

Function ApplyCosmetics(Actor akActor)
	; These are Dollform-owned SlaveTats aliases so removal does not target the user's normal makeup entries.
	RemoveCosmetics(akActor)
	SlaveTats.simple_add_tattoo(akActor, "Dollform Cosmetics", "Doll Foot Polish", 0xFFFF66AA, true, true, 0.85)

	SlaveTats.synchronize_tattoos(akActor, true)
EndFunction

Function RemoveCosmetics(Actor akActor)
	SlaveTats.simple_remove_tattoo(akActor, "Dollform Cosmetics", "Doll Blush", true, true)
	SlaveTats.simple_remove_tattoo(akActor, "Dollform Cosmetics", "Doll Hand Polish", true, true)
	SlaveTats.simple_remove_tattoo(akActor, "Dollform Cosmetics", "Doll Foot Polish", true, true)
	SlaveTats.simple_remove_tattoo(akActor, "Dollform Cosmetics", "Doll Mascara", true, true)
	SlaveTats.synchronize_tattoos(akActor, true)
EndFunction

Function ApplyActorValueChanges(Actor akActor)
	_armorMod = 60.0 + (_tier * 12.0)
	_speechMod = 10.0 + (_tier * 3.0)
	_speedMod = -12.0 - (_tier * 3.0)
	_magickaRateMod = -15.0 - (_tier * 4.0)
	_attackDamageMod = -10.0 - (_tier * 3.0)

	akActor.ModActorValue("DamageResist", _armorMod)
	akActor.ModActorValue("Speechcraft", _speechMod)
	akActor.ModActorValue("SpeedMult", _speedMod)
	akActor.ModActorValue("MagickaRateMult", _magickaRateMod)
	akActor.ModActorValue("MeleeDamage", _attackDamageMod)
EndFunction

Function RestoreActorValueChanges(Actor akActor)
	akActor.ModActorValue("DamageResist", -_armorMod)
	akActor.ModActorValue("Speechcraft", -_speechMod)
	akActor.ModActorValue("SpeedMult", -_speedMod)
	akActor.ModActorValue("MagickaRateMult", -_magickaRateMod)
	akActor.ModActorValue("MeleeDamage", -_attackDamageMod)
EndFunction

Function EnforceClothingRules(Actor akActor)
	akActor.UnequipItemSlot(32)

	If _tier >= 3
		akActor.UnequipItemSlot(30)
		akActor.UnequipItemSlot(31)
		akActor.UnequipItemSlot(33)
		akActor.UnequipItemSlot(37)
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
	Float now = Utility.GetCurrentRealTime()
	Int i = 0
	While i < _cooldownActors.Length
		If _cooldownActors[i] == akActor
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
	Float now = Utility.GetCurrentRealTime()
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
