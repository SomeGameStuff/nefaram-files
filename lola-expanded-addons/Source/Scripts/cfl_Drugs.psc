Scriptname cfl_Drugs extends Quest

cfl_config Property cfg Auto
Formlist Property AvailableDrugs Auto

String Property LFMAConfigPath = "../LolaExpandedAddons/Config.json" Auto

int Function GetCfgInt(string configPath, string keyName, int defaultValue)
    return JsonUtil.GetIntValue(configPath, keyName, defaultValue)
EndFunction

float Function GetCfgFloat(string configPath, string keyName, float defaultValue)
    return JsonUtil.GetFloatValue(configPath, keyName, defaultValue)
EndFunction

bool Function GetCfgBool(string configPath, string keyName, bool defaultValue)
    int fallback = 0
    if defaultValue
        fallback = 1
    endif
    return JsonUtil.GetIntValue(configPath, keyName, fallback) != 0
EndFunction

Function LoadDrugs()
    if (cfg.SkoomaWhoreAvailable && cfg.SkoomaWhoreAllow)
        AvailableDrugs = Game.GetFormFromFile(0x20C71, "SexLabSkoomaWhore.esp") as Formlist
        cfg.DrugType = "Skooma Whore Controlled"
    else
        AvailableDrugs = Game.GetFormFromFile(0x41730, "cfl_LolaAddon.esp") as Formlist
        cfg.DrugType = "Vanilla only"
    endif
EndFunction

Function DrugActor(Actor who, int countDrugs, bool animate = True)
    int i = 0
    LoadDrugs()
    if animate
        Debug.SendAnimationEvent(who, "IdleDrinkPotion")
    endif
    while i < countDrugs
        int rng = Utility.RandomInt(0, AvailableDrugs.GetSize() - 1)
        Form drug = AvailableDrugs.GetAt(rng)
        who.Additem(drug, 1, True)
        who.equipitem(drug, false, True)
        i += 1
    endwhile

    TryOwnerFertilityEvent(who, animate)
EndFunction

Function TryOwnerFertilityEvent(Actor who, bool animate = True)
    if !GetCfgBool(LFMAConfigPath, "fertility.enabled", true)
        return
    endif
    if !GetCfgBool(LFMAConfigPath, "fertility.allowPotionTrigger", true)
        return
    endif
    if who != Game.GetPlayer()
        return
    endif
    if Game.GetFormFromFile(0x0156C0, "Fertility Mode.esm") == None
        return
    endif

    float now = Utility.GetCurrentGameTime()
    float nextAllowed = JsonUtil.GetFloatValue(LFMAConfigPath, "fertility.nextAllowedGameDay", 0.0)
    if now < nextAllowed
        return
    endif

    int chance = GetCfgInt(LFMAConfigPath, "fertility.triggerChance", 15)
    if chance < 1
        return
    endif
    if chance < 100 && Utility.RandomInt(1, 100) > chance
        return
    endif

    Actor owner = cfg.Owner
    if owner == None
        owner = who
    endif

    bool directPregnancy = GetCfgBool(LFMAConfigPath, "fertility.allowDirectPregnancy", false)
    Spell fertilitySpell = None
    if directPregnancy
        fertilitySpell = Game.GetFormFromFile(0x0156C1, "Fertility Mode.esm") as Spell
    else
        fertilitySpell = Game.GetFormFromFile(0x0156C0, "Fertility Mode.esm") as Spell
    endif

    if fertilitySpell == None
        return
    endif

    if animate
        Debug.SendAnimationEvent(who, "IdleDrinkPotion")
    endif

    fertilitySpell.Cast(owner, who)
    SetNextFertilityTime(now)
    SayFertilityMood(directPregnancy)
EndFunction

Function SetNextFertilityTime(float now)
    float cooldownHours = GetCfgFloat(LFMAConfigPath, "fertility.cooldownHours", 72.0)
    if cooldownHours < 0.0
        cooldownHours = 0.0
    endif
    JsonUtil.SetFloatValue(LFMAConfigPath, "fertility.nextAllowedGameDay", now + (cooldownHours / 24.0))
    JsonUtil.Save(LFMAConfigPath)
EndFunction

Function SayFertilityMood(bool directPregnancy)
    if !GetCfgBool(LFMAConfigPath, "fertility.showNotifications", true)
        return
    endif

    if directPregnancy
        Debug.Notification("Your owner has decided your next duty will grow inside you.")
        return
    endif

    int line = Utility.RandomInt(0, 3)
    if line == 0
        Debug.Notification("Your owner adds a fertile little surprise to the dose.")
    elseif line == 1
        Debug.Notification("Your owner smiles as the fertility draught takes hold.")
    elseif line == 2
        Debug.Notification("Your owner has decided to leave Fertility Mode a chance.")
    else
        Debug.Notification("Your body warms as your owner watches the potion work.")
    endif
EndFunction

Function Init()
    cfg = cfl_config.GetConfig()
    LoadDrugs()
Endfunction

