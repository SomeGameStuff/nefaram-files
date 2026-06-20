Scriptname cfl_DollformEffect extends ActiveMagicEffect

Import NiOverride

GlobalVariable Property cfl_DollformMarkTier Auto
GlobalVariable Property cfl_BodymorphActiveForm Auto
Spell Property cfl_DollformEnemyDistractSpell Auto
ColorForm Property cfl_DollformHairColor Auto
Actor Property PlayerRef Auto

Float Property UpdateSeconds = 6.0 Auto
Float Property AuraRadius = 1400.0 Auto
Float Property CooldownSeconds = 45.0 Auto
Int Property MaxActorsPerPulse = 3 Auto
Int Property SampleAttempts = 8 Auto

Bool _running = false
Int _tier = 0
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
	cfl_BodymorphActiveForm.SetValue(1)
	_tier = cfl_DollformMarkTier.GetValueInt()
	_cooldownActors = New Actor[32]
	_cooldownTimes = New Float[32]

	SaveMorphs(PlayerRef)
	SaveHairColor(PlayerRef)
	ApplyDollMorphs(PlayerRef)
	ApplyHairColor(PlayerRef)
	ApplyCosmetics(PlayerRef)
	ApplyActorValueChanges(PlayerRef)
	EnforceClothingRules(PlayerRef)

	Debug.Notification("Your body smooths into Dollform.")
	RegisterForSingleUpdate(UpdateSeconds)
EndEvent

Event OnUpdate()
	If !_running
		Return
	EndIf

	EnforceClothingRules(PlayerRef)
	PulseAura()
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
	Float scale = 1.0 + (_tier * 0.18)

	SetMorph(akActor, "Breasts", _breasts + (0.50 * scale))
	SetMorph(akActor, "Butt", _butt + (0.35 * scale))
	SetMorph(akActor, "Hips", _hips + (0.25 * scale))
	SetMorph(akActor, "Thighs", _thighs + (0.20 * scale))
	SetMorph(akActor, "Waist", _waist - (0.25 * scale))
	SetMorph(akActor, "Arms", _arms - (0.12 * scale))
	SetMorph(akActor, "MuscleAbs", _abs - (0.40 * scale))
	SetMorph(akActor, "MuscleArms", _muscleArms - (0.35 * scale))
	SetMorph(akActor, "MuscleLegs", _muscleLegs - (0.25 * scale))

	If _tier >= 1
		SetMorph(akActor, "NippleSize", _nippleSize + (0.12 * scale))
		SetMorph(akActor, "AreolaSize", _areolaSize + (0.10 * scale))
	EndIf

	NiOverride.UpdateModelWeight(akActor)
EndFunction

Function RestoreMorphs(Actor akActor)
	SetMorph(akActor, "Breasts", _breasts)
	SetMorph(akActor, "Butt", _butt)
	SetMorph(akActor, "Hips", _hips)
	SetMorph(akActor, "Thighs", _thighs)
	SetMorph(akActor, "Waist", _waist)
	SetMorph(akActor, "Arms", _arms)
	SetMorph(akActor, "MuscleAbs", _abs)
	SetMorph(akActor, "MuscleArms", _muscleArms)
	SetMorph(akActor, "MuscleLegs", _muscleLegs)
	SetMorph(akActor, "NippleSize", _nippleSize)
	SetMorph(akActor, "AreolaSize", _areolaSize)
	NiOverride.UpdateModelWeight(akActor)
EndFunction

Function SetMorph(Actor akActor, String asMorph, Float afValue)
	NiOverride.ClearMorphValue(akActor, asMorph)
	NiOverride.SetMorphValue(akActor, asMorph, PapyrusUtil.ClampFloat(afValue, -2.0, 3.0))
EndFunction

Function ApplyCosmetics(Actor akActor)
	; These are Dollform-owned SlaveTats aliases so removal does not target the user's normal makeup entries.
	RemoveCosmetics(akActor)
	SlaveTats.simple_add_tattoo(akActor, "Dollform Cosmetics", "Doll Blush", 0xFFFFB6C8, true, true, 0.55)
	SlaveTats.simple_add_tattoo(akActor, "Dollform Cosmetics", "Doll Hand Polish", 0xFFFF66AA, true, true, 0.85)
	SlaveTats.simple_add_tattoo(akActor, "Dollform Cosmetics", "Doll Foot Polish", 0xFFFF66AA, true, true, 0.85)

	If _tier >= 1
		SlaveTats.simple_add_tattoo(akActor, "Dollform Cosmetics", "Doll Mascara", 0xFF2C1020, true, true, 0.40)
	EndIf

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
	If _tier >= 1
		akActor.UnequipItemSlot(32)
	EndIf

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
