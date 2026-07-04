Scriptname cfl_MCM extends SKI_ConfigBase

cfl_Config              Property config       Auto
cfl_MCM_MainPage        Property mainpage     Auto
cfl_MCM_TaskOutfitSleep Property outfitpage   Auto
cfl_MCM_MiscTask        Property misctask1    Auto
cfl_json_settings       Property JSonSettings Auto
String Property LEAConfigPath = "../LolaExpandedAddons/Config.json" Auto
String Property LEAHairPoolPath = "../LolaExpandedAddons/HairPool.json" Auto
String Property LEALolaHairStylesPath = "../Lola/HairStyles.json" Auto

bool firstModScanDone = False

int OID_LEA_MissivesStatus
int OID_LEA_MissivesDetail
int OID_LEA_TreasureFallbackMode
int OID_LEA_TreasureMinGold
int OID_LEA_TreasureMinValue
int OID_LEA_FertilityEnabled
int OID_LEA_FertilityStatus
int OID_LEA_FertilityChance
int OID_LEA_FertilityCooldown
int OID_LEA_FertilityDirect
int OID_LEA_MilkEnabled
int OID_LEA_MilkChance
int OID_LEA_MilkCooldown
int OID_LEA_MilkQuota
int OID_LEA_MilkOwnerMilking
int OID_LEA_MilkOwnerChance
int OID_LEA_MilkOwnerThreshold
int OID_LEA_MilkOwnerDistance
int OID_LEA_BodyEnabled
int OID_LEA_BodyStatus
int OID_LEA_BodyChance
int OID_LEA_BodyCooldown
int OID_LEA_BodyMoodPolicy
int OID_LEA_BodySizeOverride
int OID_LEA_BodyMoodDuration
int OID_LEA_BodyPotions
int OID_LEA_CollarEnabled
int OID_LEA_CollarChance
int OID_LEA_CollarCooldown
int OID_LEA_CollarDistance
int OID_LEA_BathEnabled
int OID_LEA_BathChance
int OID_LEA_BathCooldown
int OID_LEA_BathOwnerChance
int OID_LEA_BathCumThreshold
int OID_LEA_BathDirtStage
int OID_LEA_BathTimeout
int OID_LEA_BathRequireTown
int OID_LEA_ClothesEnabled
int OID_LEA_ClothesTownRule
int OID_LEA_ClothesBoredom
int OID_LEA_ClothesBoredomChance
int OID_LEA_ClothesBoredomCooldown
int OID_LEA_ClothesDeadline
int OID_LEA_ClothesOwnerDistance
int OID_LEA_ClothesStrictArmor
int OID_LEA_ClothesAutoEquip
int OID_LEA_ClothesPunish
int OID_LEA_ClothesLoaner
int OID_LEA_ClothesLoanerChance
int OID_LEA_ClothesLoanerDays
int OID_LEA_ClothesLoanerRecall
int OID_LEA_ClothesLoanerLingerie
int OID_LEA_ClothesLoanerPunishMissing
int OID_LEA_HairStatus
int OID_LEA_HairSeed
int OID_LEA_HairClear

String[] LEA_BodyMoodPolicies
String[] LEA_TreasureFallbackModes

; ------------------------------------------------------------------------------
;                                    STATICS                                    
; ------------------------------------------------------------------------------
int Property MCM_NoScrolBottomRight = 23 Auto
int Property MCM_NoScrolBottomLeft = 22 Auto
int Property MCM_NoScrolTopLeft = 0 Auto
int Property MCM_NoScrolTopRight = 1 Auto


int version = -1
int lastVersion = -1

; ------------------------------------------------------------------------------
;                              Generic MCM events                               
; ------------------------------------------------------------------------------


Function InitMenus()
    config.Genders = new string[3]
    config.Genders[0] = "Both"
    config.Genders[1] = "Male"
    config.Genders[2] = "Female"
Endfunction

event OnConfigInit()
	{Called when this config menu is initialized}
    ModName = "Submissive Lola Extension"
	Init()
    Pages = new string[7]
	Pages[0] = "Main"
	Pages[1] = "Outfit/Sleep"
	Pages[2] = "Misc Tasks"
	Pages[3] = "Tricks"
	Pages[4] = "System"
	Pages[5] = "Debug"
	Pages[6] = "Addons"
    InitMenus()
endEvent

int function GetVersion()
	return 3
endFunction

; @implements SKI_QuestBase
event OnGameReload()
	parent.OnGameReload()
endEvent

; @implements SKI_QuestBase
event OnVersionUpdate(int a_version)
        version = a_version
endEvent

Event OnConfigOpen()
	SetReferences()
    if !config
        Pages = new string[1]
        Pages[0] = "Still in Init"
        return
    endif
    if config.initRunning
        Pages = new string[1]
        Pages[0] = "Init running"
        return
    endif

	Pages = new string[7]
	Pages[0] = "Main"
	Pages[1] = "Outfit/Sleep"
	Pages[2] = "Misc Tasks"
	Pages[3] = "Tricks"
	Pages[4] = "System"
	Pages[5] = "Debug"
	Pages[6] = "Addons"
    mainpage = Quest.GetQuest("cfl_config") as cfl_MCM_MainPage
    outfitpage = Quest.GetQuest("cfl_config") as cfl_MCM_TaskOutfitSleep
    misctask1 = Quest.GetQuest("cfl_config") as cfl_MCM_MiscTask
EndEvent

; @implements SKI_ConfigBase
event OnPageReset(string page)
    {Called when a new page is selected, including the initial empty page}
    SetReferences()
    if !config
        AddTextOption("Init is not started", "True")
        return
    endif
    if config.initRunning
        AddTextOption("Init is Running", "True")
        return
    endif

    SetCursorFillMode(TOP_TO_BOTTOM)
    if(page == "")
        mainpage.Page_MainSetting()
    Elseif(page == "Main")
        mainpage.Page_MainSetting()
    ElseIf (page == "Outfit/Sleep")
        outfitpage.Page_Outfit()
    ElseIf (page == "Misc Tasks")
        misctask1.Page_SmallTasks()
    ElseIf (page == "Tricks")
        misctask1.Page_Tricks()
    ElseIf (page == "System")
        mainpage.Page_SystemPage()
    ElseIf (page == "Debug")
        mainpage.Page_Debug()
    ElseIf (page == "Addons")
        LEA_Page_Addons()
    endif
endEvent

event OnOptionHighlight(int a_option)
	{Called when the user highlights an option}
    if(outfitpage.Outfit_OnHighlight(a_option))
    elseif(misctask1.SmallTasks_OnHighlight(a_option))
    elseif(misctask1.Tricks_OnHighlight(a_option))
    elseif(mainpage.MainSetting_OnHighlight(a_option))
    elseif(mainpage.Debug_OnHighlight(a_option))
    elseif(mainpage.SystemPage_OnHighlight(a_option))
    elseif(LEA_OnHighlight(a_option))
    endif
endEvent

event OnOptionSelect(int a_option)
    if(mainpage.MainSetting_OnSelect(a_option))
    elseif(mainpage.SystemPage_OnSelect(a_option))
    elseif(mainpage.Debug_OnSelect(a_option))
    ElseIf(outfitpage.Outfit_OnSelect(a_option))
    ElseIf(misctask1.SmallTasks_OnSelect(a_option))
    ElseIf(misctask1.Tricks_OnSelect(a_option))
    ElseIf(LEA_OnSelect(a_option))
    endif
Endevent

event OnOptionSliderOpen(int a_option)
    if(mainpage.MainSetting_OnSliderOpen(a_option))
    elseif(mainpage.Debug_OnSliderOpen(a_option))
    elseif(mainpage.SystemPage_OnSliderOpen(a_option))
    elseif(outfitpage.Outfit_OnSliderOpen(a_option))
    elseif(misctask1.SmallTasks_OnSliderOpen(a_option))
    elseif(misctask1.Tricks_OnSliderOpen(a_option))
    elseif(LEA_OnSliderOpen(a_option))
    endif
endevent

event OnOptionSliderAccept(int a_option, float value)
    if(mainpage.MainSetting_OnSliderAccept(a_option, value))
    elseif(mainpage.SystemPage_OnSliderAccept(a_option, value))
    elseif(mainpage.Debug_OnSliderAccept(a_option, value))
    elseif(outfitpage.Outfit_OnSliderAccept(a_option, value))
    elseif(misctask1.SmallTasks_OnSliderAccept(a_option, value))
    elseif(misctask1.Tricks_OnSliderAccept(a_option, value))
    elseif(LEA_OnSliderAccept(a_option, value))
    endif
endevent

event OnOptionMenuOpen(int option)
    if(mainpage.MainSetting_OnMenuOpen(option))
    elseif(mainpage.Debug_OnMenuOpen(option))
    elseif(mainpage.SystemPage_OnMenuOpen(option))
    elseif(misctask1.SmallTasks_OnMenuOpen(option))
    elseif(misctask1.Tricks_OnMenuOpen(option))
    elseif(outfitpage.Outfit_OnMenuOpen(option))
    elseif(LEA_OnMenuOpen(option))

    endif
endevent

event OnOptionMenuAccept(int option, int index)
    if(mainpage.MainSetting_OnMenuAccept(option, index))
    elseif(mainpage.Debug_OnMenuAccept(option, index))
    elseif(mainpage.SystemPage_OnMenuAccept(option, index))
    elseif(misctask1.SmallTasks_OnMenuAccept(option, index))
    elseif(misctask1.Tricks_OnMenuAccept(option, index))
    elseif(outfitpage.Outfit_OnMenuAccept(option, index))
    elseif(LEA_OnMenuAccept(option, index))
    endif
endevent



event OnOptionKeyMapChange(int a_option, int a_keyCode, string a_conflictControl, string a_conflictName)
	{Called when a key has been remapped}
    config.DebugOutput(a_option)
    config.DebugOutput(mainpage.OID_KEY_MainSetting_ConfigKey)
    

	if (a_option == outfitpage.OID_KEY_Outfit_DressKey)

		bool continue = true

		if (a_conflictControl != "")
			string msg

			if (a_conflictName != "")
				msg = "This key is already mapped to:\n'" + a_conflictControl + "'\n(" + a_conflictName + ")\n\nAre you sure you want to continue?"
			else
				msg = "This key is already mapped to:\n'" + a_conflictControl + "'\n\nAre you sure you want to continue?"
			endIf

			continue = ShowMessage(msg, true, "$Yes", "$No")
		endIf

		if (continue)
			config.TaskOutfitChangeKey = a_keyCode
			SetKeymapOptionValue(a_option, a_keyCode)
		endIf
	elseif (a_option == mainpage.OID_KEY_MainSetting_ConfigKey)
        config.DebugOutput("Config Key reconfigure")
		bool continue = true

		if (a_conflictControl != "")
			string msg

			if (a_conflictName != "")
				msg = "This key is already mapped to:\n'" + a_conflictControl + "'\n(" + a_conflictName + ")\n\nAre you sure you want to continue?"
			else
				msg = "This key is already mapped to:\n'" + a_conflictControl + "'\n\nAre you sure you want to continue?"
			endIf

			continue = ShowMessage(msg, true, "$Yes", "$No")
		endIf

		if (continue)
			config.ConfigKey = a_keyCode
			SetKeymapOptionValue(a_option, a_keyCode)
		endIf
	elseif (a_option == mainpage.OID_KEY_Debug_DebugKey)

		bool continue = true

		if (a_conflictControl != "")
			string msg

			if (a_conflictName != "")
				msg = "This key is already mapped to:\n'" + a_conflictControl + "'\n(" + a_conflictName + ")\n\nAre you sure you want to continue?"
			else
				msg = "This key is already mapped to:\n'" + a_conflictControl + "'\n\nAre you sure you want to continue?"
			endIf

			continue = ShowMessage(msg, true, "$Yes", "$No")
		endIf

		if (continue)
			config.DebugKey = a_keyCode
			SetKeymapOptionValue(a_option, a_keyCode)
		endIf
	elseif (a_option == misctask1.OID_KEY_SmallTasks_scbreakKey)

		bool continue = true

		if (a_conflictControl != "")
			string msg

			if (a_conflictName != "")
				msg = "This key is already mapped to:\n'" + a_conflictControl + "'\n(" + a_conflictName + ")\n\nAre you sure you want to continue?"
			else
				msg = "This key is already mapped to:\n'" + a_conflictControl + "'\n\nAre you sure you want to continue?"
			endIf

			continue = ShowMessage(msg, true, "$Yes", "$No")
		endIf

		if (continue)
			config.scBreakKey = a_keyCode
			SetKeymapOptionValue(a_option, a_keyCode)
		endIf
	elseif (a_option == mainpage.OID_KEY_MainSetting_EndWalkKey)

		bool continue = true

		if (a_conflictControl != "")
			string msg

			if (a_conflictName != "")
				msg = "This key is already mapped to:\n'" + a_conflictControl + "'\n(" + a_conflictName + ")\n\nAre you sure you want to continue?"
			else
				msg = "This key is already mapped to:\n'" + a_conflictControl + "'\n\nAre you sure you want to continue?"
			endIf

			continue = ShowMessage(msg, true, "$Yes", "$No")
		endIf

		if (continue)
			config.EndWalkKey = a_keyCode
			SetKeymapOptionValue(a_option, a_keyCode)
		endIf
	endIf
    config.RequestKeyRegister()
endEvent

; ------------------------------------------------------------------------------
;                                   OnSelect                                    
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
;                                 MCM Functions                                 
; ------------------------------------------------------------------------------

bool Function LEA_GetBool(string keyName, bool defaultValue)
    int fallback = 0
    if defaultValue
        fallback = 1
    endif
    return JsonUtil.GetIntValue(LEAConfigPath, keyName, fallback) != 0
EndFunction

int Function LEA_GetInt(string keyName, int defaultValue)
    return JsonUtil.GetIntValue(LEAConfigPath, keyName, defaultValue)
EndFunction

float Function LEA_GetFloat(string keyName, float defaultValue)
    return JsonUtil.GetFloatValue(LEAConfigPath, keyName, defaultValue)
EndFunction

Function LEA_SetBool(string keyName, bool value)
    int intValue = 0
    if value
        intValue = 1
    endif
    JsonUtil.SetIntValue(LEAConfigPath, keyName, intValue)
    JsonUtil.Save(LEAConfigPath)
EndFunction

Function LEA_SetInt(string keyName, int value)
    JsonUtil.SetIntValue(LEAConfigPath, keyName, value)
    JsonUtil.Save(LEAConfigPath)
EndFunction

Function LEA_SetFloat(string keyName, float value)
    JsonUtil.SetFloatValue(LEAConfigPath, keyName, value)
    JsonUtil.Save(LEAConfigPath)
EndFunction

Function LEA_InitMenus()
    LEA_BodyMoodPolicies = new string[4]
    LEA_BodyMoodPolicies[0] = "Dynamic"
    LEA_BodyMoodPolicies[1] = "Always Bigger"
    LEA_BodyMoodPolicies[2] = "Always Smaller"
    LEA_BodyMoodPolicies[3] = "Random"

    LEA_TreasureFallbackModes = new string[3]
    LEA_TreasureFallbackModes[0] = "Off"
    LEA_TreasureFallbackModes[1] = "Valuable Loot"
    LEA_TreasureFallbackModes[2] = "Any Container"
EndFunction

string Function LEA_GetBodyMoodPolicyName()
    int mode = LEA_GetInt("body.moodPolicy", 0)
    if mode == 1
        return "Always Bigger"
    elseif mode == 2
        return "Always Smaller"
    elseif mode == 3
        return "Random"
    endif
    return "Dynamic"
EndFunction

string Function LEA_GetTreasureFallbackModeName()
    int mode = LEA_GetInt("treasure.fallbackMode", 1)
    if mode == 2
        return "Any Container"
    elseif mode == 0
        return "Off"
    endif
    return "Valuable Loot"
EndFunction

string Function LEA_GetFertilityStatusText()
    if !LEA_GetBool("fertility.enabled", true)
        return "Disabled"
    endif
    if !LEA_GetBool("fertility.allowPotionTrigger", true)
        return "Potion trigger off"
    endif
    if Game.GetFormFromFile(0x0156C0, "Fertility Mode.esm") == None
        return "Missing Fertility Mode"
    endif
    if config == None
        return "Config missing"
    endif
    if config.Drugs == None
        return "Drug hook missing; reinit"
    endif
    if !config.cflLolaActive
        return "Waiting for Lola"
    endif
    int chance = LEA_GetInt("fertility.triggerChance", 15)
    if chance < 1
        return "Chance is 0%"
    endif
    float now = Utility.GetCurrentGameTime()
    float nextAllowed = JsonUtil.GetFloatValue(LEAConfigPath, "fertility.nextAllowedGameDay", 0.0)
    if now < nextAllowed
        return "Cooldown " + (((nextAllowed - now) * 24.0) as int) + "h"
    endif
    return "Ready on drug trick"
EndFunction

string Function LEA_GetBodyStatusText()
    if !LEA_GetBool("body.enabled", true)
        return "Disabled"
    endif
    if Game.GetFormFromFile(0x000806, "TransformativeElixirs.esp") == None
        return "Missing elixirs"
    endif
    if config == None
        return "Config missing"
    endif
    if !config.cflLolaActive
        return "Waiting for Lola"
    endif
    if config.Owner == None || config.Player == None
        return "Owner/player missing; reinit"
    endif
    cfl_LolaMonitor monitor = Quest.GetQuest("cfl_Config") as cfl_LolaMonitor
    if monitor == None
        return "Monitor missing; reinit"
    endif
    if monitor.LBP_NextEventTime <= 0.0
        return "Not scheduled; reinit"
    endif
    int chance = LEA_GetInt("body.eventChance", 35)
    if chance < 1
        return "Chance is 0%"
    endif
    float now = Utility.GetCurrentGameTime()
    if now < monitor.LBP_NextEventTime
        return "Next check " + (((monitor.LBP_NextEventTime - now) * 24.0) as int) + "h"
    endif
    return "Ready/checking"
EndFunction

Function LEA_Page_Addons()
    LEA_InitMenus()
    AddHeaderOption("Forced Adventuring", OPTION_FLAG_NONE)
    OID_LEA_MissivesStatus = AddTextOption("Missives status", LEA_GetMissivesStatusText(), OPTION_FLAG_NONE)
    OID_LEA_MissivesDetail = AddTextOption("Show active Missives", "Click", OPTION_FLAG_NONE)

    AddHeaderOption("Treasure Quest", OPTION_FLAG_NONE)
    OID_LEA_TreasureFallbackMode = AddMenuOption("Treasure fallback", LEA_GetTreasureFallbackModeName(), OPTION_FLAG_NONE)
    OID_LEA_TreasureMinGold = AddSliderOption("Min gold from chest", LEA_GetFloat("treasure.minGold", 100.0), "{0}", OPTION_FLAG_NONE)
    OID_LEA_TreasureMinValue = AddSliderOption("Min item value", LEA_GetFloat("treasure.minItemValue", 250.0), "{0}", OPTION_FLAG_NONE)

    AddHeaderOption("Fertility Drug Trick", OPTION_FLAG_NONE)
    OID_LEA_FertilityEnabled = AddToggleOption("Enabled", LEA_GetBool("fertility.enabled", true), OPTION_FLAG_NONE)
    OID_LEA_FertilityStatus = AddTextOption("Status", LEA_GetFertilityStatusText(), OPTION_FLAG_NONE)
    OID_LEA_FertilityChance = AddSliderOption("Chance", LEA_GetFloat("fertility.triggerChance", 15.0), "{0}%", OPTION_FLAG_NONE)
    OID_LEA_FertilityCooldown = AddSliderOption("Cooldown hours", LEA_GetFloat("fertility.cooldownHours", 72.0), "{0}", OPTION_FLAG_NONE)
    OID_LEA_FertilityDirect = AddToggleOption("Direct pregnancy", LEA_GetBool("fertility.allowDirectPregnancy", false), OPTION_FLAG_NONE)

    AddHeaderOption("Milk Economy", OPTION_FLAG_NONE)
    OID_LEA_MilkEnabled = AddToggleOption("Enabled", LEA_GetBool("milk.enabled", true), OPTION_FLAG_NONE)
    OID_LEA_MilkChance = AddSliderOption("Chance", LEA_GetFloat("milk.dailyChance", 35.0), "{0}%", OPTION_FLAG_NONE)
    OID_LEA_MilkCooldown = AddSliderOption("Cooldown hours", LEA_GetFloat("milk.cooldownHours", 24.0), "{0}", OPTION_FLAG_NONE)
    OID_LEA_MilkQuota = AddSliderOption("Milk quota", LEA_GetFloat("milk.assignmentMilkCount", 2.0), "{0}", OPTION_FLAG_NONE)
    OID_LEA_MilkOwnerMilking = AddToggleOption("Owner milks when full", LEA_GetBool("milk.allowOwnerMilking", true), OPTION_FLAG_NONE)
    OID_LEA_MilkOwnerChance = AddSliderOption("Owner milking chance", LEA_GetFloat("milk.ownerMilkingChance", 50.0), "{0}%", OPTION_FLAG_NONE)
    OID_LEA_MilkOwnerThreshold = AddSliderOption("Fullness threshold", LEA_GetFloat("milk.ownerMilkingFullnessThreshold", 0.75) * 100.0, "{0}%", OPTION_FLAG_NONE)
    OID_LEA_MilkOwnerDistance = AddSliderOption("Owner milking distance", LEA_GetFloat("milk.ownerMilkingDistance", 500.0), "{0}", OPTION_FLAG_NONE)

    AddHeaderOption("Body Potion Routine", OPTION_FLAG_NONE)
    OID_LEA_BodyEnabled = AddToggleOption("Enabled", LEA_GetBool("body.enabled", true), OPTION_FLAG_NONE)
    OID_LEA_BodyStatus = AddTextOption("Status", LEA_GetBodyStatusText(), OPTION_FLAG_NONE)
    OID_LEA_BodyChance = AddSliderOption("Chance", LEA_GetFloat("body.eventChance", 35.0), "{0}%", OPTION_FLAG_NONE)
    OID_LEA_BodyCooldown = AddSliderOption("Cooldown hours", LEA_GetFloat("body.cooldownHours", 8.0), "{0}", OPTION_FLAG_NONE)
    OID_LEA_BodyMoodPolicy = AddMenuOption("Mood policy", LEA_GetBodyMoodPolicyName(), OPTION_FLAG_NONE)
    OID_LEA_BodySizeOverride = AddSliderOption("Current size override", LEA_GetFloat("body.sizeOverride", 0.0), "{0}", OPTION_FLAG_NONE)
    OID_LEA_BodyMoodDuration = AddSliderOption("Mood duration hours", LEA_GetFloat("body.moodDurationHours", 168.0), "{0}", OPTION_FLAG_NONE)
    OID_LEA_BodyPotions = AddSliderOption("Potions per event", LEA_GetFloat("body.potionsPerEvent", 1.0), "{0}", OPTION_FLAG_NONE)

    AddHeaderOption("Collar Changes", OPTION_FLAG_NONE)
    OID_LEA_CollarEnabled = AddToggleOption("Owner changes collar", LEA_GetBool("collar.enabled", true), OPTION_FLAG_NONE)
    OID_LEA_CollarChance = AddSliderOption("Change chance", LEA_GetFloat("collar.eventChance", 20.0), "{0}%", OPTION_FLAG_NONE)
    OID_LEA_CollarCooldown = AddSliderOption("Cooldown hours", LEA_GetFloat("collar.cooldownHours", 72.0), "{0}", OPTION_FLAG_NONE)
    OID_LEA_CollarDistance = AddSliderOption("Owner distance", LEA_GetFloat("collar.ownerDistance", 500.0), "{0}", OPTION_FLAG_NONE)

    AddHeaderOption("Bathing Orders", OPTION_FLAG_NONE)
    OID_LEA_BathEnabled = AddToggleOption("Owner demands bathing", LEA_GetBool("bath.enabled", true), OPTION_FLAG_NONE)
    OID_LEA_BathChance = AddSliderOption("Bathing chance", LEA_GetFloat("bath.eventChance", 25.0), "{0}%", OPTION_FLAG_NONE)
    OID_LEA_BathCooldown = AddSliderOption("Bath cooldown hours", LEA_GetFloat("bath.cooldownHours", 24.0), "{0}", OPTION_FLAG_NONE)
    OID_LEA_BathOwnerChance = AddSliderOption("Owner bath chance", LEA_GetFloat("bath.ownerBathChance", 35.0), "{0}%", OPTION_FLAG_NONE)
    OID_LEA_BathCumThreshold = AddSliderOption("Cum threshold", LEA_GetFloat("bath.cumThreshold", 2.0), "{0}", OPTION_FLAG_NONE)
    OID_LEA_BathDirtStage = AddSliderOption("Dirt stage threshold", LEA_GetFloat("bath.dirtMinStage", 3.0), "{0}", OPTION_FLAG_NONE)
    OID_LEA_BathTimeout = AddSliderOption("Cleanup deadline hours", LEA_GetFloat("bath.assignmentTimeoutHours", 1.0), "{0}", OPTION_FLAG_NONE)
    OID_LEA_BathRequireTown = AddToggleOption("Only in town", LEA_GetBool("bath.requireTown", true), OPTION_FLAG_NONE)

    AddHeaderOption("Clothing Discipline", OPTION_FLAG_NONE)
    OID_LEA_ClothesEnabled = AddToggleOption("Owner checks clothes", LEA_GetBool("clothes.enabled", true), OPTION_FLAG_NONE)
    OID_LEA_ClothesTownRule = AddToggleOption("Clothes in town", LEA_GetBool("clothes.townRuleEnabled", true), OPTION_FLAG_NONE)
    OID_LEA_ClothesBoredom = AddToggleOption("Owner gets bored", LEA_GetBool("clothes.boredomEnabled", true), OPTION_FLAG_NONE)
    OID_LEA_ClothesBoredomChance = AddSliderOption("Boredom chance", LEA_GetFloat("clothes.boredomChance", 20.0), "{0}%", OPTION_FLAG_NONE)
    OID_LEA_ClothesBoredomCooldown = AddSliderOption("Boredom cooldown hours", LEA_GetFloat("clothes.boredomCooldownHours", 72.0), "{0}", OPTION_FLAG_NONE)
    OID_LEA_ClothesDeadline = AddSliderOption("Change deadline hours", LEA_GetFloat("clothes.changeDeadlineHours", 2.0), "{0}", OPTION_FLAG_NONE)
    OID_LEA_ClothesOwnerDistance = AddSliderOption("Owner distance", LEA_GetFloat("clothes.ownerDistance", 700.0), "{0}", OPTION_FLAG_NONE)
    OID_LEA_ClothesStrictArmor = AddToggleOption("Strict armor check", LEA_GetBool("clothes.strictArmorSlots", false), OPTION_FLAG_NONE)
    OID_LEA_ClothesAutoEquip = AddToggleOption("Auto-equip outfit task", LEA_GetBool("clothes.autoEquipTownOutfit", false), OPTION_FLAG_NONE)
    OID_LEA_ClothesPunish = AddToggleOption("Punish clothing failure", LEA_GetBool("clothes.punishOnFail", true), OPTION_FLAG_NONE)
    OID_LEA_ClothesLoaner = AddToggleOption("Owner loans clothes", LEA_GetBool("clothes.loanerEnabled", true), OPTION_FLAG_NONE)
    OID_LEA_ClothesLoanerChance = AddSliderOption("Loaner chance", LEA_GetFloat("clothes.loanerChance", 45.0), "{0}%", OPTION_FLAG_NONE)
    OID_LEA_ClothesLoanerDays = AddSliderOption("Loaner wear days", LEA_GetFloat("clothes.loanerMinWearDays", 2.0), "{1}", OPTION_FLAG_NONE)
    OID_LEA_ClothesLoanerRecall = AddSliderOption("Loaner recall chance", LEA_GetFloat("clothes.loanerRecallChance", 70.0), "{0}%", OPTION_FLAG_NONE)
    OID_LEA_ClothesLoanerLingerie = AddToggleOption("Include lingerie loaners", LEA_GetBool("clothes.loanerIncludeLingerie", false), OPTION_FLAG_NONE)
    OID_LEA_ClothesLoanerPunishMissing = AddToggleOption("Punish missing loaners", LEA_GetBool("clothes.loanerPunishMissing", true), OPTION_FLAG_NONE)

    AddHeaderOption("Hair Style Pool", OPTION_FLAG_NONE)
    OID_LEA_HairStatus = AddTextOption("Hair styles available", LEA_GetHairStatusText(), OPTION_FLAG_NONE)
    OID_LEA_HairSeed = AddTextOption("Seed Lola hair styles", "Click", OPTION_FLAG_NONE)
    OID_LEA_HairClear = AddTextOption("Clear seeded hair styles", "Click", OPTION_FLAG_NONE)
EndFunction

bool Function LEA_OnHighlight(int option)
    if option == OID_LEA_MissivesStatus
        SetInfoText("Shows whether Forced Adventuring is active and how many selected Missives are complete.")
    elseif option == OID_LEA_MissivesDetail
        SetInfoText("Shows the selected Missives quest names and whether each one is still active.")
    elseif option == OID_LEA_TreasureFallbackMode
        SetInfoText("Lets Lola's treasure quest accept valuable loot from ordinary non-owned source containers when the chest is not tagged as a boss chest.")
    elseif option == OID_LEA_TreasureMinGold
        SetInfoText("Valuable Loot mode completes the treasure quest when this much gold is taken from a non-owned source container.")
    elseif option == OID_LEA_TreasureMinValue
        SetInfoText("Valuable Loot mode completes the treasure quest when the taken item stack is worth at least this much gold.")
    elseif option == OID_LEA_FertilityStatus
        SetInfoText("Shows whether the fertility drug hook is ready, cooling down, missing Fertility Mode, or needs script reinit.")
    elseif option == OID_LEA_FertilityDirect
        SetInfoText("Uses Fertility Mode's direct pregnancy spell instead of insemination. Leave off for normal Fertility Mode chance.")
    elseif option == OID_LEA_MilkQuota
        SetInfoText("Number of milk bottles required for owner milk quota assignments.")
    elseif option == OID_LEA_MilkOwnerMilking
        SetInfoText("Lets the owner start MME mobile hand milking when the player is nearby and sufficiently full.")
    elseif option == OID_LEA_MilkOwnerChance
        SetInfoText("Chance that a Milk Economy event becomes owner milking when the fullness checks pass.")
    elseif option == OID_LEA_MilkOwnerThreshold
        SetInfoText("Required current milk as a percent of MME's current milk maximum.")
    elseif option == OID_LEA_MilkOwnerDistance
        SetInfoText("Maximum distance from the owner before automatic owner milking can start.")
    elseif option == OID_LEA_BodyMoodPolicy
        SetInfoText("Dynamic uses current size override. Bigger/Smaller forces the owner's weekly mood.")
    elseif option == OID_LEA_BodyStatus
        SetInfoText("Shows whether the Body Potion scheduler is active, waiting, missing Transformative Elixirs, or needs script reinit.")
    elseif option == OID_LEA_BodySizeOverride
        SetInfoText("-100 means very small, 0 neutral, 100 very large. Dynamic mood tends to push back toward the opposite direction.")
    elseif option == OID_LEA_BodyMoodDuration
        SetInfoText("How long the owner keeps a chosen bigger/smaller mood before picking a new one.")
    elseif option == OID_LEA_CollarEnabled
        SetInfoText("Lets the owner periodically use Lola's own collar swap behavior.")
    elseif option == OID_LEA_CollarChance
        SetInfoText("Chance that a collar change happens when the collar cooldown expires.")
    elseif option == OID_LEA_CollarCooldown
        SetInfoText("In-game hours between possible automatic collar changes.")
    elseif option == OID_LEA_CollarDistance
        SetInfoText("Maximum distance from the owner before an automatic collar change can start.")
    elseif option == OID_LEA_BathEnabled
        SetInfoText("Lets the owner react when the player has enough cum overlays or bathing dirt effects.")
    elseif option == OID_LEA_BathChance
        SetInfoText("Chance that the owner comments when bathing checks find the player dirty.")
    elseif option == OID_LEA_BathCooldown
        SetInfoText("In-game hours between possible bathing orders.")
    elseif option == OID_LEA_BathOwnerChance
        SetInfoText("Chance the owner washes the player directly when nearby and Bathing in Skyrim is available.")
    elseif option == OID_LEA_BathCumThreshold
        SetInfoText("Total SCO oral, anal, and vaginal cum counters needed before the player counts as needing cleaning.")
    elseif option == OID_LEA_BathDirtStage
        SetInfoText("Bathing dirt stage needed before the player counts as dirty. Uses Bathing in Skyrim, Dirt and Blood, or Keep It Clean effects when present.")
    elseif option == OID_LEA_BathTimeout
        SetInfoText("In-game hours the player has to clean up when ordered to do it themselves.")
    elseif option == OID_LEA_BathRequireTown
        SetInfoText("Requires Lola's town check before bathing orders can start.")
    elseif option == OID_LEA_ClothesEnabled
        SetInfoText("Lets the owner enforce town clothing and occasional changes of clothes.")
    elseif option == OID_LEA_ClothesTownRule
        SetInfoText("Requires a clothing body item, not light or heavy armor, while in towns.")
    elseif option == OID_LEA_ClothesBoredom
        SetInfoText("Lets the owner periodically decide your current clothes are stale and demand a different outfit.")
    elseif option == OID_LEA_ClothesBoredomChance
        SetInfoText("Chance that the owner demands a new outfit when the boredom cooldown expires.")
    elseif option == OID_LEA_ClothesBoredomCooldown
        SetInfoText("In-game hours between possible bored-of-your-clothes orders.")
    elseif option == OID_LEA_ClothesDeadline
        SetInfoText("In-game hours allowed to obey a clothing order before punishment can repeat.")
    elseif option == OID_LEA_ClothesOwnerDistance
        SetInfoText("Maximum distance from the owner before clothing checks can start or progress.")
    elseif option == OID_LEA_ClothesStrictArmor
        SetInfoText("When enabled, any worn light or heavy armor piece violates the town clothing rule. When disabled, only the body slot is checked.")
    elseif option == OID_LEA_ClothesAutoEquip
        SetInfoText("When the existing Outfit Task is already running, clothing orders can ask it to pick and equip a new outfit. This does not start the Outfit Task.")
    elseif option == OID_LEA_ClothesPunish
        SetInfoText("Applies a minimal Lola punishment when a clothing order is ignored past the deadline.")
    elseif option == OID_LEA_ClothesLoaner
        SetInfoText("Lets the owner loan a matching clothing set when ordering town clothes or a change of clothes.")
    elseif option == OID_LEA_ClothesLoanerChance
        SetInfoText("Chance that a clothing order includes a loaned outfit from the generated clothing pool.")
    elseif option == OID_LEA_ClothesLoanerDays
        SetInfoText("Minimum in-game days the player is expected to wear a loaned clothing set before recall can happen.")
    elseif option == OID_LEA_ClothesLoanerRecall
        SetInfoText("Chance per clothing check that the owner asks for loaned clothes back after the minimum wear time.")
    elseif option == OID_LEA_ClothesLoanerLingerie
        SetInfoText("Allows the loaner pool to include lingerie and humiliating tagged sets as well as ordinary revealing fashion.")
    elseif option == OID_LEA_ClothesLoanerPunishMissing
        SetInfoText("Applies a minimal Lola punishment if the owner recalls loaned clothes and pieces are missing.")
    elseif option == OID_LEA_HairStatus
        SetInfoText("Generated pool count / current Lola style count / styles seeded by this addon.")
    elseif option == OID_LEA_HairSeed
        SetInfoText("Adds valid generated hair HeadParts to Lola's existing HairStyles.json list.")
    elseif option == OID_LEA_HairClear
        SetInfoText("Removes hair styles this addon previously seeded. Manually added Lola styles are left alone unless they share the same name.")
    else
        return false
    endif
    return true
EndFunction

bool Function LEA_OnSelect(int option)
    if option == OID_LEA_MissivesDetail
        Debug.MessageBox(LEA_GetMissivesDetailText())
    elseif option == OID_LEA_FertilityStatus
        Debug.MessageBox("Fertility Drug Trick: " + LEA_GetFertilityStatusText() + "\n\nIf this says hook missing or remains wrong after enabling Lola, use Reinit All Scripts.")
    elseif option == OID_LEA_BodyStatus
        Debug.MessageBox("Body Potion Routine: " + LEA_GetBodyStatusText() + "\n\nIf this says not scheduled while Lola ownership is active, use Reinit All Scripts.")
    elseif option == OID_LEA_FertilityEnabled
        bool valueFertility = !LEA_GetBool("fertility.enabled", true)
        LEA_SetBool("fertility.enabled", valueFertility)
        SetToggleOptionValue(option, valueFertility, false)
    elseif option == OID_LEA_FertilityDirect
        bool valueDirect = !LEA_GetBool("fertility.allowDirectPregnancy", false)
        LEA_SetBool("fertility.allowDirectPregnancy", valueDirect)
        SetToggleOptionValue(option, valueDirect, false)
    elseif option == OID_LEA_MilkEnabled
        bool valueMilk = !LEA_GetBool("milk.enabled", true)
        LEA_SetBool("milk.enabled", valueMilk)
        SetToggleOptionValue(option, valueMilk, false)
    elseif option == OID_LEA_MilkOwnerMilking
        bool valueOwnerMilking = !LEA_GetBool("milk.allowOwnerMilking", true)
        LEA_SetBool("milk.allowOwnerMilking", valueOwnerMilking)
        SetToggleOptionValue(option, valueOwnerMilking, false)
    elseif option == OID_LEA_BodyEnabled
        bool valueBody = !LEA_GetBool("body.enabled", true)
        LEA_SetBool("body.enabled", valueBody)
        SetToggleOptionValue(option, valueBody, false)
    elseif option == OID_LEA_CollarEnabled
        bool valueCollar = !LEA_GetBool("collar.enabled", true)
        LEA_SetBool("collar.enabled", valueCollar)
        SetToggleOptionValue(option, valueCollar, false)
    elseif option == OID_LEA_BathEnabled
        bool valueBath = !LEA_GetBool("bath.enabled", true)
        LEA_SetBool("bath.enabled", valueBath)
        SetToggleOptionValue(option, valueBath, false)
    elseif option == OID_LEA_BathRequireTown
        bool valueBathTown = !LEA_GetBool("bath.requireTown", true)
        LEA_SetBool("bath.requireTown", valueBathTown)
        SetToggleOptionValue(option, valueBathTown, false)
    elseif option == OID_LEA_ClothesEnabled
        bool valueClothes = !LEA_GetBool("clothes.enabled", true)
        LEA_SetBool("clothes.enabled", valueClothes)
        SetToggleOptionValue(option, valueClothes, false)
    elseif option == OID_LEA_ClothesTownRule
        bool valueTownClothes = !LEA_GetBool("clothes.townRuleEnabled", true)
        LEA_SetBool("clothes.townRuleEnabled", valueTownClothes)
        SetToggleOptionValue(option, valueTownClothes, false)
    elseif option == OID_LEA_ClothesBoredom
        bool valueBoredom = !LEA_GetBool("clothes.boredomEnabled", true)
        LEA_SetBool("clothes.boredomEnabled", valueBoredom)
        SetToggleOptionValue(option, valueBoredom, false)
    elseif option == OID_LEA_ClothesStrictArmor
        bool valueStrictArmor = !LEA_GetBool("clothes.strictArmorSlots", false)
        LEA_SetBool("clothes.strictArmorSlots", valueStrictArmor)
        SetToggleOptionValue(option, valueStrictArmor, false)
    elseif option == OID_LEA_ClothesAutoEquip
        bool valueAutoEquip = !LEA_GetBool("clothes.autoEquipTownOutfit", false)
        LEA_SetBool("clothes.autoEquipTownOutfit", valueAutoEquip)
        SetToggleOptionValue(option, valueAutoEquip, false)
    elseif option == OID_LEA_ClothesPunish
        bool valueClothesPunish = !LEA_GetBool("clothes.punishOnFail", true)
        LEA_SetBool("clothes.punishOnFail", valueClothesPunish)
        SetToggleOptionValue(option, valueClothesPunish, false)
    elseif option == OID_LEA_ClothesLoaner
        bool valueLoaner = !LEA_GetBool("clothes.loanerEnabled", true)
        LEA_SetBool("clothes.loanerEnabled", valueLoaner)
        SetToggleOptionValue(option, valueLoaner, false)
    elseif option == OID_LEA_ClothesLoanerLingerie
        bool valueLoanerLingerie = !LEA_GetBool("clothes.loanerIncludeLingerie", false)
        LEA_SetBool("clothes.loanerIncludeLingerie", valueLoanerLingerie)
        SetToggleOptionValue(option, valueLoanerLingerie, false)
    elseif option == OID_LEA_ClothesLoanerPunishMissing
        bool valueLoanerPunishMissing = !LEA_GetBool("clothes.loanerPunishMissing", true)
        LEA_SetBool("clothes.loanerPunishMissing", valueLoanerPunishMissing)
        SetToggleOptionValue(option, valueLoanerPunishMissing, false)
    elseif option == OID_LEA_HairSeed
        LEA_SeedHairStyles()
        ForcePageReset()
    elseif option == OID_LEA_HairClear
        LEA_ClearSeededHairStyles()
        ForcePageReset()
    else
        return false
    endif
    return true
EndFunction

string Function LEA_GetMissivesStatusText()
    cfl_Missives missives = Quest.GetQuest("cfl_Missives") as cfl_Missives
    if missives == None
        return "Unavailable"
    endif
    return missives.GetActiveMissivesStatus()
EndFunction

string Function LEA_GetMissivesDetailText()
    cfl_Missives missives = Quest.GetQuest("cfl_Missives") as cfl_Missives
    if missives == None
        return "Forced adventuring is unavailable."
    endif
    return missives.GetActiveMissivesDetail()
EndFunction

string Function LEA_GetHairStatusText()
    int poolCount = JsonUtil.StringListCount(LEAHairPoolPath, "names")
    int lolaCount = JsonUtil.StringListCount(LEALolaHairStylesPath, "hairstyles")
    int seededCount = JsonUtil.StringListCount(LEAConfigPath, "hair.seededNames")
    return poolCount + " pool / " + lolaCount + " Lola / " + seededCount + " seeded"
EndFunction

Function LEA_SeedHairStyles()
    int poolCount = JsonUtil.StringListCount(LEAHairPoolPath, "names")
    int added = 0
    int skipped = 0
    int i = 0
    while i < poolCount
        string styleName = JsonUtil.StringListGet(LEAHairPoolPath, "names", i)
        string pluginName = JsonUtil.StringListGet(LEAHairPoolPath, "plugins", i)
        int formId = JsonUtil.IntListGet(LEAHairPoolPath, "formIds", i)
        HeadPart style = Game.GetFormFromFile(formId, pluginName) as HeadPart
        if style != None && style.GetType() == 3 && styleName != ""
            if !JsonUtil.StringListHas(LEALolaHairStylesPath, "hairstyles", styleName)
                JsonUtil.StringListAdd(LEALolaHairStylesPath, "hairstyles", styleName, false)
                JsonUtil.SetFormValue(LEALolaHairStylesPath, styleName, style)
                added += 1
            else
                skipped += 1
            endif
            if !JsonUtil.StringListHas(LEAConfigPath, "hair.seededNames", styleName)
                JsonUtil.StringListAdd(LEAConfigPath, "hair.seededNames", styleName, false)
            endif
        else
            skipped += 1
        endif
        i += 1
    endwhile
    JsonUtil.Save(LEALolaHairStylesPath)
    JsonUtil.Save(LEAConfigPath)
    Debug.Notification("Lola Expanded Addons seeded " + added + " hair style(s), skipped " + skipped + ".")
EndFunction

Function LEA_ClearSeededHairStyles()
    int count = JsonUtil.StringListCount(LEAConfigPath, "hair.seededNames")
    int removed = 0
    while count > 0
        count -= 1
        string styleName = JsonUtil.StringListGet(LEAConfigPath, "hair.seededNames", count)
        if styleName != ""
            JsonUtil.StringListRemove(LEALolaHairStylesPath, "hairstyles", styleName, true)
            JsonUtil.UnsetFormValue(LEALolaHairStylesPath, styleName)
            removed += 1
        endif
        JsonUtil.StringListRemoveAt(LEAConfigPath, "hair.seededNames", count)
    endwhile
    JsonUtil.Save(LEALolaHairStylesPath)
    JsonUtil.Save(LEAConfigPath)
    Debug.Notification("Lola Expanded Addons removed " + removed + " seeded hair style(s).")
EndFunction

bool Function LEA_OnSliderOpen(int option)
    if option == OID_LEA_TreasureMinGold
        LEA_OpenSlider(LEA_GetFloat("treasure.minGold", 100.0), 1.0, 5000.0, 25.0, 100.0)
    elseif option == OID_LEA_TreasureMinValue
        LEA_OpenSlider(LEA_GetFloat("treasure.minItemValue", 250.0), 1.0, 10000.0, 25.0, 250.0)
    elseif option == OID_LEA_FertilityChance
        LEA_OpenSlider(LEA_GetFloat("fertility.triggerChance", 15.0), 0.0, 100.0, 5.0, 15.0)
    elseif option == OID_LEA_FertilityCooldown
        LEA_OpenSlider(LEA_GetFloat("fertility.cooldownHours", 72.0), 0.0, 240.0, 1.0, 72.0)
    elseif option == OID_LEA_MilkChance
        LEA_OpenSlider(LEA_GetFloat("milk.dailyChance", 35.0), 0.0, 100.0, 5.0, 35.0)
    elseif option == OID_LEA_MilkCooldown
        LEA_OpenSlider(LEA_GetFloat("milk.cooldownHours", 24.0), 0.0, 240.0, 1.0, 24.0)
    elseif option == OID_LEA_MilkQuota
        LEA_OpenSlider(LEA_GetFloat("milk.assignmentMilkCount", 2.0), 1.0, 10.0, 1.0, 2.0)
    elseif option == OID_LEA_MilkOwnerChance
        LEA_OpenSlider(LEA_GetFloat("milk.ownerMilkingChance", 50.0), 0.0, 100.0, 5.0, 50.0)
    elseif option == OID_LEA_MilkOwnerThreshold
        LEA_OpenSlider(LEA_GetFloat("milk.ownerMilkingFullnessThreshold", 0.75) * 100.0, 5.0, 100.0, 5.0, 75.0)
    elseif option == OID_LEA_MilkOwnerDistance
        LEA_OpenSlider(LEA_GetFloat("milk.ownerMilkingDistance", 500.0), 100.0, 3000.0, 50.0, 500.0)
    elseif option == OID_LEA_BodyChance
        LEA_OpenSlider(LEA_GetFloat("body.eventChance", 35.0), 0.0, 100.0, 5.0, 35.0)
    elseif option == OID_LEA_BodyCooldown
        LEA_OpenSlider(LEA_GetFloat("body.cooldownHours", 8.0), 0.0, 240.0, 1.0, 8.0)
    elseif option == OID_LEA_BodySizeOverride
        LEA_OpenSlider(LEA_GetFloat("body.sizeOverride", 0.0), -100.0, 100.0, 5.0, 0.0)
    elseif option == OID_LEA_BodyMoodDuration
        LEA_OpenSlider(LEA_GetFloat("body.moodDurationHours", 168.0), 1.0, 720.0, 1.0, 168.0)
    elseif option == OID_LEA_BodyPotions
        LEA_OpenSlider(LEA_GetFloat("body.potionsPerEvent", 1.0), 1.0, 3.0, 1.0, 1.0)
    elseif option == OID_LEA_CollarChance
        LEA_OpenSlider(LEA_GetFloat("collar.eventChance", 20.0), 0.0, 100.0, 5.0, 20.0)
    elseif option == OID_LEA_CollarCooldown
        LEA_OpenSlider(LEA_GetFloat("collar.cooldownHours", 72.0), 1.0, 720.0, 1.0, 72.0)
    elseif option == OID_LEA_CollarDistance
        LEA_OpenSlider(LEA_GetFloat("collar.ownerDistance", 500.0), 100.0, 3000.0, 50.0, 500.0)
    elseif option == OID_LEA_BathChance
        LEA_OpenSlider(LEA_GetFloat("bath.eventChance", 25.0), 0.0, 100.0, 5.0, 25.0)
    elseif option == OID_LEA_BathCooldown
        LEA_OpenSlider(LEA_GetFloat("bath.cooldownHours", 24.0), 1.0, 720.0, 1.0, 24.0)
    elseif option == OID_LEA_BathOwnerChance
        LEA_OpenSlider(LEA_GetFloat("bath.ownerBathChance", 35.0), 0.0, 100.0, 5.0, 35.0)
    elseif option == OID_LEA_BathCumThreshold
        LEA_OpenSlider(LEA_GetFloat("bath.cumThreshold", 2.0), 1.0, 10.0, 1.0, 2.0)
    elseif option == OID_LEA_BathDirtStage
        LEA_OpenSlider(LEA_GetFloat("bath.dirtMinStage", 3.0), 2.0, 5.0, 1.0, 3.0)
    elseif option == OID_LEA_BathTimeout
        LEA_OpenSlider(LEA_GetFloat("bath.assignmentTimeoutHours", 1.0), 0.25, 24.0, 0.25, 1.0)
    elseif option == OID_LEA_ClothesBoredomChance
        LEA_OpenSlider(LEA_GetFloat("clothes.boredomChance", 20.0), 0.0, 100.0, 5.0, 20.0)
    elseif option == OID_LEA_ClothesBoredomCooldown
        LEA_OpenSlider(LEA_GetFloat("clothes.boredomCooldownHours", 72.0), 1.0, 720.0, 1.0, 72.0)
    elseif option == OID_LEA_ClothesDeadline
        LEA_OpenSlider(LEA_GetFloat("clothes.changeDeadlineHours", 2.0), 0.25, 24.0, 0.25, 2.0)
    elseif option == OID_LEA_ClothesOwnerDistance
        LEA_OpenSlider(LEA_GetFloat("clothes.ownerDistance", 700.0), 100.0, 3000.0, 50.0, 700.0)
    elseif option == OID_LEA_ClothesLoanerChance
        LEA_OpenSlider(LEA_GetFloat("clothes.loanerChance", 45.0), 0.0, 100.0, 5.0, 45.0)
    elseif option == OID_LEA_ClothesLoanerDays
        LEA_OpenSlider(LEA_GetFloat("clothes.loanerMinWearDays", 2.0), 0.25, 14.0, 0.25, 2.0)
    elseif option == OID_LEA_ClothesLoanerRecall
        LEA_OpenSlider(LEA_GetFloat("clothes.loanerRecallChance", 70.0), 0.0, 100.0, 5.0, 70.0)
    else
        return false
    endif
    return true
EndFunction

Function LEA_OpenSlider(float startValue, float minValue, float maxValue, float interval, float defaultValue)
    SetSliderDialogStartValue(startValue)
    SetSliderDialogDefaultValue(defaultValue)
    SetSliderDialogRange(minValue, maxValue)
    SetSliderDialogInterval(interval)
EndFunction

bool Function LEA_OnSliderAccept(int option, float value)
    if option == OID_LEA_TreasureMinGold
        LEA_SetInt("treasure.minGold", value as int)
        SetSliderOptionValue(option, value, "{0}", false)
    elseif option == OID_LEA_TreasureMinValue
        LEA_SetInt("treasure.minItemValue", value as int)
        SetSliderOptionValue(option, value, "{0}", false)
    elseif option == OID_LEA_FertilityChance
        LEA_SetInt("fertility.triggerChance", value as int)
        SetSliderOptionValue(option, value, "{0}%", false)
    elseif option == OID_LEA_FertilityCooldown
        LEA_SetFloat("fertility.cooldownHours", value)
        SetSliderOptionValue(option, value, "{0}", false)
    elseif option == OID_LEA_MilkChance
        LEA_SetInt("milk.dailyChance", value as int)
        SetSliderOptionValue(option, value, "{0}%", false)
    elseif option == OID_LEA_MilkCooldown
        LEA_SetFloat("milk.cooldownHours", value)
        SetSliderOptionValue(option, value, "{0}", false)
    elseif option == OID_LEA_MilkQuota
        LEA_SetInt("milk.assignmentMilkCount", value as int)
        SetSliderOptionValue(option, value, "{0}", false)
    elseif option == OID_LEA_MilkOwnerChance
        LEA_SetInt("milk.ownerMilkingChance", value as int)
        SetSliderOptionValue(option, value, "{0}%", false)
    elseif option == OID_LEA_MilkOwnerThreshold
        LEA_SetFloat("milk.ownerMilkingFullnessThreshold", value / 100.0)
        SetSliderOptionValue(option, value, "{0}%", false)
    elseif option == OID_LEA_MilkOwnerDistance
        LEA_SetFloat("milk.ownerMilkingDistance", value)
        SetSliderOptionValue(option, value, "{0}", false)
    elseif option == OID_LEA_BodyChance
        LEA_SetInt("body.eventChance", value as int)
        SetSliderOptionValue(option, value, "{0}%", false)
    elseif option == OID_LEA_BodyCooldown
        LEA_SetFloat("body.cooldownHours", value)
        SetSliderOptionValue(option, value, "{0}", false)
    elseif option == OID_LEA_BodySizeOverride
        LEA_SetInt("body.sizeOverride", value as int)
        LEA_SetInt("body.currentMood", -1)
        LEA_SetFloat("body.nextMoodGameDay", 0.0)
        SetSliderOptionValue(option, value, "{0}", false)
    elseif option == OID_LEA_BodyMoodDuration
        LEA_SetFloat("body.moodDurationHours", value)
        SetSliderOptionValue(option, value, "{0}", false)
    elseif option == OID_LEA_BodyPotions
        LEA_SetInt("body.potionsPerEvent", value as int)
        SetSliderOptionValue(option, value, "{0}", false)
    elseif option == OID_LEA_CollarChance
        LEA_SetInt("collar.eventChance", value as int)
        SetSliderOptionValue(option, value, "{0}%", false)
    elseif option == OID_LEA_CollarCooldown
        LEA_SetFloat("collar.cooldownHours", value)
        SetSliderOptionValue(option, value, "{0}", false)
    elseif option == OID_LEA_CollarDistance
        LEA_SetFloat("collar.ownerDistance", value)
        SetSliderOptionValue(option, value, "{0}", false)
    elseif option == OID_LEA_BathChance
        LEA_SetInt("bath.eventChance", value as int)
        SetSliderOptionValue(option, value, "{0}%", false)
    elseif option == OID_LEA_BathCooldown
        LEA_SetFloat("bath.cooldownHours", value)
        SetSliderOptionValue(option, value, "{0}", false)
    elseif option == OID_LEA_BathOwnerChance
        LEA_SetInt("bath.ownerBathChance", value as int)
        SetSliderOptionValue(option, value, "{0}%", false)
    elseif option == OID_LEA_BathCumThreshold
        LEA_SetInt("bath.cumThreshold", value as int)
        SetSliderOptionValue(option, value, "{0}", false)
    elseif option == OID_LEA_BathDirtStage
        LEA_SetInt("bath.dirtMinStage", value as int)
        SetSliderOptionValue(option, value, "{0}", false)
    elseif option == OID_LEA_BathTimeout
        LEA_SetFloat("bath.assignmentTimeoutHours", value)
        SetSliderOptionValue(option, value, "{0}", false)
    elseif option == OID_LEA_ClothesBoredomChance
        LEA_SetInt("clothes.boredomChance", value as int)
        SetSliderOptionValue(option, value, "{0}%", false)
    elseif option == OID_LEA_ClothesBoredomCooldown
        LEA_SetFloat("clothes.boredomCooldownHours", value)
        SetSliderOptionValue(option, value, "{0}", false)
    elseif option == OID_LEA_ClothesDeadline
        LEA_SetFloat("clothes.changeDeadlineHours", value)
        SetSliderOptionValue(option, value, "{0}", false)
    elseif option == OID_LEA_ClothesOwnerDistance
        LEA_SetFloat("clothes.ownerDistance", value)
        SetSliderOptionValue(option, value, "{0}", false)
    elseif option == OID_LEA_ClothesLoanerChance
        LEA_SetInt("clothes.loanerChance", value as int)
        SetSliderOptionValue(option, value, "{0}%", false)
    elseif option == OID_LEA_ClothesLoanerDays
        LEA_SetFloat("clothes.loanerMinWearDays", value)
        SetSliderOptionValue(option, value, "{1}", false)
    elseif option == OID_LEA_ClothesLoanerRecall
        LEA_SetInt("clothes.loanerRecallChance", value as int)
        SetSliderOptionValue(option, value, "{0}%", false)
    else
        return false
    endif
    return true
EndFunction

bool Function LEA_OnMenuOpen(int option)
    if option == OID_LEA_TreasureFallbackMode
        LEA_InitMenus()
        SetMenuDialogOptions(LEA_TreasureFallbackModes)
        SetMenuDialogStartIndex(LEA_GetInt("treasure.fallbackMode", 1))
        SetMenuDialogDefaultIndex(1)
        return true
    elseif option == OID_LEA_BodyMoodPolicy
        LEA_InitMenus()
        SetMenuDialogOptions(LEA_BodyMoodPolicies)
        SetMenuDialogStartIndex(LEA_GetInt("body.moodPolicy", 0))
        SetMenuDialogDefaultIndex(0)
        return true
    endif
    return false
EndFunction

bool Function LEA_OnMenuAccept(int option, int index)
    if option == OID_LEA_TreasureFallbackMode
        if index < 0
            index = 0
        endif
        if index > 2
            index = 2
        endif
        LEA_SetInt("treasure.fallbackMode", index)
        SetMenuOptionValue(option, LEA_GetTreasureFallbackModeName(), false)
        return true
    elseif option == OID_LEA_BodyMoodPolicy
        if index < 0
            index = 0
        endif
        if index > 3
            index = 3
        endif
        LEA_SetInt("body.moodPolicy", index)
        LEA_SetInt("body.currentMood", -1)
        LEA_SetFloat("body.nextMoodGameDay", 0.0)
        SetMenuOptionValue(option, LEA_GetBodyMoodPolicyName(), false)
        return true
    endif
    return false
EndFunction

bool Function ToggleManualMode(int option)
    config.TaskOutfitManualMode = !config.TaskOutfitManualMode
    if config.TaskOutfitManualMode && config.TaskOutfit.isRunning()
        Debug.Notification("Enabling Manual Mode. This can take some time! Adding all the Outfits. Be patient")
        config.TaskOutfit.StartManualMode()
    elseif (config.TaskOutfit.isRunning())
        Debug.Notification("Disable Manual Mode. This can take some time! Remove all the Outfits. Be patient")
        config.TaskOutfit.StopManualMode()
    endif

    SetToggleOptionValue(option, config.TaskOutfitManualMode)
EndFunction

Function ShowLolaStats()
    if(config.LolaQuestRunning)
        AddTextOption("Current Owner", config.Owner.GetDisplayName())
        string playmateName = "None"
        if (config.Playmate != None)
            playmateName = config.Playmate.GetDisplayName()
        endif
        AddTextOption("Current Playmate", playmateName)
    endif
EndFunction

Function ReloadExternalMods()
    config.ScanForMods()
    ForcePageReset()
EndFunction

Function LoadSettings()
    JSonSettings = Quest.GetQuest("cfl_Config") as cfl_json_settings
    JSonSettings.Config = Config
    JSonSettings.LoadSettings()
    if config.LastPlaymateFile != ""
        (Quest.GetQuest("cfl_Config") as cfl_Configurator).LoadPlaymates(config.LastPlaymateFile)
    endif
    ForcePageReset()
EndFunction

Function SaveSettings()
    JSonSettings = Quest.GetQuest("cfl_Config") as cfl_json_settings
    JSonSettings.Config = Config
    JSonSettings.SaveSettings()
    JSonUtil.Save(config.jsonConfigPath)
    ForcePageReset()
EndFunction

Function ReeinitScripts()
    SetReferences()
    config.RequestReferenceLoad()
    ForcePageReset()
EndFunction

Function StartOutfitQuest()
    If !Config.cflLolaActive
        Debug.MessageBox("Error: Lola Extension not running")
        return
    endif
    cfl_TaskOutfit OutfitTask = config.TaskOutfit
    if(OutfitTask.IsRunning())
        if config.DebugEnabled
            OutfitTask.RequestNewOutfitSets()
        endif
    Else
        OutfitTask.Start()
    endif
    ForcePageReset()
EndFunction

Function StartSleepQuest()
    If !Config.cflLolaActive
        Debug.MessageBox("Error: Lola Extension not running")
        return
    endif
    cfl_TaskSleepDeny q = config.TaskSleepDeny
    if(!q.IsRunning())
        q.Start()
    endif
    ForcePageReset()
EndFunction

Function StopOutfitQuest()
    If !Config.cflLolaActive
        Debug.MessageBox("Error: Lola Extension not running")
        return
    endif
    cfl_TaskOutfit OutfitTask = config.TaskOutfit
    if(OutfitTask.IsRunning())
        OutfitTask.CompleteQuest()
        OutfitTask.Stop()
    endif
    ForcePageReset()
EndFunction

Function StopSleepQuest()
    If !Config.cflLolaActive
        Debug.MessageBox("Error: Lola Extension not running")
        return
    endif
    cfl_TaskSleepDeny q = config.TaskSleepDeny
    if(q.IsRunning())
        q.CompleteQuest()
        q.Stop()
    endif
    ForcePageReset()
EndFunction

Function StartLolaOnSale()
    If !Config.cflLolaActive
        Debug.MessageBox("Error: Lola Extension not running")
        return
    endif
    cfl_LolaForSale q = config.lolaForSale
        if(!q.isRunning())
    q.Start()
    endif
    ForcePageReset()
EndFunction

Function ToggleStylishOwner()
    If !Config.cflLolaActive
        Debug.MessageBox("Error: Lola Extension not running")
        return
    endif
    If (config.cflStylishOwner.IsRunning())
        config.cflStylishOwner.CompleteQuest()
        Utility.Wait(1)
        config.cflStylishOwner.Stop()
    Else
        config.cflStylishOwner.Start()
    EndIf
    ForcePageReset()
EndFunction

Function ToggleManualAddonStart()

    If !IsSubmissiveLolaRunning()
        Debug.MessageBox("Error: Submissive Lola is not running")
        return
    endif

    if Config.ExtensionRunning
        Debug.MessageBox("Error: Addon should already be active")
        return
    endif
    SimulateLolaStart()
    Debug.MessageBox("Send Startup event. Close the MCM Menu and wait for the Finish Notification")
EndFunction

Bool Function IsSubmissiveLolaRunning()
    If Config != None && Config.LolaQuestRunning
        return True
    EndIf

    Quest lolaQuest = Quest.GetQuest("vkjMQ")
    return lolaQuest != None && lolaQuest.IsRunning()
EndFunction

Function SimulateLolaStop()
    int handle = ModEvent.Create("cfeLola_LolaStop")
    If (Handle)
        ModEvent.Send(Handle)
    Endif
EndFunction

Function SimulateLolaStart()
    int handle = ModEvent.Create("cfeLola_LolaStart")
    If (Handle)
        ModEvent.Send(Handle)
    Endif
EndFunction

; ------------------------------------------------------------------------------
;                                   Functions                                   
; ------------------------------------------------------------------------------


Function Init()
    SetReferences()
    utility.Wait(5)
    config.Init(self)
EndFunction



Function SetReferences()
    config = Quest.GetQuest("cfl_Config") as cfl_Config
EndFunction

int Function GetFlagBool(bool varToCheck, bool estimtedValue, bool hide = False)
    if (varToCheck != estimtedValue)
        if(hide)
            return OPTION_FLAG_HIDDEN
        endif
        return OPTION_FLAG_DISABLED
    endif
    return OPTION_FLAG_NONE
Endfunction


; ------------------------------------------------------------------------------
;                                    Updates                                    
; ------------------------------------------------------------------------------

; Versions
; 0: 1.0.0
; 1: 1.0.2
; 2: 1.0.5
Function UpdateMod()
    if config.Version == 0
        UpdateTo1_0_2()
        config.Version = 1 
    endif
    if config.Version == 1
        UpdateTo1_0_5()
        config.Version = 2
    endif
    Debug.Notification("Updated Complete")
EndFunction


Function UpdateTo1_0_2()
    if config.TaskSleepDeny.IsRunning()
        config.TaskSleepDeny.RegisterEvents()
        config.InitArrays()
    Endif
    Debug.Notification("Updated To Lola Extension 1.0.2")
EndFunction

Function UpdateTo1_0_5()
    if config.TaskSleepDeny.IsRunning()
        config.TaskSleepDeny.RegisterEvents()
    Endif
    if config.TaskOutfit.IsRunning()
        config.TaskOutfit.RegisterEvents()
    Endif
    Debug.Notification("Updated To Lola Extension 1.0.5")
EndFunction
