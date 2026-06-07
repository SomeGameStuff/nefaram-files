Scriptname cfl_Drugs extends Quest

cfl_config Property cfg Auto
Formlist Property AvailableDrugs Auto

String Property LTEConfigPath = "../LolaExpandedAddons/Config.json" Auto
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
    if ShouldUseTransformativeElixirs()
        DrugActorTransformativeElixirs(who, countDrugs, animate)
        TryOwnerFertilityEvent(who, animate)
        return
    endif

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

bool Function ShouldUseTransformativeElixirs()
    if !GetCfgBool(LTEConfigPath, "transformative.enabled", true)
        return false
    endif

    if Game.GetFormFromFile(0x000806, "TransformativeElixirs.esp") == None
        return false
    endif

    int chance = GetCfgInt(LTEConfigPath, "transformative.triggerChance", 40)
    if chance < 1
        return false
    endif
    if chance >= 100
        return true
    endif

    return Utility.RandomInt(1, 100) <= chance
EndFunction

Function DrugActorTransformativeElixirs(Actor who, int countDrugs, bool animate = True)
    int maxPotions = GetCfgInt(LTEConfigPath, "transformative.maxPotionsPerEvent", 1)
    if maxPotions < 1
        maxPotions = 1
    endif
    if maxPotions > 3
        maxPotions = 3
    endif
    if countDrugs > maxPotions
        countDrugs = maxPotions
    endif

    if animate
        Debug.SendAnimationEvent(who, "IdleDrinkPotion")
    endif

    SayOwnerMood()

    int i = 0
    while i < countDrugs
        Form elixir = PickTransformativeElixir()
        if elixir != None
            who.AddItem(elixir, 1, True)
            who.EquipItem(elixir, false, True)
        endif
        i += 1
    endwhile
EndFunction

Function SayOwnerMood()
    if !GetCfgBool(LTEConfigPath, "transformative.showNotifications", true)
        return
    endif

    int line = Utility.RandomInt(0, 5)
    if line == 0
        Debug.Notification("Your owner has decided your body needs a little improvement.")
    elseif line == 1
        Debug.Notification("Your owner smiles and presents a strange elixir.")
    elseif line == 2
        Debug.Notification("Your owner's mood has settled on a new shape for you.")
    elseif line == 3
        Debug.Notification("Your owner orders you to drink before you can protest.")
    elseif line == 4
        Debug.Notification("Your owner wants today's look to be more memorable.")
    else
        Debug.Notification("Your owner tips the elixir to your lips.")
    endif
EndFunction

Form Function PickTransformativeElixir()
    int tries = 0
    while tries < 20
        int category = Utility.RandomInt(0, 5)
        if category == 0 && GetCfgBool(LTEConfigPath, "transformative.allowCurvy", true)
            return PickCurvyElixir()
        elseif category == 1 && GetCfgBool(LTEConfigPath, "transformative.allowThick", true)
            return PickThickElixir()
        elseif category == 2 && GetCfgBool(LTEConfigPath, "transformative.allowSlimReduced", true)
            return PickSlimReducedElixir()
        elseif category == 3 && GetCfgBool(LTEConfigPath, "transformative.allowMuscular", true)
            return PickMuscularElixir()
        elseif category == 4 && GetCfgBool(LTEConfigPath, "transformative.allowNippleTeat", true)
            return PickNippleElixir()
        elseif category == 5 && GetCfgBool(LTEConfigPath, "transformative.allowNormalcyReset", false)
            return Game.GetFormFromFile(0x000825, "TransformativeElixirs.esp")
        endif
        tries += 1
    endwhile

    return Game.GetFormFromFile(0x000806, "TransformativeElixirs.esp")
EndFunction

Form Function PickCurvyElixir()
    int pick = Utility.RandomInt(0, 4)
    if pick == 0
        return Game.GetFormFromFile(0x000D62, "TransformativeElixirs.esp")
    elseif pick == 1
        return Game.GetFormFromFile(0x000808, "TransformativeElixirs.esp")
    elseif pick == 2
        return Game.GetFormFromFile(0x00080D, "TransformativeElixirs.esp")
    elseif pick == 3
        return Game.GetFormFromFile(0x00080E, "TransformativeElixirs.esp")
    endif
    return Game.GetFormFromFile(0x00080F, "TransformativeElixirs.esp")
EndFunction

Form Function PickThickElixir()
    int pick = Utility.RandomInt(0, 3)
    if pick == 0
        return Game.GetFormFromFile(0x000806, "TransformativeElixirs.esp")
    elseif pick == 1
        return Game.GetFormFromFile(0x00081D, "TransformativeElixirs.esp")
    elseif pick == 2
        return Game.GetFormFromFile(0x00081E, "TransformativeElixirs.esp")
    endif
    return Game.GetFormFromFile(0x00081F, "TransformativeElixirs.esp")
EndFunction

Form Function PickSlimReducedElixir()
    int pick = Utility.RandomInt(0, 3)
    if pick == 0
        return Game.GetFormFromFile(0x000D64, "TransformativeElixirs.esp")
    elseif pick == 1
        return Game.GetFormFromFile(0x000804, "TransformativeElixirs.esp")
    elseif pick == 2
        return Game.GetFormFromFile(0x000812, "TransformativeElixirs.esp")
    endif
    return Game.GetFormFromFile(0x000805, "TransformativeElixirs.esp")
EndFunction

Form Function PickMuscularElixir()
    return Game.GetFormFromFile(0x000807, "TransformativeElixirs.esp")
EndFunction

Form Function PickNippleElixir()
    if Utility.RandomInt(0, 1) == 0
        return Game.GetFormFromFile(0x000811, "TransformativeElixirs.esp")
    endif
    return Game.GetFormFromFile(0x000812, "TransformativeElixirs.esp")
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

