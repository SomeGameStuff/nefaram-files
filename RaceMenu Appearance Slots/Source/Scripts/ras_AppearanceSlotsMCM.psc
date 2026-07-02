Scriptname ras_AppearanceSlotsMCM extends SKI_ConfigBase

Import NiOverride
Import CharGen
Import MiscUtil

Actor Property PlayerRef Auto
Spell Property ras_ToggleSlotPower Auto
GlobalVariable Property ras_ActiveSlot Auto
GlobalVariable Property ras_Slot1Saved Auto
GlobalVariable Property ras_Slot2Saved Auto

String Property DataFile = "../RaceMenuAppearanceSlots/Slots" Auto
String Property MorphKey = "RaceMenuAppearanceSlots.Active" Auto
Float Property MinMorphDelta = 0.001 Auto

String[] _morphsA
String[] _morphsB

Int _saveSlot1
Int _saveSlot2
Int _applySlot1
Int _applySlot2
Int _toggleSlot
Int _cleanup
Int _grantPower
Int _refresh

Event OnInit()
	OnConfigInit()
	RegisterForModEvent("SKICP_configManagerReady", "OnConfigManagerReady")
	RegisterForModEvent("SKICP_configManagerReset", "OnConfigManagerReset")
	InitMorphNames()
	GrantPower(false)
EndEvent

Event OnConfigInit()
	ModName = "RaceMenu Appearance Slots"
	Pages = New String[2]
	Pages[0] = "Slots"
	Pages[1] = "Diagnostics"
	InitMorphNames()
EndEvent

Event OnVersionUpdate(Int a_version)
	InitMorphNames()
EndEvent

Event OnPageReset(String a_page)
	If a_page == ""
		Return
	EndIf

	SetCursorFillMode(TOP_TO_BOTTOM)

	If a_page == Pages[0]
		AddHeaderOption("Current state", OPTION_FLAG_NONE)
		AddTextOption("Active slot", ActiveSlotText(), OPTION_FLAG_DISABLED)
		AddTextOption("Slot 1 saved", IsSlotSaved(1) as String, OPTION_FLAG_DISABLED)
		AddTextOption("Slot 2 saved", IsSlotSaved(2) as String, OPTION_FLAG_DISABLED)
		AddTextOption("Toggle power known", PlayerRef.HasSpell(ras_ToggleSlotPower) as String, OPTION_FLAG_DISABLED)
		AddEmptyOption()
		AddHeaderOption("Save current appearance", OPTION_FLAG_NONE)
		_saveSlot1 = AddTextOption("Save Slot 1", "Capture", OPTION_FLAG_NONE)
		_saveSlot2 = AddTextOption("Save Slot 2", "Capture", OPTION_FLAG_NONE)

		SetCursorPosition(1)
		AddHeaderOption("Apply saved appearance", OPTION_FLAG_NONE)
		_applySlot1 = AddTextOption("Apply Slot 1", ApplyLabel(1), OptionForSlot(1))
		_applySlot2 = AddTextOption("Apply Slot 2", ApplyLabel(2), OptionForSlot(2))
		_toggleSlot = AddTextOption("Toggle active slot", "Run", ToggleOptionFlags())
		_cleanup = AddTextOption("Cleanup applied morphs", "Run", OPTION_FLAG_NONE)
		_grantPower = AddTextOption("Regrant toggle power", "Run", OPTION_FLAG_NONE)
		_refresh = AddTextOption("Refresh player model", "Run", OPTION_FLAG_NONE)
	ElseIf a_page == Pages[1]
		AddHeaderOption("Runtime", OPTION_FLAG_NONE)
		AddTextOption("RaceMenu SKEE version", SKSE.GetPluginVersion("skee") as String, OPTION_FLAG_DISABLED)
		AddTextOption("NiOverride script version", NiOverride.GetScriptVersion() as String, OPTION_FLAG_DISABLED)
		AddTextOption("PapyrusUtil version", PapyrusUtil.GetVersion() as String, OPTION_FLAG_DISABLED)
		AddTextOption("JSON file loaded", JsonUtil.IsGood(DataFile) as String, OPTION_FLAG_DISABLED)
		AddTextOption("JSON errors", JsonUtil.GetErrors(DataFile), OPTION_FLAG_DISABLED)
		AddTextOption("Tracked morph count", MorphCount() as String, OPTION_FLAG_DISABLED)
		AddEmptyOption()
		AddHeaderOption("Examples", OPTION_FLAG_NONE)
		AddTextOption("Breasts target Slot 1", FormatFloat(GetSavedMorph(1, "Breasts")), OPTION_FLAG_DISABLED)
		AddTextOption("Breasts active key", FormatFloat(NiOverride.GetBodyMorph(PlayerRef, "Breasts", MorphKey)), OPTION_FLAG_DISABLED)
		AddTextOption("Butt target Slot 1", FormatFloat(GetSavedMorph(1, "Butt")), OPTION_FLAG_DISABLED)
		AddTextOption("Butt active key", FormatFloat(NiOverride.GetBodyMorph(PlayerRef, "Butt", MorphKey)), OPTION_FLAG_DISABLED)
		AddTextOption("Scale Slot 1", FormatFloat(JsonUtil.GetFloatValue(DataFile, SlotPrefix(1) + ".scale", 1.0)), OPTION_FLAG_DISABLED)
		AddTextOption("Scale Slot 2", FormatFloat(JsonUtil.GetFloatValue(DataFile, SlotPrefix(2) + ".scale", 1.0)), OPTION_FLAG_DISABLED)
	EndIf
EndEvent

Event OnOptionSelect(Int a_option)
	If a_option == _saveSlot1
		SaveSlot(1)
	ElseIf a_option == _saveSlot2
		SaveSlot(2)
	ElseIf a_option == _applySlot1
		ApplySlot(1)
	ElseIf a_option == _applySlot2
		ApplySlot(2)
	ElseIf a_option == _toggleSlot
		ToggleSlot()
	ElseIf a_option == _cleanup
		CleanupAppliedMorphs(true)
	ElseIf a_option == _grantPower
		GrantPower(true)
	ElseIf a_option == _refresh
		RefreshAppearance()
		Debug.Notification("RaceMenu Appearance Slots refreshed the player model.")
	EndIf
EndEvent

Event OnOptionHighlight(Int a_option)
	If a_option == _saveSlot1 || a_option == _saveSlot2
		SetInfoText("Captures current body morph targets, hair color, and scale into the selected slot.")
	ElseIf a_option == _applySlot1 || a_option == _applySlot2
		SetInfoText("Applies the saved target shape as this mod's own BodyMorph delta. Other morph keys are left alone.")
	ElseIf a_option == _toggleSlot
		SetInfoText("Switches between Slot 1 and Slot 2. Both slots must be saved first.")
	ElseIf a_option == _cleanup
		SetInfoText("Clears only RaceMenu Appearance Slots morphs. It does not reset RaceMenu, OBody, or other mod keys.")
	ElseIf a_option == _grantPower
		SetInfoText("Adds the Toggle Appearance Slot lesser power to the player.")
	Else
		SetInfoText("")
	EndIf
EndEvent

Function SaveSlot(Int aiSlot)
	If !IsValidSlot(aiSlot)
		Return
	EndIf

	InitMorphNames()
	CleanupAppliedMorphs(false)

	String prefix = SlotPrefix(aiSlot)
	JsonUtil.SetIntValue(DataFile, prefix + ".saved", 1)
	JsonUtil.SetFloatValue(DataFile, prefix + ".scale", PlayerRef.GetScale())
	JsonUtil.SetFormValue(DataFile, prefix + ".race", PlayerRef.GetRace())

	ColorForm hair = PlayerRef.GetActorBase().GetHairColor()
	If !hair
		hair = PO3_SKSEFunctions.GetHairColor(PlayerRef)
	EndIf
	JsonUtil.SetFormValue(DataFile, prefix + ".hairColor", hair)
	SaveFullPreset(aiSlot)

	SaveMorphArray(aiSlot, _morphsA)
	SaveMorphArray(aiSlot, _morphsB)
	JsonUtil.Save(DataFile, true)
	SetSlotSaved(aiSlot, true)
	Debug.Notification("RaceMenu Appearance Slot " + aiSlot + " saved.")
	ForcePageReset()
EndFunction

Function ApplySlot(Int aiSlot)
	If !IsSlotSaved(aiSlot)
		Debug.Notification("RaceMenu Appearance Slot " + aiSlot + " has not been saved.")
		Return
	EndIf

	InitMorphNames()
	CleanupAppliedMorphs(false)
	LoadFullPreset(aiSlot)
	ApplyMorphArray(aiSlot, _morphsA)
	ApplyMorphArray(aiSlot, _morphsB)

	ColorForm hair = JsonUtil.GetFormValue(DataFile, SlotPrefix(aiSlot) + ".hairColor") as ColorForm
	If hair
		PO3_SKSEFunctions.SetHairColor(PlayerRef, hair)
	EndIf

	Float savedScale = JsonUtil.GetFloatValue(DataFile, SlotPrefix(aiSlot) + ".scale", PlayerRef.GetScale())
	If savedScale > 0.1
		PlayerRef.SetScale(savedScale)
	EndIf

	ras_ActiveSlot.SetValue(aiSlot)
	RefreshAppearance()
	Debug.Notification("RaceMenu Appearance Slot " + aiSlot + " applied.")
	ForcePageReset()
EndFunction

Function SaveFullPreset(Int aiSlot)
	String presetName = PresetName(aiSlot)
	If CharGen.IsExternalEnabled()
		CharGen.SaveExternalCharacter(presetName)
	Else
		CharGen.SaveCharacter(presetName)
	EndIf
	CharGen.SavePreset(presetName)
EndFunction

Function LoadFullPreset(Int aiSlot)
	String presetName = PresetName(aiSlot)
	Race savedRace = JsonUtil.GetFormValue(DataFile, SlotPrefix(aiSlot) + ".race") as Race
	If !savedRace
		savedRace = PlayerRef.GetRace()
	EndIf
	If IsBeastRace(PlayerRef.GetRace())
		savedRace = PlayerRef.GetRace()
	EndIf

	ColorForm hair = JsonUtil.GetFormValue(DataFile, SlotPrefix(aiSlot) + ".hairColor") as ColorForm
	If hair
		PlayerRef.GetActorBase().SetHairColor(hair)
	EndIf

	ApplyFullPreset(presetName, savedRace)
	Utility.Wait(0.1)
	ApplyFullPreset(presetName, savedRace)
EndFunction

Function ApplyFullPreset(String asPresetName, Race akRace)
	Race currentRace = PlayerRef.GetRace()
	If akRace && currentRace != akRace
		PlayerRef.SetRace(akRace)
		Utility.Wait(0.1)
		PlayerRef.SetRace(currentRace)
		Utility.Wait(0.1)
		PlayerRef.SetRace(akRace)
		Utility.Wait(0.1)
	EndIf

	CharGen.LoadPreset(asPresetName)
	If CharGen.IsExternalEnabled()
		CharGen.LoadExternalCharacter(PlayerRef, akRace, asPresetName)
	Else
		CharGen.LoadCharacter(PlayerRef, akRace, asPresetName)
	EndIf
EndFunction

Bool Function IsBeastRace(Race akRace)
	String editorId = MiscUtil.GetRaceEditorID(akRace)
	Return editorId == "DLC1VampireBeastRace" || editorId == "WerewolfBeastRace"
EndFunction

Function ToggleSlot()
	If !IsSlotSaved(1)
		Debug.Notification("RaceMenu Appearance Slot 1 has not been saved.")
		Return
	EndIf
	If !IsSlotSaved(2)
		Debug.Notification("RaceMenu Appearance Slot 2 has not been saved.")
		Return
	EndIf

	If ras_ActiveSlot.GetValueInt() == 1
		ApplySlot(2)
	Else
		ApplySlot(1)
	EndIf
EndFunction

Function SaveMorphArray(Int aiSlot, String[] akMorphs)
	If !akMorphs
		Return
	EndIf

	Int i = 0
	While i < akMorphs.Length
		If akMorphs[i] != ""
			JsonUtil.SetFloatValue(DataFile, MorphKeyName(aiSlot, akMorphs[i]), NiOverride.GetMorphValue(PlayerRef, akMorphs[i]))
		EndIf
		i += 1
	EndWhile
EndFunction

Function ApplyMorphArray(Int aiSlot, String[] akMorphs)
	If !akMorphs
		Return
	EndIf

	Int i = 0
	While i < akMorphs.Length
		If akMorphs[i] != ""
			ApplySavedMorph(aiSlot, akMorphs[i])
		EndIf
		i += 1
	EndWhile
EndFunction

Function ApplySavedMorph(Int aiSlot, String asMorph)
	Float target = GetSavedMorph(aiSlot, asMorph)
	Float baseValue = NiOverride.GetMorphValue(PlayerRef, asMorph)
	Float delta = target - baseValue
	If delta < MinMorphDelta && delta > -MinMorphDelta
		Return
	EndIf
	NiOverride.SetBodyMorph(PlayerRef, asMorph, MorphKey, PapyrusUtil.ClampFloat(delta, -10.0, 10.0))
EndFunction

Function CleanupAppliedMorphs(Bool abNotify)
	NiOverride.ClearBodyMorphKeys(PlayerRef, MorphKey)
	RefreshAppearance()
	If abNotify
		ras_ActiveSlot.SetValue(0)
		Debug.Notification("RaceMenu Appearance Slots morphs cleared.")
		ForcePageReset()
	EndIf
EndFunction

Function GrantPower(Bool abNotify)
	If ras_ToggleSlotPower && !PlayerRef.HasSpell(ras_ToggleSlotPower)
		PlayerRef.AddSpell(ras_ToggleSlotPower, false)
	EndIf
	If abNotify
		Debug.Notification("Toggle Appearance Slot power granted.")
		ForcePageReset()
	EndIf
EndFunction

Function RefreshAppearance()
	NiOverride.UpdateModelWeight(PlayerRef)
	PlayerRef.QueueNiNodeUpdate()
EndFunction

Bool Function IsSlotSaved(Int aiSlot)
	If aiSlot == 1
		Return ras_Slot1Saved.GetValueInt() == 1 || JsonUtil.GetIntValue(DataFile, SlotPrefix(1) + ".saved", 0) == 1
	ElseIf aiSlot == 2
		Return ras_Slot2Saved.GetValueInt() == 1 || JsonUtil.GetIntValue(DataFile, SlotPrefix(2) + ".saved", 0) == 1
	EndIf
	Return false
EndFunction

Function SetSlotSaved(Int aiSlot, Bool abSaved)
	If aiSlot == 1
		ras_Slot1Saved.SetValue(abSaved as Int)
	ElseIf aiSlot == 2
		ras_Slot2Saved.SetValue(abSaved as Int)
	EndIf
EndFunction

Bool Function IsValidSlot(Int aiSlot)
	If aiSlot == 1 || aiSlot == 2
		Return true
	EndIf
	Debug.Notification("Invalid RaceMenu Appearance Slot.")
	Return false
EndFunction

String Function SlotPrefix(Int aiSlot)
	Return "slot" + aiSlot
EndFunction

String Function PresetName(Int aiSlot)
	Return "RaceMenuAppearanceSlots_Slot" + aiSlot
EndFunction

String Function MorphKeyName(Int aiSlot, String asMorph)
	Return SlotPrefix(aiSlot) + ".morph." + asMorph
EndFunction

Float Function GetSavedMorph(Int aiSlot, String asMorph)
	Return JsonUtil.GetFloatValue(DataFile, MorphKeyName(aiSlot, asMorph), 0.0)
EndFunction

String Function ActiveSlotText()
	Int active = ras_ActiveSlot.GetValueInt()
	If active == 1
		Return "Slot 1"
	ElseIf active == 2
		Return "Slot 2"
	EndIf
	Return "None"
EndFunction

String Function ApplyLabel(Int aiSlot)
	If IsSlotSaved(aiSlot)
		Return "Apply"
	EndIf
	Return "Not saved"
EndFunction

Int Function OptionForSlot(Int aiSlot)
	If IsSlotSaved(aiSlot)
		Return OPTION_FLAG_NONE
	EndIf
	Return OPTION_FLAG_DISABLED
EndFunction

Int Function ToggleOptionFlags()
	If IsSlotSaved(1) && IsSlotSaved(2)
		Return OPTION_FLAG_NONE
	EndIf
	Return OPTION_FLAG_DISABLED
EndFunction

Int Function MorphCount()
	Return _morphsA.Length + _morphsB.Length
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

Function InitMorphNames()
	If _morphsA && _morphsA.Length == 128 && _morphsB && _morphsB.Length == 31
		Return
	EndIf

	_morphsA = New String[128]
	_morphsA[0] = "Innieoutie"
	_morphsA[1] = "LabiaNeat_v2"
	_morphsA[2] = "LabiaTightUp"
	_morphsA[3] = "Labiapuffyness"
	_morphsA[4] = "LabiaMorePuffyness_v2"
	_morphsA[5] = "Labiaprotrude"
	_morphsA[6] = "Labiaprotrude2"
	_morphsA[7] = "Labiaprotrudeback"
	_morphsA[8] = "Labiaspread"
	_morphsA[9] = "LabiaCrumpled_v2"
	_morphsA[10] = "LabiaBulgogi_v2"
	_morphsA[11] = "Vaginasize"
	_morphsA[12] = "VaginaHole"
	_morphsA[13] = "Clit"
	_morphsA[14] = "ClitSwell_v2"
	_morphsA[15] = "Cutepuffyness"
	_morphsA[16] = "CBPC"
	_morphsA[17] = "CrotchGap"
	_morphsA[18] = "AnalLoose_v2"
	_morphsA[19] = "AnalPosition_v2"
	_morphsA[20] = "AnalTexPos_v2"
	_morphsA[21] = "AnalTexPosRe_v2"
	_morphsA[22] = "7B Lower"
	_morphsA[23] = "7B Upper"
	_morphsA[24] = "VanillaSSEHi"
	_morphsA[25] = "VanillaSSELo"
	_morphsA[26] = "OldBaseShape"
	_morphsA[27] = "Breasts"
	_morphsA[28] = "BreastsSmall"
	_morphsA[29] = "BreastsSmall2"
	_morphsA[30] = "DoubleMelon"
	_morphsA[31] = "BreastCleavage"
	_morphsA[32] = "BreastsTogether"
	_morphsA[33] = "BreastsConverage_v2"
	_morphsA[34] = "PushUp"
	_morphsA[35] = "BreastGravity2"
	_morphsA[36] = "BreastHeight"
	_morphsA[37] = "BreastPerkiness"
	_morphsA[38] = "BreastWidth"
	_morphsA[39] = "BreastTopSlope"
	_morphsA[40] = "BreastCenter"
	_morphsA[41] = "BreastCenterBig"
	_morphsA[42] = "BreastFlatness"
	_morphsA[43] = "BreastFlatness2"
	_morphsA[44] = "BreastsFantasy"
	_morphsA[45] = "BreastsNewSH"
	_morphsA[46] = "BreastsNewSHSymmetry"
	_morphsA[47] = "BreastsGone"
	_morphsA[48] = "BreastSideShape"
	_morphsA[49] = "BreastUnderDepth"
	_morphsA[50] = "BreastsPressed_v2"
	_morphsA[51] = "NippleSize"
	_morphsA[52] = "AreolaSize"
	_morphsA[53] = "AreolaPull_v2"
	_morphsA[54] = "NippleLength"
	_morphsA[55] = "NippleSquash1_v2"
	_morphsA[56] = "NippleSquash2_v2"
	_morphsA[57] = "NippleManga"
	_morphsA[58] = "NipplePerkiness"
	_morphsA[59] = "NipplePerkManga"
	_morphsA[60] = "NipplePuffy_v2"
	_morphsA[61] = "NippleShy_v2"
	_morphsA[62] = "NippleDistance"
	_morphsA[63] = "NippleTip"
	_morphsA[64] = "NippleTipManga"
	_morphsA[65] = "NippleThicc_v2"
	_morphsA[66] = "NippleTube_v2"
	_morphsA[67] = "NippleDown"
	_morphsA[68] = "NippleUp"
	_morphsA[69] = "NippleDip"
	_morphsA[70] = "NippleCrease_v2"
	_morphsA[71] = "NippleCrumpled_v2"
	_morphsA[72] = "NippleBump_v2"
	_morphsA[73] = "NipBGone"
	_morphsA[74] = "NippleInvert_v2"
	_morphsA[75] = "Clavicle_v2"
	_morphsA[76] = "BigTorso"
	_morphsA[77] = "ChestDepth"
	_morphsA[78] = "ChestWidth"
	_morphsA[79] = "SternumDepth"
	_morphsA[80] = "SternumHeight"
	_morphsA[81] = "RibsProminance"
	_morphsA[82] = "RibsMore_v2"
	_morphsA[83] = "NavelEven"
	_morphsA[84] = "Waist"
	_morphsA[85] = "WaistHeight"
	_morphsA[86] = "WideWaistLine"
	_morphsA[87] = "ChubbyWaist"
	_morphsA[88] = "Back"
	_morphsA[89] = "BackArch"
	_morphsA[90] = "BackValley_v2"
	_morphsA[91] = "BackWing_v2"
	_morphsA[92] = "Butt"
	_morphsA[93] = "BigButt"
	_morphsA[94] = "ButtSmall"
	_morphsA[95] = "ChubbyButt"
	_morphsA[96] = "AppleCheeks"
	_morphsA[97] = "ButtDimples"
	_morphsA[98] = "ButtUnderFold"
	_morphsA[99] = "RoundAss"
	_morphsA[100] = "ButtSaggy_v2"
	_morphsA[101] = "ButtPressed_v2"
	_morphsA[102] = "ButtNarrow_v2"
	_morphsA[103] = "ButtClassic"
	_morphsA[104] = "ButtShape2"
	_morphsA[105] = "ButtCrack"
	_morphsA[106] = "Groin"
	_morphsA[107] = "CrotchBack"
	_morphsA[108] = "7BLeg_v2"
	_morphsA[109] = "Thighs"
	_morphsA[110] = "ThighOutsideThicc_v2"
	_morphsA[111] = "ThighInsideThicc_v2"
	_morphsA[112] = "ThighFBThicc_v2"
	_morphsA[113] = "SlimThighs"
	_morphsA[114] = "LegsThin"
	_morphsA[115] = "ChubbyLegs"
	_morphsA[116] = "LegShapeClassic"
	_morphsA[117] = "LegSpread_v2"
	_morphsA[118] = "KneeHeight"
	_morphsA[119] = "KneeShape"
	_morphsA[120] = "KneeTogether_v2"
	_morphsA[121] = "CalfSize"
	_morphsA[122] = "CalfSmooth"
	_morphsA[123] = "CalfFBThicc_v2"
	_morphsA[124] = "FeetFeminine"
	_morphsA[125] = "AnkleSize"
	_morphsA[126] = "MuscleAbs"
	_morphsA[127] = "MuscleMoreAbs_v2"

	_morphsB = New String[31]
	_morphsB[0] = "MuscleArms"
	_morphsB[1] = "MuscleMoreArms_v2"
	_morphsB[2] = "MuscleButt"
	_morphsB[3] = "MuscleLegs"
	_morphsB[4] = "MuscleMoreLegs_v2"
	_morphsB[5] = "MusclePecs"
	_morphsB[6] = "MuscleBack_v2"
	_morphsB[7] = "Hips"
	_morphsB[8] = "HipBone"
	_morphsB[9] = "HipUpperWidth"
	_morphsB[10] = "HipCarved"
	_morphsB[11] = "HipForward"
	_morphsB[12] = "HipNarrow_v2"
	_morphsB[13] = "UNPHip_v2"
	_morphsB[14] = "Arms"
	_morphsB[15] = "ChubbyArms"
	_morphsB[16] = "ForearmSize"
	_morphsB[17] = "ArmpitShape_v2"
	_morphsB[18] = "WristSize"
	_morphsB[19] = "ShoulderWidth"
	_morphsB[20] = "ShoulderSmooth"
	_morphsB[21] = "ShoulderTweak"
	_morphsB[22] = "Belly"
	_morphsB[23] = "BigBelly"
	_morphsB[24] = "BellyFrontUpFat_v2"
	_morphsB[25] = "BellyFrontDownFat_v2"
	_morphsB[26] = "BellySideUpFat_v2"
	_morphsB[27] = "BellySideDownFat_v2"
	_morphsB[28] = "BellyUnder_v2"
	_morphsB[29] = "PregnancyBelly"
	_morphsB[30] = "BreastGravity"
EndFunction
