Scriptname cfl_FeralMCM extends SKI_ConfigBase

Import PO3_Events_Form
Import NiOverride

Int _enableOption
Int _feralPathOption
Int _recalculateOption
Int _claimWindowOption
Int _endShapeOption
Int _focusFamilyOption
Int _restoreExperienceOption
Int _reloadRacesOption
Int _developerOption
Int _testFamilyOption
Int _testSetTwoOption
Int _testSetNineOption
Int _testSetTwentyFourOption
Int _testClaimOption
Int _testResetOption

Int Function GetVersion()
	Return 4
EndFunction

Event OnConfigInit()
	ModName = "Feral"
	Pages = new String[3]
	Pages[0] = "Status"
	Pages[1] = "Instincts"
	Pages[2] = "Settings"
	HandleFeralReload()
EndEvent

Event OnVersionUpdate(Int newVersion)
	HandleFeralReload()
EndEvent

Bool Function IsFeralEnabled()
	Return StorageUtil.GetIntValue(Game.GetPlayer(), "Feral.Enabled") > 0
EndFunction

Bool Function IsFeralPathEnabled()
	Return StorageUtil.GetIntValue(Game.GetPlayer(), "Feral.PathEnabled") > 0
EndFunction

Bool Function IsDeveloperToolsEnabled()
	Return StorageUtil.GetIntValue(Game.GetPlayer(), "Feral.DeveloperTools") > 0
EndFunction

Function SetFeralEnabled(Bool enabled)
	Actor player = Game.GetPlayer()
	Spell claim = Game.GetFormFromFile(0x00081B, "Feral.esp") as Spell
	Spell aspect = Game.GetFormFromFile(0x00081D, "Feral.esp") as Spell
	If enabled
		StorageUtil.SetIntValue(player, "Feral.Enabled", 1)
		InitializeFeral()
		Debug.Notification("Feral hunting enabled.")
	Else
		If IsFeralPathEnabled()
			SetFeralPathEnabled(false)
		EndIf
		UnregisterForActorKilled(Self)
		EndActiveShape()
		If aspect
			player.DispelSpell(aspect)
			player.RemoveSpell(aspect)
		EndIf
		If claim
			player.RemoveSpell(claim)
		EndIf
		RemoveAllShapePowers()
		Spell revertPower = Game.GetFormFromFile(0x0009C1, "Feral.esp") as Spell
		If revertPower
			player.RemoveSpell(revertPower)
		EndIf
		StorageUtil.SetIntValue(player, "Feral.Enabled", 0)
		StorageUtil.SetIntValue(player, "Feral.Selected", 0)
		StorageUtil.SetIntValue(player, "Feral.AspectActive", 0)
		StorageUtil.UnsetFormValue(player, "Feral.LastKill")
		StorageUtil.UnsetFloatValue(player, "Feral.LastKillAt")
		Debug.Notification("Feral hunting disabled.")
	EndIf
EndFunction

Function InitializeFeral()
	Actor player = Game.GetPlayer()
	Spell claim = Game.GetFormFromFile(0x00081B, "Feral.esp") as Spell
	Spell aspect = Game.GetFormFromFile(0x00081D, "Feral.esp") as Spell
	Spell revertPower = Game.GetFormFromFile(0x0009C1, "Feral.esp") as Spell
	If claim
		player.AddSpell(claim, false)
	EndIf
	If aspect
		player.RemoveSpell(aspect)
	EndIf
	If revertPower
		player.AddSpell(revertPower, false)
	EndIf
	RefreshShapePowers()
	RegisterForFeralKills()
EndFunction

Event OnPlayerLoadGame()
	HandleFeralReload()
EndEvent

Event OnGameReload()
	Parent.OnGameReload()
	HandleFeralReload()
EndEvent

Function HandleFeralReload()
	EnsurePages()
	MigrateEconomy()
	RepairAspectState()
	If IsFeralEnabled()
		InitializeFeral()
	EndIf
	If IsFeralPathEnabled() && IsFeralEnabled()
		SaveExperienceSettings()
		ApplyFeralPathSettings()
	ElseIf IsFeralPathEnabled()
		SetFeralPathEnabled(false)
	Else
		RecoverExperienceSettingsIfNeeded()
	EndIf
EndFunction

Function EnsurePages()
	If !Pages || Pages.Length != 3
		Pages = new String[3]
		Pages[0] = "Status"
		Pages[1] = "Instincts"
		Pages[2] = "Settings"
	EndIf
EndFunction

Function RepairAspectState()
	Actor player = Game.GetPlayer()
	GlobalVariable activeForm = Game.GetFormFromFile(0x000801, "Dollform.esp") as GlobalVariable
	Int activeFamily = StorageUtil.GetIntValue(player, "Feral.ActiveFamily")
	If activeFamily < 1 || activeFamily > 8
		StorageUtil.SetIntValue(player, "Feral.AspectActive", 0)
		StorageUtil.SetIntValue(player, "Feral.ActiveFamily", 0)
		StorageUtil.SetIntValue(player, "Feral.ActiveRank", 0)
		If activeForm && activeForm.GetValueInt() >= 101 && activeForm.GetValueInt() <= 108
			activeForm.SetValue(0)
		EndIf
	EndIf
EndFunction

Function RegisterForFeralKills()
	UnregisterForActorKilled(Self)
	RegisterForActorKilled(Self)
EndFunction

Event OnActorKilled(Actor akVictim, Actor akKiller)
	If IsFeralEnabled() && akKiller == Game.GetPlayer() && GetFamily(akVictim) > 0
		StorageUtil.SetFormValue(Game.GetPlayer(), "Feral.LastKill", akVictim)
		StorageUtil.SetFloatValue(Game.GetPlayer(), "Feral.LastKillAt", Utility.GetCurrentRealTime())
		StorageUtil.SetIntValue(akVictim, "Feral.Eligible", GetFamily(akVictim))
		StorageUtil.SetIntValue(akVictim, "Feral.Claimed", 0)
		Debug.Notification("Feral: cast Claim Soul within " + GetClaimWindowSeconds() + " seconds to take the instinct.")
	EndIf
EndEvent

Event OnPageReset(String page)
	ResetOptionIDs()
	SetCursorFillMode(TOP_TO_BOTTOM)
	If page == "Instincts"
		BuildInstinctsPage()
	ElseIf page == "Settings"
		BuildSettingsPage()
	Else
		BuildStatusPage()
	EndIf
EndEvent

Function BuildStatusPage()
	AddHeaderOption("Feral Status")
	_enableOption = AddToggleOption("Enable Feral hunting", IsFeralEnabled())
	If !IsFeralEnabled()
		AddTextOption("Status", "Disabled", OPTION_FLAG_DISABLED)
		Return
	EndIf
	_feralPathOption = AddToggleOption("Feral Path: essence-only XP", IsFeralPathEnabled())
	AddTextOption("Current claim window", GetClaimWindowStatus(), OPTION_FLAG_DISABLED)
	Int activeFamily = StorageUtil.GetIntValue(Game.GetPlayer(), "Feral.ActiveFamily")
	If activeFamily > 0
		AddTextOption("Active transformation", FamilyName(activeFamily) + " / rank " + StorageUtil.GetIntValue(Game.GetPlayer(), "Feral.ActiveRank"), OPTION_FLAG_DISABLED)
		_endShapeOption = AddTextOption("Return to Self", "End shape", OPTION_FLAG_NONE)
	Else
		AddTextOption("Active transformation", "None", OPTION_FLAG_DISABLED)
	EndIf
	AddTextOption("Feral Path rewards", "25 / 35 / 50 XP", OPTION_FLAG_DISABLED)
	AddHeaderOption("Claim totals / ranks")
	Int i = 1
	While i <= 8
		AddTextOption(FamilyName(i), StorageUtil.GetIntValue(Game.GetPlayer(), "Feral.Count." + i) + " / rank " + GetRank(i), OPTION_FLAG_DISABLED)
		i += 1
	EndWhile
EndFunction

Function BuildInstinctsPage()
	Int family = GetFocusFamily()
	Int count = StorageUtil.GetIntValue(Game.GetPlayer(), "Feral.Count." + family)
	Int rank = GetRank(family)
	AddHeaderOption("Transformation")
	_focusFamilyOption = AddTextOption("Selected family", FamilyName(family), OPTION_FLAG_NONE)
	AddTextOption("Claims / rank", count + " / " + rank, OPTION_FLAG_DISABLED)
	AddTextOption("Next rank", NextRankText(count), OPTION_FLAG_DISABLED)
	Spell shape = GetShapeSpell(family, rank)
	AddTextOption("Power known", YesNo(shape && Game.GetPlayer().HasSpell(shape)), OPTION_FLAG_DISABLED)
	AddHeaderOption("Changes while transformed")
	AddTextOption("Combat effect", ShapeBonusText(family, rank), OPTION_FLAG_DISABLED)
	AddTextOption("Body expression", ShapeVisualText(family), OPTION_FLAG_DISABLED)
	AddTextOption("Duration", "120 seconds", OPTION_FLAG_DISABLED)
	AddTextOption("Strength", ShapeScaleText(rank), OPTION_FLAG_DISABLED)
EndFunction

Function BuildSettingsPage()
	AddHeaderOption("Hunting")
	_claimWindowOption = AddSliderOption("Claim window", GetClaimWindowSeconds(), "{0} seconds")
	AddHeaderOption("Maintenance")
	_recalculateOption = AddTextOption("Rebuild transformation powers", "Repair", OPTION_FLAG_NONE)
	_endShapeOption = AddTextOption("Clear active Feral shape", "Clean", OPTION_FLAG_NONE)
	_restoreExperienceOption = AddTextOption("Restore Experience settings now", "Restore", OPTION_FLAG_NONE)
	_reloadRacesOption = AddTextOption("Reload custom race config", "Reload", OPTION_FLAG_NONE)
	_developerOption = AddToggleOption("Developer testing tools", IsDeveloperToolsEnabled())
	If IsDeveloperToolsEnabled()
		Int testFamily = GetTestFamily()
		AddHeaderOption("Developer testing")
		AddTextOption("Ordinary XP suppressed", YesNo(ExperienceRewardsAreSuppressed()), OPTION_FLAG_DISABLED)
		AddTextOption("XP restore snapshot", YesNo(JsonUtil.GetIntValue(GetExperienceStateFile(), "OwnerActive") > 0), OPTION_FLAG_DISABLED)
		_testFamilyOption = AddTextOption("Test family", FamilyName(testFamily), OPTION_FLAG_NONE)
		_testSetTwoOption = AddTextOption("Set test family to 2 claims", "Set", OPTION_FLAG_NONE)
		_testSetNineOption = AddTextOption("Set test family to 9 claims", "Set", OPTION_FLAG_NONE)
		_testSetTwentyFourOption = AddTextOption("Set test family to 24 claims", "Set", OPTION_FLAG_NONE)
		_testClaimOption = AddTextOption("Simulate one successful claim", "Run", OPTION_FLAG_NONE)
		_testResetOption = AddTextOption("Reset test family", "Reset", OPTION_FLAG_NONE)
	EndIf
EndFunction

Function ResetOptionIDs()
	_enableOption = -1
	_feralPathOption = -1
	_recalculateOption = -1
	_claimWindowOption = -1
	_endShapeOption = -1
	_focusFamilyOption = -1
	_restoreExperienceOption = -1
	_reloadRacesOption = -1
	_developerOption = -1
	_testFamilyOption = -1
	_testSetTwoOption = -1
	_testSetNineOption = -1
	_testSetTwentyFourOption = -1
	_testClaimOption = -1
	_testResetOption = -1
EndFunction

String Function YesNo(Bool value)
	If value
		Return "Yes"
	EndIf
	Return "No"
EndFunction

Int Function GetClaimWindowSeconds()
	Int seconds = StorageUtil.GetIntValue(Game.GetPlayer(), "Feral.ClaimWindowSeconds")
	If seconds < 60 || seconds > 300
		seconds = 180
		StorageUtil.SetIntValue(Game.GetPlayer(), "Feral.ClaimWindowSeconds", seconds)
	EndIf
	Return seconds
EndFunction

Int Function GetFocusFamily()
	Int family = StorageUtil.GetIntValue(Game.GetPlayer(), "Feral.FocusFamily")
	If family < 1 || family > 8
		family = 1
		StorageUtil.SetIntValue(Game.GetPlayer(), "Feral.FocusFamily", family)
	EndIf
	Return family
EndFunction

String Function NextRankText(Int count)
	If count < 3
		Return (3 - count) + " more claims"
	ElseIf count < 10
		Return (10 - count) + " more claims"
	ElseIf count < 25
		Return (25 - count) + " more claims"
	EndIf
	Return "Maximum rank"
EndFunction

String Function ShapeScaleText(Int rank)
	If rank == 1
		Return "50% expression"
	ElseIf rank == 2
		Return "75% expression"
	ElseIf rank == 3
		Return "100% expression"
	EndIf
	Return "Locked at 3 claims"
EndFunction

String Function ShapeBonusText(Int family, Int rank)
	If rank < 1
		Return "Locked"
	EndIf
	Float scale = 0.50
	If rank == 2
		scale = 0.75
	ElseIf rank >= 3
		scale = 1.00
	EndIf
	If family == 1
		Return "+" + FormatShapeValue(15.0 * scale) + " speed / +" + FormatShapeValue(25.0 * scale) + " stamina regen"
	ElseIf family == 2
		Return "+" + FormatShapeValue(15.0 * scale) + " Sneak / +" + FormatShapeValue(15.0 * scale) + " unarmed"
	ElseIf family == 3
		Return "+" + FormatShapeValue(80.0 * scale) + " armor / +" + FormatShapeValue(40.0 * scale) + " Health"
	ElseIf family == 4
		Return "+" + FormatShapeValue(50.0 * scale) + " poison and disease resist"
	ElseIf family == 5
		Return "+" + FormatShapeValue(75.0 * scale) + " poison resist"
	ElseIf family == 6
		Return "+" + FormatShapeValue(65.0 * scale) + " armor"
	ElseIf family == 7
		Return "+" + FormatShapeValue(20.0 * scale) + " speed / +" + FormatShapeValue(60.0 * scale) + " Stamina"
	ElseIf family == 8
		Return "+" + FormatShapeValue(2.0 * scale) + " regen / -" + FormatShapeValue(35.0 * scale) + " fire resist"
	EndIf
	Return ""
EndFunction

String Function FormatShapeValue(Float value)
	Int scaled = (value * 100.0) as Int
	Int whole = scaled / 100
	Int fraction = scaled - (whole * 100)
	If fraction == 0
		Return whole as String
	ElseIf fraction % 10 == 0
		Return (whole as String) + "." + ((fraction / 10) as String)
	ElseIf fraction < 10
		Return (whole as String) + ".0" + (fraction as String)
	EndIf
	Return (whole as String) + "." + (fraction as String)
EndFunction

String Function ShapeVisualText(Int family)
	If family == 1
		Return "Lean athletic wolf build"
	ElseIf family == 2
		Return "Lithe feline build"
	ElseIf family == 3
		Return "Broad heavy bear build"
	ElseIf family == 4
		Return "Compact wiry skeever build"
	ElseIf family == 5
		Return "Narrow-waisted chitin build"
	ElseIf family == 6
		Return "Squat armored crab build"
	ElseIf family == 7
		Return "Powerful equine lower body"
	ElseIf family == 8
		Return "Large troll arms and shoulders"
	EndIf
	Return ""
EndFunction

String Function GetClaimWindowStatus()
	Actor player = Game.GetPlayer()
	Actor victim = StorageUtil.GetFormValue(player, "Feral.LastKill") as Actor
	If !victim || StorageUtil.GetIntValue(victim, "Feral.Eligible") < 1 || StorageUtil.GetIntValue(victim, "Feral.Claimed") > 0
		Return "None"
	EndIf
	Int seconds = (GetClaimWindowSeconds() - (Utility.GetCurrentRealTime() - StorageUtil.GetFloatValue(player, "Feral.LastKillAt"))) as Int
	If seconds < 0
		Return "Expired"
	EndIf
	Return FamilyName(StorageUtil.GetIntValue(victim, "Feral.Eligible")) + " / " + seconds + "s"
EndFunction

Event OnOptionSelect(Int option)
	If option == _enableOption
		SetFeralEnabled(!IsFeralEnabled())
		ForcePageReset()
	ElseIf option == _feralPathOption
		SetFeralPathEnabled(!IsFeralPathEnabled())
		ForcePageReset()
	ElseIf option == _recalculateOption
		RefreshShapePowers()
		RepairAspectState()
		Debug.Notification("Feral: transformation powers rebuilt from saved ranks.")
	ElseIf option == _endShapeOption
		EndActiveShape()
		ForcePageReset()
	ElseIf option == _focusFamilyOption
		Int focus = GetFocusFamily() + 1
		If focus > 8
			focus = 1
		EndIf
		StorageUtil.SetIntValue(Game.GetPlayer(), "Feral.FocusFamily", focus)
		ForcePageReset()
	ElseIf option == _restoreExperienceOption
		RestoreExperienceSettings()
		StorageUtil.SetIntValue(Game.GetPlayer(), "Feral.PathEnabled", 0)
		Debug.Notification("Feral: Experience settings restored and Feral Path disabled.")
		ForcePageReset()
	ElseIf option == _reloadRacesOption
		JsonUtil.Unload("../Feral/Races", false)
		JsonUtil.Load("../Feral/Races")
		Debug.Notification("Feral: custom race configuration reloaded.")
	ElseIf option == _developerOption
		StorageUtil.SetIntValue(Game.GetPlayer(), "Feral.DeveloperTools", (!IsDeveloperToolsEnabled()) as Int)
		ForcePageReset()
	ElseIf option == _testFamilyOption
		Int testFamily = GetTestFamily() + 1
		If testFamily > 8
			testFamily = 1
		EndIf
		StorageUtil.SetIntValue(Game.GetPlayer(), "Feral.TestFamily", testFamily)
		ForcePageReset()
	ElseIf option == _testSetTwoOption
		SetTestProgress(GetTestFamily(), 2)
		ForcePageReset()
	ElseIf option == _testSetNineOption
		SetTestProgress(GetTestFamily(), 9)
		ForcePageReset()
	ElseIf option == _testSetTwentyFourOption
		SetTestProgress(GetTestFamily(), 24)
		ForcePageReset()
	ElseIf option == _testClaimOption
		CompleteClaim(GetTestFamily())
		ForcePageReset()
	ElseIf option == _testResetOption
		SetTestProgress(GetTestFamily(), 0)
		ForcePageReset()
	EndIf
EndEvent

Event OnOptionSliderOpen(Int option)
	If option == _claimWindowOption
		SetSliderDialogStartValue(GetClaimWindowSeconds())
		SetSliderDialogDefaultValue(180.0)
		SetSliderDialogRange(60.0, 300.0)
		SetSliderDialogInterval(30.0)
	EndIf
EndEvent

Event OnOptionSliderAccept(Int option, Float value)
	If option == _claimWindowOption
		Int seconds = value as Int
		StorageUtil.SetIntValue(Game.GetPlayer(), "Feral.ClaimWindowSeconds", seconds)
		SetSliderOptionValue(option, seconds, "{0} seconds")
	EndIf
EndEvent

String Function FamilyName(Int family)
	If family == 1
		Return "Wolf"
	ElseIf family == 2
		Return "Sabre Cat"
	ElseIf family == 3
		Return "Bear"
	ElseIf family == 4
		Return "Skeever"
	ElseIf family == 5
		Return "Spider"
	ElseIf family == 6
		Return "Mudcrab"
	ElseIf family == 7
		Return "Horse"
	ElseIf family == 8
		Return "Troll"
	EndIf
	Return "None"
EndFunction

Int Function GetTestFamily()
	Int family = StorageUtil.GetIntValue(Game.GetPlayer(), "Feral.TestFamily")
	If family < 1 || family > 8
		family = 1
		StorageUtil.SetIntValue(Game.GetPlayer(), "Feral.TestFamily", family)
	EndIf
	Return family
EndFunction

Function SetTestProgress(Int family, Int count)
	If family < 1 || family > 8
		Return
	EndIf
	Actor player = Game.GetPlayer()
	StorageUtil.SetIntValue(player, "Feral.Count." + family, count)
	Int rank = RankForCount(count)
	StorageUtil.SetIntValue(player, "Feral.Rank." + family, rank)
	ApplyShapeRank(family, rank)
	Debug.Notification("Feral test: " + FamilyName(family) + " set to " + count + " claims / rank " + rank + ".")
EndFunction

Int Function RankForCount(Int count)
	If count >= 25
		Return 3
	ElseIf count >= 10
		Return 2
	ElseIf count >= 3
		Return 1
	EndIf
	Return 0
EndFunction

Int Function GetFamily(Actor akActor)
	If !akActor
		Return 0
	EndIf
	Race r = akActor.GetRace()
	If r == Game.GetForm(0x0001320A) as Race
		Return 1
	ElseIf r == Game.GetForm(0x00013200) as Race || r == Game.GetForm(0x00013202) as Race || r == Game.GetFormFromFile(0x0000D0B6, "Dawnguard.esm") as Race
		Return 2
	ElseIf r == Game.GetForm(0x000131E7) as Race || r == Game.GetForm(0x000131E8) as Race || r == Game.GetForm(0x000131E9) as Race
		Return 3
	ElseIf r == Game.GetForm(0x00013201) as Race || r == Game.GetForm(0x000C3EDF) as Race
		Return 4
	ElseIf r == Game.GetForm(0x000131F8) as Race || r == Game.GetForm(0x00053477) as Race || r == Game.GetForm(0x0004E507) as Race || r == Game.GetFormFromFile(0x00014449, "Dragonborn.esm") as Race || r == Game.GetFormFromFile(0x00027483, "Dragonborn.esm") as Race
		Return 5
	ElseIf r == Game.GetForm(0x000BA545) as Race || r == Game.GetFormFromFile(0x0001B647, "Dragonborn.esm") as Race
		Return 6
	ElseIf r == Game.GetForm(0x000131FD) as Race || r == Game.GetForm(0x000DE505) as Race
		Return 7
	ElseIf r == Game.GetForm(0x00013205) as Race || r == Game.GetForm(0x00013206) as Race || r == Game.GetFormFromFile(0x000117F4, "Dawnguard.esm") as Race || r == Game.GetFormFromFile(0x000117F5, "Dawnguard.esm") as Race
		Return 8
	EndIf
	Return GetConfiguredFamily(r)
EndFunction

Int Function GetConfiguredFamily(Race creatureRace)
	String configFile = "../Feral/Races"
	Int family = 1
	While family <= 8
		String familyKey = FamilyConfigKey(family)
		Int count = JsonUtil.StringListCount(configFile, familyKey + "Plugins")
		Int formCount = JsonUtil.IntListCount(configFile, familyKey + "FormIDs")
		If formCount < count
			count = formCount
		EndIf
		Int i = 0
		While i < count
			String pluginName = JsonUtil.StringListGet(configFile, familyKey + "Plugins", i)
			Int formID = JsonUtil.IntListGet(configFile, familyKey + "FormIDs", i)
			If creatureRace == Game.GetFormFromFile(formID, pluginName) as Race
				Return family
			EndIf
			i += 1
		EndWhile
		family += 1
	EndWhile
	Return 0
EndFunction

String Function FamilyConfigKey(Int family)
	If family == 1
		Return "Wolf"
	ElseIf family == 2
		Return "SabreCat"
	ElseIf family == 3
		Return "Bear"
	ElseIf family == 4
		Return "Skeever"
	ElseIf family == 5
		Return "Spider"
	ElseIf family == 6
		Return "Mudcrab"
	ElseIf family == 7
		Return "Horse"
	ElseIf family == 8
		Return "Troll"
	EndIf
	Return ""
EndFunction

Int Function ClaimLast()
	If !IsFeralEnabled()
		Debug.Notification("Feral hunting is disabled. Enable it in the Feral MCM first.")
		Return 0
	EndIf
	Actor victim = StorageUtil.GetFormValue(Game.GetPlayer(), "Feral.LastKill") as Actor
	If !victim || !victim.IsDead() || StorageUtil.GetIntValue(victim, "Feral.Eligible") < 1
		Debug.Notification("Feral: no recently hunted creature is ready to claim.")
		Return 0
	EndIf
	If Utility.GetCurrentRealTime() - StorageUtil.GetFloatValue(Game.GetPlayer(), "Feral.LastKillAt") > GetClaimWindowSeconds()
		Debug.Notification("Feral: the trail has gone cold. Claim essence within " + GetClaimWindowSeconds() + " seconds of the kill.")
		Return 0
	EndIf
	If StorageUtil.GetIntValue(victim, "Feral.Claimed") > 0
		Debug.Notification("Feral: that essence is already claimed.")
		Return 0
	EndIf
	Int family = StorageUtil.GetIntValue(victim, "Feral.Eligible")
	StorageUtil.SetIntValue(victim, "Feral.Claimed", 1)
	CompleteClaim(family)
	Return family
EndFunction

Function CompleteClaim(Int family)
	If family < 1 || family > 8
		Return
	EndIf
	Int count = StorageUtil.GetIntValue(Game.GetPlayer(), "Feral.Count." + family) + 1
	StorageUtil.SetIntValue(Game.GetPlayer(), "Feral.Count." + family, count)
	Int oldRank = StorageUtil.GetIntValue(Game.GetPlayer(), "Feral.Rank." + family)
	Int newRank = RankForCount(count)
	If newRank > oldRank
		StorageUtil.SetIntValue(Game.GetPlayer(), "Feral.Rank." + family, newRank)
		ApplyShapeRank(family, newRank)
		Debug.Notification("Feral " + FamilyName(family) + " transformation reaches rank " + newRank + ".")
	Else
		Debug.Notification("Feral: " + FamilyName(family) + " essence claimed (" + count + ").")
	EndIf
	If IsFeralPathEnabled()
		Int reward = GetEssenceXP(family)
		Experience.AddExperience(reward, true)
	EndIf
EndFunction

Int Function GetEssenceXP(Int family)
	If family == 1 || family == 4 || family == 6
		Return 25
	ElseIf family == 2 || family == 5
		Return 35
	ElseIf family == 3 || family == 7 || family == 8
		Return 50
	EndIf
	Return 0
EndFunction

Int Function GetRank(Int family)
	Return StorageUtil.GetIntValue(Game.GetPlayer(), "Feral.Rank." + family)
EndFunction

Function RaiseBodymorphTier(Int formID, Int rank)
	GlobalVariable tier = Game.GetFormFromFile(formID, "Dollform.esp") as GlobalVariable
	If tier && tier.GetValueInt() < rank
		tier.SetValue(rank)
	EndIf
EndFunction

Spell Function GetLegacyPassiveSpell(Int family, Int rank)
	If family < 1 || family > 8 || rank < 1 || rank > 3
		Return None
	EndIf
	Int formID = 0x000920 + ((family - 1) * 3) + (rank - 1)
	Return Game.GetFormFromFile(formID, "Feral.esp") as Spell
EndFunction

Spell Function GetShapeSpell(Int family, Int rank)
	If family < 1 || family > 8 || rank < 1 || rank > 3
		Return None
	EndIf
	Int formID = 0x0009A0 + ((family - 1) * 3) + (rank - 1)
	Return Game.GetFormFromFile(formID, "Feral.esp") as Spell
EndFunction

Function ApplyShapeRank(Int family, Int rank)
	Actor player = Game.GetPlayer()
	Int i = 1
	While i <= 3
		Spell shape = GetShapeSpell(family, i)
		If shape
			player.DispelSpell(shape)
			player.RemoveSpell(shape)
		EndIf
		i += 1
	EndWhile
	Spell current = GetShapeSpell(family, rank)
	If current && IsFeralEnabled()
		player.AddSpell(current, false)
	EndIf
EndFunction

Function RefreshShapePowers()
	Int family = 1
	While family <= 8
		ApplyShapeRank(family, GetRank(family))
		family += 1
	EndWhile
EndFunction

Function RemoveAllShapePowers()
	Actor player = Game.GetPlayer()
	Int family = 1
	While family <= 8
		ApplyShapeRank(family, 0)
		family += 1
	EndWhile
EndFunction

Function RemoveAllLegacyPassiveSpells()
	Actor player = Game.GetPlayer()
	Int family = 1
	While family <= 8
		Int rank = 1
		While rank <= 3
			Spell passive = GetLegacyPassiveSpell(family, rank)
			If passive
				player.RemoveSpell(passive)
			EndIf
			rank += 1
		EndWhile
		family += 1
	EndWhile
EndFunction

Function EndActiveShape()
	Actor player = Game.GetPlayer()
	Int family = 1
	While family <= 8
		Int rank = 1
		While rank <= 3
			Spell shape = GetShapeSpell(family, rank)
			If shape
				player.DispelSpell(shape)
			EndIf
			rank += 1
		EndWhile
		family += 1
	EndWhile
	ClearFeralVisuals()
	GlobalVariable activeForm = Game.GetFormFromFile(0x000801, "Dollform.esp") as GlobalVariable
	If activeForm && activeForm.GetValueInt() >= 101 && activeForm.GetValueInt() <= 108
		activeForm.SetValue(0)
	EndIf
	StorageUtil.SetIntValue(player, "Feral.ActiveFamily", 0)
	StorageUtil.SetIntValue(player, "Feral.ActiveRank", 0)
EndFunction

Function ClearFeralVisuals()
	Actor player = Game.GetPlayer()
	NiOverride.ClearBodyMorphKeys(player, "Feral.Shapes")
	NiOverride.ClearBodyMorphKeys(player, "Feral.Shapes.Visible")
	NiOverride.UpdateModelWeight(player)
	player.QueueNiNodeUpdate()
	SlaveTats.simple_remove_tattoo(player, "Feral Shapes", "Wolf Pelt", true, true)
	SlaveTats.simple_remove_tattoo(player, "Feral Shapes", "Sabre Stripes", true, true)
	SlaveTats.simple_remove_tattoo(player, "Feral Shapes", "Bear Mantle", true, true)
	SlaveTats.simple_remove_tattoo(player, "Feral Shapes", "Skeever Mottle", true, true)
	SlaveTats.simple_remove_tattoo(player, "Feral Shapes", "Spider Chitin", true, true)
	SlaveTats.simple_remove_tattoo(player, "Feral Shapes", "Mudcrab Carapace", true, true)
	SlaveTats.simple_remove_tattoo(player, "Feral Shapes", "Horse Stride", true, true)
	SlaveTats.simple_remove_tattoo(player, "Feral Shapes", "Troll Hide", true, true)
	SlaveTats.synchronize_tattoos(player, true)
EndFunction

Function RemoveLegacyPassiveValues(Int version)
	Actor player = Game.GetPlayer()
	Int rank = StorageUtil.GetIntValue(player, "Feral.Rank.1")
	player.ModActorValue("SpeedMult", -2.0 * rank)
	player.ModActorValue("StaminaRateMult", -3.0 * rank)
	rank = StorageUtil.GetIntValue(player, "Feral.Rank.2")
	If version < 2
		player.ModActorValue("Sneak", -2.0 * rank)
	Else
		player.ModActorValue("StaminaRateMult", -5.0 * rank)
	EndIf
	player.ModActorValue("UnarmedDamage", -2.0 * rank)
	rank = StorageUtil.GetIntValue(player, "Feral.Rank.3")
	player.ModActorValue("Health", -8.0 * rank)
	player.ModActorValue("DamageResist", -8.0 * rank)
	rank = StorageUtil.GetIntValue(player, "Feral.Rank.4")
	player.ModActorValue("PoisonResist", -8.0 * rank)
	player.ModActorValue("DiseaseResist", -8.0 * rank)
	rank = StorageUtil.GetIntValue(player, "Feral.Rank.5")
	player.ModActorValue("PoisonResist", -12.0 * rank)
	rank = StorageUtil.GetIntValue(player, "Feral.Rank.6")
	player.ModActorValue("DamageResist", -10.0 * rank)
	rank = StorageUtil.GetIntValue(player, "Feral.Rank.7")
	player.ModActorValue("Stamina", -10.0 * rank)
	player.ModActorValue("CarryWeight", -8.0 * rank)
	rank = StorageUtil.GetIntValue(player, "Feral.Rank.8")
	player.ModActorValue("HealRate", -1.0 * rank)
	player.ModActorValue("MeleeDamage", -3.0 * rank)
EndFunction

Function MigrateEconomy()
	Actor player = Game.GetPlayer()
	Int version = StorageUtil.GetIntValue(player, "Feral.EconomyVersion")
	If version < 3
		RemoveLegacyPassiveValues(version)
		StorageUtil.SetIntValue(player, "Feral.EconomyVersion", 3)
	EndIf
	If version < 4
		RemoveAllLegacyPassiveSpells()
		Spell oldAspect = Game.GetFormFromFile(0x00081D, "Feral.esp") as Spell
		If oldAspect
			player.DispelSpell(oldAspect)
			player.RemoveSpell(oldAspect)
		EndIf
		StorageUtil.SetIntValue(player, "Feral.Selected", 0)
		StorageUtil.SetIntValue(player, "Feral.AspectActive", 0)
		StorageUtil.SetIntValue(player, "Feral.EconomyVersion", 4)
	EndIf
	If IsFeralEnabled()
		RefreshShapePowers()
	Else
		RemoveAllShapePowers()
	EndIf
EndFunction

Function SetFeralPathEnabled(Bool enabled)
	Actor player = Game.GetPlayer()
	If enabled
		If !IsFeralEnabled()
			Debug.Notification("Feral: enable Feral hunting before choosing the Feral Path.")
			Return
		EndIf
		SaveExperienceSettings()
		StorageUtil.SetIntValue(player, "Feral.PathEnabled", 1)
		ApplyFeralPathSettings()
		Debug.Notification("Feral Path enabled: only claimed essence grants character XP.")
	Else
		RestoreExperienceSettings()
		StorageUtil.SetIntValue(player, "Feral.PathEnabled", 0)
		Debug.Notification("Feral Path disabled: prior Experience rewards restored.")
	EndIf
EndFunction

Function SaveExperienceSettings()
	Actor player = Game.GetPlayer()
	String stateFile = GetExperienceStateFile()
	String[] settings = GetExperienceRewardSettings()
	If JsonUtil.GetIntValue(stateFile, "OwnerActive") < 1 || !ExperienceRewardsAreSuppressed()
		Int i = 0
		While i < settings.Length
			Int value = Experience.GetSettingInt(settings[i])
			StorageUtil.SetIntValue(player, "Feral.Experience.Int." + settings[i], value)
			JsonUtil.SetIntValue(stateFile, "Int." + settings[i], value)
			i += 1
		EndWhile
		JsonUtil.SetIntValue(stateFile, "bEnableKilling", Experience.GetSettingBool("bEnableKilling") as Int)
		JsonUtil.SetIntValue(stateFile, "bEnableReading", Experience.GetSettingBool("bEnableReading") as Int)
		JsonUtil.SetIntValue(stateFile, "bEnableSkillXP", Experience.GetSettingBool("bEnableSkillXP") as Int)
		JsonUtil.SetFloatValue(stateFile, "fKillingMult", Experience.GetSettingFloat("fKillingMult"))
		JsonUtil.SetFloatValue(stateFile, "fReadingMult", Experience.GetSettingFloat("fReadingMult"))
		JsonUtil.SetIntValue(stateFile, "OwnerActive", 1)
		JsonUtil.Save(stateFile, true)
	EndIf
	StorageUtil.SetIntValue(player, "Feral.ExperienceSettingsSaved", 1)
EndFunction

Bool Function ExperienceRewardsAreSuppressed()
	String[] settings = GetExperienceRewardSettings()
	Int i = 0
	While i < settings.Length
		If Experience.GetSettingInt(settings[i]) != 0
			Return false
		EndIf
		i += 1
	EndWhile
	If Experience.GetSettingBool("bEnableKilling") || Experience.GetSettingBool("bEnableReading") || Experience.GetSettingBool("bEnableSkillXP")
		Return false
	EndIf
	If Experience.GetSettingFloat("fKillingMult") != 0.0 || Experience.GetSettingFloat("fReadingMult") != 0.0
		Return false
	EndIf
	Return true
EndFunction

Function ApplyFeralPathSettings()
	String[] settings = GetExperienceRewardSettings()
	Int i = 0
	While i < settings.Length
		Experience.SetSettingInt(settings[i], 0)
		i += 1
	EndWhile
	Experience.SetSettingBool("bEnableKilling", false)
	Experience.SetSettingBool("bEnableReading", false)
	Experience.SetSettingBool("bEnableSkillXP", false)
	Experience.SetSettingFloat("fKillingMult", 0.0)
	Experience.SetSettingFloat("fReadingMult", 0.0)
EndFunction

Function RestoreExperienceSettings()
	Actor player = Game.GetPlayer()
	String stateFile = GetExperienceStateFile()
	Bool hasGlobalSnapshot = JsonUtil.GetIntValue(stateFile, "OwnerActive") > 0
	If !hasGlobalSnapshot && StorageUtil.GetIntValue(player, "Feral.ExperienceSettingsSaved") < 1
		Return
	EndIf
	String[] settings = GetExperienceRewardSettings()
	Int i = 0
	While i < settings.Length
		If hasGlobalSnapshot
			Experience.SetSettingInt(settings[i], JsonUtil.GetIntValue(stateFile, "Int." + settings[i]))
		Else
			Experience.SetSettingInt(settings[i], StorageUtil.GetIntValue(player, "Feral.Experience.Int." + settings[i]))
		EndIf
		i += 1
	EndWhile
	If hasGlobalSnapshot
		Experience.SetSettingBool("bEnableKilling", JsonUtil.GetIntValue(stateFile, "bEnableKilling") > 0)
		Experience.SetSettingBool("bEnableReading", JsonUtil.GetIntValue(stateFile, "bEnableReading") > 0)
		Experience.SetSettingBool("bEnableSkillXP", JsonUtil.GetIntValue(stateFile, "bEnableSkillXP") > 0)
		Experience.SetSettingFloat("fKillingMult", JsonUtil.GetFloatValue(stateFile, "fKillingMult"))
		Experience.SetSettingFloat("fReadingMult", JsonUtil.GetFloatValue(stateFile, "fReadingMult"))
		JsonUtil.SetIntValue(stateFile, "OwnerActive", 0)
		JsonUtil.Save(stateFile, true)
	Else
		Experience.SetSettingBool("bEnableKilling", StorageUtil.GetIntValue(player, "Feral.Experience.bEnableKilling") > 0)
		Experience.SetSettingBool("bEnableReading", StorageUtil.GetIntValue(player, "Feral.Experience.bEnableReading") > 0)
		Experience.SetSettingBool("bEnableSkillXP", StorageUtil.GetIntValue(player, "Feral.Experience.bEnableSkillXP") > 0)
		Experience.SetSettingFloat("fKillingMult", StorageUtil.GetFloatValue(player, "Feral.Experience.fKillingMult"))
		Experience.SetSettingFloat("fReadingMult", StorageUtil.GetFloatValue(player, "Feral.Experience.fReadingMult"))
	EndIf
	StorageUtil.SetIntValue(player, "Feral.ExperienceSettingsSaved", 0)
EndFunction

Function RecoverExperienceSettingsIfNeeded()
	If JsonUtil.GetIntValue(GetExperienceStateFile(), "OwnerActive") > 0
		RestoreExperienceSettings()
		Debug.Notification("Feral: restored Experience settings left by another loaded save.")
	EndIf
EndFunction

String Function GetExperienceStateFile()
	Return "../Feral/ExperienceRuntime"
EndFunction

String[] Function GetExperienceRewardSettings()
	String[] settings = new String[91]
	settings[0] = "iXPQuestObjectives"
	settings[1] = "iXPQuestNone"
	settings[2] = "iXPQuestMain"
	settings[3] = "iXPQuestCollege"
	settings[4] = "iXPQuestThieves"
	settings[5] = "iXPQuestBrotherhood"
	settings[6] = "iXPQuestCompanions"
	settings[7] = "iXPQuestMisc"
	settings[8] = "iXPQuestDaedric"
	settings[9] = "iXPQuestSide"
	settings[10] = "iXPQuestCivilWar"
	settings[11] = "iXPQuestDawnguard"
	settings[12] = "iXPQuestDragonborn"
	settings[13] = "iXPDiscDefault"
	settings[14] = "iXPDiscCity"
	settings[15] = "iXPDiscTown"
	settings[16] = "iXPDiscSettlement"
	settings[17] = "iXPDiscCave"
	settings[18] = "iXPDiscCamp"
	settings[19] = "iXPDiscFort"
	settings[20] = "iXPDiscNordicRuin"
	settings[21] = "iXPDiscDwemerRuin"
	settings[22] = "iXPDiscShipwreck"
	settings[23] = "iXPDiscGrove"
	settings[24] = "iXPDiscLandmark"
	settings[25] = "iXPDiscDragonLair"
	settings[26] = "iXPDiscFarm"
	settings[27] = "iXPDiscWoodMill"
	settings[28] = "iXPDiscMine"
	settings[29] = "iXPDiscMilitaryCamp"
	settings[30] = "iXPDiscDoomstone"
	settings[31] = "iXPDiscWheatMill"
	settings[32] = "iXPDiscSmelter"
	settings[33] = "iXPDiscStable"
	settings[34] = "iXPDiscImperialTower"
	settings[35] = "iXPDiscClearing"
	settings[36] = "iXPDiscPass"
	settings[37] = "iXPDiscAltar"
	settings[38] = "iXPDiscRock"
	settings[39] = "iXPDiscLighthouse"
	settings[40] = "iXPDiscOrcStronghold"
	settings[41] = "iXPDiscGiantCamp"
	settings[42] = "iXPDiscShack"
	settings[43] = "iXPDiscNordicTower"
	settings[44] = "iXPDiscNordicDwelling"
	settings[45] = "iXPDiscDocks"
	settings[46] = "iXPDiscDaedricShrine"
	settings[47] = "iXPDiscCastle"
	settings[48] = "iXPDiscMiraakTemple"
	settings[49] = "iXPDiscStandingStone"
	settings[50] = "iXPDiscTelvanniTower"
	settings[51] = "iXPDiscCastleKarstaag"
	settings[52] = "iXPClearDefault"
	settings[53] = "iXPClearCity"
	settings[54] = "iXPClearTown"
	settings[55] = "iXPClearSettlement"
	settings[56] = "iXPClearCave"
	settings[57] = "iXPClearCamp"
	settings[58] = "iXPClearFort"
	settings[59] = "iXPClearNordicRuin"
	settings[60] = "iXPClearDwemerRuin"
	settings[61] = "iXPClearShipwreck"
	settings[62] = "iXPClearGrove"
	settings[63] = "iXPClearLandmark"
	settings[64] = "iXPClearDragonLair"
	settings[65] = "iXPClearFarm"
	settings[66] = "iXPClearWoodMill"
	settings[67] = "iXPClearMine"
	settings[68] = "iXPClearMilitaryCamp"
	settings[69] = "iXPClearDoomstone"
	settings[70] = "iXPClearWheatMill"
	settings[71] = "iXPClearSmelter"
	settings[72] = "iXPClearStable"
	settings[73] = "iXPClearImperialTower"
	settings[74] = "iXPClearClearing"
	settings[75] = "iXPClearPass"
	settings[76] = "iXPClearAltar"
	settings[77] = "iXPClearRock"
	settings[78] = "iXPClearLighthouse"
	settings[79] = "iXPClearOrcStronghold"
	settings[80] = "iXPClearGiantCamp"
	settings[81] = "iXPClearShack"
	settings[82] = "iXPClearNordicTower"
	settings[83] = "iXPClearNordicDwelling"
	settings[84] = "iXPClearDocks"
	settings[85] = "iXPClearDaedricShrine"
	settings[86] = "iXPClearCastle"
	settings[87] = "iXPClearMiraakTemple"
	settings[88] = "iXPClearStandingStone"
	settings[89] = "iXPClearTelvanniTower"
	settings[90] = "iXPClearCastleKarstaag"
	Return settings
EndFunction
