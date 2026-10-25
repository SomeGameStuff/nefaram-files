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
; Finish can arrive while a latent appearance operation is in progress.
Bool _transitioning = false
Bool _finishRequested = false
Bool _finished = false
Bool _elapsedClockReady = false
Float _lastElapsed = 0.0
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
Bool _hornOwnershipRecorded = false
Bool _hornsWereEquipped = false
Bool _equippedCowHorns = false

Event OnEffectStart(Actor akTarget, Actor akCaster)
	Debug.Trace("[BodymorphAlterations][Cowform] Start target=" + akTarget + " caster=" + akCaster + " active=" + cfl_BodymorphActiveForm.GetValueInt())
	If akTarget != PlayerRef
		Debug.Trace("[BodymorphAlterations][Cowform] Rejected non-player target.")
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

	_transitioning = true
	_running = true
	_ownsForm = true
	_startedAt = Utility.GetCurrentRealTime()
	_startupRefreshes = 0
	_lastElapsed = GetTimeElapsed()
	_elapsedClockReady = true
	If !BeginActiveForm(3)
		_running = false
		_ownsForm = false
		_transitioning = false
		Dispel()
		Return
	EndIf
	_tier = PapyrusUtil.ClampInt(cfl_CowformMarkTier.GetValueInt(), 0, 4)

	EnsureMCMQuestStarted()
	SaveMorphs(PlayerRef)
	SaveHairColor(PlayerRef)
	ApplyCowMorphs(PlayerRef)
	ApplyHairColor(PlayerRef)
	ApplyHorns(PlayerRef)
	ApplyActorValueChanges(PlayerRef)
	ApplyProgressTattoo(PlayerRef)
	ApplyCosmetics(PlayerRef)
	SetupMilkMod(PlayerRef)
	EnforceRestrictions(PlayerRef)
	TraceMorphState("Applied")

	CompleteTransition(UpdateSeconds)
EndEvent

Event OnUpdate()
	If !_running
		Return
	EndIf
	If !IsActiveInstance(3)
		FinishForm()
		Dispel()
		Return
	EndIf
	If _transitioning
		Return
	EndIf
	_transitioning = true

	EnforceRestrictions(PlayerRef)

	If cfl_CowformUseSeconds
		cfl_CowformUseSeconds.SetValue(cfl_CowformUseSeconds.GetValue() + ElapsedUseSeconds())
		CheckProgression(PlayerRef)
	EndIf

	_milkPulseCounter += 1
	If _milkPulseCounter >= MilkPulseUpdates
		_milkPulseCounter = 0
		Debug.Trace("[BodymorphAlterations][Cowform] Running MME pulse at tier=" + _tier)
		PulseMilkMod(PlayerRef)
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
	If IsActiveInstance(3)
		RestoreMorphs(PlayerRef)
		RestoreHairColor(PlayerRef)
		RemoveHorns(PlayerRef)
		RemoveCosmetics(PlayerRef)
		If IsActiveInstance(3)
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
	Int newTier = TierForUseSeconds(cfl_CowformUseSeconds.GetValue())
	If newTier <= _tier
		Return
	EndIf

	_tier = newTier
	cfl_CowformMarkTier.SetValue(newTier)
	ApplyActorValueChanges(akActor)
	ApplyCowMorphs(akActor)
	ApplyHorns(akActor)
	ApplyProgressTattoo(akActor)
	ApplyCosmetics(akActor)
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
	SlaveTats.simple_remove_tattoo(akActor, "Cowform", "Cowform Milk Drops", false, true)
	SlaveTats.simple_add_tattoo(akActor, "Cowform", "Cowform Milk Drops", 0xFFFFF2E2, false, true, alpha)
EndFunction

Function ApplyCosmetics(Actor akActor)
	RemoveCosmetics(akActor, false)
	SlaveTats.simple_add_tattoo(akActor, "Cowform Cosmetics", "Cow Body Spots", 0xFFFFFFFF, false, true, 0.55)
	If _tier >= 2
		SlaveTats.simple_add_tattoo(akActor, "Cowform Cosmetics", "Cow Hoof Tint", 0xFF1D120D, false, true, 0.50)
	EndIf
	If _tier >= 3
		SlaveTats.simple_add_tattoo(akActor, "Cowform Cosmetics", "Cow Heavy Spots", 0xFF1B120D, false, true, 0.40)
	EndIf
	SlaveTats.synchronize_tattoos(akActor, true)
EndFunction

Function RemoveCosmetics(Actor akActor, Bool abSynchronize = true)
	SlaveTats.simple_remove_tattoo(akActor, "Cowform Cosmetics", "Cow Body Spots", false, true)
	SlaveTats.simple_remove_tattoo(akActor, "Cowform Cosmetics", "Cow Udder Mark", false, true)
	SlaveTats.simple_remove_tattoo(akActor, "Cowform Cosmetics", "Cow Face Mark", false, true)
	SlaveTats.simple_remove_tattoo(akActor, "Cowform Cosmetics", "Cow Hand Mark", false, true)
	SlaveTats.simple_remove_tattoo(akActor, "Cowform Cosmetics", "Cow Hoof Tint", false, true)
	SlaveTats.simple_remove_tattoo(akActor, "Cowform Cosmetics", "Cow Heavy Spots", false, true)
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
	If !_hornOwnershipRecorded
		_hornsWereEquipped = akActor.IsEquipped(_cowHorns)
		_hornOwnershipRecorded = true
	EndIf
	; Never replace locked equipment sharing any horn slot.
	Int slot = 30
	While slot <= 61
		Int slotMask = Armor.GetMaskForSlot(slot)
		If Math.LogicalAnd(_cowHorns.GetSlotMask(), slotMask) != 0
			Armor conflict = akActor.GetWornForm(slotMask) as Armor
			If conflict && conflict != _cowHorns && IsLockedArmor(conflict)
				Return
			EndIf
		EndIf
		slot += 1
	EndWhile

	If akActor.GetItemCount(_cowHorns) <= 0
		akActor.AddItem(_cowHorns, 1, true)
		_addedCowHorns = true
	EndIf
	If !akActor.IsEquipped(_cowHorns)
		akActor.EquipItem(_cowHorns, false, true)
		_equippedCowHorns = true
	EndIf
EndFunction

Function RemoveHorns(Actor akActor)
	If !_cowHorns
		Return
	EndIf

	If akActor.IsEquipped(_cowHorns) && !_hornsWereEquipped
		akActor.UnequipItem(_cowHorns, false, true)
	EndIf
	If _addedCowHorns
		akActor.RemoveItem(_cowHorns, 1, true)
	EndIf
	_addedCowHorns = false
EndFunction

Function ApplyActorValueChanges(Actor akActor)

	akActor.ModActorValue("Health", (25.0 + (_tier * 15.0)) - _healthMod)
	_healthMod = 25.0 + (_tier * 15.0)
	akActor.ModActorValue("Stamina", (25.0 + (_tier * 10.0)) - _staminaMod)
	_staminaMod = 25.0 + (_tier * 10.0)
	akActor.ModActorValue("CarryWeight", (30.0 + (_tier * 20.0)) - _carryWeightMod)
	_carryWeightMod = 30.0 + (_tier * 20.0)
	akActor.ModActorValue("SpeedMult", (-8.0 - (_tier * 2.0)) - _speedMod)
	_speedMod = -8.0 - (_tier * 2.0)
	akActor.ModActorValue("MagickaRateMult", (-10.0 - (_tier * 4.0)) - _magickaRateMod)
	_magickaRateMod = -10.0 - (_tier * 4.0)
EndFunction

Function RestoreActorValueChanges(Actor akActor)
	akActor.ModActorValue("Health", -_healthMod)
	_healthMod = 0.0
	akActor.ModActorValue("Stamina", -_staminaMod)
	_staminaMod = 0.0
	akActor.ModActorValue("CarryWeight", -_carryWeightMod)
	_carryWeightMod = 0.0
	akActor.ModActorValue("SpeedMult", -_speedMod)
	_speedMod = 0.0
	akActor.ModActorValue("MagickaRateMult", -_magickaRateMod)
	_magickaRateMod = 0.0
EndFunction

Function SetupMilkMod(Actor akActor)
	_milkQuest = Game.GetFormFromFile(0x00E209, "MilkModNEW.esp") as MilkQUEST
	If !_milkQuest
		Return
	EndIf

	If _milkQuest.MilkMaid.Find(akActor) == -1 && _milkQuest.MilkSlave.Find(akActor) == -1
		_milkQuest.AssignSlot(akActor)
	EndIf

	; First production pulse comes after the normal interval. Repeatedly toggling
	; the power must not grant an instant milk/lactacid pulse on every cast.
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
