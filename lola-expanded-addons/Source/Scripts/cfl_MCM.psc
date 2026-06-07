Scriptname cfl_MCM extends SKI_ConfigBase

cfl_Config              Property config       Auto
cfl_MCM_MainPage        Property mainpage     Auto
cfl_MCM_TaskOutfitSleep Property outfitpage   Auto
cfl_MCM_MiscTask        Property misctask1    Auto
cfl_json_settings       Property JSonSettings Auto
String Property LEAConfigPath = "../LolaExpandedAddons/Config.json" Auto

bool firstModScanDone = False

int OID_LEA_TransformativeEnabled
int OID_LEA_TransformativeChance
int OID_LEA_TransformativeMaxPotions
int OID_LEA_FertilityEnabled
int OID_LEA_FertilityChance
int OID_LEA_FertilityCooldown
int OID_LEA_FertilityDirect
int OID_LEA_MilkEnabled
int OID_LEA_MilkChance
int OID_LEA_MilkCooldown
int OID_LEA_MilkQuota
int OID_LEA_BodyEnabled
int OID_LEA_BodyChance
int OID_LEA_BodyCooldown
int OID_LEA_BodyMode
int OID_LEA_BodyPotions

String[] LEA_BodyModes

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
    LEA_BodyModes = new string[3]
    LEA_BodyModes[0] = "Bigger"
    LEA_BodyModes[1] = "Smaller"
    LEA_BodyModes[2] = "Random"
EndFunction

string Function LEA_GetBodyModeName()
    int mode = LEA_GetInt("body.mode", 0)
    if mode == 1
        return "Smaller"
    elseif mode == 2
        return "Random"
    endif
    return "Bigger"
EndFunction

Function LEA_Page_Addons()
    LEA_InitMenus()
    AddHeaderOption("Transformative Drug Trick", OPTION_FLAG_NONE)
    OID_LEA_TransformativeEnabled = AddToggleOption("Enabled", LEA_GetBool("transformative.enabled", true), OPTION_FLAG_NONE)
    OID_LEA_TransformativeChance = AddSliderOption("Chance", LEA_GetFloat("transformative.triggerChance", 40.0), "{0}%", OPTION_FLAG_NONE)
    OID_LEA_TransformativeMaxPotions = AddSliderOption("Max potions", LEA_GetFloat("transformative.maxPotionsPerEvent", 1.0), "{0}", OPTION_FLAG_NONE)

    AddHeaderOption("Fertility Drug Trick", OPTION_FLAG_NONE)
    OID_LEA_FertilityEnabled = AddToggleOption("Enabled", LEA_GetBool("fertility.enabled", true), OPTION_FLAG_NONE)
    OID_LEA_FertilityChance = AddSliderOption("Chance", LEA_GetFloat("fertility.triggerChance", 15.0), "{0}%", OPTION_FLAG_NONE)
    OID_LEA_FertilityCooldown = AddSliderOption("Cooldown hours", LEA_GetFloat("fertility.cooldownHours", 72.0), "{0}", OPTION_FLAG_NONE)
    OID_LEA_FertilityDirect = AddToggleOption("Direct pregnancy", LEA_GetBool("fertility.allowDirectPregnancy", false), OPTION_FLAG_NONE)

    AddHeaderOption("Milk Economy", OPTION_FLAG_NONE)
    OID_LEA_MilkEnabled = AddToggleOption("Enabled", LEA_GetBool("milk.enabled", true), OPTION_FLAG_NONE)
    OID_LEA_MilkChance = AddSliderOption("Chance", LEA_GetFloat("milk.dailyChance", 35.0), "{0}%", OPTION_FLAG_NONE)
    OID_LEA_MilkCooldown = AddSliderOption("Cooldown hours", LEA_GetFloat("milk.cooldownHours", 24.0), "{0}", OPTION_FLAG_NONE)
    OID_LEA_MilkQuota = AddSliderOption("Milk quota", LEA_GetFloat("milk.assignmentMilkCount", 2.0), "{0}", OPTION_FLAG_NONE)

    AddHeaderOption("Body Potion Routine", OPTION_FLAG_NONE)
    OID_LEA_BodyEnabled = AddToggleOption("Enabled", LEA_GetBool("body.enabled", true), OPTION_FLAG_NONE)
    OID_LEA_BodyChance = AddSliderOption("Chance", LEA_GetFloat("body.eventChance", 35.0), "{0}%", OPTION_FLAG_NONE)
    OID_LEA_BodyCooldown = AddSliderOption("Cooldown hours", LEA_GetFloat("body.cooldownHours", 8.0), "{0}", OPTION_FLAG_NONE)
    OID_LEA_BodyMode = AddMenuOption("Mode", LEA_GetBodyModeName(), OPTION_FLAG_NONE)
    OID_LEA_BodyPotions = AddSliderOption("Potions per event", LEA_GetFloat("body.potionsPerEvent", 1.0), "{0}", OPTION_FLAG_NONE)
EndFunction

bool Function LEA_OnHighlight(int option)
    if option == OID_LEA_TransformativeChance
        SetInfoText("Chance that Lola's drug trick uses Transformative Elixirs.")
    elseif option == OID_LEA_FertilityDirect
        SetInfoText("Uses Fertility Mode's direct pregnancy spell instead of insemination. Leave off for normal Fertility Mode chance.")
    elseif option == OID_LEA_MilkQuota
        SetInfoText("Number of milk bottles required for owner milk quota assignments.")
    elseif option == OID_LEA_BodyMode
        SetInfoText("Bigger, smaller, or random recurring body potion events.")
    else
        return false
    endif
    return true
EndFunction

bool Function LEA_OnSelect(int option)
    if option == OID_LEA_TransformativeEnabled
        bool value = !LEA_GetBool("transformative.enabled", true)
        LEA_SetBool("transformative.enabled", value)
        SetToggleOptionValue(option, value, false)
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
    elseif option == OID_LEA_BodyEnabled
        bool valueBody = !LEA_GetBool("body.enabled", true)
        LEA_SetBool("body.enabled", valueBody)
        SetToggleOptionValue(option, valueBody, false)
    else
        return false
    endif
    return true
EndFunction

bool Function LEA_OnSliderOpen(int option)
    if option == OID_LEA_TransformativeChance
        LEA_OpenSlider(LEA_GetFloat("transformative.triggerChance", 40.0), 0.0, 100.0, 5.0, 40.0)
    elseif option == OID_LEA_TransformativeMaxPotions
        LEA_OpenSlider(LEA_GetFloat("transformative.maxPotionsPerEvent", 1.0), 1.0, 3.0, 1.0, 1.0)
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
    elseif option == OID_LEA_BodyChance
        LEA_OpenSlider(LEA_GetFloat("body.eventChance", 35.0), 0.0, 100.0, 5.0, 35.0)
    elseif option == OID_LEA_BodyCooldown
        LEA_OpenSlider(LEA_GetFloat("body.cooldownHours", 8.0), 0.0, 240.0, 1.0, 8.0)
    elseif option == OID_LEA_BodyPotions
        LEA_OpenSlider(LEA_GetFloat("body.potionsPerEvent", 1.0), 1.0, 3.0, 1.0, 1.0)
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
    if option == OID_LEA_TransformativeChance
        LEA_SetInt("transformative.triggerChance", value as int)
        SetSliderOptionValue(option, value, "{0}%", false)
    elseif option == OID_LEA_TransformativeMaxPotions
        LEA_SetInt("transformative.maxPotionsPerEvent", value as int)
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
    elseif option == OID_LEA_BodyChance
        LEA_SetInt("body.eventChance", value as int)
        SetSliderOptionValue(option, value, "{0}%", false)
    elseif option == OID_LEA_BodyCooldown
        LEA_SetFloat("body.cooldownHours", value)
        SetSliderOptionValue(option, value, "{0}", false)
    elseif option == OID_LEA_BodyPotions
        LEA_SetInt("body.potionsPerEvent", value as int)
        SetSliderOptionValue(option, value, "{0}", false)
    else
        return false
    endif
    return true
EndFunction

bool Function LEA_OnMenuOpen(int option)
    if option != OID_LEA_BodyMode
        return false
    endif
    LEA_InitMenus()
    SetMenuDialogOptions(LEA_BodyModes)
    SetMenuDialogStartIndex(LEA_GetInt("body.mode", 0))
    SetMenuDialogDefaultIndex(0)
    return true
EndFunction

bool Function LEA_OnMenuAccept(int option, int index)
    if option != OID_LEA_BodyMode
        return false
    endif
    if index < 0
        index = 0
    endif
    if index > 2
        index = 2
    endif
    LEA_SetInt("body.mode", index)
    SetMenuOptionValue(option, LEA_GetBodyModeName(), false)
    return true
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

    If !Config.LolaQuestRunning
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
