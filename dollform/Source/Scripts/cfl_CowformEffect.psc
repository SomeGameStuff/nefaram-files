Scriptname cfl_CowformEffect extends ActiveMagicEffect

Import NiOverride

GlobalVariable Property cfl_CowformMarkTier Auto
GlobalVariable Property cfl_BodymorphActiveForm Auto
GlobalVariable Property cfl_CowformUseSeconds Auto
GlobalVariable Property cfl_BodymorphMorphScale Auto
GlobalVariable Property cfl_BodymorphProgressionScale Auto
Spell Property cfl_SpellCowform Auto
ColorForm Property cfl_CowformHairColor Auto
Actor Property PlayerRef Auto

Float Property UpdateSeconds = 6.0 Auto
Int Property MilkPulseUpdates = 5 Auto
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
Int _milkPulseCounter = 0
Int _startupRefreshes = 0

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
Float _startedAt

MilkQUEST _milkQuest
Armor _cowHorns
Bool _addedCowHorns = false

Event OnEffectStart(Actor akTarget, Actor akCaster)
	Debug.Trace("[BodymorphAlterations][Cowform] Start target=" + akTarget + " caster=" + akCaster + " active=" + cfl_BodymorphActiveForm.GetValueInt())
	If akTarget != PlayerRef
		Debug.Trace("[BodymorphAlterations][Cowform] Rejected non-player target.")
		Dispel()
		Return
	EndIf

	Int activeForm = ActiveFormId(cfl_BodymorphActiveForm.GetValueInt())
	If activeForm != 0
		If activeForm == 3
			Debug.Trace("[BodymorphAlterations][Cowform] Recast requests normal cleanup.")
			Debug.Notification("Cowform fades.")
			PlayerRef.DispelSpell(cfl_SpellCowform)
			Return
		EndIf
		Debug.Trace("[BodymorphAlterations][Cowform] Rejected because form " + activeForm + " owns the lock.")
		Debug.Notification("Another bodymorph alteration is already active.")
		Dispel()
		Return
	EndIf

	_running = true
	_ownsForm = true
	_startedAt = Utility.GetCurrentRealTime()
	_startupRefreshes = 2
	BeginActiveForm(3)
	_tier = cfl_CowformMarkTier.GetValueInt()

	EnsureMCMQuestStarted()
	SaveMorphs(PlayerRef)
	SaveHairColor(PlayerRef)
	ApplyCowMorphs(PlayerRef)
	ApplyHairColor(PlayerRef)
	ApplyHorns(PlayerRef)
	ApplyProgressTattoo(PlayerRef)
	ApplyActorValueChanges(PlayerRef)
	ApplyCosmetics(PlayerRef)
	SetupMilkMod(PlayerRef)
	EnforceRestrictions(PlayerRef)
	TraceMorphState("Applied")

	RegisterForSingleUpdate(1.0)
EndEvent

Event OnUpdate()
	If !_running
		Return
	EndIf
	If !IsActiveInstance(3)
		_running = false
		Return
	EndIf

	EnforceRestrictions(PlayerRef)
	If _startupRefreshes > 0
		RefreshAppearance(PlayerRef)
		ApplyHorns(PlayerRef)
		Debug.Trace("[BodymorphAlterations][Cowform] Startup refresh remaining=" + _startupRefreshes)
		_startupRefreshes -= 1
		RegisterForSingleUpdate(1.0)
		Return
	EndIf

	If cfl_CowformUseSeconds
		cfl_CowformUseSeconds.SetValue(cfl_CowformUseSeconds.GetValue() + UpdateSeconds)
		CheckProgression(PlayerRef)
	EndIf

	_milkPulseCounter += 1
	If _milkPulseCounter >= MilkPulseUpdates
		_milkPulseCounter = 0
		Debug.Trace("[BodymorphAlterations][Cowform] Running MME pulse at tier=" + _tier)
		PulseMilkMod(PlayerRef)
	EndIf

	RegisterForSingleUpdate(UpdateSeconds)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	_running = false
	UnregisterForUpdate()
	Debug.Trace("[BodymorphAlterations][Cowform] Finish target=" + akTarget + " elapsed=" + (Utility.GetCurrentRealTime() - _startedAt))

	If akTarget == PlayerRef && _ownsForm
		Bool ownsActiveInstance = IsActiveInstance(3)
		If ownsActiveInstance
			RestoreMorphs(PlayerRef)
			RestoreHairColor(PlayerRef)
			RemoveHorns(PlayerRef)
			RemoveCosmetics(PlayerRef)
			RestoreActorValueChanges(PlayerRef)
		EndIf
		If ownsActiveInstance
			cfl_BodymorphActiveForm.SetValue(0)
		EndIf
		TraceMorphState("Restored")
		Debug.Trace("[BodymorphAlterations][Cowform] Cleanup complete; active=" + cfl_BodymorphActiveForm.GetValueInt())
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
	Float scale = (1.0 + (_tier * 0.15)) * MorphScale()

	SetMorph(akActor, "Breasts", 0.35 * scale)
	SetMorph(akActor, "BreastsSH", 0.25 * scale)
	SetMorph(akActor, "BreastsNewSH", 0.25 * scale)
	SetMorph(akActor, "DoubleMelon", 0.18 * scale)
	SetMorph(akActor, "BreastsFantasy", 0.12 * scale)
	SetMorph(akActor, "BreastWidth", 0.18 * scale)
	SetMorph(akActor, "BreastUnderDepth", 0.18 * scale)
	SetMorph(akActor, "BreastGravity", 0.15 * scale)
	SetMorph(akActor, "BreastGravity2", 0.15 * scale)
	SetMorph(akActor, "NippleAreola", 0.15 * scale)
	SetMorph(akActor, "NippleSize", 0.18 * scale)
	SetMorph(akActor, "AreolaSize", 0.15 * scale)
	SetMorph(akActor, "NippleLength", 0.10 * scale)
	SetMorph(akActor, "Belly", 0.20 * scale)
	SetMorph(akActor, "BigBelly", 0.15 * scale)
	SetMorph(akActor, "PregnancyBelly", 0.15 * scale)
	SetMorph(akActor, "BellyFrontUpFat_v2", 0.20 * scale)
	SetMorph(akActor, "BellyFrontDownFat_v2", 0.20 * scale)
	SetMorph(akActor, "BellySideUpFat_v2", 0.16 * scale)
	SetMorph(akActor, "BellySideDownFat_v2", 0.16 * scale)
	SetMorph(akActor, "BellyUnder_v2", 0.16 * scale)
	SetMorph(akActor, "Hips", 0.35 * scale)
	SetMorph(akActor, "HipUpperWidth", 0.25 * scale)
	SetMorph(akActor, "Butt", 0.25 * scale)
	SetMorph(akActor, "BigButt", 0.25 * scale)
	SetMorph(akActor, "ChubbyButt", 0.20 * scale)
	SetMorph(akActor, "WideWaistLine", 0.20 * scale)
	SetMorph(akActor, "ChubbyWaist", 0.18 * scale)
	SetMorph(akActor, "ChubbyArms", 0.15 * scale)
	SetMorph(akActor, "Thighs", 0.20 * scale)
	SetMorph(akActor, "ChubbyLegs", 0.15 * scale)

	ApplyDirectCowMorphs(akActor, scale)
	RefreshAppearance(akActor)
EndFunction

Function TraceMorphState(String asPhase)
	Debug.Trace("[BodymorphAlterations][Cowform] " + asPhase + " tier=" + _tier + " active=" + cfl_BodymorphActiveForm.GetValueInt() + " breasts=" + NiOverride.GetMorphValue(PlayerRef, "Breasts") + " belly=" + NiOverride.GetMorphValue(PlayerRef, "Belly") + " hips=" + NiOverride.GetMorphValue(PlayerRef, "Hips") + " butt=" + NiOverride.GetMorphValue(PlayerRef, "Butt") + " nipples=" + NiOverride.GetMorphValue(PlayerRef, "NippleSize"))
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
	RestoreDirectMorph(akActor, "NippleSize", _nippleSize)
	RestoreDirectMorph(akActor, "AreolaSize", _areolaSize)
	RefreshAppearance(akActor)
EndFunction

Function ApplyDirectCowMorphs(Actor akActor, Float afScale)
	SetDirectMorph(akActor, "Breasts", _breasts, 0.45 * afScale)
	SetDirectMorph(akActor, "BreastsSH", 0.0, 0.30 * afScale)
	SetDirectMorph(akActor, "BreastsNewSH", 0.0, 0.30 * afScale)
	SetDirectMorph(akActor, "DoubleMelon", 0.0, 0.25 * afScale)
	SetDirectMorph(akActor, "BreastsFantasy", 0.0, 0.18 * afScale)
	SetDirectMorph(akActor, "BreastGravity", 0.0, 0.20 * afScale)
	SetDirectMorph(akActor, "BreastGravity2", 0.0, 0.20 * afScale)
	SetDirectMorph(akActor, "NippleSize", _nippleSize, 0.22 * afScale)
	SetDirectMorph(akActor, "NippleAreola", 0.0, 0.20 * afScale)
	SetDirectMorph(akActor, "AreolaSize", _areolaSize, 0.20 * afScale)
	SetDirectMorph(akActor, "Belly", _belly, 0.30 * afScale)
	SetDirectMorph(akActor, "BigBelly", 0.0, 0.22 * afScale)
	SetDirectMorph(akActor, "PregnancyBelly", 0.0, 0.20 * afScale)
	SetDirectMorph(akActor, "BellyFrontUpFat_v2", 0.0, 0.35 * afScale)
	SetDirectMorph(akActor, "BellyFrontDownFat_v2", 0.0, 0.35 * afScale)
	SetDirectMorph(akActor, "BellySideUpFat_v2", 0.0, 0.28 * afScale)
	SetDirectMorph(akActor, "BellySideDownFat_v2", 0.0, 0.28 * afScale)
	SetDirectMorph(akActor, "BellyUnder_v2", 0.0, 0.28 * afScale)
	SetDirectMorph(akActor, "Hips", _hips, 0.45 * afScale)
	SetDirectMorph(akActor, "Butt", _butt, 0.35 * afScale)
	SetDirectMorph(akActor, "Thighs", _thighs, 0.30 * afScale)
	SetDirectMorph(akActor, "Waist", _waist, 0.20 * afScale)
	SetDirectMorph(akActor, "Arms", _arms, 0.18 * afScale)
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
	Int newTier = TierForUseSeconds(cfl_CowformUseSeconds.GetValue())
	If newTier <= _tier
		Return
	EndIf

	RestoreActorValueChanges(akActor)
	_tier = newTier
	cfl_CowformMarkTier.SetValue(newTier)
	ApplyCowMorphs(akActor)
	ApplyHorns(akActor)
	ApplyProgressTattoo(akActor)
	ApplyCosmetics(akActor)
	ApplyActorValueChanges(akActor)
	EnforceRestrictions(akActor)
	Game.AdvanceSkill("Alteration", 35.0 + (newTier * 20.0))
	Debug.Notification("Cowform deepens to tier " + newTier + ".")
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
	SlaveTats.simple_remove_tattoo(akActor, "Cowform", "Cowform Milk Drops", true, false)
	SlaveTats.simple_add_tattoo(akActor, "Cowform", "Cowform Milk Drops", 0xFFFFF2E2, true, false, alpha)
EndFunction

Function ApplyCosmetics(Actor akActor)
	RemoveCosmetics(akActor, false)
	SlaveTats.simple_add_tattoo(akActor, "Cowform Cosmetics", "Cow Body Spots", 0xFFFFFFFF, true, true, 0.55)
	If _tier >= 2
		SlaveTats.simple_add_tattoo(akActor, "Cowform Cosmetics", "Cow Hoof Tint", 0xFF1D120D, true, true, 0.50)
	EndIf
	If _tier >= 3
		SlaveTats.simple_add_tattoo(akActor, "Cowform Cosmetics", "Cow Heavy Spots", 0xFF1B120D, true, true, 0.40)
	EndIf
	SlaveTats.synchronize_tattoos(akActor, true)
EndFunction

Function RemoveCosmetics(Actor akActor, Bool abSynchronize = true)
	SlaveTats.simple_remove_tattoo(akActor, "Cowform Cosmetics", "Cow Body Spots", true, true)
	SlaveTats.simple_remove_tattoo(akActor, "Cowform Cosmetics", "Cow Udder Mark", true, true)
	SlaveTats.simple_remove_tattoo(akActor, "Cowform Cosmetics", "Cow Face Mark", true, true)
	SlaveTats.simple_remove_tattoo(akActor, "Cowform Cosmetics", "Cow Hand Mark", true, true)
	SlaveTats.simple_remove_tattoo(akActor, "Cowform Cosmetics", "Cow Hoof Tint", true, true)
	SlaveTats.simple_remove_tattoo(akActor, "Cowform Cosmetics", "Cow Heavy Spots", true, true)
	If abSynchronize
		SlaveTats.synchronize_tattoos(akActor, true)
	EndIf
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
