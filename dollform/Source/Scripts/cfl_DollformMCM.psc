Scriptname cfl_DollformMCM extends SKI_ConfigBase

Import NiOverride

GlobalVariable Property cfl_DollformMarkTier Auto
GlobalVariable Property cfl_HorseformMarkTier Auto
GlobalVariable Property cfl_CowformMarkTier Auto
GlobalVariable Property cfl_RabbitformMarkTier Auto
GlobalVariable Property cfl_TrollformMarkTier Auto
GlobalVariable Property cfl_BodymorphActiveForm Auto
GlobalVariable Property cfl_DollformUseSeconds Auto
GlobalVariable Property cfl_HorseformUseSeconds Auto
GlobalVariable Property cfl_CowformUseSeconds Auto
GlobalVariable Property cfl_RabbitformUseSeconds Auto
GlobalVariable Property cfl_TrollformUseSeconds Auto
GlobalVariable Property cfl_BodymorphMorphScale Auto
GlobalVariable Property cfl_BodymorphProgressionScale Auto
Spell Property cfl_SpellDollform Auto
Spell Property cfl_SpellHorseform Auto
Spell Property cfl_SpellCowform Auto
Spell Property cfl_SpellRabbitform Auto
Spell Property cfl_SpellTrollform Auto
Actor Property PlayerRef Auto
String Property MorphKey = "Dollform.BodymorphAlterations" Auto
String Property VisibleMorphKey = "Dollform.BodymorphAlterations.Visible" Auto

Int _setDollTier0
Int _setDollTier1
Int _setDollTier4
Int _setHorseTier0
Int _setHorseTier1
Int _setHorseTier4
Int _setCowTier0
Int _setCowTier1
Int _setCowTier4
Int _setRabbitTier0
Int _setRabbitTier1
Int _setRabbitTier4
Int _setTrollTier0
Int _setTrollTier1
Int _setTrollTier4
Int _grantSpells
Int _runRecovery
Int _clearActive
Int _clearMorphs
Int _removeTempTats
Int _removeProgressionTats
Int _testCowHorns
Int _removeCowHorns
Int _resetUseCounters
Int _cycleDollTier
Int _cycleHorseTier
Int _cycleCowTier
Int _cycleRabbitTier
Int _cycleTrollTier
Int _applyDollMorphTest
Int _applyCowMorphTest
Int _reportCowMorphs
Int _cycleMorphScale
Int _cycleProgressionScale

Event OnConfigInit()
	ModName = "Bodymorph Alterations CURRENT"
	Pages = New String[4]
	Pages[0] = "Status"
	Pages[1] = "Debug"
	Pages[2] = "Diagnostics"
	Pages[3] = "Tuning"
EndEvent

Event OnPageReset(String a_page)
	If a_page == ""
		Return
	EndIf

	SetCursorFillMode(TOP_TO_BOTTOM)

	If a_page == Pages[0]
		AddHeaderOption("Current state", OPTION_FLAG_NONE)
		AddTextOption("Active form", ActiveFormName(), OPTION_FLAG_DISABLED)
		AddTextOption("Active token", ActiveTokenStatus(), OPTION_FLAG_DISABLED)
		AddTextOption("Recovery status", RecoveryStatus(), OPTION_FLAG_DISABLED)
		AddTextOption("Dollform tier", cfl_DollformMarkTier.GetValueInt() as String, OPTION_FLAG_DISABLED)
		AddTextOption("Horseform tier", cfl_HorseformMarkTier.GetValueInt() as String, OPTION_FLAG_DISABLED)
		AddTextOption("Cowform tier", cfl_CowformMarkTier.GetValueInt() as String, OPTION_FLAG_DISABLED)
		AddTextOption("Rabbitform tier", cfl_RabbitformMarkTier.GetValueInt() as String, OPTION_FLAG_DISABLED)
		AddTextOption("Trollform tier", cfl_TrollformMarkTier.GetValueInt() as String, OPTION_FLAG_DISABLED)
		AddEmptyOption()
		AddHeaderOption("Use counters", OPTION_FLAG_NONE)
		AddTextOption("Dollform use", FormatSeconds(cfl_DollformUseSeconds), OPTION_FLAG_DISABLED)
		AddTextOption("Horseform use", FormatSeconds(cfl_HorseformUseSeconds), OPTION_FLAG_DISABLED)
		AddTextOption("Cowform use", FormatSeconds(cfl_CowformUseSeconds), OPTION_FLAG_DISABLED)
		AddTextOption("Rabbitform use", FormatSeconds(cfl_RabbitformUseSeconds), OPTION_FLAG_DISABLED)
		AddTextOption("Trollform use", FormatSeconds(cfl_TrollformUseSeconds), OPTION_FLAG_DISABLED)
		AddEmptyOption()
		AddHeaderOption("Powers", OPTION_FLAG_NONE)
		AddTextOption("Dollform known", PlayerRef.HasSpell(cfl_SpellDollform) as String, OPTION_FLAG_DISABLED)
		AddTextOption("Horseform known", PlayerRef.HasSpell(cfl_SpellHorseform) as String, OPTION_FLAG_DISABLED)
		AddTextOption("Cowform known", PlayerRef.HasSpell(cfl_SpellCowform) as String, OPTION_FLAG_DISABLED)
		AddTextOption("Rabbitform known", PlayerRef.HasSpell(cfl_SpellRabbitform) as String, OPTION_FLAG_DISABLED)
		AddTextOption("Trollform known", PlayerRef.HasSpell(cfl_SpellTrollform) as String, OPTION_FLAG_DISABLED)
	ElseIf a_page == Pages[1]
		AddHeaderOption("Tier controls", OPTION_FLAG_NONE)
		_cycleDollTier = AddTextOption("Dollform tier", cfl_DollformMarkTier.GetValueInt() as String, OPTION_FLAG_NONE)
		_cycleHorseTier = AddTextOption("Horseform tier", cfl_HorseformMarkTier.GetValueInt() as String, OPTION_FLAG_NONE)
		_cycleCowTier = AddTextOption("Cowform tier", cfl_CowformMarkTier.GetValueInt() as String, OPTION_FLAG_NONE)
		_cycleRabbitTier = AddTextOption("Rabbitform tier", cfl_RabbitformMarkTier.GetValueInt() as String, OPTION_FLAG_NONE)
		_cycleTrollTier = AddTextOption("Trollform tier", cfl_TrollformMarkTier.GetValueInt() as String, OPTION_FLAG_NONE)

		SetCursorPosition(1)
		AddHeaderOption("Actions", OPTION_FLAG_NONE)
		_grantSpells = AddTextOption("Grant base powers", "Run", OPTION_FLAG_NONE)
		_runRecovery = AddTextOption("Run form recovery", "Run", OPTION_FLAG_NONE)
		_clearActive = AddTextOption("Clear active-form lock", "Run", OPTION_FLAG_NONE)
		_clearMorphs = AddTextOption("Clear form morphs", "Run", OPTION_FLAG_NONE)
		_applyDollMorphTest = AddTextOption("Apply Dollform morph test", "Run", OPTION_FLAG_NONE)
		_applyCowMorphTest = AddTextOption("Apply Cowform morph test", "Run", OPTION_FLAG_NONE)
		_reportCowMorphs = AddTextOption("Log Cowform morph state", "Run", OPTION_FLAG_NONE)
		_removeTempTats = AddTextOption("Remove temporary tattoos", "Run", OPTION_FLAG_NONE)
		_removeProgressionTats = AddTextOption("Remove progression tattoos", "Run", OPTION_FLAG_NONE)
		_testCowHorns = AddTextOption("Test cow horns", "Equip", OPTION_FLAG_NONE)
		_removeCowHorns = AddTextOption("Remove cow horns", "Run", OPTION_FLAG_NONE)
		_resetUseCounters = AddTextOption("Reset use counters", "Run", OPTION_FLAG_NONE)
	ElseIf a_page == Pages[2]
		AddHeaderOption("Runtime", OPTION_FLAG_NONE)
		AddTextOption("Active form", ActiveFormName(), OPTION_FLAG_DISABLED)
		AddTextOption("Raw active global", cfl_BodymorphActiveForm.GetValueInt() as String, OPTION_FLAG_DISABLED)
		AddTextOption("Form id/token", ActiveTokenStatus(), OPTION_FLAG_DISABLED)
		AddTextOption("Recovery status", RecoveryStatus(), OPTION_FLAG_DISABLED)
		AddTextOption("Morph residue", MorphResidueStatus(), OPTION_FLAG_DISABLED)
		AddTextOption("Cow horns found", CowHornsFound() as String, OPTION_FLAG_DISABLED)
		AddTextOption("Cow horns equipped", IsCowHornsEquipped() as String, OPTION_FLAG_DISABLED)
		AddTextOption("Milk Mod found", MilkModFound() as String, OPTION_FLAG_DISABLED)
		AddTextOption("Fertility Mode found", FertilityModeFound() as String, OPTION_FLAG_DISABLED)
		AddEmptyOption()
		AddHeaderOption("BodyMorph values", OPTION_FLAG_NONE)
		AddTextOption("Main Breasts", FormatFloat(NiOverride.GetBodyMorph(PlayerRef, "Breasts", MorphKey)), OPTION_FLAG_DISABLED)
		AddTextOption("Visible Breasts", FormatFloat(NiOverride.GetBodyMorph(PlayerRef, "Breasts", VisibleMorphKey)), OPTION_FLAG_DISABLED)
		AddTextOption("Visible BreastsNewSH", FormatFloat(NiOverride.GetBodyMorph(PlayerRef, "BreastsNewSH", VisibleMorphKey)), OPTION_FLAG_DISABLED)
		AddTextOption("Visible PregnancyBelly", FormatFloat(NiOverride.GetBodyMorph(PlayerRef, "PregnancyBelly", VisibleMorphKey)), OPTION_FLAG_DISABLED)
		AddTextOption("Direct Breasts", FormatFloat(NiOverride.GetMorphValue(PlayerRef, "Breasts")), OPTION_FLAG_DISABLED)
		AddTextOption("Main Butt", FormatFloat(NiOverride.GetBodyMorph(PlayerRef, "Butt", MorphKey)), OPTION_FLAG_DISABLED)
		AddTextOption("Visible Butt", FormatFloat(NiOverride.GetBodyMorph(PlayerRef, "Butt", VisibleMorphKey)), OPTION_FLAG_DISABLED)
		AddTextOption("Direct Butt", FormatFloat(NiOverride.GetMorphValue(PlayerRef, "Butt")), OPTION_FLAG_DISABLED)
		AddTextOption("Main Hips", FormatFloat(NiOverride.GetBodyMorph(PlayerRef, "Hips", MorphKey)), OPTION_FLAG_DISABLED)
		AddTextOption("Visible Hips", FormatFloat(NiOverride.GetBodyMorph(PlayerRef, "Hips", VisibleMorphKey)), OPTION_FLAG_DISABLED)
		AddTextOption("Direct Hips", FormatFloat(NiOverride.GetMorphValue(PlayerRef, "Hips")), OPTION_FLAG_DISABLED)
		AddTextOption("Main Thighs", FormatFloat(NiOverride.GetBodyMorph(PlayerRef, "Thighs", MorphKey)), OPTION_FLAG_DISABLED)
		AddTextOption("Visible Thighs", FormatFloat(NiOverride.GetBodyMorph(PlayerRef, "Thighs", VisibleMorphKey)), OPTION_FLAG_DISABLED)
		AddTextOption("Direct Thighs", FormatFloat(NiOverride.GetMorphValue(PlayerRef, "Thighs")), OPTION_FLAG_DISABLED)
	ElseIf a_page == Pages[3]
		AddHeaderOption("Global tuning", OPTION_FLAG_NONE)
		_cycleMorphScale = AddTextOption("Morph strength", FormatFloat(cfl_BodymorphMorphScale.GetValue()) + "x", OPTION_FLAG_NONE)
		_cycleProgressionScale = AddTextOption("Progression time", FormatFloat(cfl_BodymorphProgressionScale.GetValue()) + "x", OPTION_FLAG_NONE)
		AddEmptyOption()
		AddTextOption("Morph strength applies to all forms", "", OPTION_FLAG_DISABLED)
		AddTextOption("Progression time applies to all forms", "", OPTION_FLAG_DISABLED)
	EndIf
EndEvent

Event OnOptionSelect(Int a_option)
	If a_option == _cycleDollTier
		CycleTier(cfl_DollformMarkTier, "Dollform")
	ElseIf a_option == _cycleHorseTier
		CycleTier(cfl_HorseformMarkTier, "Horseform")
	ElseIf a_option == _cycleCowTier
		CycleTier(cfl_CowformMarkTier, "Cowform")
	ElseIf a_option == _cycleRabbitTier
		CycleTier(cfl_RabbitformMarkTier, "Rabbitform")
	ElseIf a_option == _cycleTrollTier
		CycleTier(cfl_TrollformMarkTier, "Trollform")
	ElseIf a_option == _setDollTier0
		SetTier(cfl_DollformMarkTier, 0, "Dollform")
	ElseIf a_option == _setDollTier1
		SetTier(cfl_DollformMarkTier, 1, "Dollform")
	ElseIf a_option == _setDollTier4
		SetTier(cfl_DollformMarkTier, 4, "Dollform")
	ElseIf a_option == _setHorseTier0
		SetTier(cfl_HorseformMarkTier, 0, "Horseform")
	ElseIf a_option == _setHorseTier1
		SetTier(cfl_HorseformMarkTier, 1, "Horseform")
	ElseIf a_option == _setHorseTier4
		SetTier(cfl_HorseformMarkTier, 4, "Horseform")
	ElseIf a_option == _setCowTier0
		SetTier(cfl_CowformMarkTier, 0, "Cowform")
	ElseIf a_option == _setCowTier1
		SetTier(cfl_CowformMarkTier, 1, "Cowform")
	ElseIf a_option == _setCowTier4
		SetTier(cfl_CowformMarkTier, 4, "Cowform")
	ElseIf a_option == _setRabbitTier0
		SetTier(cfl_RabbitformMarkTier, 0, "Rabbitform")
	ElseIf a_option == _setRabbitTier1
		SetTier(cfl_RabbitformMarkTier, 1, "Rabbitform")
	ElseIf a_option == _setRabbitTier4
		SetTier(cfl_RabbitformMarkTier, 4, "Rabbitform")
	ElseIf a_option == _setTrollTier0
		SetTier(cfl_TrollformMarkTier, 0, "Trollform")
	ElseIf a_option == _setTrollTier1
		SetTier(cfl_TrollformMarkTier, 1, "Trollform")
	ElseIf a_option == _setTrollTier4
		SetTier(cfl_TrollformMarkTier, 4, "Trollform")
	ElseIf a_option == _grantSpells
		GrantBaseSpells()
	ElseIf a_option == _runRecovery
		RunFormRecovery()
	ElseIf a_option == _clearActive
		ClearActiveLock()
	ElseIf a_option == _clearMorphs
		ClearFormMorphs()
	ElseIf a_option == _applyDollMorphTest
		ApplyDollformMorphTest()
	ElseIf a_option == _applyCowMorphTest
		ApplyCowformMorphTest()
	ElseIf a_option == _reportCowMorphs
		ReportCowformMorphState()
	ElseIf a_option == _removeTempTats
		RemoveTemporaryTattoos()
	ElseIf a_option == _removeProgressionTats
		RemoveProgressionTattoos()
	ElseIf a_option == _testCowHorns
		TestCowHorns()
	ElseIf a_option == _removeCowHorns
		RemoveCowHorns()
	ElseIf a_option == _resetUseCounters
		ResetUseCounters()
	ElseIf a_option == _cycleMorphScale
		CycleMorphScale()
	ElseIf a_option == _cycleProgressionScale
		CycleProgressionScale()
	EndIf
EndEvent

Event OnOptionHighlight(Int a_option)
	If a_option == _clearActive
		SetInfoText("Resets the shared active-form global if a form got stuck.")
	ElseIf a_option == _runRecovery
		SetInfoText("Dispels form spells, clears temporary morphs/overlays/items, restores base hair color, and clears the active token.")
	ElseIf a_option == _clearMorphs
		SetInfoText("Clears only this mod's RaceMenu BodyMorph key and refreshes the player model.")
	ElseIf a_option == _applyDollMorphTest
		SetInfoText("Applies a visible Dollform BodyMorph layer without casting the power.")
	ElseIf a_option == _applyCowMorphTest
		SetInfoText("Applies a visible Cowform BodyMorph layer without casting the power.")
	ElseIf a_option == _reportCowMorphs
		SetInfoText("Writes the current Cowform-relevant morph totals and active form to Papyrus.0.log.")
	ElseIf a_option == _removeTempTats
		SetInfoText("Removes temporary form cosmetics without touching permanent initiation marks.")
	ElseIf a_option == _removeProgressionTats
		SetInfoText("Removes only Bodymorph Alterations progression/permanent marks.")
	ElseIf a_option == _testCowHorns
		SetInfoText("Adds and equips TDN cow horns for testing the horn asset and slot behavior.")
	ElseIf a_option == _resetUseCounters
		SetInfoText("Clears the form-use counters used by the planned progression system.")
	ElseIf a_option == _cycleMorphScale
		SetInfoText("Cycles Rabbitform morph strength: 0.5x, 1.0x, 1.5x, 2.0x.")
	ElseIf a_option == _cycleProgressionScale
		SetInfoText("Cycles Rabbitform tier timing: lower is faster, higher is slower.")
	Else
		SetInfoText("")
	EndIf
EndEvent

Function SetTier(GlobalVariable akGlobal, Int aiTier, String asName)
	akGlobal.SetValue(aiTier)
	Debug.Notification(asName + " tier set to " + aiTier)
	ForcePageReset()
EndFunction

Function CycleTier(GlobalVariable akGlobal, String asName)
	Int current = akGlobal.GetValueInt()
	If current < 1
		SetTier(akGlobal, 1, asName)
	ElseIf current < 4
		SetTier(akGlobal, 4, asName)
	Else
		SetTier(akGlobal, 0, asName)
	EndIf
EndFunction

Function GrantBaseSpells()
	If cfl_SpellDollform
		PlayerRef.AddSpell(cfl_SpellDollform, false)
	EndIf
	If cfl_SpellHorseform
		PlayerRef.AddSpell(cfl_SpellHorseform, false)
	EndIf
	If cfl_SpellCowform
		PlayerRef.AddSpell(cfl_SpellCowform, false)
	EndIf
	If cfl_SpellRabbitform
		PlayerRef.AddSpell(cfl_SpellRabbitform, false)
	EndIf
	If cfl_SpellTrollform
		PlayerRef.AddSpell(cfl_SpellTrollform, false)
	EndIf
	Debug.Notification("Bodymorph Alteration base powers granted.")
	ForcePageReset()
EndFunction

Function RunFormRecovery()
	Debug.Trace("[BodymorphAlterations][MCM] Running transactional recovery; active=" + cfl_BodymorphActiveForm.GetValueInt())
	DispelBodymorphSpells()
	Utility.Wait(1.0)
	ClearFormMorphs(false)
	RemoveTemporaryTattoos(false)
	RemoveActiveFormTattoos(false)
	RemoveCowHorns(false)
	RestoreBaseHairColor()
	cfl_BodymorphActiveForm.SetValue(0)
	SlaveTats.synchronize_tattoos(PlayerRef, true)
	Debug.Notification("Bodymorph Alterations recovery complete.")
	Debug.Trace("[BodymorphAlterations][MCM] Recovery complete; active=" + cfl_BodymorphActiveForm.GetValueInt())
	ForcePageReset()
EndFunction

Function DispelBodymorphSpells()
	If cfl_SpellDollform
		PlayerRef.DispelSpell(cfl_SpellDollform)
	EndIf
	If cfl_SpellHorseform
		PlayerRef.DispelSpell(cfl_SpellHorseform)
	EndIf
	If cfl_SpellCowform
		PlayerRef.DispelSpell(cfl_SpellCowform)
	EndIf
	If cfl_SpellRabbitform
		PlayerRef.DispelSpell(cfl_SpellRabbitform)
	EndIf
	If cfl_SpellTrollform
		PlayerRef.DispelSpell(cfl_SpellTrollform)
	EndIf
EndFunction

Function RestoreBaseHairColor()
	ColorForm baseHairColor = PlayerRef.GetActorBase().GetHairColor()
	If baseHairColor
		PO3_SKSEFunctions.SetHairColor(PlayerRef, baseHairColor)
	EndIf
EndFunction

Function ClearActiveLock()
	cfl_BodymorphActiveForm.SetValue(0)
	Debug.Notification("Bodymorph active-form lock cleared.")
	ForcePageReset()
EndFunction

Function ClearFormMorphs(Bool abNotify = true)
	NiOverride.ClearBodyMorphKeys(PlayerRef, MorphKey)
	NiOverride.ClearBodyMorphKeys(PlayerRef, VisibleMorphKey)
	NiOverride.UpdateModelWeight(PlayerRef)
	PlayerRef.QueueNiNodeUpdate()
	If abNotify
		Debug.Notification("Bodymorph Alteration morphs cleared.")
	EndIf
EndFunction

Function ApplyDollformMorphTest()
	Debug.Notification("Applying CURRENT Dollform morph test.")
	ClearFormMorphs(false)
	SetMorph("Breasts", 1.75)
	SetMorph("BreastsSH", 1.20)
	SetMorph("BreastsNewSH", 1.20)
	SetMorph("Butt", 1.30)
	SetMorph("Hips", 1.00)
	SetMorph("Thighs", 0.80)
	SetMorph("Waist", -0.80)
	SetMorph("Arms", -0.45)
	NiOverride.UpdateModelWeight(PlayerRef)
	PlayerRef.QueueNiNodeUpdate()
	Debug.Notification("CURRENT Dollform morph test applied.")
	ForcePageReset()
EndFunction

Function ApplyCowformMorphTest()
	Debug.Notification("Applying CURRENT Cowform morph test.")
	ClearFormMorphs(false)
	SetMorph("Breasts", 2.50)
	SetMorph("BreastsSH", 1.75)
	SetMorph("BreastsNewSH", 1.75)
	SetMorph("DoubleMelon", 1.00)
	SetMorph("BreastsFantasy", 1.00)
	SetMorph("BreastGravity", 0.80)
	SetMorph("BreastGravity2", 0.80)
	SetMorph("BreastWidth", 0.90)
	SetMorph("Belly", 1.00)
	SetMorph("BigBelly", 0.80)
	SetMorph("PregnancyBelly", 0.75)
	SetMorph("BellyFrontUpFat_v2", 0.60)
	SetMorph("BellyFrontDownFat_v2", 0.60)
	SetMorph("BellySideUpFat_v2", 0.45)
	SetMorph("BellySideDownFat_v2", 0.45)
	SetMorph("BellyUnder_v2", 0.45)
	SetMorph("Hips", 0.80)
	SetMorph("Butt", 0.60)
	SetMorph("Thighs", 0.55)
	SetMorph("Waist", 0.35)
	SetMorph("Arms", 0.30)
	NiOverride.UpdateModelWeight(PlayerRef)
	PlayerRef.QueueNiNodeUpdate()
	Debug.Notification("CURRENT Cowform morph test applied.")
	ForcePageReset()
EndFunction

Function ReportCowformMorphState()
	Debug.Trace("[BodymorphAlterations][MCM] Cowform state active=" + cfl_BodymorphActiveForm.GetValueInt() + " tier=" + cfl_CowformMarkTier.GetValueInt() + " breasts=" + NiOverride.GetMorphValue(PlayerRef, "Breasts") + " breastsSH=" + NiOverride.GetMorphValue(PlayerRef, "BreastsSH") + " belly=" + NiOverride.GetMorphValue(PlayerRef, "Belly") + " pregnancyBelly=" + NiOverride.GetMorphValue(PlayerRef, "PregnancyBelly") + " hips=" + NiOverride.GetMorphValue(PlayerRef, "Hips") + " butt=" + NiOverride.GetMorphValue(PlayerRef, "Butt") + " nipples=" + NiOverride.GetMorphValue(PlayerRef, "NippleSize"))
	Debug.Notification("Cowform morph state written to Papyrus log.")
EndFunction

Function SetMorph(String asMorph, Float afValue)
	NiOverride.ClearBodyMorph(PlayerRef, asMorph, VisibleMorphKey)
	NiOverride.SetBodyMorph(PlayerRef, asMorph, VisibleMorphKey, PapyrusUtil.ClampFloat(afValue, -2.0, 3.0))
EndFunction

Function RemoveTemporaryTattoos(Bool abSynchronize = true)
	SlaveTats.simple_remove_tattoo(PlayerRef, "Dollform Cosmetics", "Doll Blush", true, true)
	SlaveTats.simple_remove_tattoo(PlayerRef, "Dollform Cosmetics", "Doll Hand Polish", true, true)
	SlaveTats.simple_remove_tattoo(PlayerRef, "Dollform Cosmetics", "Doll Foot Polish", true, true)
	SlaveTats.simple_remove_tattoo(PlayerRef, "Dollform Cosmetics", "Doll Mascara", true, true)
	SlaveTats.simple_remove_tattoo(PlayerRef, "Horseform Cosmetics", "Horse Hand Mark", true, true)
	SlaveTats.simple_remove_tattoo(PlayerRef, "Horseform Cosmetics", "Horse Hoof Tint", true, true)
	SlaveTats.simple_remove_tattoo(PlayerRef, "Horseform Cosmetics", "Horse Body Mark", true, true)
	SlaveTats.simple_remove_tattoo(PlayerRef, "Horseform Cosmetics", "Horse Stride Mark", true, true)
	SlaveTats.simple_remove_tattoo(PlayerRef, "Cowform Cosmetics", "Cow Body Spots", true, true)
	SlaveTats.simple_remove_tattoo(PlayerRef, "Cowform Cosmetics", "Cow Udder Mark", true, true)
	SlaveTats.simple_remove_tattoo(PlayerRef, "Cowform Cosmetics", "Cow Face Mark", true, true)
	SlaveTats.simple_remove_tattoo(PlayerRef, "Cowform Cosmetics", "Cow Hand Mark", true, true)
	SlaveTats.simple_remove_tattoo(PlayerRef, "Cowform Cosmetics", "Cow Hoof Tint", true, true)
	SlaveTats.simple_remove_tattoo(PlayerRef, "Cowform Cosmetics", "Cow Heavy Spots", true, true)
	SlaveTats.simple_remove_tattoo(PlayerRef, "Rabbitform Cosmetics", "Rabbit Hip Mark", true, true)
	SlaveTats.simple_remove_tattoo(PlayerRef, "Rabbitform Cosmetics", "Rabbit Leap Mark", true, true)
	SlaveTats.simple_remove_tattoo(PlayerRef, "Trollform Cosmetics", "Troll Grayhide Patches", true, true)
	SlaveTats.simple_remove_tattoo(PlayerRef, "Trollform Cosmetics", "Troll Stone Scars", true, true)
	If abSynchronize
		SlaveTats.synchronize_tattoos(PlayerRef, true)
		Debug.Notification("Temporary form tattoos removed.")
	EndIf
EndFunction

Function RemoveActiveFormTattoos(Bool abSynchronize = true)
	SlaveTats.simple_remove_tattoo(PlayerRef, "Dollform", "Dollform Attunement", true, true)
	SlaveTats.simple_remove_tattoo(PlayerRef, "Horseform", "Horseform Seed Brand", true, true)
	SlaveTats.simple_remove_tattoo(PlayerRef, "Cowform", "Cowform Milk Drops", true, true)
	SlaveTats.simple_remove_tattoo(PlayerRef, "Rabbitform", "Rabbitform Moon Mark", true, true)
	SlaveTats.simple_remove_tattoo(PlayerRef, "Trollform", "Trollform Grayhide Brand", true, true)
	If abSynchronize
		SlaveTats.synchronize_tattoos(PlayerRef, true)
	EndIf
EndFunction

Function RemoveProgressionTattoos()
	RemoveActiveFormTattoos(false)
	SlaveTats.simple_remove_tattoo(PlayerRef, "Dollform", "Porcelain Lines", true, true)
	SlaveTats.simple_remove_tattoo(PlayerRef, "Dollform", "Joint Seals", true, true)
	SlaveTats.simple_remove_tattoo(PlayerRef, "Dollform", "Display Sigil", true, true)
	SlaveTats.simple_remove_tattoo(PlayerRef, "Dollform", "Perfect Doll Brand", true, true)
	SlaveTats.simple_remove_tattoo(PlayerRef, "Horseform", "Strong Legs", true, true)
	SlaveTats.simple_remove_tattoo(PlayerRef, "Horseform", "Burdened Hands", true, true)
	SlaveTats.simple_remove_tattoo(PlayerRef, "Horseform", "Hoofbound Stride", true, true)
	SlaveTats.simple_remove_tattoo(PlayerRef, "Horseform", "Perfect Courser", true, true)
	SlaveTats.simple_remove_tattoo(PlayerRef, "Cowform", "First Letdown", true, true)
	SlaveTats.simple_remove_tattoo(PlayerRef, "Cowform", "Full Udder", true, true)
	SlaveTats.simple_remove_tattoo(PlayerRef, "Cowform", "Barn Brand", true, true)
	SlaveTats.simple_remove_tattoo(PlayerRef, "Cowform", "Perfect Dairy Cow", true, true)
	SlaveTats.synchronize_tattoos(PlayerRef, true)
	Debug.Notification("Bodymorph progression tattoos removed.")
EndFunction

Function TestCowHorns()
	Armor horns = GetCowHorns()
	If !horns
		Debug.Notification("TDN cow horns were not found.")
		Return
	EndIf
	If PlayerRef.GetItemCount(horns) <= 0
		PlayerRef.AddItem(horns, 1, true)
	EndIf
	PlayerRef.EquipItem(horns, false, true)
	PlayerRef.QueueNiNodeUpdate()
	Debug.Notification("TDN cow horns equipped for testing.")
EndFunction

Function RemoveCowHorns(Bool abNotify = true)
	Armor horns = GetCowHorns()
	If !horns
		If abNotify
			Debug.Notification("TDN cow horns were not found.")
		EndIf
		Return
	EndIf
	If PlayerRef.IsEquipped(horns)
		PlayerRef.UnequipItem(horns, false, true)
	EndIf
	If abNotify
		Debug.Notification("TDN cow horns unequipped.")
	EndIf
EndFunction

Function ResetUseCounters()
	cfl_DollformUseSeconds.SetValue(0.0)
	cfl_HorseformUseSeconds.SetValue(0.0)
	cfl_CowformUseSeconds.SetValue(0.0)
	cfl_RabbitformUseSeconds.SetValue(0.0)
	cfl_TrollformUseSeconds.SetValue(0.0)
	Debug.Notification("Bodymorph Alteration use counters reset.")
	ForcePageReset()
EndFunction

Function CycleMorphScale()
	Float current = cfl_BodymorphMorphScale.GetValue()
	If current < 0.75
		cfl_BodymorphMorphScale.SetValue(1.0)
	ElseIf current < 1.25
		cfl_BodymorphMorphScale.SetValue(1.5)
	ElseIf current < 1.75
		cfl_BodymorphMorphScale.SetValue(2.0)
	Else
		cfl_BodymorphMorphScale.SetValue(0.5)
	EndIf
	ForcePageReset()
EndFunction

Function CycleProgressionScale()
	Float current = cfl_BodymorphProgressionScale.GetValue()
	If current < 0.75
		cfl_BodymorphProgressionScale.SetValue(1.0)
	ElseIf current < 1.25
		cfl_BodymorphProgressionScale.SetValue(2.0)
	ElseIf current < 3.0
		cfl_BodymorphProgressionScale.SetValue(4.0)
	Else
		cfl_BodymorphProgressionScale.SetValue(0.5)
	EndIf
	ForcePageReset()
EndFunction

Armor Function GetCowHorns()
	Return Game.GetFormFromFile(0x0012E5, "TDNEquipableHorns.esp") as Armor
EndFunction

Bool Function CowHornsFound()
	If GetCowHorns()
		Return true
	EndIf
	Return false
EndFunction

Bool Function IsCowHornsEquipped()
	Armor horns = GetCowHorns()
	If horns && PlayerRef.IsEquipped(horns)
		Return true
	EndIf
	Return false
EndFunction

Bool Function MilkModFound()
	If Game.GetFormFromFile(0x00E209, "MilkModNEW.esp")
		Return true
	EndIf
	Return false
EndFunction

Bool Function FertilityModeFound()
	If Game.GetFormFromFile(0x000D62, "Fertility Mode 3 Fixes and Updates.esp")
		Return true
	EndIf
	Return false
EndFunction

String Function ActiveFormName()
	Int activeValue = cfl_BodymorphActiveForm.GetValueInt()
	Int activeForm = ActiveFormId(activeValue)
	String tokenText = ""
	If ActiveToken(activeValue) > 0
		tokenText = " #" + (ActiveToken(activeValue) as String)
	EndIf
	If activeForm == 1
		Return "Dollform" + tokenText
	ElseIf activeForm == 2
		Return "Horseform" + tokenText
	ElseIf activeForm == 3
		Return "Cowform" + tokenText
	ElseIf activeForm == 4
		Return "Rabbitform" + tokenText
	ElseIf activeForm == 5
		Return "Trollform" + tokenText
	ElseIf activeForm == 101
		Return "Feral Wolf"
	ElseIf activeForm == 102
		Return "Feral Sabre Cat"
	ElseIf activeForm == 103
		Return "Feral Bear"
	ElseIf activeForm == 104
		Return "Feral Skeever"
	ElseIf activeForm == 105
		Return "Feral Spider"
	ElseIf activeForm == 106
		Return "Feral Mudcrab"
	ElseIf activeForm == 107
		Return "Feral Stag"
	ElseIf activeForm == 108
		Return "Feral Troll"
	EndIf
	Return "None"
EndFunction

String Function ActiveTokenStatus()
	Int activeValue = cfl_BodymorphActiveForm.GetValueInt()
	Return (ActiveFormId(activeValue) as String) + "/" + (ActiveToken(activeValue) as String)
EndFunction

String Function RecoveryStatus()
	If cfl_BodymorphActiveForm.GetValueInt() != 0
		Return "active"
	EndIf
	If HasMorphResidue()
		Return "morph residue"
	EndIf
	If IsCowHornsEquipped()
		Return "horns equipped"
	EndIf
	Return "clean"
EndFunction

String Function MorphResidueStatus()
	If HasMorphResidue()
		Return "present"
	EndIf
	Return "clear"
EndFunction

Bool Function HasMorphResidue()
	If NiOverride.GetBodyMorph(PlayerRef, "Breasts", MorphKey) != 0.0
		Return true
	EndIf
	If NiOverride.GetBodyMorph(PlayerRef, "Breasts", VisibleMorphKey) != 0.0
		Return true
	EndIf
	If NiOverride.GetBodyMorph(PlayerRef, "Butt", MorphKey) != 0.0
		Return true
	EndIf
	If NiOverride.GetBodyMorph(PlayerRef, "Butt", VisibleMorphKey) != 0.0
		Return true
	EndIf
	If NiOverride.GetBodyMorph(PlayerRef, "Hips", MorphKey) != 0.0
		Return true
	EndIf
	If NiOverride.GetBodyMorph(PlayerRef, "Hips", VisibleMorphKey) != 0.0
		Return true
	EndIf
	If NiOverride.GetBodyMorph(PlayerRef, "Thighs", MorphKey) != 0.0
		Return true
	EndIf
	If NiOverride.GetBodyMorph(PlayerRef, "Thighs", VisibleMorphKey) != 0.0
		Return true
	EndIf
	Return false
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

String Function FormatSeconds(GlobalVariable akGlobal)
	If !akGlobal
		Return "missing"
	EndIf

	Int seconds = akGlobal.GetValueInt()
	Int minutes = seconds / 60
	Int remainder = seconds - (minutes * 60)
	Return (minutes as String) + "m " + (remainder as String) + "s"
EndFunction

String Function FormatFloat(Float afValue)
	Int scaled = (afValue * 100.0) as Int
	Int whole = scaled / 100
	Int frac = scaled - (whole * 100)
	If frac < 0
		frac = -frac
	EndIf
	If frac < 10
		Return (whole as String) + ".0" + (frac as String)
	EndIf
	Return (whole as String) + "." + (frac as String)
EndFunction
