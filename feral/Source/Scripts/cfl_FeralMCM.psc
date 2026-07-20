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
Int _humanResponseOption
Int _testFamilyOption
Int _testSetTwoOption
Int _testSetNineOption
Int _testSetTwentyFourOption
Int _testClaimOption
Int _testResetOption
Int _testNotorietyOption
Int _testHuntersOption
Int _testLevelSliderOption
Int _morphMultiplierOption
Int _morphResetOption
Int _kinshipOption
Int _kinshipApproachesOption
Int _kinshipLevelOption
Int _kinshipFrequencyOption
Int _kinshipCooldownOption
Int _kinshipCleanupOption
Int[] _morphOptions

Int Function GetVersion()
	Return 13
EndFunction

Event OnConfigInit()
	ModName = "Feral"
	EnsurePages()
	HandleFeralReload()
EndEvent

Event OnVersionUpdate(Int newVersion)
	EnsurePages()
	HandleFeralReload()
EndEvent

Event OnConfigOpen()
	; SkyUI sends Pages to the menu after this event. Rebuild the complete
	; array here so older saved quest instances cannot retain a blank or
	; partially initialized navigation list.
	EnsurePages()
EndEvent

Bool Function IsFeralEnabled()
	Return StorageUtil.GetIntValue(Game.GetPlayer(), "Feral.Enabled") > 0
EndFunction

Bool Function IsFeralPathEnabled()
	Return GetFeralPathMode() > 0
EndFunction

Int Function GetFeralPathMode()
	Int mode = StorageUtil.GetIntValue(Game.GetPlayer(), "Feral.PathMode")
	If mode < 0 || mode > 2
		mode = 0
	EndIf
	If mode == 0 && StorageUtil.GetIntValue(Game.GetPlayer(), "Feral.PathEnabled") > 0
		mode = 2
	EndIf
	Return mode
EndFunction

String Function FeralPathModeName()
	Int mode = GetFeralPathMode()
	If mode == 1
		Return "Balanced"
	ElseIf mode == 2
		Return "Hardcore"
	EndIf
	Return "Off"
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
		UnregisterForCellFullyLoaded(Self)
		EndActiveShape()
		If aspect
			player.DispelSpell(aspect)
			player.RemoveSpell(aspect)
		EndIf
		If claim
			player.RemoveSpell(claim)
		EndIf
		RemoveAllShapePowers()
		RemoveAllPassivePowers()
		RemoveAllTechniquePowers()
		Spell revertPower = Game.GetFormFromFile(0x0009C1, "Feral.esp") as Spell
		If revertPower
			player.RemoveSpell(revertPower)
		EndIf
		StorageUtil.SetIntValue(player, "Feral.Enabled", 0)
		StorageUtil.SetIntValue(player, "Feral.Selected", 0)
		StorageUtil.SetIntValue(player, "Feral.AspectActive", 0)
		ClearPendingEssence()
		Debug.Notification("Feral hunting disabled.")
	EndIf
EndFunction

Function InitializeFeral()
	Actor player = Game.GetPlayer()
	Spell claim = Game.GetFormFromFile(0x00081B, "Feral.esp") as Spell
	Spell aspect = Game.GetFormFromFile(0x00081D, "Feral.esp") as Spell
	Spell revertPower = Game.GetFormFromFile(0x0009C1, "Feral.esp") as Spell
	If claim
		player.RemoveSpell(claim)
	EndIf
	If aspect
		player.RemoveSpell(aspect)
	EndIf
	If revertPower
		; Return to Self is retired: recasting the active shape releases it.
		player.RemoveSpell(revertPower)
	EndIf
	RefreshShapePowers()
	RefreshPassivePowers()
	RefreshTechniquePowers()
	ClearPendingEssence()
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
	Else
		RemoveAllShapePowers()
		RemoveAllPassivePowers()
		RemoveAllTechniquePowers()
		UnregisterForCellFullyLoaded(Self)
	EndIf
	If GetFeralPathMode() > 0 && IsFeralEnabled()
		SaveExperienceSettings()
		ApplyFeralPathSettings()
	ElseIf GetFeralPathMode() > 0
		SetFeralPathMode(0)
	Else
		RecoverExperienceSettingsIfNeeded()
	EndIf
EndFunction

Function EnsurePages()
	Pages = new String[6]
	Pages[0] = "Overview"
	Pages[1] = "Progression"
	Pages[2] = "Families"
	Pages[3] = "Morphs"
	Pages[4] = "Human response"
	Pages[5] = "Settings"
EndFunction

Function RepairAspectState()
	Actor player = Game.GetPlayer()
	GlobalVariable activeForm = Game.GetFormFromFile(0x000801, "Dollform.esp") as GlobalVariable
	Int activeFamily = StorageUtil.GetIntValue(player, "Feral.ActiveFamily")
	If activeFamily < 1 || activeFamily > 8
		StorageUtil.SetIntValue(player, "Feral.AspectActive", 0)
		StorageUtil.SetIntValue(player, "Feral.ActiveFamily", 0)
		StorageUtil.SetIntValue(player, "Feral.ActiveRank", 0)
		StorageUtil.SetIntValue(player, "Feral.ActiveToken", 0)
		StorageUtil.UnsetFloatValue(player, "Feral.ActiveExpression")
		If activeForm && IsFeralActiveValue(activeForm.GetValueInt())
			activeForm.SetValue(0)
		EndIf
		Return
	EndIf
	; Saved state claims an active shape. If no matching effect is actually
	; live (killed by an unload, an external dispel, or a finish event that
	; died with its native binding), the lock and StorageUtil state would
	; block every future cast forever. Recover them.
	Int activeRank = StorageUtil.GetIntValue(player, "Feral.ActiveRank")
	If activeRank < 1 || activeRank > 5
		activeRank = 1
	EndIf
	Int shapeEffectId
	If activeRank <= 3
		shapeEffectId = 0x000980 + ((activeFamily - 1) * 3) + (activeRank - 1)
	Else
		shapeEffectId = 0x000A30 + ((activeFamily - 1) * 2) + (activeRank - 4)
	EndIf
	MagicEffect liveShape = Game.GetFormFromFile(shapeEffectId, "Feral.esp") as MagicEffect
	If liveShape && !player.HasMagicEffect(liveShape)
		ClearFeralVisuals()
		If activeForm && IsFeralActiveValue(activeForm.GetValueInt())
			activeForm.SetValue(0)
		EndIf
		StorageUtil.SetIntValue(player, "Feral.ActiveFamily", 0)
		StorageUtil.SetIntValue(player, "Feral.ActiveRank", 0)
		StorageUtil.SetIntValue(player, "Feral.ActiveToken", 0)
		StorageUtil.UnsetFloatValue(player, "Feral.ActiveExpression")
		StorageUtil.SetFloatValue(player, "Feral.FatigueUntil", 0.0)
		Debug.Notification("Feral: recovered a stale transformation state.")
	EndIf
EndFunction

Int Function ActiveFormId(Int activeValue)
	If activeValue >= 100000
		Return activeValue / 100000
	EndIf
	Return activeValue
EndFunction

Bool Function IsFeralActiveValue(Int activeValue)
	Int formID = ActiveFormId(activeValue)
	Return formID >= 101 && formID <= 108
EndFunction

Function RegisterForFeralKills()
	UnregisterForActorKilled(Self)
	RegisterForActorKilled(Self)
	UnregisterForCellFullyLoaded(Self)
	RegisterForCellFullyLoaded(Self)
EndFunction

Event OnActorKilled(Actor akVictim, Actor akKiller)
	If !IsFeralEnabled() || akKiller != Game.GetPlayer()
		Return
	EndIf
	Int family = GetFamily(akVictim)
	If family > 0
		CompleteClaim(family)
	ElseIf GetActiveFamily() > 0
		RecordWitnessedHumanKill(akVictim)
	EndIf
EndEvent

Event OnPageReset(String page)
	ResetOptionIDs()
	SetCursorFillMode(TOP_TO_BOTTOM)
	If page == "Progression"
		BuildProgressionPage()
	ElseIf page == "Families"
		BuildFamiliesPage()
	ElseIf page == "Morphs"
		BuildMorphsPage()
	ElseIf page == "Human response"
		BuildHumanResponsePage()
	ElseIf page == "Settings"
		BuildSettingsPage()
	Else
		BuildOverviewPage()
	EndIf
EndEvent

Function BuildOverviewPage()
	AddHeaderOption("Feral status")
	_enableOption = AddToggleOption("Enable Feral hunting", IsFeralEnabled())
	If !IsFeralEnabled()
		AddTextOption("Status", "Disabled", OPTION_FLAG_DISABLED)
		AddTextOption("Getting started", "Enable hunting, then kill a supported creature", OPTION_FLAG_DISABLED)
		AddTextOption("Essence", "Harvested automatically from your kills", OPTION_FLAG_DISABLED)
		Return
	EndIf
	_feralPathOption = AddTextOption("Feral Path XP mode", FeralPathModeName(), OPTION_FLAG_NONE)
	AddTextOption("Essence harvesting", "Automatic from supported player kills", OPTION_FLAG_DISABLED)
	AddTextOption("Transformation fatigue", FatigueStatus(), OPTION_FLAG_DISABLED)
	Int activeFamily = StorageUtil.GetIntValue(Game.GetPlayer(), "Feral.ActiveFamily")
	If activeFamily > 0
		AddTextOption("Active shape", FamilyName(activeFamily) + " / level " + GetMasteryLevel(activeFamily) + " / " + FormatShapeValue(StorageUtil.GetFloatValue(Game.GetPlayer(), "Feral.ActiveExpression") * 100.0) + "%", OPTION_FLAG_DISABLED)
		_endShapeOption = AddTextOption("End active shape", "Release", OPTION_FLAG_NONE)
	Else
		AddTextOption("Active shape", "None", OPTION_FLAG_DISABLED)
	EndIf
	Int focus = GetFocusFamily()
	AddHeaderOption("Focused family")
	_focusFamilyOption = AddTextOption("Family", FamilyName(focus), OPTION_FLAG_NONE)
	AddTextOption("Mastery", "Level " + GetMasteryLevel(focus) + " / " + MasteryProgressText(focus), OPTION_FLAG_DISABLED)
	AddTextOption("Expression", FormatShapeValue(GetExpressionScale(focus) * 100.0) + "%", OPTION_FLAG_DISABLED)
	AddHeaderOption("Connected systems")
	AddTextOption("Sex progression", SexIntegrationStatus(), OPTION_FLAG_DISABLED)
	AddTextOption("Human response", HumanResponseModeName(), OPTION_FLAG_DISABLED)
	AddTextOption("Notoriety", GetNotoriety() + " / 100 - " + NotorietyTierName(GetNotoriety()), OPTION_FLAG_DISABLED)
EndFunction

Function BuildProgressionPage()
	AddHeaderOption("Mastery sources")
	AddTextOption("Hunting", "Automatic: +10 / +18 / +28 mastery", OPTION_FLAG_DISABLED)
	AddTextOption("Common families", "Wolf, Skeever, Spider, Mudcrab: +10", OPTION_FLAG_DISABLED)
	AddTextOption("Uncommon families", "Sabre Cat, Stag: +18", OPTION_FLAG_DISABLED)
	AddTextOption("Rare families", "Bear, Troll: +28", OPTION_FLAG_DISABLED)
	AddTextOption("Time transformed", "+1 mastery per completed 10 seconds", OPTION_FLAG_DISABLED)
	AddTextOption("Matching creature sex", SexProgressionText(), OPTION_FLAG_DISABLED)
	AddHeaderOption("Level curve")
	AddTextOption("Family levels", "Eight independent paths, levels 1-100", OPTION_FLAG_DISABLED)
	AddTextOption("Next-level cost", "5 + ceil(current level x 0.45)", OPTION_FLAG_DISABLED)
	AddTextOption("Level 100 total", "2,775 mastery per family", OPTION_FLAG_DISABLED)
	AddTextOption("Visual expression", "25% at level 1; continuous to 100%", OPTION_FLAG_DISABLED)
	AddHeaderOption("Milestones")
	AddTextOption("Levels 1 / 25 / 50 / 75 / 100", "2 / 5 / 10 / 15 / 20 minute shapes", OPTION_FLAG_DISABLED)
	AddTextOption("Levels 25 / 50 / 75", "Permanent instinct ranks", OPTION_FLAG_DISABLED)
	AddTextOption("Levels 25 and 75", "Additional transformed traits", OPTION_FLAG_DISABLED)
	AddTextOption("Level 50", "Unlocks the family technique", OPTION_FLAG_DISABLED)
	AddTextOption("Level 100", "Upgrades the technique to apex strength", OPTION_FLAG_DISABLED)
	AddHeaderOption("Feral Path character XP")
	_feralPathOption = AddTextOption("Mode", FeralPathModeName(), OPTION_FLAG_NONE)
	AddTextOption("Harvest XP", "Common 30 / uncommon 45 / rare 70", OPTION_FLAG_DISABLED)
	AddTextOption("Shape-use XP", "Matches mastery earned from transformed time", OPTION_FLAG_DISABLED)
	AddTextOption("Off", "Feral grants no character XP", OPTION_FLAG_DISABLED)
	AddTextOption("Balanced", "Disables kill and skill XP; keeps other rewards", OPTION_FLAG_DISABLED)
	AddTextOption("Hardcore", "Disables ordinary Experience reward sources", OPTION_FLAG_DISABLED)
	AddTextOption("Restoration", "Prior Experience settings are restored on Off", OPTION_FLAG_DISABLED)
EndFunction

Function BuildFamiliesPage()
	Int family = GetFocusFamily()
	Int count = StorageUtil.GetIntValue(Game.GetPlayer(), "Feral.Count." + family)
	Int rank = GetRank(family)
	Int level = GetMasteryLevel(family)
	Int passiveRank = PassiveRankForLevel(level)
	Int durationTier = DurationTierForLevel(level)
	AddHeaderOption("Family progression")
	_focusFamilyOption = AddTextOption("Selected family", FamilyName(family), OPTION_FLAG_NONE)
	AddTextOption("Harvests", count, OPTION_FLAG_DISABLED)
	AddTextOption("Mastery level", level + " / 100", OPTION_FLAG_DISABLED)
	AddTextOption("Level progress", MasteryProgressText(family), OPTION_FLAG_DISABLED)
	AddTextOption("Current expression", FormatShapeValue(GetExpressionScale(family) * 100.0) + "%", OPTION_FLAG_DISABLED)
	AddTextOption("Next harvest", "+" + MasteryAwardForHarvest(family) + " mastery", OPTION_FLAG_DISABLED)
	AddTextOption("Time transformed", "+1 mastery per completed 10 seconds", OPTION_FLAG_DISABLED)
	Spell shape = GetShapeSpell(family, durationTier)
	AddTextOption("Shape power known", YesNo(shape && Game.GetPlayer().HasSpell(shape)), OPTION_FLAG_DISABLED)
	AddHeaderOption("Permanent instinct")
	AddTextOption("Passive rank", passiveRank + " / 3", OPTION_FLAG_DISABLED)
	AddTextOption("Always active bonus", PermanentBonusText(family, passiveRank), OPTION_FLAG_DISABLED)
	AddHeaderOption("While transformed")
	AddTextOption("Combat effect", ShapeBonusText(family, rank), OPTION_FLAG_DISABLED)
	AddTextOption("Visual direction", ShapeVisualText(family), OPTION_FLAG_DISABLED)
	AddTextOption("Marking opacity", FormatShapeValue(GetMarkOpacity(family) * 100.0) + "%", OPTION_FLAG_DISABLED)
	AddTextOption("Shape duration", ShapeDurationForLevel(level) + " seconds", OPTION_FLAG_DISABLED)
	AddHeaderOption("Mastery milestones")
	AddTextOption("Level 25 trait", MilestoneTraitText(family, 25), OPTION_FLAG_DISABLED)
	AddTextOption("Level 50 technique", TechniqueStatusText(family), OPTION_FLAG_DISABLED)
	AddTextOption("Level 75 trait", MilestoneTraitText(family, 75), OPTION_FLAG_DISABLED)
	AddTextOption("Level 100 apex", "Upgrades " + TechniqueName(family), OPTION_FLAG_DISABLED)
	AddTextOption("Next milestone", NextMilestoneText(level), OPTION_FLAG_DISABLED)
EndFunction

Function BuildMorphsPage()
	Actor player = Game.GetPlayer()
	Int family = GetFocusFamily()
	Int level = GetMasteryLevel(family)
	Float expression = GetExpressionScale(family)
	AddHeaderOption("Feral morphs")
	_focusFamilyOption = AddTextOption("Selected family", FamilyName(family), OPTION_FLAG_NONE)
	AddTextOption("Mastery / expression", "Level " + level + " / " + FormatShapeValue(expression * 100.0) + "%", OPTION_FLAG_DISABLED)
	AddTextOption("Selected shape active", YesNo(GetActiveFamily() == family), OPTION_FLAG_DISABLED)
	AddTextOption("Calculation", "Slider x intensity x expression = applied", OPTION_FLAG_DISABLED)
	AddTextOption("Visible layer", "Applied value x 0.75", OPTION_FLAG_DISABLED)
	_morphMultiplierOption = AddSliderOption("Family intensity", GetMorphMultiplier(family), "{2}")
	_morphResetOption = AddTextOption("Reset selected family", "Defaults", OPTION_FLAG_NONE)
	AddHeaderOption("Full-strength morph values")
	_morphOptions = new Int[12]
	Int clearIndex = 0
	While clearIndex < _morphOptions.Length
		_morphOptions[clearIndex] = -1
		clearIndex += 1
	EndWhile
	Int index = 0
	While index < GetMorphCount(family)
		String morph = GetMorphName(family, index)
		_morphOptions[index] = AddSliderOption(MorphDisplayName(morph), GetConfiguredMorphValue(family, index), "{2}")
		Float mainValue = NiOverride.GetBodyMorph(player, morph, "Feral.Shapes")
		Float visibleValue = NiOverride.GetBodyMorph(player, morph, "Feral.Shapes.Visible")
		AddTextOption("Applied main / visible", FormatMorphValue(mainValue) + " / " + FormatMorphValue(visibleValue), OPTION_FLAG_DISABLED)
		index += 1
	EndWhile
	AddTextOption("When changes apply", "Next transformation", OPTION_FLAG_DISABLED)
EndFunction

Function BuildHumanResponsePage()
	Int notoriety = GetNotoriety()
	AddHeaderOption("Human response")
	_humanResponseOption = AddTextOption("Response mode", HumanResponseModeName(), OPTION_FLAG_NONE)
	AddTextOption("Off", "No notoriety or witness reactions", OPTION_FLAG_DISABLED)
	AddTextOption("Reactions", "Notoriety, warnings, and witness fear", OPTION_FLAG_DISABLED)
	AddTextOption("Full", "Also enables guard bounties and hunters", OPTION_FLAG_DISABLED)
	AddHeaderOption("Current notoriety")
	AddTextOption("Notoriety", notoriety + " / 100", OPTION_FLAG_DISABLED)
	AddTextOption("Current tier", NotorietyTierName(notoriety), OPTION_FLAG_DISABLED)
	AddTextOption("Witnessed transformation", "+5", OPTION_FLAG_DISABLED)
	AddTextOption("Witnessed human kill", "+15 while transformed", OPTION_FLAG_DISABLED)
	AddTextOption("Decay", "-2 per full game day after 1 quiet day", OPTION_FLAG_DISABLED)
	AddHeaderOption("Thresholds")
	AddTextOption("20 - Whispered about", "People begin spreading warnings", OPTION_FLAG_DISABLED)
	AddTextOption("40 - Feared", "Witnesses can flee", OPTION_FLAG_DISABLED)
	AddTextOption("60 - Outlawed", "Witnessing guards add 250 bounty once/day", OPTION_FLAG_DISABLED)
	AddTextOption("80 - Hunted", "20% exterior-cell hunter check", OPTION_FLAG_DISABLED)
	AddTextOption("100 - Apex quarry", "35% check and an elite third hunter", OPTION_FLAG_DISABLED)
	AddTextOption("Hunter cooldown", "3 game days; one active group", OPTION_FLAG_DISABLED)
EndFunction

String Function CosmeticStatus(Int family, Int rank)
	If rank < 3
		Return "Unlocks at mastery level 67 when configured"
	EndIf
	String configKey = "Family" + family + "Rank3"
	String pluginName = JsonUtil.GetStringValue("../Feral/Cosmetics", configKey + "Plugin")
	Int formID = JsonUtil.GetIntValue("../Feral/Cosmetics", configKey + "FormID")
	If pluginName == "" || formID <= 0
		Return "None configured"
	ElseIf Game.GetFormFromFile(formID, pluginName)
		Return "Available: " + pluginName
	EndIf
	Return "Configured plugin not found"
EndFunction

Function BuildSettingsPage()
	AddHeaderOption("Hunting")
	AddTextOption("Essence collection", "Automatic", OPTION_FLAG_DISABLED)
	AddHeaderOption("Creature kinship")
	AddTextOption("Integration", KinshipIntegrationStatus(), OPTION_FLAG_DISABLED)
	_kinshipOption = AddToggleOption("Matching creatures become neutral", IsKinshipEnabled())
	_kinshipApproachesOption = AddToggleOption("Matching creature approaches", AreKinshipApproachesEnabled())
	_kinshipLevelOption = AddSliderOption("Minimum mastery level", GetKinshipMinimumLevel(), "{0}")
	_kinshipFrequencyOption = AddTextOption("Approach frequency", KinshipFrequencyName(), OPTION_FLAG_NONE)
	_kinshipCooldownOption = AddSliderOption("Accepted-scene cooldown", GetKinshipCooldownHours(), "{0} game hours")
	_kinshipCleanupOption = AddTextOption("Clear temporary kinship", "Clean", OPTION_FLAG_NONE)
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
		_testLevelSliderOption = AddSliderOption("Set exact mastery level", GetMasteryLevel(testFamily), "{0}")
		_testSetTwoOption = AddTextOption("Set mastery level 1", "Set", OPTION_FLAG_NONE)
		_testSetNineOption = AddTextOption("Set mastery level 50", "Set", OPTION_FLAG_NONE)
		_testSetTwentyFourOption = AddTextOption("Set mastery level 100", "Set", OPTION_FLAG_NONE)
		_testClaimOption = AddTextOption("Simulate one automatic harvest", "Run", OPTION_FLAG_NONE)
		_testNotorietyOption = AddTextOption("Set notoriety 80", "Set", OPTION_FLAG_NONE)
		_testHuntersOption = AddTextOption("Force hunter group", "Spawn", OPTION_FLAG_NONE)
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
	_humanResponseOption = -1
	_testFamilyOption = -1
	_testSetTwoOption = -1
	_testSetNineOption = -1
	_testSetTwentyFourOption = -1
	_testClaimOption = -1
	_testResetOption = -1
	_testNotorietyOption = -1
	_testHuntersOption = -1
	_testLevelSliderOption = -1
	_morphMultiplierOption = -1
	_morphResetOption = -1
	_kinshipOption = -1
	_kinshipApproachesOption = -1
	_kinshipLevelOption = -1
	_kinshipFrequencyOption = -1
	_kinshipCooldownOption = -1
	_kinshipCleanupOption = -1
	_morphOptions = new Int[1]
	_morphOptions[0] = -1
EndFunction

Bool Function SexIntegrationInstalled()
	String integrationFile = "../Feral/SexIntegration"
	Return JsonUtil.JsonExists(integrationFile) && JsonUtil.IsGood(integrationFile) && JsonUtil.GetIntValue(integrationFile, "Installed") > 0
EndFunction

Int Function SexIntegrationReward()
	If SexIntegrationInstalled()
		Int reward = JsonUtil.GetIntValue("../Feral/SexIntegration", "MasteryPerMatchingScene", 12)
		If reward > 0
			Return reward
		EndIf
	EndIf
	Return 12
EndFunction

String Function SexIntegrationStatus()
	If SexIntegrationInstalled()
		Return "Installed; matching scenes grant +" + SexIntegrationReward() + " mastery"
	EndIf
	Return "Optional integration not detected"
EndFunction

String Function SexProgressionText()
	If SexIntegrationInstalled()
		Return "+" + SexIntegrationReward() + " with matching creature and shape"
	EndIf
	Return "Requires the optional sex integration"
EndFunction

Function EnsureKinshipDefaults()
	Actor player = Game.GetPlayer()
	If StorageUtil.GetIntValue(player, "Feral.Kinship.Initialized") < 1
		StorageUtil.SetIntValue(player, "Feral.Kinship.Enabled", 1)
		StorageUtil.SetIntValue(player, "Feral.Kinship.Approaches", 1)
		StorageUtil.SetIntValue(player, "Feral.Kinship.MinimumLevel", 10)
		StorageUtil.SetIntValue(player, "Feral.Kinship.Frequency", 1)
		StorageUtil.SetIntValue(player, "Feral.Kinship.CooldownHours", 6)
		StorageUtil.SetIntValue(player, "Feral.Kinship.Initialized", 1)
	EndIf
EndFunction

Bool Function IsKinshipEnabled()
	EnsureKinshipDefaults()
	Return StorageUtil.GetIntValue(Game.GetPlayer(), "Feral.Kinship.Enabled") > 0
EndFunction

Bool Function AreKinshipApproachesEnabled()
	EnsureKinshipDefaults()
	Return StorageUtil.GetIntValue(Game.GetPlayer(), "Feral.Kinship.Approaches") > 0
EndFunction

Int Function GetKinshipMinimumLevel()
	EnsureKinshipDefaults()
	Return StorageUtil.GetIntValue(Game.GetPlayer(), "Feral.Kinship.MinimumLevel")
EndFunction

Int Function GetKinshipFrequency()
	EnsureKinshipDefaults()
	Return StorageUtil.GetIntValue(Game.GetPlayer(), "Feral.Kinship.Frequency")
EndFunction

String Function KinshipFrequencyName()
	Int frequency = GetKinshipFrequency()
	If frequency == 0
		Return "Rare"
	ElseIf frequency == 2
		Return "Likely"
	EndIf
	Return "Occasional"
EndFunction

Int Function GetKinshipCooldownHours()
	EnsureKinshipDefaults()
	Return StorageUtil.GetIntValue(Game.GetPlayer(), "Feral.Kinship.CooldownHours")
EndFunction

String Function KinshipIntegrationStatus()
	Quest controller = Game.GetFormFromFile(0x000803, "FeralCreatureKinship.esp") as Quest
	If controller
		Return "Installed; neutral at level " + GetKinshipMinimumLevel()
	EndIf
	Return "Optional integration plugin not detected"
EndFunction

Function RequestKinshipCleanup()
	Int handle = ModEvent.Create("FeralKinshipCleanup")
	If handle
		ModEvent.Send(handle)
	EndIf
EndFunction

Function BroadcastShapeStart(Int family, Int masteryLevel, Int token)
	Int handle = ModEvent.Create("FeralShapeStart")
	If handle
		ModEvent.PushInt(handle, family)
		ModEvent.PushInt(handle, masteryLevel)
		ModEvent.PushInt(handle, token)
		ModEvent.PushInt(handle, ShapeDurationForLevel(masteryLevel))
		ModEvent.Send(handle)
	EndIf
EndFunction

Function BroadcastShapeEnd(Int family, Int token)
	If family < 1 || token < 1
		Return
	EndIf
	Int handle = ModEvent.Create("FeralShapeEnd")
	If handle
		ModEvent.PushInt(handle, family)
		ModEvent.PushInt(handle, token)
		ModEvent.Send(handle)
	EndIf
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

Int Function MasteryPointsForNextLevel(Int level)
	If level >= 100
		Return 0
	EndIf
	Return 5 + (Math.Ceiling(level * 0.45) as Int)
EndFunction

Int Function MasteryAwardForHarvest(Int family)
	If family == 3 || family == 8
		Return 28
	ElseIf family == 2 || family == 7
		Return 18
	EndIf
	Return 10
EndFunction

Int Function GetMasteryLevel(Int family)
	Return StorageUtil.GetIntValue(Game.GetPlayer(), "Feral.MasteryLevel." + family)
EndFunction

Int Function GetMasteryProgress(Int family)
	Return StorageUtil.GetIntValue(Game.GetPlayer(), "Feral.MasteryProgress." + family)
EndFunction

String Function MasteryProgressText(Int family)
	Int level = GetMasteryLevel(family)
	If level >= 100
		Return "Maximum mastery"
	EndIf
	Return GetMasteryProgress(family) + " / " + MasteryPointsForNextLevel(level)
EndFunction

Int Function RankForLevel(Int level)
	; One transformation power per family. Ranks 2/3 remain only as save-compatible records.
	If level >= 1
		Return 1
	EndIf
	Return 0
EndFunction

Int Function PassiveRankForLevel(Int level)
	If level >= 75
		Return 3
	ElseIf level >= 50
		Return 2
	ElseIf level >= 25
		Return 1
	EndIf
	Return 0
EndFunction

Int Function DurationTierForLevel(Int level)
	If level >= 100
		Return 5
	ElseIf level >= 75
		Return 4
	ElseIf level >= 50
		Return 3
	ElseIf level >= 25
		Return 2
	ElseIf level >= 1
		Return 1
	EndIf
	Return 0
EndFunction

Int Function GetDurationTier(Int family)
	Return DurationTierForLevel(GetMasteryLevel(family))
EndFunction

Int Function ShapeDurationForLevel(Int level)
	Int tier = DurationTierForLevel(level)
	If tier == 5
		Return 1200
	ElseIf tier == 4
		Return 900
	ElseIf tier == 3
		Return 600
	ElseIf tier == 2
		Return 300
	ElseIf tier == 1
		Return 120
	EndIf
	Return 0
EndFunction

Float Function GetExpressionScale(Int family)
	Return ExpressionScaleForLevel(GetMasteryLevel(family))
EndFunction

Float Function ExpressionScaleForLevel(Int level)
	If level < 1
		Return 0.0
	ElseIf level >= 100
		Return 1.0
	EndIf
	Return 0.25 + ((level - 1) * (0.75 / 99.0))
EndFunction

Float Function GetMarkOpacity(Int family)
	Float expression = GetExpressionScale(family)
	If expression <= 0.0
		Return 0.0
	EndIf
	Return 0.25 + (0.65 * expression)
EndFunction

Function GrantMastery(Int family, Int amount, String source = "activity", Bool silent = false)
	If family < 1 || family > 8 || amount < 1
		Return
	EndIf
	Actor player = Game.GetPlayer()
	Int oldLevel = GetMasteryLevel(family)
	Int oldPassiveRank = PassiveRankForLevel(oldLevel)
	Int oldDurationTier = DurationTierForLevel(oldLevel)
	Int level = oldLevel
	Int progress = GetMasteryProgress(family) + amount
	While level < 100 && progress >= MasteryPointsForNextLevel(level)
		progress -= MasteryPointsForNextLevel(level)
		level += 1
	EndWhile
	If level >= 100
		level = 100
		progress = 0
	EndIf
	StorageUtil.SetIntValue(player, "Feral.MasteryLevel." + family, level)
	StorageUtil.SetIntValue(player, "Feral.MasteryProgress." + family, progress)
	Int newRank = RankForLevel(level)
	StorageUtil.SetIntValue(player, "Feral.Rank." + family, newRank)
	Int newDurationTier = DurationTierForLevel(level)
	If newDurationTier != oldDurationTier
		ApplyShapeTier(family, newDurationTier)
	EndIf
	Int newPassiveRank = PassiveRankForLevel(level)
	If newPassiveRank != oldPassiveRank
		ApplyPassiveRank(family, newPassiveRank)
	EndIf
	If oldLevel < 50 && level >= 50
		ApplyTechniquePower(family)
	EndIf
	If !silent
		If level > oldLevel
			Debug.Notification("Feral " + FamilyName(family) + " mastery reaches level " + level + " through " + source + ".")
		ElseIf level < 100
			Debug.Notification("Feral " + FamilyName(family) + ": +" + amount + " mastery (" + progress + "/" + MasteryPointsForNextLevel(level) + ").")
		EndIf
	EndIf
EndFunction

Function SetMasteryFromTotalPoints(Int family, Int totalPoints)
	Actor player = Game.GetPlayer()
	Int level = 0
	Int progress = totalPoints
	While level < 100 && progress >= MasteryPointsForNextLevel(level)
		progress -= MasteryPointsForNextLevel(level)
		level += 1
	EndWhile
	If level >= 100
		level = 100
		progress = 0
	EndIf
	StorageUtil.SetIntValue(player, "Feral.MasteryLevel." + family, level)
	StorageUtil.SetIntValue(player, "Feral.MasteryProgress." + family, progress)
	StorageUtil.SetIntValue(player, "Feral.Rank." + family, RankForLevel(level))
EndFunction

Function AddActivityMastery(Int family, Int points, String source = "activity")
	GrantMastery(family, points, source)
EndFunction

Function AddShapeTime(Int family, Float seconds)
	If seconds > 1200.0
		seconds = 1200.0
	EndIf
	Int points = (seconds / 10.0) as Int
	If points > 0
		GrantMastery(family, points, "shape use")
		If IsFeralPathEnabled()
			Experience.AddExperience(points, true)
		EndIf
	EndIf
EndFunction

String Function PermanentBonusText(Int family, Int rank)
	If rank < 1
		Return "Unlocks at mastery level 25"
	EndIf
	If family == 1
		Return "+" + FormatShapeValue(2.0 * rank) + " speed / +" + FormatShapeValue(3.0 * rank) + " stamina regen"
	ElseIf family == 2
		Return "+" + FormatShapeValue(5.0 * rank) + " stamina regen / +" + FormatShapeValue(2.0 * rank) + " unarmed"
	ElseIf family == 3
		Return "+" + FormatShapeValue(8.0 * rank) + " health / +" + FormatShapeValue(8.0 * rank) + " armor"
	ElseIf family == 4
		Return "+" + FormatShapeValue(8.0 * rank) + " poison/disease resist"
	ElseIf family == 5
		Return "+" + FormatShapeValue(12.0 * rank) + " poison resist"
	ElseIf family == 6
		Return "+" + FormatShapeValue(10.0 * rank) + " armor"
	ElseIf family == 7
		Return "+" + FormatShapeValue(10.0 * rank) + " stamina / +" + FormatShapeValue(8.0 * rank) + " carry"
	ElseIf family == 8
		Return "+" + FormatShapeValue(0.25 * rank) + " regen / +" + FormatShapeValue(3.0 * rank) + " melee"
	EndIf
	Return ""
EndFunction

String Function ShapeBonusText(Int family, Int rank)
	If rank < 1
		Return "Locked"
	EndIf
	Float scale = GetExpressionScale(family)
	If family == 1
		Return "+" + FormatShapeValue(12.0 * scale) + " speed / +" + FormatShapeValue(35.0 * scale) + " stamina regen / +" + FormatShapeValue(15.0 * scale) + " unarmed / -" + FormatShapeValue(15.0 * scale) + " magic resist"
	ElseIf family == 2
		Return "+" + FormatShapeValue(25.0 * scale) + " sneak / +" + FormatShapeValue(25.0 * scale) + " unarmed / +" + FormatShapeValue(10.0 * scale) + "% attack speed / -" + FormatShapeValue(25.0 * scale) + " health"
	ElseIf family == 3
		Return "+" + FormatShapeValue(100.0 * scale) + " armor / +" + FormatShapeValue(50.0 * scale) + " health / +" + FormatShapeValue(25.0 * scale) + " stagger resist / -" + FormatShapeValue(20.0 * scale) + " sneak"
	ElseIf family == 4
		Return "+" + FormatShapeValue(60.0 * scale) + " poison/disease resist / +" + FormatShapeValue(20.0 * scale) + " sneak / +" + FormatShapeValue(30.0 * scale) + " carry / -" + FormatShapeValue(15.0 * scale) + " fire resist"
	ElseIf family == 5
		Return "+" + FormatShapeValue(80.0 * scale) + " poison resist / +" + FormatShapeValue(30.0 * scale) + " unarmed / +" + FormatShapeValue(15.0 * scale) + " speed / -" + FormatShapeValue(20.0 * scale) + " stamina regen"
	ElseIf family == 6
		Return "+" + FormatShapeValue(140.0 * scale) + " armor / +" + FormatShapeValue(20.0 * scale) + " block / -" + FormatShapeValue(8.0 * scale) + " speed"
	ElseIf family == 7
		Return "+" + FormatShapeValue(15.0 * scale) + " speed / +" + FormatShapeValue(80.0 * scale) + " stamina / +" + FormatShapeValue(20.0 * scale) + " archery / -" + FormatShapeValue(20.0 * scale) + " armor"
	ElseIf family == 8
		Return "+" + FormatShapeValue(2.0 * scale) + " regen / +" + FormatShapeValue(25.0 * scale) + " melee / +" + FormatShapeValue(60.0 * scale) + " health / -" + FormatShapeValue(40.0 * scale) + " fire resist"
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

String Function FormatMorphValue(Float value)
	String prefix = ""
	If value < 0.0
		prefix = "-"
		value = -value
	EndIf
	Int scaled = ((value * 1000.0) + 0.5) as Int
	Int whole = scaled / 1000
	Int fraction = scaled - (whole * 1000)
	If fraction < 10
		Return prefix + whole + ".00" + fraction
	ElseIf fraction < 100
		Return prefix + whole + ".0" + fraction
	EndIf
	Return prefix + whole + "." + fraction
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
		Return "Graceful long-legged stag build"
	ElseIf family == 8
		Return "Large troll arms and shoulders"
	EndIf
	Return ""
EndFunction

Int Function GetMorphCount(Int family)
	If family == 4 || family == 5 || family == 6
		Return 11
	ElseIf family >= 1 && family <= 8
		Return 12
	EndIf
	Return 0
EndFunction

String Function GetMorphName(Int family, Int index)
	If family == 1
		If index == 0
			Return "MuscleLegs"
		ElseIf index == 1
			Return "MuscleMoreLegs_v2"
		ElseIf index == 2
			Return "Thighs"
		ElseIf index == 3
			Return "ThighOutsideThicc_v2"
		ElseIf index == 4
			Return "CalfSize"
		ElseIf index == 5
			Return "CalfFBThicc_v2"
		ElseIf index == 6
			Return "MuscleButt"
		ElseIf index == 7
			Return "Butt"
		ElseIf index == 8
			Return "Waist"
		ElseIf index == 9
			Return "Belly"
		ElseIf index == 10
			Return "Arms"
		ElseIf index == 11
			Return "ShoulderWidth"
		EndIf
	ElseIf family == 2
		If index == 0
			Return "Thighs"
		ElseIf index == 1
			Return "ThighInsideThicc_v2"
		ElseIf index == 2
			Return "MuscleLegs"
		ElseIf index == 3
			Return "CalfSize"
		ElseIf index == 4
			Return "Butt"
		ElseIf index == 5
			Return "RoundAss"
		ElseIf index == 6
			Return "Hips"
		ElseIf index == 7
			Return "HipUpperWidth"
		ElseIf index == 8
			Return "Waist"
		ElseIf index == 9
			Return "Belly"
		ElseIf index == 10
			Return "Arms"
		ElseIf index == 11
			Return "ShoulderWidth"
		EndIf
	ElseIf family == 3
		If index == 0
			Return "Arms"
		ElseIf index == 1
			Return "MuscleArms"
		ElseIf index == 2
			Return "MuscleMoreArms_v2"
		ElseIf index == 3
			Return "ShoulderWidth"
		ElseIf index == 4
			Return "MuscleAbs"
		ElseIf index == 5
			Return "MuscleLegs"
		ElseIf index == 6
			Return "MuscleMoreLegs_v2"
		ElseIf index == 7
			Return "Thighs"
		ElseIf index == 8
			Return "CalfSize"
		ElseIf index == 9
			Return "Waist"
		ElseIf index == 10
			Return "Belly"
		ElseIf index == 11
			Return "Butt"
		EndIf
	ElseIf family == 4
		If index == 0
			Return "Arms"
		ElseIf index == 1
			Return "MuscleArms"
		ElseIf index == 2
			Return "ShoulderWidth"
		ElseIf index == 3
			Return "Thighs"
		ElseIf index == 4
			Return "ChubbyLegs"
		ElseIf index == 5
			Return "Waist"
		ElseIf index == 6
			Return "Belly"
		ElseIf index == 7
			Return "CalfSize"
		ElseIf index == 8
			Return "CalfFBThicc_v2"
		ElseIf index == 9
			Return "Butt"
		ElseIf index == 10
			Return "Hips"
		EndIf
	ElseIf family == 5
		If index == 0
			Return "Waist"
		ElseIf index == 1
			Return "Belly"
		ElseIf index == 2
			Return "Hips"
		ElseIf index == 3
			Return "HipUpperWidth"
		ElseIf index == 4
			Return "Butt"
		ElseIf index == 5
			Return "BigButt"
		ElseIf index == 6
			Return "Thighs"
		ElseIf index == 7
			Return "ThighOutsideThicc_v2"
		ElseIf index == 8
			Return "Arms"
		ElseIf index == 9
			Return "MuscleArms"
		ElseIf index == 10
			Return "ShoulderWidth"
		EndIf
	ElseIf family == 6
		If index == 0
			Return "ShoulderWidth"
		ElseIf index == 1
			Return "Arms"
		ElseIf index == 2
			Return "MuscleArms"
		ElseIf index == 3
			Return "Waist"
		ElseIf index == 4
			Return "Belly"
		ElseIf index == 5
			Return "Hips"
		ElseIf index == 6
			Return "Thighs"
		ElseIf index == 7
			Return "ChubbyLegs"
		ElseIf index == 8
			Return "CalfSize"
		ElseIf index == 9
			Return "Butt"
		ElseIf index == 10
			Return "MuscleButt"
		EndIf
	ElseIf family == 7
		If index == 0
			Return "Thighs"
		ElseIf index == 1
			Return "ThighOutsideThicc_v2"
		ElseIf index == 2
			Return "CalfSize"
		ElseIf index == 3
			Return "CalfFBThicc_v2"
		ElseIf index == 4
			Return "MuscleLegs"
		ElseIf index == 5
			Return "MuscleMoreLegs_v2"
		ElseIf index == 6
			Return "MuscleButt"
		ElseIf index == 7
			Return "Butt"
		ElseIf index == 8
			Return "Hips"
		ElseIf index == 9
			Return "Waist"
		ElseIf index == 10
			Return "Belly"
		ElseIf index == 11
			Return "Arms"
		EndIf
	ElseIf family == 8
		If index == 0
			Return "Arms"
		ElseIf index == 1
			Return "MuscleArms"
		ElseIf index == 2
			Return "MuscleMoreArms_v2"
		ElseIf index == 3
			Return "ShoulderWidth"
		ElseIf index == 4
			Return "MuscleAbs"
		ElseIf index == 5
			Return "MuscleLegs"
		ElseIf index == 6
			Return "MuscleMoreLegs_v2"
		ElseIf index == 7
			Return "Thighs"
		ElseIf index == 8
			Return "CalfSize"
		ElseIf index == 9
			Return "Waist"
		ElseIf index == 10
			Return "Belly"
		ElseIf index == 11
			Return "Butt"
		EndIf
	EndIf
	Return ""
EndFunction

Float Function GetDefaultMorphValue(Int family, Int index)
	Float[] values
	If family == 1
		values = new Float[12]
		values[0] = 0.58
		values[1] = 0.42
		values[2] = 0.32
		values[3] = 0.30
		values[4] = 0.42
		values[5] = 0.32
		values[6] = 0.38
		values[7] = 0.22
		values[8] = -0.25
		values[9] = -0.12
		values[10] = 0.20
		values[11] = 0.16
		Return values[index]
	ElseIf family == 2
		values = new Float[12]
		values[0] = 0.38
		values[1] = 0.20
		values[2] = 0.28
		values[3] = 0.24
		values[4] = 0.42
		values[5] = 0.30
		values[6] = 0.32
		values[7] = 0.22
		values[8] = -0.42
		values[9] = -0.18
		values[10] = -0.18
		values[11] = -0.10
		Return values[index]
	ElseIf family == 3
		values = new Float[12]
		values[0] = 0.82
		values[1] = 0.95
		values[2] = 0.62
		values[3] = 0.72
		values[4] = 0.45
		values[5] = 0.62
		values[6] = 0.48
		values[7] = 0.38
		values[8] = 0.32
		values[9] = 0.38
		values[10] = 0.18
		values[11] = 0.28
		Return values[index]
	ElseIf family == 4
		values = new Float[11]
		values[0] = -0.32
		values[1] = -0.30
		values[2] = -0.20
		values[3] = -0.22
		values[4] = -0.22
		values[5] = -0.38
		values[6] = -0.24
		values[7] = 0.24
		values[8] = 0.20
		values[9] = -0.18
		values[10] = -0.12
		Return values[index]
	ElseIf family == 5
		values = new Float[11]
		values[0] = -0.68
		values[1] = -0.28
		values[2] = 0.52
		values[3] = 0.38
		values[4] = 0.55
		values[5] = 0.26
		values[6] = 0.28
		values[7] = 0.24
		values[8] = 0.30
		values[9] = 0.28
		values[10] = 0.20
		Return values[index]
	ElseIf family == 6
		values = new Float[11]
		values[0] = 0.62
		values[1] = 0.58
		values[2] = 0.45
		values[3] = 0.52
		values[4] = 0.28
		values[5] = 0.38
		values[6] = 0.48
		values[7] = 0.30
		values[8] = 0.40
		values[9] = 0.30
		values[10] = 0.24
		Return values[index]
	ElseIf family == 7
		values = new Float[12]
		values[0] = 0.42
		values[1] = 0.22
		values[2] = 0.46
		values[3] = 0.40
		values[4] = 0.68
		values[5] = 0.52
		values[6] = 0.38
		values[7] = 0.34
		values[8] = 0.20
		values[9] = -0.32
		values[10] = -0.20
		values[11] = -0.12
		Return values[index]
	ElseIf family == 8
		values = new Float[12]
		values[0] = 0.95
		values[1] = 1.05
		values[2] = 0.78
		values[3] = 0.86
		values[4] = 0.58
		values[5] = 0.72
		values[6] = 0.55
		values[7] = 0.46
		values[8] = 0.38
		values[9] = 0.48
		values[10] = 0.24
		values[11] = 0.32
		Return values[index]
	EndIf
	Return 0.0
EndFunction

String Function MorphStorageKey(Int family, String morph)
	Return "Feral.Morph.Value." + family + "." + morph
EndFunction

Float Function GetMorphMultiplier(Int family)
	Actor player = Game.GetPlayer()
	String storageKey = "Feral.Morph.Multiplier." + family
	If StorageUtil.HasFloatValue(player, storageKey)
		Return StorageUtil.GetFloatValue(player, storageKey)
	EndIf
	Return 1.0
EndFunction

Float Function GetConfiguredMorphValue(Int family, Int index)
	Actor player = Game.GetPlayer()
	String storageKey = MorphStorageKey(family, GetMorphName(family, index))
	If StorageUtil.HasFloatValue(player, storageKey)
		Return StorageUtil.GetFloatValue(player, storageKey)
	EndIf
	Return GetDefaultMorphValue(family, index)
EndFunction

Function ResetMorphOverrides(Int family)
	Actor player = Game.GetPlayer()
	StorageUtil.UnsetFloatValue(player, "Feral.Morph.Multiplier." + family)
	Int index = 0
	While index < GetMorphCount(family)
		StorageUtil.UnsetFloatValue(player, MorphStorageKey(family, GetMorphName(family, index)))
		index += 1
	EndWhile
EndFunction

Int Function MorphIndexForOption(Int option)
	If !_morphOptions
		Return -1
	EndIf
	Int index = 0
	While index < _morphOptions.Length
		If _morphOptions[index] == option
			Return index
		EndIf
		index += 1
	EndWhile
	Return -1
EndFunction

String Function MorphDisplayName(String morph)
	If morph == "MuscleLegs"
		Return "Leg muscle"
	ElseIf morph == "MuscleMoreLegs_v2"
		Return "Additional leg muscle"
	ElseIf morph == "Thighs"
		Return "Thigh size"
	ElseIf morph == "ThighOutsideThicc_v2"
		Return "Outer thigh fullness"
	ElseIf morph == "ThighInsideThicc_v2"
		Return "Inner thigh fullness"
	ElseIf morph == "CalfSize"
		Return "Calf size"
	ElseIf morph == "CalfFBThicc_v2"
		Return "Calf fullness"
	ElseIf morph == "MuscleButt"
		Return "Glute muscle"
	ElseIf morph == "Butt"
		Return "Butt size"
	ElseIf morph == "BigButt"
		Return "Additional butt size"
	ElseIf morph == "RoundAss"
		Return "Butt roundness"
	ElseIf morph == "Waist"
		Return "Waist"
	ElseIf morph == "Belly"
		Return "Belly"
	ElseIf morph == "Arms"
		Return "Arm size"
	ElseIf morph == "MuscleArms"
		Return "Arm muscle"
	ElseIf morph == "MuscleMoreArms_v2"
		Return "Additional arm muscle"
	ElseIf morph == "ShoulderWidth"
		Return "Shoulder width"
	ElseIf morph == "MuscleAbs"
		Return "Abdominal muscle"
	ElseIf morph == "ChubbyLegs"
		Return "Leg fullness"
	ElseIf morph == "Hips"
		Return "Hip width"
	ElseIf morph == "HipUpperWidth"
		Return "Upper hip width"
	EndIf
	Return morph
EndFunction

String Function TechniqueName(Int family)
	If family == 1
		Return "Dread howl"
	ElseIf family == 2
		Return "Vanish and pounce"
	ElseIf family == 3
		Return "Maul"
	ElseIf family == 4
		Return "Plague spit"
	ElseIf family == 5
		Return "Web snare"
	ElseIf family == 6
		Return "Fortress"
	ElseIf family == 7
		Return "Stampede"
	ElseIf family == 8
		Return "Monstrous regeneration"
	EndIf
	Return "Locked"
EndFunction

String Function MilestoneTraitText(Int family, Int milestone)
	Int level = GetMasteryLevel(family)
	String prefix = "Locked: "
	If level >= milestone
		prefix = "Unlocked: "
	EndIf
	If milestone == 25
		If family == 1
			Return prefix + "Tireless hunt"
		ElseIf family == 2
			Return prefix + "Soft step"
		ElseIf family == 3
			Return prefix + "Thick hide"
		ElseIf family == 4
			Return prefix + "Filthborn"
		ElseIf family == 5
			Return prefix + "Venomous"
		ElseIf family == 6
			Return prefix + "Arrow-shell"
		ElseIf family == 7
			Return prefix + "Surefooted"
		ElseIf family == 8
			Return prefix + "Mending flesh"
		EndIf
	ElseIf milestone == 75
		If family == 1
			Return prefix + "Blood scent"
		ElseIf family == 2
			Return prefix + "Ambush"
		ElseIf family == 3
			Return prefix + "Unstoppable"
		ElseIf family == 4
			Return prefix + "Escape artist"
		ElseIf family == 5
			Return prefix + "Chitin reflex"
		ElseIf family == 6
			Return prefix + "Counterclaw"
		ElseIf family == 7
			Return prefix + "Keen flight"
		ElseIf family == 8
			Return prefix + "Cornered monster"
		EndIf
	EndIf
	Return ""
EndFunction

String Function TechniqueStatusText(Int family)
	Int level = GetMasteryLevel(family)
	If level < 50
		Return "Locked: " + TechniqueName(family)
	ElseIf level >= 100
		Return "Apex: " + TechniqueName(family)
	EndIf
	Return "Unlocked: " + TechniqueName(family)
EndFunction

String Function NextMilestoneText(Int level)
	If level < 25
		Return "Trait at level 25"
	ElseIf level < 50
		Return "Technique at level 50"
	ElseIf level < 75
		Return "Trait at level 75"
	ElseIf level < 100
		Return "Apex technique at level 100"
	EndIf
	Return "All milestones mastered"
EndFunction

String Function GetClaimWindowStatus()
	Int count = GetPendingEssenceCount()
	If count < 1
		Return "None"
	EndIf
	Return count + " essence(s) ready / " + GetClaimWindowSeconds() + "s window"
EndFunction

Int Function GetPendingEssenceCount()
	PurgeExpiredEssence()
	Return StorageUtil.FormListCount(Game.GetPlayer(), "Feral.PendingEssence")
EndFunction

Function PurgeExpiredEssence()
	Actor player = Game.GetPlayer()
	Int i = StorageUtil.FormListCount(player, "Feral.PendingEssence") - 1
	While i >= 0
		Actor victim = StorageUtil.FormListGet(player, "Feral.PendingEssence", i) as Actor
		If !victim || !victim.IsDead() || StorageUtil.GetIntValue(victim, "Feral.Eligible") < 1 || StorageUtil.GetIntValue(victim, "Feral.Claimed") > 0 || Utility.GetCurrentRealTime() - StorageUtil.GetFloatValue(victim, "Feral.KilledAt") > GetClaimWindowSeconds()
			StorageUtil.FormListRemoveAt(player, "Feral.PendingEssence", i)
		EndIf
		i -= 1
	EndWhile
EndFunction

Function ClearPendingEssence()
	StorageUtil.FormListClear(Game.GetPlayer(), "Feral.PendingEssence")
EndFunction

Int Function GetFatigueSecondsRemaining()
	Float remaining = StorageUtil.GetFloatValue(Game.GetPlayer(), "Feral.FatigueUntil") - Utility.GetCurrentRealTime()
	If remaining <= 0.0
		Return 0
	ElseIf remaining > 15.0
		; GetCurrentRealTime resets when Skyrim restarts; discard a persisted timer from another session.
		StorageUtil.UnsetFloatValue(Game.GetPlayer(), "Feral.FatigueUntil")
		Return 0
	EndIf
	Return Math.Ceiling(remaining) as Int
EndFunction

String Function FatigueStatus()
	Int seconds = GetFatigueSecondsRemaining()
	If seconds > 0
		Return seconds + "s"
	EndIf
	Return "Ready"
EndFunction

Bool Function CanBeginShape()
	Return GetFatigueSecondsRemaining() <= 0
EndFunction

Function StartFeralFatigue()
	StorageUtil.SetFloatValue(Game.GetPlayer(), "Feral.FatigueUntil", Utility.GetCurrentRealTime() + 15.0)
EndFunction

Int Function GetActiveFamily()
	Int family = StorageUtil.GetIntValue(Game.GetPlayer(), "Feral.ActiveFamily")
	If family < 1 || family > 8
		Return 0
	EndIf
	Return family
EndFunction

Int Function GetHumanResponseMode()
	Actor player = Game.GetPlayer()
	If StorageUtil.GetIntValue(player, "Feral.HumanResponseInitialized") < 1
		StorageUtil.SetIntValue(player, "Feral.HumanResponseInitialized", 1)
		StorageUtil.SetIntValue(player, "Feral.HumanResponseMode", 2)
	EndIf
	Return StorageUtil.GetIntValue(player, "Feral.HumanResponseMode")
EndFunction

Function SetHumanResponseMode(Int mode)
	If mode < 0 || mode > 2
		mode = 2
	EndIf
	StorageUtil.SetIntValue(Game.GetPlayer(), "Feral.HumanResponseInitialized", 1)
	StorageUtil.SetIntValue(Game.GetPlayer(), "Feral.HumanResponseMode", mode)
EndFunction

String Function HumanResponseModeName()
	Int mode = GetHumanResponseMode()
	If mode == 1
		Return "Reactions"
	ElseIf mode == 2
		Return "Full"
	EndIf
	Return "Off"
EndFunction

Int Function GetNotoriety()
	Actor player = Game.GetPlayer()
	Int stored = StorageUtil.GetIntValue(player, "Feral.Notoriety")
	Float lastExposure = StorageUtil.GetFloatValue(player, "Feral.NotorietyLastExposure")
	If stored < 1 || lastExposure <= 0.0
		Return stored
	EndIf
	Int decayDays = (Utility.GetCurrentGameTime() - lastExposure - 1.0) as Int
	If decayDays < 1
		Return stored
	EndIf
	Int value = stored - (decayDays * 2)
	If value < 0
		value = 0
	EndIf
	Return value
EndFunction

Function SetNotoriety(Int value)
	If value < 0
		value = 0
	ElseIf value > 100
		value = 100
	EndIf
	Actor player = Game.GetPlayer()
	StorageUtil.SetIntValue(player, "Feral.Notoriety", value)
	StorageUtil.SetFloatValue(player, "Feral.NotorietyLastExposure", Utility.GetCurrentGameTime())
EndFunction

Function AddNotoriety(Int amount, Actor witness)
	If amount < 1 || GetHumanResponseMode() < 1
		Return
	EndIf
	Int before = GetNotoriety()
	SetNotoriety(before + amount)
	Int after = GetNotoriety()
	If before < 20 && after >= 20
		Debug.Notification("Feral: people have begun whispering about your unnatural shape.")
	ElseIf before < 40 && after >= 40
		Debug.Notification("Feral: civilians now fear your revealed form.")
	ElseIf before < 60 && after >= 60
		Debug.Notification("Feral: guards now treat witnessed transformations as a crime.")
	ElseIf before < 80 && after >= 80
		Debug.Notification("Feral: organized hunters have taken up your trail.")
	EndIf
	ApplyWitnessReaction(witness, after)
EndFunction

String Function NotorietyTierName(Int value)
	If value >= 100
		Return "Apex quarry"
	ElseIf value >= 80
		Return "Hunted"
	ElseIf value >= 60
		Return "Outlawed"
	ElseIf value >= 40
		Return "Feared"
	ElseIf value >= 20
		Return "Whispered about"
	EndIf
	Return "Unknown"
EndFunction

Actor Function FindHumanWitness(Actor ignoreActor = None)
	Actor player = Game.GetPlayer()
	Keyword actorTypeNPC = Game.GetForm(0x00013794) as Keyword
	Actor candidate = Game.FindClosestActorFromRef(player, 2500.0)
	If IsValidHumanWitness(candidate, ignoreActor, actorTypeNPC)
		Return candidate
	EndIf
	Int attempts = 0
	While attempts < 4
		candidate = Game.FindRandomActorFromRef(player, 2500.0)
		If IsValidHumanWitness(candidate, ignoreActor, actorTypeNPC)
			Return candidate
		EndIf
		attempts += 1
	EndWhile
	Return None
EndFunction

Bool Function IsValidHumanWitness(Actor candidate, Actor ignoreActor, Keyword actorTypeNPC)
	Actor player = Game.GetPlayer()
	Return candidate && candidate != player && candidate != ignoreActor && !candidate.IsDead() && !candidate.IsPlayerTeammate() && candidate.HasKeyword(actorTypeNPC) && candidate.HasLOS(player)
EndFunction

Function RecordWitnessedTransformation(Int family, Int token)
	If GetHumanResponseMode() < 1 || family < 1 || family > 8
		Return
	EndIf
	Actor player = Game.GetPlayer()
	If StorageUtil.GetIntValue(player, "Feral.LastWitnessToken") == token
		Return
	EndIf
	Actor witness = FindHumanWitness()
	If witness
		StorageUtil.SetIntValue(player, "Feral.LastWitnessToken", token)
		AddNotoriety(5, witness)
	EndIf
EndFunction

Function RecordWitnessedHumanKill(Actor victim)
	If !victim || GetHumanResponseMode() < 1
		Return
	EndIf
	Keyword actorTypeNPC = Game.GetForm(0x00013794) as Keyword
	If !victim.HasKeyword(actorTypeNPC)
		Return
	EndIf
	Actor witness = FindHumanWitness(victim)
	If witness
		AddNotoriety(15, witness)
	EndIf
EndFunction

Function ApplyWitnessReaction(Actor witness, Int notoriety)
	If !witness
		Return
	EndIf
	Int mode = GetHumanResponseMode()
	If notoriety >= 40
		Spell fear = Game.GetFormFromFile(0x000A21, "Feral.esp") as Spell
		If fear
			fear.Cast(Game.GetPlayer(), witness)
		EndIf
	EndIf
	If mode >= 2 && notoriety >= 60 && witness.IsGuard()
		Float now = Utility.GetCurrentGameTime()
		Float lastBounty = StorageUtil.GetFloatValue(Game.GetPlayer(), "Feral.LastGuardBounty")
		Faction crimeFaction = witness.GetCrimeFaction()
		If crimeFaction && now - lastBounty >= 1.0
			crimeFaction.ModCrimeGold(250, false)
			StorageUtil.SetFloatValue(Game.GetPlayer(), "Feral.LastGuardBounty", now)
		EndIf
	EndIf
EndFunction

Event OnCellFullyLoaded(Cell akCell)
	If !IsFeralEnabled() || GetHumanResponseMode() < 2 || GetNotoriety() < 80 || !akCell || akCell.IsInterior()
		Return
	EndIf
	If HunterGroupIsActive()
		Return
	EndIf
	Float now = Utility.GetCurrentGameTime()
	If now - StorageUtil.GetFloatValue(Game.GetPlayer(), "Feral.LastHunterEncounter") < 3.0
		Return
	EndIf
	Int chance = 20
	If GetNotoriety() >= 100
		chance = 35
	EndIf
	If Utility.RandomInt(1, 100) <= chance
		SpawnHunterGroup(false)
	EndIf
EndEvent

Bool Function HunterGroupIsActive()
	Actor player = Game.GetPlayer()
	Int count = StorageUtil.FormListCount(player, "Feral.Hunters")
	Int i = 0
	Bool active = false
	While i < count
		Actor hunter = StorageUtil.FormListGet(player, "Feral.Hunters", i) as Actor
		If hunter && !hunter.IsDead()
			active = true
		ElseIf hunter
			hunter.Disable()
			hunter.Delete()
		EndIf
		i += 1
	EndWhile
	If !active
		StorageUtil.FormListClear(player, "Feral.Hunters")
	EndIf
	Return active
EndFunction

Function SpawnHunterGroup(Bool forced)
	If HunterGroupIsActive()
		Debug.Notification("Feral: a hunter group is already pursuing you.")
		Return
	EndIf
	Actor player = Game.GetPlayer()
	ActorBase meleeBase = Game.GetForm(0x00039D01) as ActorBase
	ActorBase missileBase = Game.GetForm(0x00037C00) as ActorBase
	Actor first = player.PlaceAtMe(meleeBase, 1, false, true) as Actor
	Actor second = player.PlaceAtMe(missileBase, 1, false, true) as Actor
	PrepareHunter(first, 2200.0, 1400.0)
	PrepareHunter(second, -2200.0, 1600.0)
	If GetNotoriety() >= 100 || forced
		ActorBase bossBase = Game.GetForm(0x0003DEEA) as ActorBase
		Actor boss = player.PlaceAtMe(bossBase, 1, false, true) as Actor
		PrepareHunter(boss, 0.0, 2400.0)
	EndIf
	StorageUtil.SetFloatValue(player, "Feral.LastHunterEncounter", Utility.GetCurrentGameTime())
	Debug.Notification("Feral: hunters have found your trail.")
EndFunction

Function PrepareHunter(Actor hunter, Float xOffset, Float yOffset)
	If !hunter
		Return
	EndIf
	Actor player = Game.GetPlayer()
	hunter.MoveTo(player, xOffset, yOffset, 0.0, true)
	hunter.Enable()
	StorageUtil.FormListAdd(player, "Feral.Hunters", hunter, false)
	hunter.StartCombat(player)
EndFunction

Event OnOptionHighlight(Int option)
	Int morphIndex = MorphIndexForOption(option)
	If option == _focusFamilyOption
		SetInfoText("Select to cycle through the eight Feral families.")
	ElseIf option == _morphMultiplierOption
		SetInfoText("Scales every configured morph in the selected family without changing the saved individual slider values.")
	ElseIf option == _morphResetOption
		SetInfoText("Restores the selected family's intensity and individual morph sliders to their defaults. The next transformation uses the restored values.")
	ElseIf morphIndex >= 0 && morphIndex < GetMorphCount(GetFocusFamily())
		String morph = GetMorphName(GetFocusFamily(), morphIndex)
		SetInfoText("BodySlide key: " + morph + ". This is the full-strength level-100 value before family intensity and current expression are applied.")
	ElseIf option == _feralPathOption
		SetInfoText("Off grants no Feral character XP. Balanced disables ordinary kill and skill XP. Hardcore disables ordinary Experience reward sources. Saved settings return when switched Off.")
	ElseIf option == _humanResponseOption
		SetInfoText("Off disables notoriety. Reactions enables warnings and fear. Full also enables guard bounties and hunter encounters.")
	ElseIf option == _kinshipOption
		SetInfoText("At the configured mastery level, matching loaded creatures become temporarily neutral while their Feral shape is active. Attacking one breaks kinship for that creature until the next transformation.")
	ElseIf option == _kinshipApproachesOption
		SetInfoText("Allows eligible matching creatures to approach after five transformed seconds and offer an Accept or Refuse prompt for a consensual SexLab scene.")
	ElseIf option == _kinshipFrequencyOption
		SetInfoText("Rare halves approach rolls, Occasional uses the designed 40-60% two-minute chance, and Likely increases the roll by 75%.")
	ElseIf option == _kinshipCleanupOption
		SetInfoText("Removes every temporary kinship or approach effect tracked by the optional integration.")
	EndIf
EndEvent

Event OnOptionSelect(Int option)
	If option == _enableOption
		SetFeralEnabled(!IsFeralEnabled())
		ForcePageReset()
	ElseIf option == _feralPathOption
		Int nextMode = GetFeralPathMode() + 1
		If nextMode > 2
			nextMode = 0
		EndIf
		SetFeralPathMode(nextMode)
		ForcePageReset()
	ElseIf option == _humanResponseOption
		Int nextResponse = GetHumanResponseMode() + 1
		If nextResponse > 2
			nextResponse = 0
		EndIf
		SetHumanResponseMode(nextResponse)
		ForcePageReset()
	ElseIf option == _kinshipOption
		EnsureKinshipDefaults()
		StorageUtil.SetIntValue(Game.GetPlayer(), "Feral.Kinship.Enabled", (!IsKinshipEnabled()) as Int)
		If !IsKinshipEnabled()
			RequestKinshipCleanup()
		EndIf
		ForcePageReset()
	ElseIf option == _kinshipApproachesOption
		EnsureKinshipDefaults()
		StorageUtil.SetIntValue(Game.GetPlayer(), "Feral.Kinship.Approaches", (!AreKinshipApproachesEnabled()) as Int)
		ForcePageReset()
	ElseIf option == _kinshipFrequencyOption
		Int nextFrequency = GetKinshipFrequency() + 1
		If nextFrequency > 2
			nextFrequency = 0
		EndIf
		StorageUtil.SetIntValue(Game.GetPlayer(), "Feral.Kinship.Frequency", nextFrequency)
		ForcePageReset()
	ElseIf option == _kinshipCleanupOption
		RequestKinshipCleanup()
		Debug.Notification("Feral: requested creature kinship cleanup.")
	ElseIf option == _recalculateOption
		RefreshShapePowers()
		RefreshPassivePowers()
		RepairAspectState()
		Debug.Notification("Feral: transformation and passive powers rebuilt from saved mastery levels.")
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
	ElseIf option == _morphResetOption
		ResetMorphOverrides(GetFocusFamily())
		Debug.Notification("Feral: selected family morphs restored to defaults. Changes apply on the next transformation.")
		ForcePageReset()
	ElseIf option == _restoreExperienceOption
		RestoreExperienceSettings()
		StorageUtil.SetIntValue(Game.GetPlayer(), "Feral.PathEnabled", 0)
		StorageUtil.SetIntValue(Game.GetPlayer(), "Feral.PathMode", 0)
		Debug.Notification("Feral: Experience settings restored and Feral Path disabled.")
		ForcePageReset()
	ElseIf option == _reloadRacesOption
		JsonUtil.Unload("../Feral/Races", false)
		JsonUtil.Load("../Feral/Races")
		JsonUtil.Unload("../Feral/Cosmetics", false)
		JsonUtil.Load("../Feral/Cosmetics")
		Debug.Notification("Feral: race and cosmetic configurations reloaded.")
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
		SetTestLevel(GetTestFamily(), 1)
		ForcePageReset()
	ElseIf option == _testSetNineOption
		SetTestLevel(GetTestFamily(), 50)
		ForcePageReset()
	ElseIf option == _testSetTwentyFourOption
		SetTestLevel(GetTestFamily(), 100)
		ForcePageReset()
	ElseIf option == _testClaimOption
		CompleteClaim(GetTestFamily())
		ForcePageReset()
	ElseIf option == _testNotorietyOption
		SetNotoriety(80)
		ForcePageReset()
	ElseIf option == _testHuntersOption
		SpawnHunterGroup(true)
		ForcePageReset()
	ElseIf option == _testResetOption
		SetTestLevel(GetTestFamily(), 0)
		ForcePageReset()
	EndIf
EndEvent

Event OnOptionSliderOpen(Int option)
	Int morphIndex = MorphIndexForOption(option)
	If option == _morphMultiplierOption
		SetSliderDialogStartValue(GetMorphMultiplier(GetFocusFamily()))
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogRange(0.0, 2.0)
		SetSliderDialogInterval(0.05)
	ElseIf morphIndex >= 0 && morphIndex < GetMorphCount(GetFocusFamily())
		SetSliderDialogStartValue(GetConfiguredMorphValue(GetFocusFamily(), morphIndex))
		SetSliderDialogDefaultValue(GetDefaultMorphValue(GetFocusFamily(), morphIndex))
		SetSliderDialogRange(-2.0, 3.0)
		SetSliderDialogInterval(0.01)
	ElseIf option == _testLevelSliderOption
		SetSliderDialogStartValue(GetMasteryLevel(GetTestFamily()))
		SetSliderDialogDefaultValue(50.0)
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(1.0)
	ElseIf option == _claimWindowOption
		SetSliderDialogStartValue(GetClaimWindowSeconds())
		SetSliderDialogDefaultValue(180.0)
		SetSliderDialogRange(60.0, 300.0)
		SetSliderDialogInterval(30.0)
	ElseIf option == _kinshipLevelOption
		SetSliderDialogStartValue(GetKinshipMinimumLevel())
		SetSliderDialogDefaultValue(10.0)
		SetSliderDialogRange(1.0, 100.0)
		SetSliderDialogInterval(1.0)
	ElseIf option == _kinshipCooldownOption
		SetSliderDialogStartValue(GetKinshipCooldownHours())
		SetSliderDialogDefaultValue(6.0)
		SetSliderDialogRange(1.0, 24.0)
		SetSliderDialogInterval(1.0)
	EndIf
EndEvent

Event OnOptionSliderAccept(Int option, Float value)
	Int morphIndex = MorphIndexForOption(option)
	If option == _morphMultiplierOption
		StorageUtil.SetFloatValue(Game.GetPlayer(), "Feral.Morph.Multiplier." + GetFocusFamily(), value)
		SetSliderOptionValue(option, value, "{2}")
	ElseIf morphIndex >= 0 && morphIndex < GetMorphCount(GetFocusFamily())
		String morph = GetMorphName(GetFocusFamily(), morphIndex)
		StorageUtil.SetFloatValue(Game.GetPlayer(), MorphStorageKey(GetFocusFamily(), morph), value)
		SetSliderOptionValue(option, value, "{2}")
	ElseIf option == _testLevelSliderOption
		SetTestLevel(GetTestFamily(), value as Int)
		SetSliderOptionValue(option, value, "{0}")
		ForcePageReset()
	ElseIf option == _claimWindowOption
		Int seconds = value as Int
		StorageUtil.SetIntValue(Game.GetPlayer(), "Feral.ClaimWindowSeconds", seconds)
		SetSliderOptionValue(option, seconds, "{0} seconds")
	ElseIf option == _kinshipLevelOption
		Int level = value as Int
		StorageUtil.SetIntValue(Game.GetPlayer(), "Feral.Kinship.MinimumLevel", level)
		SetSliderOptionValue(option, level, "{0}")
		RequestKinshipCleanup()
	ElseIf option == _kinshipCooldownOption
		Int hours = value as Int
		StorageUtil.SetIntValue(Game.GetPlayer(), "Feral.Kinship.CooldownHours", hours)
		SetSliderOptionValue(option, hours, "{0} game hours")
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
		Return "Stag"
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

Function SetTestLevel(Int family, Int level)
	If family < 1 || family > 8
		Return
	EndIf
	Actor player = Game.GetPlayer()
	StorageUtil.SetIntValue(player, "Feral.MasteryLevel." + family, level)
	StorageUtil.SetIntValue(player, "Feral.MasteryProgress." + family, 0)
	Int rank = RankForLevel(level)
	StorageUtil.SetIntValue(player, "Feral.Rank." + family, rank)
	ApplyShapeTier(family, DurationTierForLevel(level))
	ApplyPassiveRank(family, PassiveRankForLevel(level))
	ApplyTechniquePower(family)
	Debug.Notification("Feral test: " + FamilyName(family) + " set to mastery level " + level + " / " + FormatShapeValue(GetExpressionScale(family) * 100.0) + "% expression.")
EndFunction

Int Function RankForCount(Int family, Int count)
	; Legacy v5 conversion only. New progression uses RankForLevel.
	Int totalPoints = count * MasteryAwardForHarvest(family)
	Int level = 0
	While level < 100 && totalPoints >= MasteryPointsForNextLevel(level)
		totalPoints -= MasteryPointsForNextLevel(level)
		level += 1
	EndWhile
	Return RankForLevel(level)
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
	ElseIf r == Game.GetForm(0x000131ED) as Race || r == Game.GetForm(0x000CF89B) as Race || r == Game.GetForm(0x00104F45) as Race || r == Game.GetFormFromFile(0x0000D0B2, "Dawnguard.esm") as Race
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
		If RaceMatchesConfig(creatureRace, configFile, familyKey)
			Return family
		EndIf
		If family == 7 && RaceMatchesConfig(creatureRace, configFile, "Horse")
			Return family
		EndIf
		family += 1
	EndWhile
	Return 0
EndFunction

Bool Function RaceMatchesConfig(Race creatureRace, String configFile, String familyKey)
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
			Return true
		EndIf
		i += 1
	EndWhile
	Return false
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
		Return "Stag"
	ElseIf family == 8
		Return "Troll"
	EndIf
	Return ""
EndFunction

Int Function ClaimLast()
	ClearPendingEssence()
	Debug.Notification("Feral: essence harvesting is automatic; Claim soul is retired.")
	Return 0
EndFunction

Int Function ClaimPendingEssence()
	Return ClaimLast()
EndFunction

Function CompleteClaim(Int family, Bool silent = false)
	If family < 1 || family > 8
		Return
	EndIf
	Int count = StorageUtil.GetIntValue(Game.GetPlayer(), "Feral.Count." + family) + 1
	StorageUtil.SetIntValue(Game.GetPlayer(), "Feral.Count." + family, count)
	GrantMastery(family, MasteryAwardForHarvest(family), "hunting", silent)
	If IsFeralPathEnabled()
		Int reward = GetEssenceXP(family)
		Experience.AddExperience(reward, true)
	EndIf
EndFunction

Int Function GetEssenceXP(Int family)
	If family == 1 || family == 4 || family == 5 || family == 6
		Return 30
	ElseIf family == 2 || family == 7
		Return 45
	ElseIf family == 3 || family == 8
		Return 70
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
	If family < 1 || family > 8 || rank < 1 || rank > 5
		Return None
	EndIf
	Int formID
	If rank <= 3
		formID = 0x0009A0 + ((family - 1) * 3) + (rank - 1)
	Else
		formID = 0x000A40 + ((family - 1) * 2) + (rank - 4)
	EndIf
	Return Game.GetFormFromFile(formID, "Feral.esp") as Spell
EndFunction

Function ApplyPassiveRank(Int family, Int rank)
	Actor player = Game.GetPlayer()
	Int currentRank = 1
	While currentRank <= 3
		Spell passive = GetLegacyPassiveSpell(family, currentRank)
		If passive
			player.RemoveSpell(passive)
		EndIf
		currentRank += 1
	EndWhile
	Spell current = GetLegacyPassiveSpell(family, rank)
	If current && IsFeralEnabled()
		player.AddSpell(current, false)
	EndIf
EndFunction

Function RefreshPassivePowers()
	Int family = 1
	While family <= 8
		ApplyPassiveRank(family, PassiveRankForLevel(GetMasteryLevel(family)))
		family += 1
	EndWhile
EndFunction

Function RemoveAllPassivePowers()
	Int family = 1
	While family <= 8
		ApplyPassiveRank(family, 0)
		family += 1
	EndWhile
EndFunction

Spell Function GetTechniqueSpell(Int family)
	If family < 1 || family > 8
		Return None
	EndIf
	Return Game.GetFormFromFile(0x000A10 + (family - 1), "Feral.esp") as Spell
EndFunction

Function ApplyTechniquePower(Int family)
	Spell technique = GetTechniqueSpell(family)
	If !technique
		Return
	EndIf
	Actor player = Game.GetPlayer()
	If IsFeralEnabled() && GetMasteryLevel(family) >= 50
		player.AddSpell(technique, false)
	Else
		player.RemoveSpell(technique)
	EndIf
EndFunction

Function RefreshTechniquePowers()
	Int family = 1
	While family <= 8
		ApplyTechniquePower(family)
		family += 1
	EndWhile
EndFunction

Function RemoveAllTechniquePowers()
	Actor player = Game.GetPlayer()
	Int family = 1
	While family <= 8
		Spell technique = GetTechniqueSpell(family)
		If technique
			player.RemoveSpell(technique)
		EndIf
		family += 1
	EndWhile
EndFunction

Function ApplyShapeRank(Int family, Int rank)
	; Compatibility wrapper retained for older callers. Duration tiers own the
	; actual transformation power selection from v11 onward.
	ApplyShapeTier(family, DurationTierForLevel(GetMasteryLevel(family)))
EndFunction

Function RemoveShapeVariants(Int family)
	Actor player = Game.GetPlayer()
	Int i = 1
	While i <= 5
		Spell shape = GetShapeSpell(family, i)
		If shape
			player.RemoveSpell(shape)
		EndIf
		i += 1
	EndWhile
EndFunction

Function ApplyShapeTier(Int family, Int tier)
	Actor player = Game.GetPlayer()
	If GetActiveFamily() == family
		StorageUtil.SetIntValue(player, "Feral.PendingShapeRefresh." + family, 1)
		Return
	EndIf
	RemoveShapeVariants(family)
	StorageUtil.UnsetIntValue(player, "Feral.PendingShapeRefresh." + family)
	Spell current = GetShapeSpell(family, tier)
	If current && IsFeralEnabled()
		player.AddSpell(current, false)
	EndIf
EndFunction

Function FinalizeShapePowerRefresh(Int family)
	If StorageUtil.HasIntValue(Game.GetPlayer(), "Feral.PendingShapeRefresh." + family)
		ApplyShapeTier(family, DurationTierForLevel(GetMasteryLevel(family)))
	EndIf
EndFunction

Function RefreshShapePowers()
	Int family = 1
	While family <= 8
		ApplyShapeTier(family, DurationTierForLevel(GetMasteryLevel(family)))
		family += 1
	EndWhile
EndFunction

Function RemoveAllShapePowers()
	Actor player = Game.GetPlayer()
	Int family = 1
	While family <= 8
		RemoveShapeVariants(family)
		StorageUtil.UnsetIntValue(player, "Feral.PendingShapeRefresh." + family)
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
	Int endingFamily = StorageUtil.GetIntValue(player, "Feral.ActiveFamily")
	Int endingToken = StorageUtil.GetIntValue(player, "Feral.ActiveToken")
	Bool dispelledActiveEffect = false
	Int family = 1
	While family <= 8
		Int rank = 1
		While rank <= 5
			Spell shape = GetShapeSpell(family, rank)
			If shape && player.DispelSpell(shape)
				dispelledActiveEffect = true
			EndIf
			rank += 1
		EndWhile
		family += 1
	EndWhile
	If dispelledActiveEffect
		Return
	EndIf
	; No live effect owned the saved state, so this is stale-state recovery.
	ClearFeralVisuals()
	GlobalVariable activeForm = Game.GetFormFromFile(0x000801, "Dollform.esp") as GlobalVariable
	If activeForm && IsFeralActiveValue(activeForm.GetValueInt())
		activeForm.SetValue(0)
	EndIf
	StorageUtil.SetIntValue(player, "Feral.ActiveFamily", 0)
	StorageUtil.SetIntValue(player, "Feral.ActiveRank", 0)
	StorageUtil.SetIntValue(player, "Feral.ActiveToken", 0)
	StorageUtil.UnsetFloatValue(player, "Feral.ActiveExpression")
	BroadcastShapeEnd(endingFamily, endingToken)
	; Stale recovery never transforms, so leftover fatigue only blocks a
	; legitimate fresh cast.
	StorageUtil.SetFloatValue(player, "Feral.FatigueUntil", 0.0)
EndFunction

Function ClearFeralVisuals()
	Actor player = Game.GetPlayer()
	Armor cosmetic = StorageUtil.GetFormValue(player, "Feral.ActiveCosmetic") as Armor
	If cosmetic
		If StorageUtil.GetIntValue(player, "Feral.ActiveCosmeticEquipped") > 0 && player.IsEquipped(cosmetic)
			player.UnequipItem(cosmetic, false, true)
		EndIf
		If StorageUtil.GetIntValue(player, "Feral.ActiveCosmeticAdded") > 0 && player.GetItemCount(cosmetic) > 0
			player.RemoveItem(cosmetic, 1, true)
		EndIf
	EndIf
	StorageUtil.UnsetFormValue(player, "Feral.ActiveCosmetic")
	StorageUtil.UnsetIntValue(player, "Feral.ActiveCosmeticAdded")
	StorageUtil.UnsetIntValue(player, "Feral.ActiveCosmeticEquipped")
	NiOverride.ClearBodyMorphKeys(player, "Feral.Shapes")
	NiOverride.ClearBodyMorphKeys(player, "Feral.Shapes.Visible")
	NiOverride.UpdateModelWeight(player)
	SlaveTats.simple_remove_tattoo(player, "Feral Shapes", "Wolf Pelt", true, true)
	SlaveTats.simple_remove_tattoo(player, "Feral Shapes", "Sabre Stripes", true, true)
	SlaveTats.simple_remove_tattoo(player, "Feral Shapes", "Bear Mantle", true, true)
	SlaveTats.simple_remove_tattoo(player, "Feral Shapes", "Skeever Mottle", true, true)
	SlaveTats.simple_remove_tattoo(player, "Feral Shapes", "Spider Chitin", true, true)
	SlaveTats.simple_remove_tattoo(player, "Feral Shapes", "Mudcrab Carapace", true, true)
	SlaveTats.simple_remove_tattoo(player, "Feral Shapes", "Horse Stride", true, true)
	SlaveTats.simple_remove_tattoo(player, "Feral Shapes", "Troll Hide", true, true)
	RemoveMarkStages(player, "Wolf Pelt")
	RemoveMarkStages(player, "Sabre Stripes")
	RemoveMarkStages(player, "Bear Mantle")
	RemoveMarkStages(player, "Skeever Mottle")
	RemoveMarkStages(player, "Spider Chitin")
	RemoveMarkStages(player, "Mudcrab Carapace")
	RemoveMarkStages(player, "Stag Dappling")
	RemoveMarkStages(player, "Troll Hide")
	SlaveTats.synchronize_tattoos(player, true)
EndFunction

Function RemoveMarkStages(Actor player, String baseName)
	SlaveTats.simple_remove_tattoo(player, "Feral Shapes", baseName + " I", true, true)
	SlaveTats.simple_remove_tattoo(player, "Feral Shapes", baseName + " II", true, true)
	SlaveTats.simple_remove_tattoo(player, "Feral Shapes", baseName + " III", true, true)
	SlaveTats.simple_remove_tattoo(player, "Feral Shapes", baseName + " III (Feet)", true, true)
	SlaveTats.simple_remove_tattoo(player, "Feral Shapes", baseName + " III (Hands)", true, true)
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
	If version < 5
		Int family = 1
		While family <= 8
			StorageUtil.SetIntValue(player, "Feral.Rank." + family, RankForCount(family, StorageUtil.GetIntValue(player, "Feral.Count." + family)))
			family += 1
		EndWhile
		If StorageUtil.GetIntValue(player, "Feral.PathEnabled") > 0
			StorageUtil.SetIntValue(player, "Feral.PathMode", 2)
		EndIf
		Actor legacyVictim = StorageUtil.GetFormValue(player, "Feral.LastKill") as Actor
		If legacyVictim && legacyVictim.IsDead() && StorageUtil.GetIntValue(legacyVictim, "Feral.Claimed") < 1
			StorageUtil.SetFloatValue(legacyVictim, "Feral.KilledAt", StorageUtil.GetFloatValue(player, "Feral.LastKillAt"))
			StorageUtil.FormListAdd(player, "Feral.PendingEssence", legacyVictim, false)
		EndIf
		StorageUtil.UnsetFormValue(player, "Feral.LastKill")
		StorageUtil.UnsetFloatValue(player, "Feral.LastKillAt")
		StorageUtil.SetIntValue(player, "Feral.EconomyVersion", 5)
	EndIf
	If version < 6
		Int masteryFamily = 1
		While masteryFamily <= 8
			Int historicalPoints = StorageUtil.GetIntValue(player, "Feral.Count." + masteryFamily) * MasteryAwardForHarvest(masteryFamily)
			SetMasteryFromTotalPoints(masteryFamily, historicalPoints)
			masteryFamily += 1
		EndWhile
		Spell retiredClaim = Game.GetFormFromFile(0x00081B, "Feral.esp") as Spell
		If retiredClaim
			player.RemoveSpell(retiredClaim)
		EndIf
		ClearPendingEssence()
		StorageUtil.SetIntValue(player, "Feral.EconomyVersion", 6)
	EndIf
	If version < 7
		Int visualFamily = 1
		While visualFamily <= 8
			StorageUtil.SetIntValue(player, "Feral.Rank." + visualFamily, RankForLevel(GetMasteryLevel(visualFamily)))
			visualFamily += 1
		EndWhile
		StorageUtil.SetIntValue(player, "Feral.EconomyVersion", 7)
	EndIf
	If version < 8
		RefreshTechniquePowers()
		StorageUtil.SetIntValue(player, "Feral.EconomyVersion", 8)
	EndIf
	If version < 9
		If StorageUtil.GetIntValue(player, "Feral.HumanResponseInitialized") < 1
			StorageUtil.SetIntValue(player, "Feral.HumanResponseInitialized", 1)
			StorageUtil.SetIntValue(player, "Feral.HumanResponseMode", 2)
		EndIf
		StorageUtil.SetIntValue(player, "Feral.EconomyVersion", 9)
	EndIf
	If version < 10
		RemoveAllLegacyPassiveSpells()
		RefreshPassivePowers()
		RefreshShapePowers()
		StorageUtil.SetIntValue(player, "Feral.EconomyVersion", 10)
	EndIf
	If version < 11
		; Return to Self is retired: recasting the active shape releases it.
		Spell retiredRevert = Game.GetFormFromFile(0x0009C1, "Feral.esp") as Spell
		If retiredRevert
			player.RemoveSpell(retiredRevert)
		EndIf
		StorageUtil.SetIntValue(player, "Feral.EconomyVersion", 11)
	EndIf
EndFunction

Function SetFeralPathEnabled(Bool enabled)
	If enabled
		SetFeralPathMode(2)
	Else
		SetFeralPathMode(0)
	EndIf
EndFunction

Function SetFeralPathMode(Int mode)
	Actor player = Game.GetPlayer()
	If mode > 0
		If !IsFeralEnabled()
			Debug.Notification("Feral: enable Feral hunting before choosing the Feral Path.")
			Return
		EndIf
		SaveExperienceSettings()
		StorageUtil.SetIntValue(player, "Feral.PathEnabled", 1)
		StorageUtil.SetIntValue(player, "Feral.PathMode", mode)
		ApplyFeralPathSettings()
		Debug.Notification("Feral Path " + FeralPathModeName() + " mode enabled.")
	Else
		RestoreExperienceSettings()
		StorageUtil.SetIntValue(player, "Feral.PathEnabled", 0)
		StorageUtil.SetIntValue(player, "Feral.PathMode", 0)
		Debug.Notification("Feral Path disabled: prior Experience rewards restored.")
	EndIf
EndFunction

Function SaveExperienceSettings()
	Actor player = Game.GetPlayer()
	String stateFile = GetExperienceStateFile()
	String[] settings = GetExperienceRewardSettings()
	If JsonUtil.GetIntValue(stateFile, "OwnerActive") < 1 && StorageUtil.GetIntValue(player, "Feral.ExperienceSettingsSaved") < 1
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
	Int mode = GetFeralPathMode()
	If mode == 1
		Return !Experience.GetSettingBool("bEnableKilling") && !Experience.GetSettingBool("bEnableSkillXP") && Experience.GetSettingFloat("fKillingMult") == 0.0
	EndIf
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
	String stateFile = GetExperienceStateFile()
	Int mode = GetFeralPathMode()
	Int i = 0
	While i < settings.Length
		If mode == 2
			Experience.SetSettingInt(settings[i], 0)
		Else
			Experience.SetSettingInt(settings[i], JsonUtil.GetIntValue(stateFile, "Int." + settings[i]))
		EndIf
		i += 1
	EndWhile
	Experience.SetSettingBool("bEnableKilling", false)
	Experience.SetSettingBool("bEnableSkillXP", false)
	Experience.SetSettingFloat("fKillingMult", 0.0)
	If mode == 2
		Experience.SetSettingBool("bEnableReading", false)
		Experience.SetSettingFloat("fReadingMult", 0.0)
	Else
		Experience.SetSettingBool("bEnableReading", JsonUtil.GetIntValue(stateFile, "bEnableReading") > 0)
		Experience.SetSettingFloat("fReadingMult", JsonUtil.GetFloatValue(stateFile, "fReadingMult"))
	EndIf
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
