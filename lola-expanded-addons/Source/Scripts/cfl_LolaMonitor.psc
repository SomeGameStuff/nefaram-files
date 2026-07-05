Scriptname cfl_LolaMonitor extends Quest

cfl_config Property cfg Auto

String Property LMEConfigPath = "../LolaExpandedAddons/Config.json" Auto
String Property LBPConfigPath = "../LolaExpandedAddons/Config.json" Auto
String Property LCCConfigPath = "../LolaExpandedAddons/Config.json" Auto
String Property LBTConfigPath = "../LolaExpandedAddons/Config.json" Auto
String Property LCLConfigPath = "../LolaExpandedAddons/Config.json" Auto
String Property LCLLoanerPoolPath = "../LolaExpandedAddons/LoanerOutfitPool.json" Auto

Bool Property LME_AssignmentActive = False Auto
Float Property LME_AssignmentStarted = 0.0 Auto
Float Property LME_NextEventTime = 0.0 Auto
Int Property LME_RequiredMilk = 0 Auto
Float Property LME_LastReminderTime = 0.0 Auto

Float Property LBP_NextEventTime = 0.0 Auto
Float Property LCC_NextEventTime = 0.0 Auto
Float Property LBT_NextEventTime = 0.0 Auto
Bool Property LBT_AssignmentActive = False Auto
Float Property LBT_AssignmentStarted = 0.0 Auto
Bool Property LCL_AssignmentActive = False Auto
Int Property LCL_AssignmentType = 0 Auto
Float Property LCL_AssignmentStarted = 0.0 Auto
Float Property LCL_NextBoredomTime = 0.0 Auto
Armor Property LCL_StaleBodyItem = None Auto
Bool Property LCL_LoanerActive = False Auto
Int Property LCL_LoanerSetId = 0 Auto
Float Property LCL_LoanerStarted = 0.0 Auto
Float Property LCL_LoanerLastEnforced = 0.0 Auto

Function LolaStopDetected()
    int handle = ModEvent.Create("cfeLola_LolaStop")
    If (Handle)
        ModEvent.Send(Handle)
    Endif
EndFunction

Function LolaStartDetected()
    int handle = ModEvent.Create("cfeLola_LolaStart")
    If (Handle)
        ModEvent.Send(Handle)
    Endif
EndFunction

Function LolaOwnerChanged()
    int handle = ModEvent.Create("cfeLola_OwnerChanged")
    If (Handle)
        ModEvent.Send(Handle)
    Endif
EndFunction

Function LolaPlaymateChanged()
    int handle = ModEvent.Create("cfeLola_PlaymateChanged")
    If (Handle)
        ModEvent.Send(Handle)
    Endif
EndFunction

Function LolaPlaymateChangedExt(Form who)
    int handle = ModEvent.Create("cfeLola_PlaymateChangedExt")
    If (Handle)
        ModEvent.PushForm(handle, who)
        ModEvent.Send(Handle)
    Endif
EndFunction

Event OnInit()
    Utility.Wait(60)
    SetReferences()
    RegisterEvents()
    cfg.Log("Lola Monitor Stated")
    If IsSubmissiveLolaRunning()
        LolaStartDetected()
    EndIf
    LME_StartScheduler()
    LBP_StartScheduler()
    LCC_StartScheduler()
    LBT_StartScheduler()
    LCL_StartScheduler()
    LEA_ShowOwnerLine("I have some new uses for you. When I decide you need changing, you will obey.", LBP_GetBool("body.showNotifications", true) || LME_GetBool("milk.showNotifications", true))
EndEvent

Event OnReloadReferences()
    cfg.Log("lola_Monitor: Reference Reload")
    SetReferences()
    ResetModEvents()
    LME_StartScheduler()
    LBP_StartScheduler()
    LCC_StartScheduler()
    LBT_StartScheduler()
    LCL_StartScheduler()
    LEA_ShowOwnerLine("I have some new uses for you. When I decide you need changing, you will obey.", LBP_GetBool("body.showNotifications", true) || LME_GetBool("milk.showNotifications", true))
EndEvent

Event OnSLTR_Exit(String eventName, Form ownerActor, float score, float daysEnslaved)
    LolaStopDetected()
    LME_StopScheduler()
    LBP_StopScheduler()
    LCC_StopScheduler()
    LBT_StopScheduler()
    LCL_StopScheduler()
EndEvent

Event OnSLTR_Start(string eventName, string argStr, float argNum, form sender)
    LolaStartDetected()
    LME_StartScheduler()
    LBP_StartScheduler()
    LCC_StartScheduler()
    LBT_StartScheduler()
    LCL_StartScheduler()
EndEvent

Event OnSLTR_OwnerChange(string eventName, string argStr, float argNum, form sender)
    LolaOwnerChanged()
    LME_StartScheduler()
    LBP_StartScheduler()
    LCC_StartScheduler()
    LBT_StartScheduler()
    LCL_StartScheduler()
EndEvent

Event OnSLTR_PlaymateChange(string eventName, string argStr, float argNum, form sender)
    LolaPlaymateChanged()
EndEvent

Event OnUpdateGameTime()
    LME_Tick()
    LBP_Tick()
    LCC_Tick()
    LBT_Tick()
    LCL_Tick()
EndEvent

Function SetReferences()
    cfg = cfl_config.GetConfig()
EndFunction

Function Init()
    SetReferences()
    ResetModEvents()
    if IsSubmissiveLolaRunning()
        LolaStartDetected()
    endif
    LME_StartScheduler()
    LBP_StartScheduler()
    LCC_StartScheduler()
    LBT_StartScheduler()
    LCL_StartScheduler()
EndFunction

Function LEA_ShowOwnerLine(string lineText, bool showLine = true)
    if !showLine || lineText == ""
        return
    endif
    Debug.Notification("Owner: \"" + lineText + "\"")
EndFunction

Function RegisterEvents()
    cfg.Log("Register Events for Lola Monitor")
    RegisterForModEvent("cfeLola_TechReloadReferences", "OnReloadReferences")
    RegisterForModEvent("SLTR Exit", "OnSLTR_Exit")
    RegisterForModEvent("SLTR Start", "OnSLTR_Start")
    RegisterForModEvent("SLTR_OwnerChanged", "OnSLTR_OwnerChange")
    RegisterForModEvent("SLTR_PlaymateChanged", "OnSLTR_PlaymateChange")
EndFunction

Function UnregisterEvents()
    UnregisterForModEvent("cfeLola_TechReloadReferences")
    UnregisterForModEvent("SLTR Exit")
    UnRegisterForModEvent("SLTR Start")
    UnRegisterForModEvent("SLTR_OwnerChanged")
    UnRegisterForModEvent("SLTR_PlaymateChanged")
EndFunction

Function ResetModEvents()
    UnregisterEvents()
    RegisterEvents()
    If IsSubmissiveLolaRunning()
        LolaStartDetected()
    EndIf
EndFunction

Bool Function IsSubmissiveLolaRunning()
    If cfg != None && cfg.LolaQuestRunning
        return True
    EndIf

    Quest lolaQuest = Quest.GetQuest("vkjMQ")
    return lolaQuest != None && lolaQuest.IsRunning()
EndFunction

int Function LME_GetInt(string keyName, int defaultValue)
    return JsonUtil.GetIntValue(LMEConfigPath, keyName, defaultValue)
EndFunction

float Function LME_GetFloat(string keyName, float defaultValue)
    return JsonUtil.GetFloatValue(LMEConfigPath, keyName, defaultValue)
EndFunction

bool Function LME_GetBool(string keyName, bool defaultValue)
    int fallback = 0
    if defaultValue
        fallback = 1
    endif
    return JsonUtil.GetIntValue(LMEConfigPath, keyName, fallback) != 0
EndFunction

int Function LCC_GetInt(string keyName, int defaultValue)
    return JsonUtil.GetIntValue(LCCConfigPath, keyName, defaultValue)
EndFunction

float Function LCC_GetFloat(string keyName, float defaultValue)
    return JsonUtil.GetFloatValue(LCCConfigPath, keyName, defaultValue)
EndFunction

bool Function LCC_GetBool(string keyName, bool defaultValue)
    int fallback = 0
    if defaultValue
        fallback = 1
    endif
    return JsonUtil.GetIntValue(LCCConfigPath, keyName, fallback) != 0
EndFunction

int Function LBT_GetInt(string keyName, int defaultValue)
    return JsonUtil.GetIntValue(LBTConfigPath, keyName, defaultValue)
EndFunction

float Function LBT_GetFloat(string keyName, float defaultValue)
    return JsonUtil.GetFloatValue(LBTConfigPath, keyName, defaultValue)
EndFunction

bool Function LBT_GetBool(string keyName, bool defaultValue)
    int fallback = 0
    if defaultValue
        fallback = 1
    endif
    return JsonUtil.GetIntValue(LBTConfigPath, keyName, fallback) != 0
EndFunction

int Function LCL_GetInt(string keyName, int defaultValue)
    return JsonUtil.GetIntValue(LCLConfigPath, keyName, defaultValue)
EndFunction

float Function LCL_GetFloat(string keyName, float defaultValue)
    return JsonUtil.GetFloatValue(LCLConfigPath, keyName, defaultValue)
EndFunction

bool Function LCL_GetBool(string keyName, bool defaultValue)
    int fallback = 0
    if defaultValue
        fallback = 1
    endif
    return JsonUtil.GetIntValue(LCLConfigPath, keyName, fallback) != 0
EndFunction

Function LCL_StartScheduler()
    if !LCL_GetBool("clothes.enabled", true)
        return
    endif
    if !LCL_IsReady()
        return
    endif
    if LCL_NextBoredomTime <= 0.0
        LCL_NextBoredomTime = Utility.GetCurrentGameTime() + LCL_GetFloat("clothes.initialDelayHours", 4.0) / 24.0
    endif
    RegisterForSingleUpdateGameTime(LCL_GetFloat("clothes.pollHours", 0.5))
EndFunction

Function LCL_StopScheduler()
    LCL_AssignmentActive = False
    LCL_AssignmentType = 0
    LCL_AssignmentStarted = 0.0
    LCL_NextBoredomTime = 0.0
    LCL_StaleBodyItem = None
EndFunction

bool Function LCL_IsReady()
    if cfg == None
        return false
    endif
    if !cfg.cflLolaActive
        return false
    endif
    if cfg.Owner == None || cfg.Player == None || cfg.lola == None
        return false
    endif
    return true
EndFunction

Function LCL_Tick()
    if !LCL_GetBool("clothes.enabled", true)
        return
    endif
    if !LCL_IsReady()
        RegisterForSingleUpdateGameTime(LCL_GetFloat("clothes.pollHours", 0.5))
        return
    endif

    if LCL_LoanerActive
        LCL_CheckLoaner()
    endif

    if LCL_AssignmentActive
        LCL_CheckAssignment()
        RegisterForSingleUpdateGameTime(LCL_GetFloat("clothes.pollHours", 0.5))
        return
    endif

    if LCL_GetBool("clothes.townRuleEnabled", true) && LCL_IsInTown() && !LCL_ShouldSkipCheck()
        if LCL_IsBodyBlockedByDevice()
            RegisterForSingleUpdateGameTime(LCL_GetFloat("clothes.pollHours", 0.5))
            return
        endif
        if !LCL_IsClothingCompliant()
            LCL_StartTownAssignment()
            RegisterForSingleUpdateGameTime(LCL_GetFloat("clothes.pollHours", 0.5))
            return
        endif
    endif

    float now = Utility.GetCurrentGameTime()
    if LCL_GetBool("clothes.boredomEnabled", true) && now >= LCL_NextBoredomTime && !LCL_ShouldSkipCheck()
        LCL_NextBoredomTime = now + LCL_GetFloat("clothes.boredomCooldownHours", 72.0) / 24.0
        int chance = LCL_GetInt("clothes.boredomChance", 20)
        if chance >= 100 || (chance > 0 && Utility.RandomInt(1, 100) <= chance)
            LCL_TryStartBoredomAssignment()
        endif
    endif

    RegisterForSingleUpdateGameTime(LCL_GetFloat("clothes.pollHours", 0.5))
EndFunction

bool Function LCL_ShouldSkipCheck()
    Actor playerRef = cfg.Player
    Actor ownerRef = cfg.Owner
    if playerRef == None || ownerRef == None
        return true
    endif
    if cfg.lola.SuspendAll || cfg.lola.BlockEvents
        return true
    endif
    if playerRef.IsInCombat() || playerRef.IsOnMount()
        return true
    endif
    if playerRef.GetDistance(ownerRef) > LCL_GetFloat("clothes.ownerDistance", 700.0)
        return true
    endif
    return false
EndFunction

bool Function LCL_IsInTown()
    vkjmq lolaMain = cfg.lola
    if lolaMain != None
        return lolaMain.IsInTown()
    endif
    return false
EndFunction

Armor Function LCL_GetBodyItem()
    if cfg == None || cfg.Player == None
        return None
    endif
    return cfg.Player.GetWornForm(0x00000004) as Armor
EndFunction

bool Function LCL_IsBodyBlockedByDevice()
    Armor bodyItem = LCL_GetBodyItem()
    if bodyItem == None || cfg == None || cfg.dd == None
        return false
    endif
    return bodyItem.HasKeyword(cfg.dd.zad_Lockable) || bodyItem.HasKeyword(cfg.dd.zad_DeviousPlug)
EndFunction

bool Function LCL_IsClothingCompliant()
    Actor playerRef = cfg.Player
    Armor bodyItem = LCL_GetBodyItem()
    if playerRef == None || bodyItem == None || cfg.TaskOutfit == None
        return false
    endif
    if LCL_IsBodyBlockedByDevice()
        return true
    endif
    if !bodyItem.HasKeyword(cfg.TaskOutfit.ArmorClothing)
        return false
    endif
    if bodyItem.HasKeyword(cfg.TaskOutfit.ArmorHeavy) || bodyItem.HasKeyword(cfg.TaskOutfit.ArmorLight)
        return false
    endif
    if LCL_GetBool("clothes.strictArmorSlots", false)
        if playerRef.WornHasKeyword(cfg.TaskOutfit.ArmorHeavy) || playerRef.WornHasKeyword(cfg.TaskOutfit.ArmorLight)
            return false
        endif
    endif
    return true
EndFunction

Function LCL_StartTownAssignment()
    LCL_AssignmentActive = True
    LCL_AssignmentType = 1
    LCL_AssignmentStarted = Utility.GetCurrentGameTime()
    LCL_StaleBodyItem = None
    if LCL_GetBool("clothes.showNotifications", true)
        Debug.Notification("Your owner orders you to wear proper clothes while in town.")
    endif
    LCL_TryStartLoaner()
    if !LCL_LoanerActive
        LCL_TryAutoEquipTownOutfit()
    endif
EndFunction

Function LCL_TryStartBoredomAssignment()
    if !LCL_IsClothingCompliant()
        return
    endif

    Armor bodyItem = LCL_GetBodyItem()
    if bodyItem == None
        return
    endif

    LCL_AssignmentActive = True
    LCL_AssignmentType = 2
    LCL_AssignmentStarted = Utility.GetCurrentGameTime()
    LCL_StaleBodyItem = bodyItem
    if LCL_GetBool("clothes.showNotifications", true)
        Debug.Notification("Your owner is bored of your clothes and orders you to change.")
    endif
    LCL_TryStartLoaner()
    if !LCL_LoanerActive
        LCL_TryAutoEquipTownOutfit()
    endif
EndFunction

Function LCL_TryAutoEquipTownOutfit()
    if !LCL_GetBool("clothes.autoEquipTownOutfit", false)
        return
    endif
    if cfg == None || cfg.TaskOutfit == None || !cfg.TaskOutfit.IsRunning()
        return
    endif
    cfg.TaskOutfit.RequestNewOutfit()
EndFunction

Function LCL_TryStartLoaner()
    if !LCL_GetBool("clothes.loanerEnabled", true)
        return
    endif
    if LCL_LoanerActive
        return
    endif
    int chance = LCL_GetInt("clothes.loanerChance", 45)
    if chance < 1
        return
    endif
    if chance < 100 && Utility.RandomInt(1, 100) > chance
        return
    endif

    int setId = LCL_PickLoanerSet()
    if setId <= 0
        return
    endif
    Form[] loanerForms = JsonUtil.FormListToArray(LCLLoanerPoolPath, setId as string)
    if loanerForms.Length < 1
        return
    endif

    Actor playerRef = cfg.Player
    if playerRef == None
        return
    endif
    int i = 0
    while i < loanerForms.Length
        Armor item = loanerForms[i] as Armor
        if item != None
            if playerRef.GetItemCount(item) < 1
                playerRef.AddItem(item, 1, True)
            endif
            playerRef.EquipItem(item, false, true)
        endif
        i += 1
    endwhile

    LCL_LoanerActive = True
    LCL_LoanerSetId = setId
    LCL_LoanerStarted = Utility.GetCurrentGameTime()
    LCL_LoanerLastEnforced = LCL_LoanerStarted

    if LCL_GetBool("clothes.showNotifications", true)
        Debug.Notification("Your owner gives you " + JsonUtil.GetStringValue(LCLLoanerPoolPath, setId as string, "loaned clothes") + " and expects you to wear it.")
    endif
EndFunction

int Function LCL_PickLoanerSet()
    int count = JsonUtil.IntListCount(LCLLoanerPoolPath, "ids")
    if count <= 0
        return 0
    endif

    int attempts = 0
    while attempts < 30
        int index = Utility.RandomInt(0, count - 1)
        int setId = JsonUtil.IntListGet(LCLLoanerPoolPath, "ids", index)
        if LCL_LoanerSetAllowed(setId) && JsonUtil.FormListCount(LCLLoanerPoolPath, setId as string) > 0
            return setId
        endif
        attempts += 1
    endwhile
    return JsonUtil.IntListGet(LCLLoanerPoolPath, "ids", Utility.RandomInt(0, count - 1))
EndFunction

bool Function LCL_LoanerSetAllowed(int setId)
    string tags = JsonUtil.GetStringValue(LCLLoanerPoolPath, (setId as string) + ".tags", "")
    if !LCL_GetBool("clothes.loanerIncludeLingerie", false)
        if StringUtil.Find(tags, "lingerie") >= 0 || StringUtil.Find(tags, "humiliating") >= 0
            return false
        endif
    endif
    return true
EndFunction

Function LCL_CheckLoaner()
    if !LCL_LoanerActive || LCL_LoanerSetId <= 0
        return
    endif
    float now = Utility.GetCurrentGameTime()
    float requiredDays = LCL_GetFloat("clothes.loanerMinWearDays", 2.0)
    if requiredDays < 0.1
        requiredDays = 0.1
    endif

    if now < LCL_LoanerStarted + requiredDays
        if !LCL_PlayerWearsLoanerBody()
            float enforceDays = LCL_GetFloat("clothes.changeDeadlineHours", 2.0) / 24.0
            if now > LCL_LoanerLastEnforced + enforceDays
                LCL_LoanerLastEnforced = now
                if LCL_GetBool("clothes.showNotifications", true)
                    Debug.Notification("Your owner notices you are not wearing the clothes you were given.")
                endif
                if LCL_GetBool("clothes.punishOnFail", true)
                    cfg.lola.PunishMinimal()
                endif
            endif
        endif
        return
    endif

    int recallChance = LCL_GetInt("clothes.loanerRecallChance", 70)
    if recallChance >= 100 || (recallChance > 0 && Utility.RandomInt(1, 100) <= recallChance)
        LCL_RecallLoaner()
    endif
EndFunction

bool Function LCL_PlayerWearsLoanerBody()
    Actor playerRef = cfg.Player
    if playerRef == None
        return false
    endif
    Armor bodyItem = LCL_GetBodyItem()
    if bodyItem == None
        return false
    endif
    Form[] loanerForms = JsonUtil.FormListToArray(LCLLoanerPoolPath, LCL_LoanerSetId as string)
    int i = 0
    while i < loanerForms.Length
        Armor item = loanerForms[i] as Armor
        if item != None && Math.LogicalAnd(item.GetSlotMask(), 0x00000004) != 0 && bodyItem == item
            return true
        endif
        i += 1
    endwhile
    return false
EndFunction

Function LCL_RecallLoaner()
    Actor playerRef = cfg.Player
    if playerRef == None
        return
    endif
    Form[] loanerForms = JsonUtil.FormListToArray(LCLLoanerPoolPath, LCL_LoanerSetId as string)
    int missing = 0
    int i = 0
    while i < loanerForms.Length
        Armor item = loanerForms[i] as Armor
        if item != None
            if playerRef.GetItemCount(item) > 0
                playerRef.UnequipItem(item, abSilent = True)
                playerRef.RemoveItem(item, 1, True, cfg.Owner)
            else
                missing += 1
            endif
        endif
        i += 1
    endwhile

    if LCL_GetBool("clothes.showNotifications", true)
        if missing > 0
            Debug.Notification("Your owner asks for the loaned clothes back and notices pieces are missing.")
        else
            Debug.Notification("Your owner takes back the clothes they loaned you.")
        endif
    endif
    if missing > 0 && LCL_GetBool("clothes.loanerPunishMissing", true)
        cfg.lola.PunishMinimal()
    endif

    LCL_ClearLoaner()
EndFunction

Function LCL_ClearLoaner()
    LCL_LoanerActive = False
    LCL_LoanerSetId = 0
    LCL_LoanerStarted = 0.0
    LCL_LoanerLastEnforced = 0.0
EndFunction

Function LCL_CheckAssignment()
    if LCL_ShouldSkipCheck()
        return
    endif

    if LCL_IsBodyBlockedByDevice()
        LCL_ClearAssignment()
        return
    endif

    if LCL_AssignmentType == 1
        if !LCL_IsInTown() || LCL_IsClothingCompliant()
            if LCL_GetBool("clothes.showNotifications", true)
                Debug.Notification("Your owner accepts your town clothes.")
            endif
            LCL_ClearAssignment()
            return
        endif
    elseif LCL_AssignmentType == 2
        if LCL_IsClothingCompliant() && LCL_GetBodyItem() != LCL_StaleBodyItem
            if LCL_GetBool("clothes.showNotifications", true)
                Debug.Notification("Your owner accepts your change of clothes.")
            endif
            LCL_ClearAssignment()
            return
        endif
    endif

    float timeoutDays = LCL_GetFloat("clothes.changeDeadlineHours", 2.0) / 24.0
    if Utility.GetCurrentGameTime() > LCL_AssignmentStarted + timeoutDays
        if LCL_GetBool("clothes.showNotifications", true)
            Debug.Notification("You failed your owner's clothing order.")
        endif
        if LCL_GetBool("clothes.punishOnFail", true)
            cfg.lola.PunishMinimal()
        endif
        LCL_AssignmentStarted = Utility.GetCurrentGameTime()
    endif
EndFunction

Function LCL_ClearAssignment()
    LCL_AssignmentActive = False
    LCL_AssignmentType = 0
    LCL_AssignmentStarted = 0.0
    LCL_StaleBodyItem = None
EndFunction

Function LBT_StartScheduler()
    if !LBT_GetBool("bath.enabled", true)
        return
    endif
    if !LBT_IsReady()
        return
    endif
    if LBT_NextEventTime <= 0.0
        LBT_NextEventTime = Utility.GetCurrentGameTime() + LBT_GetFloat("bath.initialDelayHours", 8.0) / 24.0
    endif
    RegisterForSingleUpdateGameTime(LBT_GetFloat("bath.pollHours", 1.0))
EndFunction

Function LBT_StopScheduler()
    LBT_AssignmentActive = False
    LBT_NextEventTime = 0.0
EndFunction

bool Function LBT_IsReady()
    if cfg == None
        return false
    endif
    if !cfg.cflLolaActive
        return false
    endif
    if cfg.Owner == None || cfg.Player == None || cfg.lola == None
        return false
    endif
    return true
EndFunction

Function LBT_Tick()
    if !LBT_GetBool("bath.enabled", true)
        return
    endif
    if !LBT_IsReady()
        RegisterForSingleUpdateGameTime(LBT_GetFloat("bath.pollHours", 1.0))
        return
    endif

    if LBT_AssignmentActive
        LBT_CheckAssignment()
        RegisterForSingleUpdateGameTime(LBT_GetFloat("bath.pollHours", 1.0))
        return
    endif

    float now = Utility.GetCurrentGameTime()
    if now < LBT_NextEventTime
        RegisterForSingleUpdateGameTime(LBT_GetFloat("bath.pollHours", 1.0))
        return
    endif

    LBT_NextEventTime = now + LBT_GetFloat("bath.cooldownHours", 24.0) / 24.0

    int chance = LBT_GetInt("bath.eventChance", 25)
    if chance >= 100 || (chance > 0 && Utility.RandomInt(1, 100) <= chance)
        LBT_TryStartEvent()
    endif

    RegisterForSingleUpdateGameTime(LBT_GetFloat("bath.pollHours", 1.0))
EndFunction

Function LBT_TryStartEvent()
    if !LBT_PlayerNeedsCleaning()
        return
    endif
    if LBT_GetBool("bath.requireTown", true) && !LBT_IsInTown()
        return
    endif

    Actor playerRef = cfg.Player
    Actor ownerRef = cfg.Owner
    if playerRef == None || ownerRef == None
        return
    endif
    if playerRef.IsInCombat() || playerRef.IsOnMount()
        return
    endif

    if LBT_CanUseBathingInSkyrim() && playerRef.GetDistance(ownerRef) <= LBT_GetFloat("bath.ownerBathDistance", 500.0)
        int ownerChance = LBT_GetInt("bath.ownerBathChance", 35)
        if ownerChance >= 100 || (ownerChance > 0 && Utility.RandomInt(1, 100) <= ownerChance)
            LBT_OwnerBathesPlayer()
            return
        endif
    endif

    LBT_StartCleanYourselfAssignment()
EndFunction

Function LBT_OwnerBathesPlayer()
    if LBT_GetBool("bath.showNotifications", true)
        Debug.Notification("Your owner decides you are too filthy and washes you.")
    endif
    LBT_SendWashEvent()
EndFunction

Function LBT_StartCleanYourselfAssignment()
    LBT_AssignmentActive = True
    LBT_AssignmentStarted = Utility.GetCurrentGameTime()
    if LBT_GetBool("bath.showNotifications", true)
        Debug.Notification("Your owner orders you to clean yourself within the hour.")
    endif
EndFunction

Function LBT_CheckAssignment()
    if !LBT_PlayerNeedsCleaning()
        LBT_AssignmentActive = False
        if LBT_GetBool("bath.showNotifications", true)
            Debug.Notification("Your owner accepts that you cleaned yourself.")
        endif
        return
    endif

    float timeoutDays = LBT_GetFloat("bath.assignmentTimeoutHours", 1.0) / 24.0
    if Utility.GetCurrentGameTime() > LBT_AssignmentStarted + timeoutDays
        LBT_AssignmentActive = False
        if LBT_GetBool("bath.showNotifications", true)
            Debug.Notification("You failed to clean yourself before your owner's deadline.")
        endif
        if LBT_GetBool("bath.punishOnFail", true)
            cfg.lola.PunishMinimal()
        endif
    endif
EndFunction

bool Function LBT_PlayerNeedsCleaning()
    return LBT_GetDirtStage(cfg.Player) >= LBT_GetInt("bath.dirtMinStage", 3) || LBT_GetCumCount(cfg.Player) >= LBT_GetInt("bath.cumThreshold", 2)
EndFunction

int Function LBT_GetCumCount(Actor who)
    if who == None
        return 0
    endif
    return StorageUtil.GetIntValue(who, "SCO_CumOral", 0) + StorageUtil.GetIntValue(who, "SCO_CumAnal", 0) + StorageUtil.GetIntValue(who, "SCO_CumVaginal", 0)
EndFunction

int Function LBT_GetDirtStage(Actor who)
    if who == None
        return 0
    endif
    if LBT_HasEffect(who, 0x000083B, "Dirt and Blood - Dynamic Visuals.esp")
        return 5
    endif
    if LBT_HasEffect(who, 0x0000E55E, "Bathing in Skyrim - Main.esp") || LBT_HasEffect(who, 0x00000029, "Bathing in Skyrim.esp") || LBT_HasEffect(who, 0x0000080F, "Dirt and Blood - Dynamic Visuals.esp") || LBT_HasEffect(who, 0x001564EE, "Keep It Clean.esp")
        return 4
    endif
    if LBT_HasEffect(who, 0x0000E55D, "Bathing in Skyrim - Main.esp") || LBT_HasEffect(who, 0x00000028, "Bathing in Skyrim.esp") || LBT_HasEffect(who, 0x0000080E, "Dirt and Blood - Dynamic Visuals.esp") || LBT_HasEffect(who, 0x000FBDB6, "Keep It Clean.esp")
        return 3
    endif
    if LBT_HasEffect(who, 0x0000E55C, "Bathing in Skyrim - Main.esp") || LBT_HasEffect(who, 0x00000027, "Bathing in Skyrim.esp") || LBT_HasEffect(who, 0x0000080D, "Dirt and Blood - Dynamic Visuals.esp") || LBT_HasEffect(who, 0x000FBDBA, "Keep It Clean.esp")
        return 2
    endif
    return 0
EndFunction

bool Function LBT_HasEffect(Actor who, int formId, string pluginName)
    MagicEffect effectRef = Game.GetFormFromFile(formId, pluginName) as MagicEffect
    return effectRef != None && who.HasMagicEffect(effectRef)
EndFunction

bool Function LBT_IsInTown()
    vkjmq lolaMain = cfg.lola
    if lolaMain != None
        return lolaMain.IsInTown()
    endif
    return false
EndFunction

bool Function LBT_CanUseBathingInSkyrim()
    return Game.GetModByName("Bathing in Skyrim - Main.esp") != 255 || Game.GetModByName("Bathing in Skyrim.esp") != 255
EndFunction

Function LBT_SendWashEvent()
    int washActor = ModEvent.Create("BiS_WashActor")
    if washActor
        ModEvent.PushForm(washActor, cfg.Player as Form)
        ModEvent.PushBool(washActor, false)
        ModEvent.PushBool(washActor, true)
        ModEvent.PushBool(washActor, true)
        ModEvent.Send(washActor)
    endif
EndFunction

Function LME_StartScheduler()
    if !LME_GetBool("milk.enabled", true)
        return
    endif
    if !LME_IsReady()
        return
    endif
    if LME_NextEventTime <= 0.0
        LME_NextEventTime = Utility.GetCurrentGameTime() + LME_GetFloat("milk.initialDelayHours", 4.0) / 24.0
    endif
    RegisterForSingleUpdateGameTime(LME_GetFloat("milk.pollHours", 1.0))
EndFunction

Function LME_StopScheduler()
    UnregisterForUpdateGameTime()
    LME_AssignmentActive = False
    LME_LastReminderTime = 0.0
EndFunction

Function LCC_StartScheduler()
    if !LCC_GetBool("collar.enabled", true)
        return
    endif
    if !LCC_IsReady()
        return
    endif
    if LCC_NextEventTime <= 0.0
        LCC_NextEventTime = Utility.GetCurrentGameTime() + LCC_GetFloat("collar.initialDelayHours", 12.0) / 24.0
    endif
    RegisterForSingleUpdateGameTime(LCC_GetFloat("collar.pollHours", 1.0))
EndFunction

Function LCC_StopScheduler()
    UnregisterForUpdateGameTime()
EndFunction

bool Function LCC_IsReady()
    if cfg == None
        return false
    endif
    if !cfg.cflLolaActive
        return false
    endif
    if cfg.Owner == None || cfg.Player == None || cfg.lola == None
        return false
    endif
    return true
EndFunction

Function LCC_Tick()
    if !LCC_GetBool("collar.enabled", true)
        return
    endif
    if !LCC_IsReady()
        RegisterForSingleUpdateGameTime(LCC_GetFloat("collar.pollHours", 1.0))
        return
    endif

    float now = Utility.GetCurrentGameTime()
    if now < LCC_NextEventTime
        RegisterForSingleUpdateGameTime(LCC_GetFloat("collar.pollHours", 1.0))
        return
    endif

    LCC_NextEventTime = now + LCC_GetFloat("collar.cooldownHours", 72.0) / 24.0

    int chance = LCC_GetInt("collar.eventChance", 20)
    if chance >= 100 || (chance > 0 && Utility.RandomInt(1, 100) <= chance)
        LCC_TrySwapCollar()
    endif

    RegisterForSingleUpdateGameTime(LCC_GetFloat("collar.pollHours", 1.0))
EndFunction

Function LCC_TrySwapCollar()
    Actor playerRef = cfg.Player
    Actor ownerRef = cfg.Owner
    if playerRef == None || ownerRef == None
        return
    endif
    if playerRef.IsInCombat() || playerRef.IsOnMount()
        return
    endif
    if playerRef.GetDistance(ownerRef) > LCC_GetFloat("collar.ownerDistance", 500.0)
        return
    endif

    vkjDeviceControl devControl = (cfg.lola as Quest) as vkjDeviceControl
    if devControl == None || devControl.zlib == None
        return
    endif

    Armor currentCollar = playerRef.GetWornForm(0x00008000) as Armor
    if currentCollar != None && (currentCollar.HasKeyword(devControl.zlib.zad_QuestItem) || currentCollar.HasKeyword(devControl.zlib.zad_BlockGeneric))
        if LCC_GetBool("collar.showNotifications", true)
            Debug.Notification("Your owner considers replacing your collar, but the current one cannot be removed.")
        endif
        return
    endif

    if LCC_GetBool("collar.showNotifications", true)
        Debug.Notification("Your owner says they are tired of your collar and locks on a different one.")
    endif

    devControl.Device = currentCollar
    devControl.Swapout()
EndFunction

bool Function LME_IsReady()
    if cfg == None
        return false
    endif
    if !cfg.cflLolaActive
        return false
    endif
    if cfg.Owner == None || cfg.Player == None
        return false
    endif
    if Quest.GetQuest("MME_MilkQUEST") == None
        return false
    endif
    if Game.GetFormFromFile(0x0343F2, "MilkModNEW.esp") == None
        return false
    endif
    return true
EndFunction

Function LME_Tick()
    if !LME_GetBool("milk.enabled", true)
        return
    endif
    if !LME_IsReady()
        RegisterForSingleUpdateGameTime(LME_GetFloat("milk.pollHours", 1.0))
        return
    endif

    if LME_AssignmentActive
        LME_CheckAssignment()
    else
        LME_TryStartEvent()
    endif

    RegisterForSingleUpdateGameTime(LME_GetFloat("milk.pollHours", 1.0))
EndFunction

Function LME_TryStartEvent()
    float now = Utility.GetCurrentGameTime()
    if now < LME_NextEventTime
        return
    endif

    float cooldownDays = LME_GetFloat("milk.cooldownHours", 24.0) / 24.0
    LME_NextEventTime = now + cooldownDays

    int chance = LME_GetInt("milk.dailyChance", 35)
    if chance < 1
        return
    endif
    if chance < 100 && Utility.RandomInt(1, 100) > chance
        return
    endif

    bool allowDose = LME_GetBool("milk.allowLactacidDose", true)
    bool allowAssignment = LME_GetBool("milk.allowMilkAssignment", true)
    bool allowOwnerMilking = LME_GetBool("milk.allowOwnerMilking", true)

    if allowOwnerMilking && LME_ShouldOwnerMilkPlayer()
        int ownerMilkingChance = LME_GetInt("milk.ownerMilkingChance", 50)
        if ownerMilkingChance >= 100 || Utility.RandomInt(1, 100) <= ownerMilkingChance
            LME_DoOwnerMilking()
            return
        endif
    endif

    if allowDose && allowAssignment
        if Utility.RandomInt(0, 1) == 0
            LME_DoLactacidDose()
        else
            LME_StartMilkAssignment()
        endif
    elseif allowDose
        LME_DoLactacidDose()
    elseif allowAssignment
        LME_StartMilkAssignment()
    endif
EndFunction

bool Function LME_ShouldOwnerMilkPlayer()
    Actor playerRef = cfg.Player
    Actor ownerRef = cfg.Owner
    MilkQUEST milkQ = Quest.GetQuest("MME_MilkQUEST") as MilkQUEST
    if playerRef == None || ownerRef == None || milkQ == None
        return false
    endif
    if playerRef.IsInCombat() || playerRef.IsOnMount()
        return false
    endif
    if playerRef.HasSpell(milkQ.BeingMilkedPassive)
        return false
    endif
    if playerRef.GetDistance(ownerRef) > LME_GetFloat("milk.ownerMilkingDistance", 500.0)
        return false
    endif
    if milkQ.MILKmaid.Find(playerRef) == -1 && milkQ.MILKslave.Find(playerRef) == -1
        return false
    endif

    float milkCurrent = MME_Storage.getMilkCurrent(playerRef)
    float milkMaximum = MME_Storage.getMilkMaximum(playerRef)
    if milkMaximum < 1.0
        milkMaximum = 1.0
    endif

    float threshold = LME_GetFloat("milk.ownerMilkingFullnessThreshold", 0.75)
    if threshold < 0.05
        threshold = 0.05
    elseif threshold > 1.0
        threshold = 1.0
    endif

    return milkCurrent >= 1.0 && milkCurrent >= milkMaximum * threshold
EndFunction

Function LME_DoOwnerMilking()
    LEA_ShowOwnerLine("You are full enough. Come here and let me milk you.", LME_GetBool("milk.showNotifications", true))
    LME_StartMilkingNow()
EndFunction

Function LME_DoLactacidDose()
    Actor playerRef = cfg.Player
    Form lactacid = Game.GetFormFromFile(0x0343F2, "MilkModNEW.esp")
    if lactacid == None || playerRef == None
        return
    endif

    LEA_ShowOwnerLine("Drink this. I expect you to be more productive for me.", LME_GetBool("milk.showNotifications", true))

    Debug.SendAnimationEvent(playerRef, "IdleDrinkPotion")
    playerRef.AddItem(lactacid, 1, True)
    playerRef.EquipItem(lactacid, false, True)
EndFunction

Function LME_StartMilkAssignment()
    Actor playerRef = cfg.Player
    MilkQUEST milkQ = Quest.GetQuest("MME_MilkQUEST") as MilkQUEST
    if playerRef == None || milkQ == None
        return
    endif

    if milkQ.MILKmaid.Find(playerRef) == -1 && milkQ.MILKslave.Find(playerRef) == -1
        milkQ.AssignSlotMaid(playerRef)
    endif

    if LME_GetBool("milk.giveLactacidIfNeeded", true) && MME_Storage.getLactacidCurrent(playerRef) < 1.0
        LME_DoLactacidDose()
    endif

    LME_RequiredMilk = LME_GetInt("milk.assignmentMilkCount", 2)
    int maxCount = LME_GetInt("milk.maxAssignmentMilkCount", 5)
    if LME_RequiredMilk < 1
        LME_RequiredMilk = 1
    endif
    if LME_RequiredMilk > maxCount
        LME_RequiredMilk = maxCount
    endif

    LME_AssignmentActive = True
    LME_AssignmentStarted = Utility.GetCurrentGameTime()
    LME_LastReminderTime = LME_AssignmentStarted

    if LME_GetBool("milk.showNotifications", true)
        int timeoutHours = LME_GetAssignmentTimeoutHours()
        LEA_ShowOwnerLine("You are going to be my milk maid. Bring me " + LME_RequiredMilk + " bottle(s) of your milk within " + timeoutHours + " hours.", true)
        Debug.Notification("Milk quota: 0/" + LME_RequiredMilk + " bottle(s), " + timeoutHours + "h remaining. Return to your owner.")
    endif

    if LME_GetBool("milk.forceStartMilking", false)
        LME_StartMilkingNow()
    endif
EndFunction

Function LME_StartMilkingNow()
    Actor playerRef = cfg.Player
    MilkQUEST milkQ = Quest.GetQuest("MME_MilkQUEST") as MilkQUEST
    if playerRef == None || milkQ == None
        return
    endif
    if playerRef.IsInCombat() || playerRef.IsOnMount()
        return
    endif
    if !playerRef.HasSpell(milkQ.BeingMilkedPassive)
        milkQ.Milking(playerRef, 0, 1, 1)
    endif
EndFunction

Function LME_CheckAssignment()
    Actor playerRef = cfg.Player
    Actor ownerRef = cfg.Owner
    if playerRef == None || ownerRef == None
        return
    endif

    float timeoutDays = LME_GetFloat("milk.assignmentTimeoutHours", 48.0) / 24.0
    float now = Utility.GetCurrentGameTime()
    if now > LME_AssignmentStarted + timeoutDays
        LME_FailMilkAssignment()
        return
    endif

    LME_ShowAssignmentReminder()

    if LME_CanTurnInMilk()
        LME_TurnInMilk()
    elseif playerRef.GetDistance(ownerRef) <= LME_GetFloat("milk.turnInDistance", 500.0) && LME_GetBool("milk.showProgressNotifications", false)
        Debug.Notification(LME_GetAssignmentStatusText())
    endif
EndFunction

Function LME_FailMilkAssignment()
    LME_AssignmentActive = False
    LME_LastReminderTime = 0.0
    LEA_ShowOwnerLine("You missed your milk quota. You are going to learn what happens when you waste my patience.", LME_GetBool("milk.showNotifications", true))
    if LME_GetBool("milk.punishOnFail", true) && cfg != None && cfg.lola != None
        cfg.lola.PunishMinimal()
    endif
EndFunction

bool Function LME_CanTurnInMilk()
    if !LME_AssignmentActive || cfg == None || cfg.Player == None || cfg.Owner == None
        return false
    endif
    if cfg.Player.GetDistance(cfg.Owner) > LME_GetFloat("milk.turnInDistance", 500.0)
        return false
    endif
    return LME_CountMilkItems(cfg.Player) >= LME_RequiredMilk
EndFunction

bool Function LME_TurnInMilk()
    if !LME_CanTurnInMilk()
        return false
    endif
    LME_RemoveMilkItems(cfg.Player, LME_RequiredMilk)
    LME_AssignmentActive = False
    LME_LastReminderTime = 0.0
    LEA_ShowOwnerLine("Good. You can be useful when you remember what you are for.", LME_GetBool("milk.showNotifications", true))
    return true
EndFunction

int Function LME_GetAssignmentTimeoutHours()
    int timeoutHours = LME_GetFloat("milk.assignmentTimeoutHours", 48.0) as int
    if timeoutHours < 1
        timeoutHours = 1
    endif
    return timeoutHours
EndFunction

int Function LME_GetAssignmentHoursRemaining()
    if !LME_AssignmentActive
        return 0
    endif
    float timeoutDays = LME_GetFloat("milk.assignmentTimeoutHours", 48.0) / 24.0
    float endTime = LME_AssignmentStarted + timeoutDays
    float remaining = endTime - Utility.GetCurrentGameTime()
    if remaining <= 0.0
        return 0
    endif
    int hours = (remaining * 24.0) as int
    if hours < 1
        return 1
    endif
    return hours
EndFunction

string Function LME_GetAssignmentStatusText()
    if !LME_GetBool("milk.enabled", true)
        return "Milk Economy disabled"
    endif
    if !LME_IsReady()
        return "Milk Economy missing or waiting"
    endif
    if !LME_AssignmentActive
        return "No active quota"
    endif
    return "Milk quota: " + LME_CountMilkItems(cfg.Player) + "/" + LME_RequiredMilk + ", " + LME_GetAssignmentHoursRemaining() + "h remaining"
EndFunction

string Function LME_GetAssignmentDetailText()
    if !LME_AssignmentActive
        return "No active milk quota.\n\nWhen the owner assigns one, this page will show the required bottles and time remaining."
    endif
    return LME_GetAssignmentStatusText() + "\n\nBring that many milk bottles back to your owner before the timer expires. For now, the bottles turn in automatically when you stand close enough to your owner. You can milk yourself through Milk Mod Economy, or let owner milking start when you are nearby and full enough."
EndFunction

Function LME_ShowAssignmentReminder()
    if !LME_GetBool("milk.showNotifications", true)
        return
    endif
    float reminderDays = LME_GetFloat("milk.assignmentReminderHours", 6.0) / 24.0
    if reminderDays <= 0.0
        return
    endif
    float now = Utility.GetCurrentGameTime()
    if LME_LastReminderTime <= 0.0 || now >= LME_LastReminderTime + reminderDays
        LME_LastReminderTime = now
        Debug.Notification(LME_GetAssignmentStatusText())
    endif
EndFunction

int Function LME_CountMilkItems(Actor who)
    MilkQUEST milkQ = Quest.GetQuest("MME_MilkQUEST") as MilkQUEST
    if milkQ == None || milkQ.MME_Milks == None || who == None
        return 0
    endif

    int total = 0
    int i = 0
    while i < milkQ.MME_Milks.GetSize()
        Form milk = milkQ.MME_Milks.GetAt(i)
        if milk != None
            total += who.GetItemCount(milk)
        endif
        i += 1
    endwhile
    return total
EndFunction

Function LME_RemoveMilkItems(Actor who, int count)
    MilkQUEST milkQ = Quest.GetQuest("MME_MilkQUEST") as MilkQUEST
    if milkQ == None || milkQ.MME_Milks == None || who == None
        return
    endif

    int remaining = count
    int i = 0
    while i < milkQ.MME_Milks.GetSize() && remaining > 0
        Form milk = milkQ.MME_Milks.GetAt(i)
        if milk != None
            int have = who.GetItemCount(milk)
            if have > 0
                int removeCount = have
                if removeCount > remaining
                    removeCount = remaining
                endif
                who.RemoveItem(milk, removeCount, True, cfg.Owner)
                remaining -= removeCount
            endif
        endif
        i += 1
    endwhile
EndFunction

int Function LBP_GetInt(string keyName, int defaultValue)
    return JsonUtil.GetIntValue(LBPConfigPath, keyName, defaultValue)
EndFunction

float Function LBP_GetFloat(string keyName, float defaultValue)
    return JsonUtil.GetFloatValue(LBPConfigPath, keyName, defaultValue)
EndFunction

bool Function LBP_GetBool(string keyName, bool defaultValue)
    int fallback = 0
    if defaultValue
        fallback = 1
    endif
    return JsonUtil.GetIntValue(LBPConfigPath, keyName, fallback) != 0
EndFunction

Function LBP_StartScheduler()
    string blockReason = LBP_GetBlockReason()
    if blockReason != ""
        if cfg != None
            cfg.Log("LEA Body Potion scheduler not started: " + blockReason)
        endif
        return
    endif
    if LBP_NextEventTime <= 0.0
        LBP_NextEventTime = Utility.GetCurrentGameTime() + LBP_GetFloat("body.initialDelayHours", 6.0) / 24.0
    endif
    RegisterForSingleUpdateGameTime(LBP_GetFloat("body.pollHours", 1.0))
    if cfg != None
        cfg.Log("LEA Body Potion scheduler active. Next check in " + (((LBP_NextEventTime - Utility.GetCurrentGameTime()) * 24.0) as int) + "h")
    endif
EndFunction

Function LBP_StopScheduler()
    LBP_NextEventTime = 0.0
EndFunction

bool Function LBP_IsReady()
    return LBP_GetBlockReason() == ""
EndFunction

string Function LBP_GetBlockReason()
    if !LBP_GetBool("body.enabled", true)
        return "body.enabled is off"
    endif
    if cfg == None
        return "config is missing"
    endif
    if !cfg.cflLolaActive
        return "Lola ownership is not active"
    endif
    if cfg.Owner == None || cfg.Player == None
        return "owner or player reference is missing"
    endif
    if Game.GetFormFromFile(0x000806, "TransformativeElixirs.esp") == None
        return "TransformativeElixirs.esp is not loaded"
    endif
    return ""
EndFunction

Function LBP_Tick()
    if !LBP_GetBool("body.enabled", true)
        return
    endif
    if !LBP_IsReady()
        RegisterForSingleUpdateGameTime(LBP_GetFloat("body.pollHours", 1.0))
        return
    endif

    float now = Utility.GetCurrentGameTime()
    if now < LBP_NextEventTime
        RegisterForSingleUpdateGameTime(LBP_GetFloat("body.pollHours", 1.0))
        return
    endif

    LBP_NextEventTime = now + LBP_GetFloat("body.cooldownHours", 8.0) / 24.0

    int chance = LBP_GetInt("body.eventChance", 35)
    if chance < 1
        RegisterForSingleUpdateGameTime(LBP_GetFloat("body.pollHours", 1.0))
        return
    endif
    if chance < 100 && Utility.RandomInt(1, 100) > chance
        RegisterForSingleUpdateGameTime(LBP_GetFloat("body.pollHours", 1.0))
        return
    endif

    LBP_DoPotionEvent()
    RegisterForSingleUpdateGameTime(LBP_GetFloat("body.pollHours", 1.0))
EndFunction

Function LBP_DoPotionEvent()
    Actor playerRef = cfg.Player
    if playerRef == None
        return
    endif

    bool shrink = LBP_GetMoodShrink()

    int count = LBP_GetInt("body.potionsPerEvent", 1)
    int maxCount = LBP_GetInt("body.maxPotionsPerEvent", 2)
    if count < 1
        count = 1
    endif
    if count > maxCount
        count = maxCount
    endif
    if count > 3
        count = 3
    endif

    LBP_SayOwnerIntent(shrink)
    Debug.SendAnimationEvent(playerRef, "IdleDrinkPotion")

    int i = 0
    while i < count
        Form elixir = None
        if shrink
            elixir = LBP_PickSmallerPotion()
        else
            elixir = LBP_PickBiggerPotion()
        endif
        if elixir != None
            playerRef.AddItem(elixir, 1, True)
            playerRef.EquipItem(elixir, false, True)
        endif
        i += 1
    endwhile
EndFunction

bool Function LBP_GetMoodShrink()
    float now = Utility.GetCurrentGameTime()
    float nextMood = JsonUtil.GetFloatValue(LBPConfigPath, "body.nextMoodGameDay", 0.0)
    int currentMood = LBP_GetInt("body.currentMood", -1)

    if currentMood < 0 || now >= nextMood
        currentMood = LBP_PickNewMood()
        JsonUtil.SetIntValue(LBPConfigPath, "body.currentMood", currentMood)

        float moodHours = LBP_GetFloat("body.moodDurationHours", 168.0)
        if moodHours < 1.0
            moodHours = 1.0
        endif
        JsonUtil.SetFloatValue(LBPConfigPath, "body.nextMoodGameDay", now + (moodHours / 24.0))
        JsonUtil.Save(LBPConfigPath)
        LBP_SayNewMood(currentMood == 1)
    endif

    return currentMood == 1
EndFunction

int Function LBP_PickNewMood()
    int policy = LBP_GetInt("body.moodPolicy", 0)
    if policy == 1
        return 0
    elseif policy == 2
        return 1
    elseif policy == 3
        return Utility.RandomInt(0, 1)
    endif

    int sizeOverride = LBP_GetInt("body.sizeOverride", 0)
    if sizeOverride <= -50
        if Utility.RandomInt(1, 100) <= 75
            return 0
        endif
        return 1
    elseif sizeOverride >= 50
        if Utility.RandomInt(1, 100) <= 75
            return 1
        endif
        return 0
    endif

    return Utility.RandomInt(0, 1)
EndFunction

Function LBP_SayNewMood(bool shrink)
    if !LBP_GetBool("body.showNotifications", true)
        return
    endif

    if shrink
        LEA_ShowOwnerLine("I think I want you smaller for a while. Easier to handle.", true)
    else
        LEA_ShowOwnerLine("I think I want you bigger for a while. More of you to admire and use.", true)
    endif
EndFunction

Function LBP_SayOwnerIntent(bool shrink)
    if !LBP_GetBool("body.showNotifications", true)
        return
    endif

    if shrink
        int line = Utility.RandomInt(0, 2)
        if line == 0
            LEA_ShowOwnerLine("You have gotten much too big. We will fix that.", true)
        elseif line == 1
            LEA_ShowOwnerLine("Drink this. I want you reduced.", true)
        else
            LEA_ShowOwnerLine("Smaller will suit you. Easier to manage, easier to keep.", true)
        endif
    else
        int lineBig = Utility.RandomInt(0, 2)
        if lineBig == 0
            LEA_ShowOwnerLine("You should be much bigger for me.", true)
        elseif lineBig == 1
            LEA_ShowOwnerLine("Open your mouth. This should make you grow nicely.", true)
        else
            LEA_ShowOwnerLine("I want your body harder to ignore.", true)
        endif
    endif
EndFunction

Form Function LBP_PickBiggerPotion()
    int pick = Utility.RandomInt(0, 10)
    if pick == 0
        return Game.GetFormFromFile(0x000D62, "TransformativeElixirs.esp")
    elseif pick == 1
        return Game.GetFormFromFile(0x000808, "TransformativeElixirs.esp")
    elseif pick == 2
        return Game.GetFormFromFile(0x00080D, "TransformativeElixirs.esp")
    elseif pick == 3
        return Game.GetFormFromFile(0x00080E, "TransformativeElixirs.esp")
    elseif pick == 4
        return Game.GetFormFromFile(0x00080F, "TransformativeElixirs.esp")
    elseif pick == 5
        return Game.GetFormFromFile(0x000806, "TransformativeElixirs.esp")
    elseif pick == 6
        return Game.GetFormFromFile(0x00081D, "TransformativeElixirs.esp")
    elseif pick == 7
        return Game.GetFormFromFile(0x00081E, "TransformativeElixirs.esp")
    elseif pick == 8
        return Game.GetFormFromFile(0x00081F, "TransformativeElixirs.esp")
    elseif pick == 9
        return Game.GetFormFromFile(0x000807, "TransformativeElixirs.esp")
    endif
    return Game.GetFormFromFile(0x000811, "TransformativeElixirs.esp")
EndFunction

Form Function LBP_PickSmallerPotion()
    int pick = Utility.RandomInt(0, 4)
    if pick == 0
        return Game.GetFormFromFile(0x000D64, "TransformativeElixirs.esp")
    elseif pick == 1
        return Game.GetFormFromFile(0x000804, "TransformativeElixirs.esp")
    elseif pick == 2
        return Game.GetFormFromFile(0x000812, "TransformativeElixirs.esp")
    elseif pick == 3
        return Game.GetFormFromFile(0x000805, "TransformativeElixirs.esp")
    endif
    if LBP_GetBool("body.allowNormalcyReset", false)
        return Game.GetFormFromFile(0x000825, "TransformativeElixirs.esp")
    endif
    return Game.GetFormFromFile(0x000804, "TransformativeElixirs.esp")
EndFunction

