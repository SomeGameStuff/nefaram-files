Scriptname cfl_LolaMonitor extends Quest

cfl_config Property cfg Auto

String Property LMEConfigPath = "../LolaExpandedAddons/Config.json" Auto
String Property LBPConfigPath = "../LolaExpandedAddons/Config.json" Auto
String Property LCCConfigPath = "../LolaExpandedAddons/Config.json" Auto
String Property LBTConfigPath = "../LolaExpandedAddons/Config.json" Auto

Bool Property LME_AssignmentActive = False Auto
Float Property LME_AssignmentStarted = 0.0 Auto
Float Property LME_NextEventTime = 0.0 Auto
Int Property LME_RequiredMilk = 0 Auto

Float Property LBP_NextEventTime = 0.0 Auto
Float Property LCC_NextEventTime = 0.0 Auto
Float Property LBT_NextEventTime = 0.0 Auto
Bool Property LBT_AssignmentActive = False Auto
Float Property LBT_AssignmentStarted = 0.0 Auto

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
    LME_StartScheduler()
    LBP_StartScheduler()
    LCC_StartScheduler()
    LBT_StartScheduler()
EndEvent

Event OnReloadReferences()
    cfg.Log("lola_Monitor: Reference Reload")
    SetReferences()
    ResetModEvents()
    LME_StartScheduler()
    LBP_StartScheduler()
    LCC_StartScheduler()
    LBT_StartScheduler()
EndEvent

Event OnSLTR_Exit(String eventName, Form ownerActor, float score, float daysEnslaved)
    LolaStopDetected()
    LME_StopScheduler()
    LBP_StopScheduler()
    LCC_StopScheduler()
    LBT_StopScheduler()
EndEvent

Event OnSLTR_Start(string eventName, string argStr, float argNum, form sender)
    LolaStartDetected()
    LME_StartScheduler()
    LBP_StartScheduler()
    LCC_StartScheduler()
    LBT_StartScheduler()
EndEvent

Event OnSLTR_OwnerChange(string eventName, string argStr, float argNum, form sender)
    LolaOwnerChanged()
    LME_StartScheduler()
    LBP_StartScheduler()
    LCC_StartScheduler()
    LBT_StartScheduler()
EndEvent

Event OnSLTR_PlaymateChange(string eventName, string argStr, float argNum, form sender)
    LolaPlaymateChanged()
EndEvent

Event OnUpdateGameTime()
    LME_Tick()
    LBP_Tick()
    LCC_Tick()
    LBT_Tick()
EndEvent

Function SetReferences()
    cfg = cfl_config.GetConfig()
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
    if LME_GetBool("milk.showNotifications", true)
        Debug.Notification("Your owner notices how full you are and decides to milk you.")
    endif
    LME_StartMilkingNow()
EndFunction

Function LME_DoLactacidDose()
    Actor playerRef = cfg.Player
    Form lactacid = Game.GetFormFromFile(0x0343F2, "MilkModNEW.esp")
    if lactacid == None || playerRef == None
        return
    endif

    if LME_GetBool("milk.showNotifications", true)
        Debug.Notification("Your owner decides you should be more productive and makes you drink Lactacid.")
    endif

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

    if LME_GetBool("milk.showNotifications", true)
        Debug.Notification("Your owner orders you to bring back " + LME_RequiredMilk + " bottle(s) of your milk.")
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
    if Utility.GetCurrentGameTime() > LME_AssignmentStarted + timeoutDays
        LME_AssignmentActive = False
        if LME_GetBool("milk.showNotifications", true)
            Debug.Notification("You failed to deliver your owner's milk quota in time.")
        endif
        return
    endif

    if playerRef.GetDistance(ownerRef) > LME_GetFloat("milk.turnInDistance", 500.0)
        return
    endif

    if LME_CountMilkItems(playerRef) >= LME_RequiredMilk
        LME_RemoveMilkItems(playerRef, LME_RequiredMilk)
        LME_AssignmentActive = False
        if LME_GetBool("milk.showNotifications", true)
            Debug.Notification("Your owner accepts the milk and seems satisfied with your usefulness.")
        endif
    elseif LME_GetBool("milk.showProgressNotifications", false)
        Debug.Notification("Milk quota: " + LME_CountMilkItems(playerRef) + "/" + LME_RequiredMilk)
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
    if !LBP_GetBool("body.enabled", true)
        return
    endif
    if !LBP_IsReady()
        return
    endif
    if LBP_NextEventTime <= 0.0
        LBP_NextEventTime = Utility.GetCurrentGameTime() + LBP_GetFloat("body.initialDelayHours", 6.0) / 24.0
    endif
    RegisterForSingleUpdateGameTime(LBP_GetFloat("body.pollHours", 1.0))
EndFunction

Function LBP_StopScheduler()
    LBP_NextEventTime = 0.0
EndFunction

bool Function LBP_IsReady()
    if cfg == None
        return false
    endif
    if !cfg.cflLolaActive
        return false
    endif
    if cfg.Owner == None || cfg.Player == None
        return false
    endif
    if Game.GetFormFromFile(0x000806, "TransformativeElixirs.esp") == None
        return false
    endif
    return true
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
        Debug.Notification("Your owner has settled into a mood for making you smaller.")
    else
        Debug.Notification("Your owner has settled into a mood for making you bigger.")
    endif
EndFunction

Function LBP_SayOwnerIntent(bool shrink)
    if !LBP_GetBool("body.showNotifications", true)
        return
    endif

    if shrink
        int line = Utility.RandomInt(0, 2)
        if line == 0
            Debug.Notification("Your owner decides you have gotten much too big.")
        elseif line == 1
            Debug.Notification("Your owner makes you drink something to reduce you.")
        else
            Debug.Notification("Your owner wants you smaller and easier to manage.")
        endif
    else
        int lineBig = Utility.RandomInt(0, 2)
        if lineBig == 0
            Debug.Notification("Your owner decides you should be much bigger.")
        elseif lineBig == 1
            Debug.Notification("Your owner smiles and feeds you a growth elixir.")
        else
            Debug.Notification("Your owner wants your body to become harder to ignore.")
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

