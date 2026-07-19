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
Int _activeToken = 0
Int _tier = 0
Int _startupRefreshes = 0
Int _regenSuppressionUpdates = 0
Bool _regenSuppressed = false

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

	_running = true
	_ownsForm = true
	_startupRefreshes = 2
	BeginActiveForm(5)
	_tier = cfl_TrollformMarkTier.GetValueInt()

	SaveMorphs(PlayerRef)
	SaveHairColor(PlayerRef)
	SaveScale(PlayerRef)
	EnsureMCMQuestStarted()
	ApplyTrollScale(PlayerRef)
	ApplyTrollMorphs(PlayerRef)
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
	If !IsActiveInstance(5)
		_running = false
		Return
	EndIf

	EnforceRestrictions(PlayerRef)
	UpdateRegenSuppression(PlayerRef)
	If _startupRefreshes > 0
		RefreshAppearance(PlayerRef)
		_startupRefreshes -= 1
		RegisterForSingleUpdate(1.0)
		Return
	EndIf

	If cfl_TrollformUseSeconds
		cfl_TrollformUseSeconds.SetValue(cfl_TrollformUseSeconds.GetValue() + UpdateSeconds)
		CheckProgression(PlayerRef)
	EndIf

	RegisterForSingleUpdate(UpdateSeconds)
EndEvent

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, Bool abPowerAttack, Bool abSneakAttack, Bool abBashAttack, Bool abHitBlocked)
	If !_running
		Return
	EndIf
	If !IsActiveInstance(5)
		Return
	EndIf

	If IsFireSource(akSource)
		SuppressRegeneration(PlayerRef)
	EndIf
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	_running = false
	UnregisterForUpdate()

	If akTarget == PlayerRef && _ownsForm
		Bool ownsActiveInstance = IsActiveInstance(5)
		If ownsActiveInstance
			RestoreMorphs(PlayerRef)
			RestoreHairColor(PlayerRef)
			RestoreScale(PlayerRef)
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
	_muscleArms = NiOverride.GetMorphValue(akActor, "MuscleArms")
	_muscleLegs = NiOverride.GetMorphValue(akActor, "MuscleLegs")
	_muscleAbs = NiOverride.GetMorphValue(akActor, "MuscleAbs")
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
	RestoreDirectMorph(akActor, "Breasts", _breasts)
	RestoreDirectMorph(akActor, "Butt", _butt)
	RestoreDirectMorph(akActor, "Hips", _hips)
	RestoreDirectMorph(akActor, "Thighs", _thighs)
	RestoreDirectMorph(akActor, "Waist", _waist)
	RestoreDirectMorph(akActor, "Arms", _arms)
	RestoreDirectMorph(akActor, "Belly", _belly)
	RestoreDirectMorph(akActor, "CalfSize", _calves)
	RestoreDirectMorph(akActor, "MuscleArms", _muscleArms)
	RestoreDirectMorph(akActor, "MuscleLegs", _muscleLegs)
	RestoreDirectMorph(akActor, "MuscleAbs", _muscleAbs)
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
	Int newTier = TierForUseSeconds(cfl_TrollformUseSeconds.GetValue())
	If newTier <= _tier
		Return
	EndIf

	RestoreActorValueChanges(akActor)
	_tier = newTier
	cfl_TrollformMarkTier.SetValue(newTier)
	ApplyTrollScale(akActor)
	ApplyTrollMorphs(akActor)
	ApplyProgressTattoo(akActor)
	ApplyCosmetics(akActor)
	ApplyActorValueChanges(akActor)
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
	SlaveTats.simple_remove_tattoo(akActor, "Trollform", "Trollform Grayhide Brand", true, false)
	SlaveTats.simple_add_tattoo(akActor, "Trollform", "Trollform Grayhide Brand", 0xFF8A8F88, true, false, alpha)
EndFunction

Function ApplyCosmetics(Actor akActor)
	RemoveCosmetics(akActor, false)
	SlaveTats.simple_add_tattoo(akActor, "Trollform Cosmetics", "Troll Grayhide Patches", 0xFF7B817A, true, true, 0.50)
	If _tier >= 2
		SlaveTats.simple_add_tattoo(akActor, "Trollform Cosmetics", "Troll Stone Scars", 0xFFB8B9B0, true, true, 0.45)
	EndIf
	SlaveTats.synchronize_tattoos(akActor, true)
EndFunction

Function RemoveCosmetics(Actor akActor, Bool abSynchronize = true)
	SlaveTats.simple_remove_tattoo(akActor, "Trollform Cosmetics", "Troll Grayhide Patches", true, true)
	SlaveTats.simple_remove_tattoo(akActor, "Trollform Cosmetics", "Troll Stone Scars", true, true)
	If abSynchronize
		SlaveTats.synchronize_tattoos(akActor, true)
	EndIf
EndFunction

Function ApplyActorValueChanges(Actor akActor)
	_healthMod = 250.0 + (_tier * 35.0)
	_healRateMod = 8.0 + (_tier * 1.0)
	_meleeDamageMod = 40.0 + (_tier * 5.0)
	_unarmedMod = 20.0 + (_tier * 5.0)
	_twoHandedMod = 15.0 + (_tier * 5.0)
	_staminaMod = 60.0 + (_tier * 15.0)
	_carryWeightMod = 100.0 + (_tier * 15.0)
	_damageResistMod = 40.0 + (_tier * 10.0)
	_speedMod = -20.0 - (_tier * 1.0)
	_weaponSpeedMod = -15.0
	_magickaMod = -100.0 - (_tier * 10.0)
	_magickaRateMod = -80.0
	_fireResistMod = -100.0
	_sneakMod = -90.0
	_lockpickMod = -40.0
	_pickpocketMod = -40.0
	_speechMod = -30.0
	_marksmanMod = -50.0

	akActor.ModActorValue("Health", _healthMod)
	If !_regenSuppressed
		akActor.ModActorValue("HealRate", _healRateMod)
	EndIf
	akActor.ModActorValue("MeleeDamage", _meleeDamageMod)
	akActor.ModActorValue("UnarmedDamage", _unarmedMod)
	akActor.ModActorValue("TwoHanded", _twoHandedMod)
	akActor.ModActorValue("Stamina", _staminaMod)
	akActor.ModActorValue("CarryWeight", _carryWeightMod)
	akActor.ModActorValue("DamageResist", _damageResistMod)
	akActor.ModActorValue("SpeedMult", _speedMod)
	akActor.ModActorValue("WeaponSpeedMult", _weaponSpeedMod)
	akActor.ModActorValue("Magicka", _magickaMod)
	akActor.ModActorValue("MagickaRateMult", _magickaRateMod)
	akActor.ModActorValue("FireResist", _fireResistMod)
	akActor.ModActorValue("Sneak", _sneakMod)
	akActor.ModActorValue("Lockpicking", _lockpickMod)
	akActor.ModActorValue("Pickpocket", _pickpocketMod)
	akActor.ModActorValue("Speechcraft", _speechMod)
	akActor.ModActorValue("Marksman", _marksmanMod)
EndFunction

Function RestoreActorValueChanges(Actor akActor)
	akActor.ModActorValue("Health", -_healthMod)
	If !_regenSuppressed
		akActor.ModActorValue("HealRate", -_healRateMod)
	EndIf
	_regenSuppressed = false
	_regenSuppressionUpdates = 0
	akActor.ModActorValue("MeleeDamage", -_meleeDamageMod)
	akActor.ModActorValue("UnarmedDamage", -_unarmedMod)
	akActor.ModActorValue("TwoHanded", -_twoHandedMod)
	akActor.ModActorValue("Stamina", -_staminaMod)
	akActor.ModActorValue("CarryWeight", -_carryWeightMod)
	akActor.ModActorValue("DamageResist", -_damageResistMod)
	akActor.ModActorValue("SpeedMult", -_speedMod)
	akActor.ModActorValue("WeaponSpeedMult", -_weaponSpeedMod)
	akActor.ModActorValue("Magicka", -_magickaMod)
	akActor.ModActorValue("MagickaRateMult", -_magickaRateMod)
	akActor.ModActorValue("FireResist", -_fireResistMod)
	akActor.ModActorValue("Sneak", -_sneakMod)
	akActor.ModActorValue("Lockpicking", -_lockpickMod)
	akActor.ModActorValue("Pickpocket", -_pickpocketMod)
	akActor.ModActorValue("Speechcraft", -_speechMod)
	akActor.ModActorValue("Marksman", -_marksmanMod)
EndFunction

Function SuppressRegeneration(Actor akActor)
	_regenSuppressionUpdates = 2
	If _regenSuppressed
		Return
	EndIf

	akActor.ModActorValue("HealRate", -_healRateMod)
	_regenSuppressed = true
	Debug.Notification("Fire sears away your troll regeneration.")
EndFunction

Function UpdateRegenSuppression(Actor akActor)
	If !_regenSuppressed
		Return
	EndIf

	_regenSuppressionUpdates -= 1
	If _regenSuppressionUpdates > 0
		Return
	EndIf

	akActor.ModActorValue("HealRate", _healRateMod)
	_regenSuppressed = false
EndFunction

Bool Function IsFireSource(Form akSource)
	If !akSource
		Return false
	EndIf

	Keyword fireKeyword = Game.GetFormFromFile(0x01CEAD, "Skyrim.esm") as Keyword
	If fireKeyword && akSource.HasKeyword(fireKeyword)
		Return true
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
