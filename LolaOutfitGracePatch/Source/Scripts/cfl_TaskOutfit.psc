Scriptname cfl_TaskOutfit extends Quest Conditional
; ------------------------------------------------------------------------------
;                                  Properties                                   
; ------------------------------------------------------------------------------

ReferenceAlias Property Alias_Owner Auto
ReferenceAlias Property Alias_T Auto

    ; -------------------------------- Quests ----------------------------------
cfl_config            Property cfg                Auto
cfl_lolaMain          Property cflLola            Auto
cfl_UtilityOutfit     Property utOutfit           Auto
vkjMQ                 Property lola               Auto
Actor Player
Quest                 Property lolaProstitution   Auto
Quest                 Property FitForAJarl        Auto
Quest                 Property DiplomaticImmunity Auto
cfl_TaskOutfitStarter Property OutfitStarter      Auto

    ; ----------------------------- Refs to Lola -------------------------------
MagicEffect EyeCandyEffectExtended
MagicEffect EyeCandyEffect
GlobalVariable Timescale


    ; --------------------------------- Vars -----------------------------------

int    Property AskedForEnding           = 0         Auto Conditional
int    Property OutfitLevel              = 1         Auto
int    Property WarnedForViolation       = 0         Auto

string Property CurrentLocation          = "Capital" Auto
string Property LastLocationOutfitChange = "Never"   Auto

Bool   Property ForceDowngradePunishment = False     Auto
Bool   Property ForceDowngrade           = False     Auto
Bool   Property ForceUpgrade             = False     Auto
Bool   Property ChangeDecided            = false     Auto
Bool   Property AskedForChange           = false     Auto Conditional

Bool   Property ArmorCanBeSlutty         = false     Auto Conditional
Bool   Property ArmorCanBreak            = false     Auto Conditional
Bool   Property ArmorCanBreakPlaymate    = false     Auto Conditional
Bool   Property ArmorBroken              = false     Auto Conditional
Bool   Property ArmorBrokenPlaymate      = false     Auto Conditional
Bool   Property ArmorSlutty              = false     Auto Conditional
Bool   Property HasBrokenArmor           = false     Auto Conditional

cfl_OutfitDegrationTracker Property PlayerTracker Auto
cfl_OutfitDegrationTracker Property PlaymateTracker Auto


Bool   Property PlaymateFirstChange      = True      Auto
Actor  Property LastUsedPlaymate         = None      Auto
Outfit Property PlaymateBaseOutfit                   Auto
Outfit Property Naked                                Auto


Sound Property SoundHeavyArmorBreaking Auto
Sound Property SoundLightArmorBreaking Auto
Sound Property SoundClothesTearing Auto
keyword Property ArmorHeavy Auto
keyword Property ArmorLight Auto
keyword Property ArmorClothing Auto
keyword Property Shield Auto


string Property CurrentFileName
    string function get()
        return CurrentLocation + "_" + OutfitLevel as string
    endFunction
endProperty

Bool Property PlaymateAllow
    Bool function get()
        return (cfg.TaskOutfitAllowPlaymate && cfg.PlaymateAllow && cflLola.PlaymateSameSex)
    endFunction
endproperty


string lastFile = ""
int lastOutfit = -1
float OutfitCorrectStart = 0.0
float lastCheck = 0.0
bool pressedChangeForUndress = True
bool ChangeKeyLastStripped = False
string baselocName = "City"

int Property CurrentOutfit             = -1 Auto
int Property OutfitAdventuring         = -1 Auto
int Property OutfitCapital             = -1 Auto
int Property OutfitSettlement          = -1 Auto
int Property OutfitPlayerHome          = -1 Auto
int Property OutfitInn                 = -1 Auto

int Property PlaymateCurrentOutfit     = -1 Auto
int Property PlaymateOutfitAdventuring = -1 Auto
int Property PlaymateOutfitCapital     = -1 Auto
int Property PlaymateOutfitSettlement  = -1 Auto
int Property PlaymateOutfitPlayerHome  = -1 Auto
int Property PlaymateOutfitInn         = -1 Auto



bool fitq_warning = False

; ------------------------------------------------------------------------------
;                                   Functions                                   
; ------------------------------------------------------------------------------

Function ResetVars()
    lastFile                  = ""
    lastOutfit                = -1

    CurrentOutfit             = -1
    OutfitAdventuring         = -1
    OutfitCapital             = -1
    OutfitSettlement          = -1
    OutfitPlayerHome          = -1
    OutfitInn                 = -1
    OutfitCorrectStart        = 0.0
    lastCheck                 = 0.0

    PlaymateCurrentOutfit     = -1
    PlaymateOutfitAdventuring = -1
    PlaymateOutfitCapital     = -1
    PlaymateOutfitSettlement  = -1
    PlaymateOutfitPlayerHome  = -1
    PlaymateOutfitInn         = -1
Endfunction


Function StartOutfitTask()
    SetReferences()
    cfg.DebugOutput("Start Quest")
    RegisterEvents()
    if !cfg.locationTracker.IsRunning()
        cfg.locationTracker.Start()
    endif
    ResetVars()
    if !utOutfit.DefaultOutfitsSetupCorrectly()
        Debug.MessageBox("ERROR: Outfits are not setup Correctly. Stop Quest now")
        Stop()
    endif

    if (cfg.SubmissionScore < cfg.TaskOutfitLevel1Threshold)
        OutfitLevel = 0
    Else
        OutfitLevel = 1
    endif
    cfg.DebugOutput("Strip Player")
    if !cfg.TaskOutfitManualMode
        cfl_UtilityOutfit.StripActor(Player)
    endif
    cfg.DebugOutput("Call Set Outfit")
    RequestNewOutfitSets()
    If (PlaymateAllow)
        HandlePlaymateDefaultOutfit()
        cfg.DebugOutput("Strip Playmate")
        ; kill the armor
        cfl_UtilityOutfit.StripActor(cfg.Playmate, true)
    EndIf
    cfg.DebugOutput("Equip Outfit At Player")

    EquipOutfit()
    StartManualMode()
    cfg.DebugOutput("Player Done")

    RegisterForSingleUpdate(cfg.TaskOutfitCheckTimeSeconds)
    OutfitCorrectStart = Utility.GetCurrentGameTime()

    RegisterForModEvent("cfeLola_LocationChanged", "OnLolaLocationChange")
    RegisterForModEvent("cfe_LolaStopped", "EndOutfitTask")
    cfg.DebugOutput("StartUp OutfitTask Finished")
    RegisterForKey(cfg.TaskOutfitChangeKey)
    RegisterForModEvent("cfeLola_TechReloadReferences", "OnReloadReferences")
    RegisterForModEvent("cfeLola_PlaymateChanged", "onPlaymateChange")
    RegisterEvents()
    SetObjectiveDisplayed(10, True, True)


    if (cfg.StylishMasterAutoStart && !cfg.cflStylishOwner.IsRunning())
        cfg.Log("Starting Stylish Master")
        bool result = cfg.cflStylishOwner.Start()
    endif

    if cfg.lolaConfig.NudeRule != 7
        string warning = "The Start detected that Nude Rule is not set to Never. \n\n"
        warning += "Keep in Mind that the Nude Rule Armor can clash with the requested Outfit.\n "
        warning += "Staying naked should be fine.\n It is recommended to set NudeRule to "
        warning += "Never if you want to take this Outfit Task to take over full control"

        Debug.MessageBox(warning)
    endif


EndFunction

; ------------------------------------------------------------------------------
;                               Outfit Management                               
; ------------------------------------------------------------------------------

Function SwapOutfit(int oldOutfit)
    utOutfit.RemoveOutfit(Player, CurrentFileName, oldOutfit, true)
    utOutfit.EquipOutfit(Player, currentFileName, CurrentOutfit, False)
EndFunction

Function SwapOutfitPlaymate(int oldOutfit)
    cfl_UtilityOutfit.StripActor(cfg.Playmate, true)
    utOutfit.EquipOutfit(cfg.Playmate, currentFileName, PlaymateCurrentOutfit, False)
EndFunction

Function EquipOutfit()
    cfg.Log("Equip Ouftit id " + CurrentOutfit)
    if !cfg.TaskOutfitManualMode
        utOutfit.EquipOutfit(Player, currentFileName, CurrentOutfit, False)
    endif
    if(PlaymateAllow)
        utOutfit.EquipOutfit(cfg.Playmate, currentFileName, PlaymateCurrentOutfit, False)
    endif
Endfunction

Function StripOutfit(bool destroy=false, bool removeLast=false)
    int id = CurrentOutfit
    string filename = CurrentFileName
    if removeLast
        id = lastOutfit
        filename = lastFile
    endif
    cfg.Log("Undress Clothes id " + id)
    if !cfg.TaskOutfitManualMode
        utOutfit.RemoveOutfit(Player, filename, id, destroy)
    endif
    if(PlaymateAllow)
        cfl_UtilityOutfit.StripActor(cfg.Playmate, true)
    endif
Endfunction

string Function GetFilename(string locationClass)
    return locationClass + "_" + OutfitLevel as string
Endfunction

Function SelectOutfit(string locationClass, bool forceNewOutfit=False)
    if(locationClass == "Capital")
        cfg.DebugOutput("Capital inside")
        if (OutfitCapital == -1 || forceNewOutfit )
            OutfitCapital = utOutfit.GetRandomOutfitID(GetFilename(locationClass))
            PlaymateOutfitCapital = utOutfit.GetRandomOutfitID(GetFilename(locationClass))
            cfg.DebugOutput("Outfit Selected Player: " + OutfitCapital + " in " + locationClass)
            cfg.DebugOutput("Outfit Selected Playmate: " + PlaymateOutfitCapital + " in " + locationClass)
        endif
        CurrentOutfit = OutfitCapital
        PlaymateCurrentOutfit = PlaymateOutfitCapital

    ElseIf (locationClass == "Settlement")
        if (OutfitSettlement ==  -1 || forceNewOutfit)
            OutfitSettlement = utOutfit.GetRandomOutfitID(GetFilename(locationClass))
            PlaymateOutfitSettlement = utOutfit.GetRandomOutfitID(GetFilename(locationClass))
            cfg.DebugOutput("Outfit Selected Player: " + OutfitSettlement + " in " + locationClass)
            cfg.DebugOutput("Outfit Selected Playmate: " + PlaymateOutfitSettlement + " in " + locationClass)
        endif
        CurrentOutfit = OutfitSettlement
        PlaymateCurrentOutfit = PlaymateOutfitSettlement

    ElseIf (locationClass == "Inn")
        if (OutfitInn ==  -1 || forceNewOutfit)
            OutfitInn = utOutfit.GetRandomOutfitID(GetFilename(locationClass))
            PlaymateOutfitInn = utOutfit.GetRandomOutfitID(GetFilename(locationClass))
            cfg.DebugOutput("Outfit Selected Player: " + OutfitInn + " in " + locationClass)
            cfg.DebugOutput("Outfit Selected Playmate: " + PlaymateOutfitInn + " in " + locationClass)
        endif
        CurrentOutfit = OutfitInn
        PlaymateCurrentOutfit = PlaymateOutfitInn

    ElseIf (locationClass == "PlayerHome")
        if (OutfitPlayerHome ==  -1 || forceNewOutfit)
            OutfitPlayerHome = utOutfit.GetRandomOutfitID(GetFilename(locationClass))
            PlaymateOutfitPlayerHome = utOutfit.GetRandomOutfitID(GetFilename(locationClass))
            cfg.DebugOutput("Outfit Selected Player: " + OutfitPlayerHome + " in " + locationClass)
            cfg.DebugOutput("Outfit Selected Playmate: " + PlaymateOutfitPlayerHome + " in " + locationClass)
        endif
        CurrentOutfit = OutfitPlayerHome
        PlaymateCurrentOutfit = PlaymateOutfitPlayerHome

    ElseIf (locationClass == "Adventuring")
        if (OutfitAdventuring ==  -1 || forceNewOutfit)
            OutfitAdventuring = utOutfit.GetRandomOutfitID(GetFilename(locationClass))
            PlaymateOutfitAdventuring = utOutfit.GetRandomOutfitID(GetFilename(locationClass))
            cfg.DebugOutput("Outfit Selected Player: " + OutfitAdventuring + " in " + locationClass)
            cfg.DebugOutput("Outfit Selected Playmate: " + PlaymateOutfitAdventuring + " in " + locationClass)
        endif
        PlaymateCurrentOutfit = PlaymateOutfitAdventuring
        CurrentOutfit = OutfitAdventuring

    else
        if (OutfitAdventuring == -1 || forceNewOutfit)
            OutfitAdventuring = utOutfit.GetRandomOutfitID(CurrentFileName)
            PlaymateOutfitAdventuring = utOutfit.GetRandomOutfitID(CurrentFileName)
        endif
        PlaymateCurrentOutfit = PlaymateOutfitAdventuring
        CurrentOutfit = OutfitAdventuring

    endif
    cfg.DebugOutput("Current Outfit Selected Player: " + CurrentOutfit + " in " + locationClass)
    cfg.DebugOutput("Current Outfit Selected Playmate: " + PlaymateCurrentOutfit + " in " + locationClass)

    int tempid = CurrentOutfit
    if CurrentOutfit >= cfg.OUTFITBREAKPREFIX
        ArmorBroken = True
        tempid = CurrentOutfit - cfg.OUTFITBREAKPREFIX
    elseif CurrentOutfit >= cfg.OUTFITSLUTTYPREFIX
        ArmorSlutty = True
        tempid = CurrentOutfit - cfg.OUTFITSLUTTYPREFIX
    endif

    int tempidpl = PlaymateCurrentOutfit
    if PlaymateCurrentOutfit >= cfg.OUTFITBREAKPREFIX
        ArmorBrokenPlaymate = True
        tempidpl = PlaymateCurrentOutfit - cfg.OUTFITBREAKPREFIX
    elseif PlaymateCurrentOutfit >= cfg.OUTFITSLUTTYPREFIX
        tempidpl = PlaymateCurrentOutfit - cfg.OUTFITSLUTTYPREFIX
    endif

    ArmorCanBreak = HasBrokenVersion(outfitId = tempid)
    ArmorCanBreakPlaymate = HasBrokenVersion(outfitId = tempidpl)
    ArmorCanBeSlutty = HasSluttyVersion(outfitId = tempid)

    if (!ArmorBroken && ArmorCanBreak)
        PlayerTracker.Activate()
    endif
    if (!ArmorBrokenPlaymate && ArmorCanBreakPlaymate)
        PlayerTracker.Activate()
    endif


    ; For manual Mode trigger Outfit change for Playmate
    if cfg.TaskOutfitManualMode
        ChangeOutfit()
    endif
EndFunction


; ------------------------------------------------------------------------------
;                            Qust Outfit Management                             
; ------------------------------------------------------------------------------

Function RequestNewOutfitSets(bool upgrade = false, bool downgrade = false)
    if upgrade
        OutfitLevel = PapyrusUtil.ClampInt(OutfitLevel + 1, 0, 2)
        cfg.Log("Upgrade to Level " + OutfitLevel)
        SetObjectiveDisplayed(20, False, True)
        SetObjectiveDisplayed(10, True, True)
    elseif downgrade
        OutfitLevel = PapyrusUtil.ClampInt(OutfitLevel - 1, 0, 2)
        cfg.Log("Downgrade to Level " + OutfitLevel)
        SetObjectiveDisplayed(20, False, True)
        SetObjectiveDisplayed(10, True, True)
    endif
    ForceDowngradePunishment = False
    ForceDowngrade = False
    ForceUpgrade = False
    ChangeDecided = False
    AskedForChange = False
    lastOutfit = CurrentOutfit
    lastFile = CurrentFileName
    SelectOutfit("Adventuring", true)
    SelectOutfit("Capital", true)
    SelectOutfit("Settlement", true)
    SelectOutfit("Inn", true)
    SelectOutfit("PlayerHome", true)
    SelectOutfit("Adventuring", true)
    ; to set the real Current Outfit
    SelectOutfit(CurrentLocation, true)
EndFunction


Function RequestNewOutfit()
    StripOutfit(true)
    SelectOutfit(CurrentLocation, true)
    EquipOutfit()
EndFunction

Function SavePlaymateOutfit()
    if !cfg.TaskOutfitAllowPlaymate
        return
    endif
    PlaymateBaseOutfit = cfg.Playmate.GetActorBase().GetOutfit()
    utOutfit.SaveActorOutfit(cfg.Playmate)
Endfunction

Function TryRestorePlaymateOutfit(Actor npc=None)
    if !cfg.TaskOutfitAllowPlaymate
        return
    endif
    if npc == None
        npc = cfg.Playmate
    endif
    if npc == None
        return
    endif

    cfl_UtilityOutfit.StripActor(npc, True)
    cfg.Playmate.SetOutfit(PlaymateBaseOutfit)
    utOutfit.RestoreActorOutfit(npc)
Endfunction

Function HandlePlaymateDefaultOutfit()
    if(cfg.TaskOutfitAllowPlaymate)
        if (PlaymateFirstChange && cflLola.PlaymateSameSex)
            SavePlaymateOutfit()
            cfg.Playmate.SetOutfit(Naked)
            LastUsedPlaymate = cfg.Playmate
            PlaymateFirstChange = False
        endif
        if (LastUsedPlaymate != cfg.Playmate)
            TryRestorePlaymateOutfit(LastUsedPlaymate)
            LastUsedPlaymate = cfg.Playmate
            PlaymateFirstChange = True
        endif
    endif
EndFunction

Function ChangeOutfit()
    Debug.Trace("Change Outfit")
    HandlePlaymateDefaultOutfit()
    ; we are changed outfit in this location we will strip instead.
    if (LastLocationOutfitChange == CurrentLocation)
        cfg.DebugOutput("redress in same location")
        ; redress to fix issues
        if(pressedChangeForUndress)
            cfg.log("Dress Again")
            EquipOutfit()
            pressedChangeForUndress = False
        else
            cfg.log("Undress")
            StripOutfit()
            pressedChangeForUndress = True
        endif
        return
    endif
    cfg.DebugOutput("change clothes")
    LastLocationOutfitChange = CurrentLocation
    pressedChangeForUndress = False
    ; we are in a new location
    StripOutfit(true, true)
    EquipOutfit()
EndFunction

Bool Function isShield(Form item)
    return item.HasKeyword(Shield)
EndFunction

Bool Function isKalItem(Form item)
    ; 0kal not loaded and initialized
    if !cfg.kal_Eequipment_Animated
        return False
    endif
    ; it's an if else shit because readability, Line breaks not fully working...
    if item.HasKeyword(cfg.kal_Eequipment_Animated)
        return True
    elseif item.HasKeyword(cfg.kal_Eequipment_AN)
        return True
    elseif item.HasKeyword(cfg.kal_Eequipment_VA)
        return True
    elseif item.HasKeyword(cfg.kal_Eequipment_BO)
        return True
    elseif item.HasKeyword(cfg.kal_Eequipment_BR)
        return True
    endif
    return false
endfunction

bool Function isDDEquipment(Form item)
    return (item.HasKeyword(cfg.dd.zad_Lockable) || item.HasKeyword(cfg.dd.zad_DeviousPlug))
EndFunction

bool Function isSexlabNoStrip(Form item)
    return item.HasKeyword(cfg.SexlabNoStrip)
Endfunction

Bool Function CheckOutfit()
    cfg.DebugOutput("Call Check Outfit")
    Form[] wornOutfit = cfl_UtilityOutfit.GetWornOutfit(Player, IncludeDD = true)
    int i = 0
    int index = 0
    Form[] ReferenceOutfit = utOutfit.LoadOutfit(CurrentFileName, CurrentOutfit)
     ;Check for additional Items
    While (index < wornOutfit.Length)
        Form item = wornOutfit[index]
        int found = ReferenceOutfit.Find(item)
        ; check if it's a DD
        if (found < 0 && !isDDEquipment(item) && !isKalItem(item) && !isSexlabNoStrip(item) && !isShield(item))
            Debug.Notification("You are not allower to wear " + item.GetName())
            cfg.DebugOutput("Item is not allowed to wear: " + item.GetName())
            return false
        endif
        index += 1
     EndWhile
     i = 0
     ; check if all needed Devices are worn
    While (i < ReferenceOutfit.Length)
        Armor item = ReferenceOutfit[i] as Armor
         int mask = item.GetSlotMask()
         Armor worn_item = Player.GetWornForm(mask) as Armor
         ; allow naked OR DD Item on slot
         ;if (worn_item && worn_item != item && !worn_item.HasKeyword(cfg.dd.zad_Lockable) && !worn_item.HasKeyword(cfg.dd.zad_DeviousPlug))
         if (worn_item && worn_item != item && !isDDEquipment(worn_item) && !isKalItem(worn_item) && !isSexlabNoStrip(worn_item) && !isShield(worn_item))
            Debug.Notification("You are missing your " + item.GetName())
             cfg.DebugOutput("Item is not correct here: " +  item.GetName())
             return False
         endif
        ; code
        i += 1
    EndWhile
    cfg.DebugOutput("Outfit OK")
    return True
 EndFunction

Form[] Function CheckForForbiddenItems()
    Form[] wornOutfit = cfl_UtilityOutfit.GetWornOutfit(Player, IncludeDD = true)
    Form[] result
    int i = 0
    int index = 0
    Form[] ReferenceOutfit = utOutfit.LoadOutfit(CurrentFileName, CurrentOutfit)
     ;Check for additional Items
    While (index < wornOutfit.Length)
        Form item = wornOutfit[index]
        int found = ReferenceOutfit.Find(item)
        ; check if it's a DD
        if (found < 0 && !isDDEquipment(item) && !isKalItem(item) && !isSexlabNoStrip(item) && !isShield(item))
            result = PapyrusUtil.PushForm(result, item)
        endif
        index += 1
     EndWhile
     return result
EndFunction

Form[] Function CheckForMissingItems()
    int i = 0
    Form[] result
    Form[] ReferenceOutfit = utOutfit.LoadOutfit(CurrentFileName, CurrentOutfit)
    While (i < ReferenceOutfit.Length)
        Armor item = ReferenceOutfit[i] as Armor
         int mask = item.GetSlotMask()
         Armor worn_item = Player.GetWornForm(mask) as Armor
         ; allow naked OR DD Item on slot
         ;if (worn_item && worn_item != item && !worn_item.HasKeyword(cfg.dd.zad_Lockable) && !worn_item.HasKeyword(cfg.dd.zad_DeviousPlug))
         if (worn_item && worn_item != item && !isDDEquipment(worn_item) && !isKalItem(worn_item) && !isSexlabNoStrip(worn_item) && !isShield(worn_item))
             result = PapyrusUtil.PushForm(result, item)
         endif
        ; code
        i += 1
    EndWhile
    return result
EndFunction


 Function MasterChecksOutfit()
    lastCheck = Utility.GetCurrentGameTime()
    bool outfitCorrect = CheckOutfit()

    if outfitCorrect
        WarnedForViolation = 0
    else
        string outfitname = utOutfit.GetOutfitName(CurrentFileName, CurrentOutfit)
        Debug.Notification(lola.OwnerTitle + " warns you for not wearing your" + outfitname+ " outfit as you should")
        WarnedForViolation += 1
    endif

    ; Lola was very naughty. 
    if WarnedForViolation > cfg.TaskOutfitMaxWarnings
        Debug.Notification(lola.OwnerTitle + " zaps you for not wearing your outfit for a long time")
        lola.PunishForViolation()
        if (lastCheck > cfg.TaskOutfitMinWearTimeOver && OutfitLevel > 0)
            Debug.Notification(lola.OwnerTitle + " is angry and will buy you some new clothes")
            ForceDowngradePunishment = True
            ForceDowngrade = False
            ForceUpgrade = False
        endif
    endif

    ; check if submission Score is to high or low now
    ; min time done?
    if (lastCheck > cfg.TaskOutfitMinWearTimeOver && !ForceDowngradePunishment && !ChangeDecided)
        CheckForUpdateUpgrade()
    endif
EndFunction

Function CheckForUpdateUpgrade()
    if (cfg.SubmissionScore >= cfg.TaskOutfitLevel1Threshold && OutfitLevel == 0)
        ForceUpgrade = True
        ForceDowngrade = False
    elseif(cfg.SubmissionScore >= cfg.TaskOutfitLevel2Threshold && OutfitLevel == 1)
        ForceUpgrade = True
        ForceDowngrade = False
    ; if behavior was going down during questing
    elseif(cfg.SubmissionScore < cfg.TaskOutfitLevel2Threshold && OutfitLevel == 1)
        ForceUpgrade = False
        ForceDowngrade = False
    elseif(cfg.SubmissionScore < cfg.TaskOutfitLevel1Threshold && OutfitLevel == 0)
        ForceUpgrade = False
        ForceDowngrade = False
    ; Punishments 
    elseif(cfg.SubmissionScore < cfg.TaskOutfitLevel2Threshold && OutfitLevel == 2)
        ForceUpgrade = False
        ForceDowngrade = True
    elseif(cfg.SubmissionScore > cfg.TaskOutfitLevel1Threshold && OutfitLevel == 1)
        ForceUpgrade = False
        ForceDowngrade = True
    ; if behavior was going up during questing
    elseif(cfg.SubmissionScore >= cfg.TaskOutfitLevel2Threshold && OutfitLevel == 2)
        ForceUpgrade = False
        ForceDowngrade = False
    elseif(cfg.SubmissionScore >= cfg.TaskOutfitLevel1Threshold && OutfitLevel == 1)
        ForceUpgrade = False
        ForceDowngrade = False
    endif
EndFunction

Form[] Function GetManulModeItems()
    Form[] Equipment = utOutfit.LoadOutfit("Capital" + "_" + OutfitLevel, OutfitCapital)
    cfg.Log(Equipment)
    Form[] nextOutfit = utOutfit.LoadOutfit("Settlement" + "_" + OutfitLevel, OutfitSettlement)
    Equipment = PapyrusUtil.MergeFormArray(Equipment, nextOutfit, true)
    nextOutfit = utOutfit.LoadOutfit("Inn" + "_" + OutfitLevel, OutfitInn)
    Equipment = PapyrusUtil.MergeFormArray(Equipment, nextOutfit, true)
    nextOutfit = utOutfit.LoadOutfit("PlayerHome" + "_" + OutfitLevel, OutfitPlayerHome)
    Equipment = PapyrusUtil.MergeFormArray(Equipment, nextOutfit, true)
    nextOutfit = utOutfit.LoadOutfit("Adventuring" + "_" + OutfitLevel, OutfitAdventuring)
    Equipment = PapyrusUtil.MergeFormArray(Equipment, nextOutfit, true)
    return Equipment
Endfunction 

Function ManualAddItems()
    cfg.Log("Add Manual Mode Items")
    Form[] Equipment = GetManulModeItems()
    int i = 0
    While (i < Equipment.Length)
        Form item = Equipment[i]
        if (Player.GetItemCount(item) <= 0)
            Player.AddItem(item, 1)
        endif
        i += 1
    EndWhile
Endfunction

Function ManualRemoveItems()
    cfg.Log("Remove Manual Mode Items")
    Form[] Equipment = GetManulModeItems()
    int i = 0
    While (i < Equipment.Length)
        Form item = Equipment[i]
        if (Player.GetItemCount(item) > 0)
            Player.RemoveItem(item, 1, abSilent = True)
        endif
        i += 1
    EndWhile
Endfunction

Function StartManualMode()
    if !cfg.TaskOutfitManualMode
        cfg.Log("Manual Mode disabled")
        return
    endif
    cfg.Log("Start Manual Mode")
    ManualAddItems()
EndFunction

Function StopManualMode()
    if cfg.TaskOutfitManualMode
        return
        cfg.Log("Manual Mode is enabled")
    endif
    ManualRemoveItems()
endfunction

Function NotifyPlayerOverPossibleChange()
    Debug.Notification("Your " + lola.Title + " wants to buy you some new clothes")
    SetObjectiveDisplayed(10, False, True)
    SetObjectiveDisplayed(20, True, True)
Endfunction

Bool Function Available()
    if (lola.SuspendAll || lola.BlockEvents || cfg.TaskOutfitSuspendCheck)
        cfg.log("Lola is blocking or manual suspend")
        return False
    endif
    return True
EndFunction

Bool Function IsPlayerVampireLord()
    Race vampireLordRace = Game.GetFormFromFile(0x0000283A, "Dawnguard.esm") as Race
    return vampireLordRace && Player.GetRace() == vampireLordRace
EndFunction

Bool Function CanCheck()
    ; first check high Level Blocker
    if (!Available())
        cfg.log("Lola is blocking or manual suspend")
        return False
    endif
    if IsPlayerVampireLord()
        cfg.log("Player is in Vampire Lord form")
        return False
    endif
    ;now check Quest Stuff
    ; Prosititution running Avoid the complex situations
    if(lolaProstitution.IsRunning() && lolaProstitution.GetStage() >= 5)
        return false
        cfg.log("Prostitution running")
    endif
    if (FitForAJarl.IsRunning() && FitForAJarl.GetStage() > 0 && !cfg.TaskOutfitIgnoreFitForAJarl)
        cfg.log("Fit for a Jarl running")
        if !fitq_warning
            fitq_warning = True
            Debug.MessageBox("Fit for a Jarl is detected. Suspend Outfit Task. To restart it either set the option in the MCM to ignore the quest or finish it")
        endif
        return False
    endif
    if (DiplomaticImmunity.IsRunning() && DiplomaticImmunity.GetStage() > 70)
        cfg.log("Diplomatic Immunity is running and higher stage")
        return False
    endif
    return True
EndFunction

Bool Function CanCheckShortBlocker()
    return !Player.HasMagicEffect(EyeCandyEffect) && !Player.HasMagicEffect(EyeCandyEffectExtended) && !Player.IsInCombat()
EndFunction

;test if problem first
Bool Function CheckFastTravelOrWait()
    ; This can result into unfair bugs.
    float timebetween = Utility.GetCurrentGameTime() - lastCheck
    float estimate = (cfg.TaskOutfitCheckTimeSeconds as float / Timescale.GetValueInt() as float)
    if(timebetween > estimate * 10)

    endif
Endfunction

; Parse all possible kw to outfitname
Function SetCurrentLocation(string newLocation)
    if newLocation == "Inn"
        CurrentLocation = "Inn"
    elseif newLocation == "City"
        CurrentLocation = "Capital"
    elseif newLocation == "Settlement"
        CurrentLocation = "Settlement"
    elseif newLocation == "PlayerHome"
        CurrentLocation = "PlayerHome"
    elseif newLocation == "Castle"
        CurrentLocation = "Capital"
    elseif newLocation == "Adventuring"
        CurrentLocation = "Adventuring"
    Else
        CurrentLocation = "Adventuring"
    endif
    cfg.log("New Location to " + CurrentLocation)
    Debug.Trace("New Location to " + CurrentLocation)
    Debug.Notification("Entered new Location " + CurrentLocation)
EndFunction

Function checkAndStartOutfitchange(string newLocation)
    ; avoid may Ask for service not to interfiere with other Starts
    if newLocation != "City" || !Available() || !lola.MayAskForService
        return
    endif
    if(ForceDowngrade || ForceDowngradePunishment || ForceUpgrade || AskedForChange)
        ChangeDecided = True
        OutfitStarter.Start()
    endif
Endfunction

; cleanup
Function EndOutFitTask()
    StripOutfit(true, false)
    ResetVars()

    TryRestorePlaymateOutfit()
    if !cfg.locationTracker.IsRunning()
        cfg.locationTracker.TryToStop()
    endif
    UnregisterForUpdate()
    UnregisterForKey(cfg.TaskOutfitChangeKey)
EndFunction


; ------------------------------------------------------------------------------
;                               Dialoge Functions                               
; ------------------------------------------------------------------------------

Function PlayerAsksForNewClothes()
    CheckForUpdateUpgrade()
    AskedForChange = True
EndFunction

Function PlayerAsksForShowingOutfit()
    string outfitname = utOutfit.GetOutfitName(CurrentFileName, CurrentOutfit)
    Form[] ReferenceOutfit = utOutfit.LoadOutfit(CurrentFileName, CurrentOutfit)
    string result = "You are currently in Location Type:  " + CurrentLocation + "\n"
    result = result + "Your selected outfit is: " + outfitname + "\n\n"
    result = result + "====You have to wear====\n\n"
    int i = 0
    While (i < ReferenceOutfit.Length)
        Form item = ReferenceOutfit[i]
        result = result + item.GetName() + "\n"
        i += 1
    EndWhile
    Debug.MessageBox(result)
EndFunction

Function PlayerAsksForOutfitCheck()
    string outfitname = utOutfit.GetOutfitName(CurrentFileName, CurrentOutfit)
    Form[] forbiddenItems = CheckForForbiddenItems()
    Form[] missingItems = CheckForMissingItems()
    string result = "You are currently in Location Type:  " + CurrentLocation + "\n"
    result = result + "Your selected outfit is: " + outfitname + "\n"
    if (!forbiddenItems && !missingItems)
        result = result + "Everything is fine" + outfitname + "\n"
    endif
    
    if (forbiddenItems)
        result = result + "\n====You are not allowed to wear====\n"
        int i = 0
        While (i < forbiddenItems.Length)
            Form item = forbiddenItems[i]
            result = result + item.GetName() + "\n"
            i += 1
        EndWhile
    endif

    if (missingItems)
        result = result + "\n====You are missing the following items====\n"
        int i = 0
        While (i < missingItems.Length)
            Form item = missingItems[i]
            result = result + item.GetName() + "\n"
            i += 1
        EndWhile
    endif
    Debug.MessageBox(result)
EndFunction

Function PlayerAsksForBrokenEquipmentCheck()
    CheckForBrokenArmor()
EndFunction

Function PlayerRequestsRepair(Actor who, int gold)
    ; Player pays with Body
    if gold < 0
        cfg.lola.oralSex(who, Player)
    Else
        Player.RemoveItem(cfg.Gold, gold)
    endif
    RepairArmor()
EndFunction

Function PlayerAsksForUnslutyfy(bool ForSex=False)
    UnSluttyfy()
    if ForSex
        Utility.Wait(3)
        cfg.lola.Fuck(cfg.Owner)
    endif
EndFunction

Function OwnerWantsSluttyArmor()
    Sluttyfy()
EndFunction
; ------------------------------------------------------------------------------
;                                    Events                                     
; ------------------------------------------------------------------------------

Event OnLolaLocationChange(string newLocation)
    
    if(baselocName == newLocation)
        return
    endif

    lastOutfit = CurrentOutfit
    lastFile = CurrentFileName
    SetCurrentLocation(newLocation)
    baselocName = newLocation

    cfg.DebugOutput("Event: New Location entered: " + newLocation)
    UnregisterForUpdate()
    WarnedForViolation = 0
    ; This Functions sets the outfit, if it's not loaded yet it get's an random outfit
    SelectOutfit(CurrentLocation)
    checkAndStartOutfitchange(newLocation)
    int locChangeDelay = cfg.TaskOutfitCheckTimeLocChangeSeconds
    if locChangeDelay < 30
        locChangeDelay = 30
    endif
    RegisterForSingleUpdate(locChangeDelay)
EndEvent

Event onPlaymateChange()
    if cfg.Playmate == None
        TryRestorePlaymateOutfit(LastUsedPlaymate)
    endif
EndEvent


; Event OnInit()
;     SetReferences()
;     RegisterEvents()
; EndEvent
bool hkReady
Event OnKeyDown(int keyCode)
    ; if !hkReady
    ;     return
    ; endif
    ; hkReady = False
    ; cfg.DebugOutput("Key pressed")
    ; if !cfl_Utility.IsPlayerAvailable() || cfl_Utility.IsRelevantMenuOpen() 
    ;     return
    ; endif
    ; If (keyCode == cfg.TaskOutfitChangeKey)
    ;     ChangeOutfit()
    ; endif
    ; hkReady = True
EndEvent

; Event OnInit()
;     SetReferences()
;     RegisterEvents()
; EndEvent
Event OnKeyUp(int keyCode, float presstime)
    if (!cfl_Utility.IsPlayerAvailable() || cfl_Utility.IsRelevantMenuOpen())
        return
    endif
    If (keyCode == cfg.TaskOutfitChangeKey && presstime > 0.2)
        ChangeOutfit()
    endif
EndEvent

Event OnUpdate()
    ; as long as Prostitution Quest is running ignore the Outfit
    if (!CanCheck())
        RegisterForSingleUpdate(cfg.TaskOutfitCheckTimeSeconds)
        return
    endif
    if !CanCheckShortBlocker()
        RegisterForSingleUpdate(5)
        return
    endif

    MasterChecksOutfit()
    RegisterForSingleUpdate(cfg.TaskOutfitCheckTimeSeconds)
endevent

Event OnKeyRegister()
    UnregisterForKey(cfg.TaskOutfitChangeKey)
    RegisterForKey(cfg.TaskOutfitChangeKey)
EndEvent

; ------------------------------------------------------------------------------
;                           Sluttyfy Breaking Common                            
; ------------------------------------------------------------------------------

Function OverwriteCurrentOutfit(int id)
    if !utOutfit.IdExits(currentFileName, id)
        cfg.Log("Somehow tried to overwrite the Outfit to an invalid outfit")
        cfg.Log("File: " + currentFileName + " id: " + id)
        return
    endif

    CurrentOutfit = id
    if CurrentLocation == cfg.OUTFITCLASSCAPITAL
        OutfitCapital = id
    elseif CurrentLocation == cfg.OUTFITCLASSINN
        OutfitInn = id
    elseif CurrentLocation == cfg.OUTFITCLASSHOME
        OutfitPlayerHome = id
    elseif CurrentLocation == cfg.OUTFITCLASSSETTLEMENT
        OutfitSettlement = id
    elseif CurrentLocation == cfg.OUTFITCLASSADVENTURE
        OutfitAdventuring = id
    endif
EndFunction

Function OverwriteCurrentOutfitPlaymate(int id)
    if !utOutfit.IdExits(currentFileName, id)
        cfg.Log("Somehow tried to overwrite the Outfit to an invalid outfit")
        cfg.Log("File: " + currentFileName + " id: " + id)
        return
    endif

    PlaymateCurrentOutfit = id
    if CurrentLocation == cfg.OUTFITCLASSCAPITAL
        PlaymateOutfitCapital = id
    elseif CurrentLocation == cfg.OUTFITCLASSINN
        PlaymateOutfitInn = id
    elseif CurrentLocation == cfg.OUTFITCLASSHOME
        PlaymateOutfitPlayerHome = id
    elseif CurrentLocation == cfg.OUTFITCLASSSETTLEMENT
        PlaymateOutfitSettlement = id
    elseif CurrentLocation == cfg.OUTFITCLASSADVENTURE
        PlaymateOutfitAdventuring = id
    endif
EndFunction

int Function GetBaseID(int id)
    if id > cfg.OUTFITBREAKPREFIX
        cfg.DebugOutput("Broken Armor")
        return (id - cfg.OUTFITBREAKPREFIX)
    elseif id > cfg.OUTFITSLUTTYPREFIX
        cfg.DebugOutput("Slutty Armor")
        return (id - cfg.OUTFITSLUTTYPREFIX)
    endif
    return id
endFunction


; ------------------------------------------------------------------------------
;                                Sluttyfy Outfit                                
; ------------------------------------------------------------------------------

Bool Function HasSluttyVersion(string filename = "", int outfitId = -1)
    int id = outfitId
    string file = filename
    if filename == ""
        file = currentFileName
    endif
    if outfitId <= 0
        id = CurrentOutfit
    endif
    ; 10k as parameter is Slutty Area
    id = GetBaseID(id)
    return utOutfit.HasSluttyVersion(file, id)
EndFunction

Function SluttyfyOutfit(int id)
    OverwriteCurrentOutfit(id + cfg.OUTFITSLUTTYPREFIX)
EndFunction

Function SluttyfyOutfitPlaymate(int id)
    OverwriteCurrentOutfitPlaymate(id + cfg.OUTFITSLUTTYPREFIX)
EndFunction

Function UnSluttyfyOutfit(int id)
    OverwriteCurrentOutfit(id - cfg.OUTFITSLUTTYPREFIX)
EndFunction

Function UnSluttyfyOutfitPlaymate(int id)
    OverwriteCurrentOutfitPlaymate(id - cfg.OUTFITSLUTTYPREFIX)
EndFunction

Function Sluttyfy()
    cfg.DebugOutput("Sluttify Armor")
    int tempPlayerOutfit = -1
    int tempPlaymateOutfit = -1
    if HasSluttyVersion()
        if CurrentOutfit >= cfg.OUTFITBREAKPREFIX
            cfg.Log("Can not Slutify a broken Armor")
            return
        endif
        tempPlayerOutfit = CurrentOutfit
        SluttyfyOutfit(CurrentOutfit)
        SwapOutfit(tempPlayerOutfit)
        ArmorSlutty = True
    Else
        cfg.DebugOutput("Player is not wearing slutty possible Armor")
    Endif

    if PlaymateAllow
        if HasSluttyVersion(outfitId=PlaymateCurrentOutfit)
            if PlaymateCurrentOutfit >= cfg.OUTFITBREAKPREFIX
                cfg.Log("Can not Slutify a broken Armor")
                return
            endif
            tempPlaymateOutfit = PlaymateCurrentOutfit
            SluttyfyOutfitPlaymate(PlaymateCurrentOutfit)
            SwapOutfitPlaymate(tempPlaymateOutfit)
        else
            cfg.DebugOutput("Playmate is not wearing slutty possible Armor")
        endif
    endif
Endfunction

Function UnSluttyfy()
    int tempPlayerOutfit = -1
    int tempPlaymateOutfit = -1
    if CurrentOutfit >= cfg.OUTFITBREAKPREFIX
        cfg.Log("Can not UnSlutify a broken Armor")
        return
    endif
    UnSluttyfyOutfit(CurrentOutfit)
    SwapOutfit(tempPlayerOutfit)
    ArmorSlutty = False

    if PlaymateAllow
        if PlaymateCurrentOutfit >= cfg.OUTFITBREAKPREFIX
            cfg.Log("Can not UnSlutify a broken Armor")
            return
        endif
        UnSluttyfyOutfitPlaymate(PlaymateCurrentOutfit)
        SwapOutfitPlaymate(tempPlaymateOutfit)
    endif
Endfunction



; ------------------------------------------------------------------------------
;                                 Tearing Armor                                 
; ------------------------------------------------------------------------------

Bool Function HasBrokenVersion(string filename = "", int outfitId = -1)
    int id = outfitId
    string file = filename
    if filename == ""
        file = currentFileName
    endif
    if outfitId <= 0
        id = CurrentOutfit
    endif

    id = GetBaseID(id)
    return utOutfit.HasBrokenVersion(file, id)
EndFunction

Function PlayBreakingSound(Actor who)
    if who.WornHasKeyword(ArmorHeavy)
        SoundHeavyArmorBreaking.Play(who)

    elseif(who.WornHasKeyword(ArmorLight))
        SoundLightArmorBreaking.Play(who)
    else
        SoundClothesTearing.Play(who)
    endif
EndFunction

Function BreakOutfit(int id)
    int temp = id
    int baseid = GetBaseID(id)
    OverwriteCurrentOutfit(baseid + cfg.OUTFITBREAKPREFIX)
    PlayBreakingSound(Player)
    SwapOutfit(temp)
    ArmorBroken = True
    ArmorSlutty = False
EndFunction

Function BreakOutfitPlaymate(int id)
    int temp = id
    int baseid = GetBaseID(id)
    OverwriteCurrentOutfitPlaymate(baseid + cfg.OUTFITBREAKPREFIX)
    PlayBreakingSound(cfg.Playmate)
    SwapOutfitPlaymate(temp)
    ArmorBrokenPlaymate = True
EndFunction

Function Breaking(Actor who)
    if (who == Player)
        if HasBrokenVersion() && CurrentOutfit < cfg.OUTFITBREAKPREFIX
            BreakOutfit(CurrentOutfit)
        Endif
    endif

    if (who == cfg.Playmate && PlaymateAllow)
        if (HasBrokenVersion(outfitId=PlaymateCurrentOutfit) && CurrentOutfit < cfg.OUTFITBREAKPREFIX)
            BreakOutfitPlaymate(PlaymateCurrentOutfit)
        endif
    endif
Endfunction

Function CheckForBrokenArmor()
    if OutfitAdventuring >= cfg.OUTFITBREAKPREFIX
        HasBrokenArmor = True
    elseif OutfitCapital >= cfg.OUTFITBREAKPREFIX
        HasBrokenArmor = True
    elseif OutfitInn >= cfg.OUTFITBREAKPREFIX
        HasBrokenArmor = True
    elseif OutfitPlayerHome >= cfg.OUTFITBREAKPREFIX
        HasBrokenArmor = True
    elseif OutfitSettlement >= cfg.OUTFITBREAKPREFIX
        HasBrokenArmor = True
    elseif PlaymateOutfitAdventuring >= cfg.OUTFITBREAKPREFIX
        HasBrokenArmor = True
    elseif PlaymateOutfitCapital >= cfg.OUTFITBREAKPREFIX
        HasBrokenArmor = True
    elseif PlaymateOutfitInn >= cfg.OUTFITBREAKPREFIX
        HasBrokenArmor = True
    elseif PlaymateOutfitPlayerHome >= cfg.OUTFITBREAKPREFIX
        HasBrokenArmor = True
    elseif PlaymateOutfitSettlement >= cfg.OUTFITBREAKPREFIX
        HasBrokenArmor = True
    endif
EndFunction

Function RepairArmor()
    int temp = -1
    if CurrentOutfit >= cfg.OUTFITBREAKPREFIX
        temp = CurrentOutfit
        CurrentOutfit = CurrentOutfit - cfg.OUTFITBREAKPREFIX
        SwapOutfit(temp)
        ArmorBroken = false
    endif

    if PlaymateCurrentOutfit >= cfg.OUTFITBREAKPREFIX
        temp = CurrentOutfit
        PlaymateCurrentOutfit = PlaymateCurrentOutfit - cfg.OUTFITBREAKPREFIX
        SwapOutfitPlaymate(temp)
        ArmorBrokenPlaymate = False
    endif
    
    if OutfitAdventuring >= cfg.OUTFITBREAKPREFIX
        OutfitAdventuring -= cfg.OUTFITBREAKPREFIX
    endif

    if OutfitCapital >= cfg.OUTFITBREAKPREFIX
        OutfitCapital -= cfg.OUTFITBREAKPREFIX
    endif

    if OutfitInn >= cfg.OUTFITBREAKPREFIX
        OutfitInn -= cfg.OUTFITBREAKPREFIX
    endif

    if OutfitPlayerHome >= cfg.OUTFITBREAKPREFIX
        OutfitPlayerHome -= cfg.OUTFITBREAKPREFIX
    endif

    if OutfitSettlement >= cfg.OUTFITBREAKPREFIX
        OutfitSettlement -= cfg.OUTFITBREAKPREFIX
    endif

    if PlaymateOutfitAdventuring >= cfg.OUTFITBREAKPREFIX
        PlaymateOutfitAdventuring -= cfg.OUTFITBREAKPREFIX
    endif

    if PlaymateOutfitCapital >= cfg.OUTFITBREAKPREFIX
        PlaymateOutfitCapital -= cfg.OUTFITBREAKPREFIX
    endif

    if PlaymateOutfitInn >= cfg.OUTFITBREAKPREFIX
        PlaymateOutfitInn -= cfg.OUTFITBREAKPREFIX
    endif

    if PlaymateOutfitPlayerHome >= cfg.OUTFITBREAKPREFIX
        PlaymateOutfitPlayerHome -= cfg.OUTFITBREAKPREFIX
    endif

    if PlaymateOutfitSettlement >= cfg.OUTFITBREAKPREFIX
        PlaymateOutfitSettlement -= cfg.OUTFITBREAKPREFIX
    endif
    HasBrokenArmor = False
EndFunction

; ------------------------------------------------------------------------------
;                                Base Functions                                 
; ------------------------------------------------------------------------------


Function SetReferences()
    cfg = cfl_config.GetConfig()
    cfg.DebugOutput("Load Outfit Task Refs")
    utOutfit = cfg.utOutfit
    lola = cfg.lola
    cflLola = cfg.cflLola
    Player = Game.GetPlayer()
    OutfitStarter = cfg.TaskOutfitStarter
    lolaProstitution = Quest.GetQuest("vkjPimpedBasic")
    FitForAJarl = Quest.GetQuest("SolitudeFreeform02")
    cfg.DebugOutput(FitForAJarl)
    DiplomaticImmunity  = Quest.GetQuest("MQ201")
    EyeCandyEffect = cfg.EyeCandyEffect
    EyeCandyEffectExtended = cfg.EyeCandyEffectExtended
EndFunction

Function RegisterEvents()

    cfg.Log("Register Events for Outfit Task")
    RegisterForModEvent("cfeLola_TechReloadReferences", "OnReloadReferences")
    RegisterForModEvent("cfeLola_TechReloadKeys", "OnKeyRegister")
    RegisterForModEvent("cfl_LocationChange", "OnLolaLocationChange")
    RegisterForModEvent("cfeLola_PlaymateChanged", "onPlaymateChange")
    RegisterForModEvent("cfeLola_OwnerChanged", "OwnerChanged")
    RegisterForKey(cfg.TaskOutfitChangeKey)

EndFunction


Function UnregisterEvents()
    UnregisterForKey(cfg.TaskOutfitChangeKey)
    UnregisterForModEvent("cfeLola_TechReloadReferences")
    UnregisterForModEvent("cfeLola_TechReloadKeys")
    UnregisterForModEvent("cfl_LocationChange")
    UnregisterForModEvent("cfeLola_PlaymateChanged")
EndFunction

Function ResetModEvents()
    UnregisterEvents()
    RegisterEvents()
EndFunction

Event OwnerChanged()
    Alias_Owner.Clear()
    Alias_Owner.ForceRefTo(cfg.Owner)
    Alias_T = GetAliasByName("T") as ReferenceAlias
    Alias_T.Clear()
    Alias_T.ForceRefTo(lola.Title.GetReference())
EndEvent


Event OnReloadReferences()
    if (isRunning())
        cfg.Log("lola Location Tracker: Reference Reload")
        SetReferences()
        ResetModEvents()
    endif
EndEvent
