;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 8
Scriptname cfl_Missives Extends Quest Hidden

;BEGIN ALIAS PROPERTY Owner
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Owner Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY t
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_t Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Playmate
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Playmate Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_6
Function Fragment_6()
;BEGIN CODE
    ; Stage 5500
    ; Not all Quests are finished
    ; Fail
    SetObjectiveDisplayed(2000, False)
    SetObjectiveDisplayed(5000)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN CODE
    ; Stage 1000
    ; If enabled walk to missive Board is done
    cfl_Utility.ActorFaceToObject(Owner, TargetBoard)
    Debug.SendAnimationEvent(Owner, cfg.TakeAnimation())
    Utility.Wait(2)
    SetStage(2000)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
; Stage 10
; Init Force Greet
; No Code
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_4
Function Fragment_4()
;BEGIN CODE
    ; stage 2000
    ; Start Up Main Quest
    ; Select Quests

    ; just for safety
    cflLola.SetBlockingEvent(False)

    SelectQuests()
    SetObjectiveDisplayed(100, False)
    SetObjectiveDisplayed(2000)
    ; Start Timer
    SetTimer()
    ShowActiveMissivesMessage()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
    ; Stage 100
    ; Force Greet Done
    ; Function handles also if walking is disabled
    WalkToBoard()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
    ; Stage 0
    ; Init Quest
    Init()
    SetCurrentQuests()
    if VeryHighQ == None
        cfg.Log("Something went completly wrong! Exit Quest", 2)
        setStage(65000)
        return
    endif
    SetStage(10)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_7
Function Fragment_7()
;BEGIN CODE
    ; Stage 65000
    ; End Quest
    ; Clean up
    SetObjectiveDisplayed(2000, False)
    SetObjectiveDisplayed(5000, False)
    SetObjectiveDisplayed(5500, False)
    SetObjectiveDisplayed(100, False)
    cfg.misNextStart = cfg.GetGameTime() + cfg.misCooldown
    EndAllMissives()
    stop()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN CODE
    ; Stage 5000
    ; All Selected Quests are done
    ; Enable Master Pass
    SetObjectiveDisplayed(2000, False)
    SetObjectiveDisplayed(5000)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

; Stage 0    : Init
; Stage 10   : Start FG
; Stage 100  : FG Done, Start Walking to Board
; Stage 1000 : Board Reached
; Stage 2000 : Select quests, start timer etc.
; Stage 5000 : All Missives Done, Go Back to Owner
; Stage 5500 : Time Up. Go Back To Owner
; Stage 65000: End Stage, Cleanup

; ------------------------------------------------------------------------------
;                                  Properties                                   
; ------------------------------------------------------------------------------

cfl_config      Property cfg                 Auto
cfl_lolaMain    Property cflLola             Auto
vkjmq           Property lola                Auto
cfl_WalkToQuest Property walkingQ            Auto
Actor           Property Owner               Auto
Actor           Property Player              Auto
Form[]          Property ActiveMissives      Auto
MiscObject      Property Gold                Auto

GlobalVariable  Property QuestChanceLow      Auto
GlobalVariable  Property QuestChanceMed      Auto
GlobalVariable  Property QuestChanceHigh     Auto
GlobalVariable  Property QuestChanceVeryHigh Auto
float           Property endTime             Auto

FormList VeryHighQ
FormList HighQ
FormList MedQ
FormList LowQ
ObjectReference TargetBoard



; ------------------------------------------------------------------------------
;                                   Functions                                   
; ------------------------------------------------------------------------------

Function EndSuccess()
    lola.MediumReward()

    TakeQuestGold(False)
    ; 1 stric, 0 playful
    if(lola.MCM.OwnerAttitude == 1)
        player.Additem(Gold, 1)
    else
        int targetgold = (cfg.misTargetGold * cfg.misGoldReward) as int
        player.Additem(Gold, targetgold)
    endif
    SetStage(65000)
EndFunction

Function EndFail()
    TakeQuestGold(True)
    lola.PunishForViolation()
    lola.Punish()
    SetStage(65000)
EndFunction

Function TakeQuestGold(bool Punish=False)
    int playergold = player.GetItemCount(Gold)
    int targetgold = cfg.misTargetGold as int
    if punish
        targetgold = targetgold * 2
    endif
    if (playerGold < targetgold)
        player.RemoveItem(Gold, playergold)
        owner.AddItem(Gold, playergold)
    else 
        player.RemoveItem(Gold, targetgold)
        owner.AddItem(Gold, targetgold)
    endif
EndFunction

; ------------------------------------------------------------------------------
;                                Quest Selection                                
; ------------------------------------------------------------------------------
Function SelectQuests()
    bool questsAvailable = True
    Form[] missives = _GetMissives()
    int i = 0
    While (i < missives.Length)
        form item = missives[i]
        Quest missive = item as Quest
        missive.SetStage(20)
        i += 1
    EndWhile
    ActiveMissives = missives
EndFunction

String Function GetActiveMissivesStatus()
    if !IsRunning()
        return "Not active"
    endif
    if ActiveMissives == None || ActiveMissives.Length == 0
        return "Starting"
    endif
    int total = ActiveMissives.Length
    int finished = _GetFinishedQuestCount()
    return finished + "/" + total + " complete"
EndFunction

String Function GetActiveMissivesDetail()
    if !IsRunning()
        return "Forced adventuring is not active."
    endif
    if ActiveMissives == None || ActiveMissives.Length == 0
        return "Forced adventuring is active, but Lola has not selected Missives yet."
    endif

    string result = "Forced adventuring:\n"
    int i = 0
    while i < ActiveMissives.Length
        Quest missive = ActiveMissives[i] as Quest
        if missive != None
            string stateText = "active"
            if !missive.IsRunning()
                stateText = "done"
            endif
            result += "- " + missive.GetName() + " (" + stateText + ")\n"
        endif
        i += 1
    endwhile

    float hoursLeft = (endTime - cfg.GetGameTime()) * 24.0
    if hoursLeft > 0.0
        result += "\nAbout " + Math.Ceiling(hoursLeft) + " in-game hour(s) left."
    endif
    return result
EndFunction

Function ShowActiveMissivesMessage()
    Debug.MessageBox(GetActiveMissivesDetail())
EndFunction

Function EndAllMissives()
    cfg.Log("End All missives")
    int i = 0
    While (i < ActiveMissives.Length)
        form item = ActiveMissives[i]
        Quest missive = item as Quest
        if missive.isRunning()
            missive.SetStage(105)
            cfg.Log("End missive " + missive.GetName())
        endif
        i += 1
    EndWhile
EndFunction

Form[] Function _GetMissives()
    int countQuests = 0
    int max = cfg.misMaxQuests as int
    Form[] missives = PapyrusUtil.FormArray(max)
    countQuests += _UpdateQuests(QuestChanceLow.GetValue(), LowQ, max, countQuests, missives)
    countQuests += _UpdateQuests(QuestChanceMed.GetValue(), MedQ, max, countQuests, missives)
    countQuests += _UpdateQuests(QuestChanceHigh.GetValue(), HighQ, max, countQuests, missives)
    countQuests += _UpdateQuests(QuestChanceVeryHigh.GetValue(), VeryHighQ, max, countQuests, missives)

    if countQuests < max
        missives = Papyrusutil.ResizeFormArray(missives, countQuests)
    endif

    return missives
EndFunction

Function SetCurrentQuests()
    string currentLoc = cflLola.CurrentHold
    cfg.Log("We are in Hold " + currentLoc)
    if currentLoc == "Whiterun"
        VeryHighQ = WhiterunVeryHigh
        HighQ = WhiterunHigh
        MedQ = WhiterunMed
        LowQ = WhiterunLow
    ElseIf (currentLoc == "Solitude")
        VeryHighQ = HaafingarVeryHigh
        HighQ = HaafingarHigh
        MedQ = HaafingarMed
        LowQ = HaafingarLow
    ElseIf (currentLoc == "Windhelm")
        VeryHighQ = EastmarchVeryHigh
        HighQ = EastmarchHigh
        MedQ = EastmarchMed
        LowQ = EastmarchLow
    ElseIf (currentLoc == "Riften")
        VeryHighQ = RiftVeryHigh
        HighQ = RiftHigh
        MedQ = RiftMed
        LowQ = RiftLow
    ElseIf (currentLoc == "Markarth")
        VeryHighQ = ReachVeryHigh
        HighQ = ReachHigh
        MedQ = ReachMed
        LowQ = ReachLow
    ElseIf (currentLoc == "Falkreath")
        VeryHighQ = FalkreathVeryHigh
        HighQ = FalkreathHigh
        MedQ = FalkreathMed
        LowQ = FalkreathLow
    ElseIf (currentLoc == "Morthal")
        VeryHighQ = HjaalmarchVeryHigh
        HighQ = HjaalmarchHigh
        MedQ = HjaalmarchMed
        LowQ = HjaalmarchLow
    ElseIf (currentLoc == "Winterhold")
        VeryHighQ = WinterholdVeryHigh
        HighQ = WinterholdHigh
        MedQ = WinterholdMed
        LowQ = WinterholdLow
    ElseIf (currentLoc == "Dawnstar")
        VeryHighQ = PaleVeryHigh
        HighQ = PaleHigh
        MedQ = PaleMed
        LowQ = PaleLow
    Else
        ; We are not in a town
        VeryHighQ = None
        HighQ = None
        MedQ = None
        LowQ = None
    endif
EndFunction

; Function copied from Missives Activator Script
; Modified to fit the purpose but as close as possible to not interfere with missive base logic
int Function _UpdateQuests(float QuestChance, FormList QuestList, int maxQuests, int countQuests, Form[] Quests)
	int QuestIndex = 0
    int questsFound = 0
	while(QuestIndex < QuestList.GetSize() && countQuests < maxQuests)
		if(Utility.RandomInt() < QuestChance)
			Quest MissiveQuest = QuestList.GetAt(QuestIndex) as Quest
			;If the quest isn't running, start it up
			;If the quest is running, but hasn't been picked up by the player, reset it
			if(!MissiveQuest.IsRunning())
				bool Started = MissiveQuest.Start()
				if(Started)
					Debug.Trace("Missives: Starting Quest " + QuestIndex + ":" + MissiveQuest + ", in Quest List: " + QuestList)
                    Quests[countQuests] = MissiveQuest as Form
                    countQuests += 1
                    questsFound += 1
                    cfg.Log("Add missive to list: " + MissiveQuest.GetName())
				else
					Debug.Trace("Missives: Failed to Start Quest " + QuestIndex + ":" + MissiveQuest + ", in Quest List: " + QuestList)
				endIf
			elseif(MissiveQuest.GetStage() == 0)
				Debug.Trace("Missives: Stoping Quest " + QuestIndex + ":" + MissiveQuest + ", in Quest List: " + QuestList)
				MissiveQuest.SetStage(110)
			endIf
		endIf
		QuestIndex += 1
	endWhile
    return questsFound
endFunction

; ------------------------------------------------------------------------------
;                               Tracking Missives                               
; ------------------------------------------------------------------------------



Function SetTimer()
    endTime = cfg.GetGameTime() + cfg.misQuestTime
    ; check every 6 hours the status
    RegisterForSingleUpdateGameTime(6.0)
Endfunction

Event OnUpdateGametime()
    float currentTime = cfg.GetGameTime()
    int finished = _GetFinishedQuestCount()

    if finished >= ActiveMissives.Length
        cfg.Log("All Missives done")
        SetStage(5000)
        return
    endif

    ; ckeck if times is up
    if currentTime >= endTime
        cfg.Log("Time up, still Missives left")
        SetStage(5500)
        return
    endif

    ; still ongoing, register for next check
    cfg.Log("Time left, still Missives left")
    RegisterForSingleUpdateGameTime(6.0)
Endevent

int Function _GetFinishedQuestCount()
    int i = 0
    int countFinished = 0
    While (i < ActiveMissives.Length)
        Form item = ActiveMissives[i]
        Quest missive = item as Quest
        if !missive.isRunning()
            countFinished += 1
        endIf
        i += 1
    EndWhile
    return countFinished
endFunction

Function WalkToBoard()
    if !cfg.misWalkToBoard
        ; skip walking
        setStage(2000)
        return
    endif

    TargetBoard = GetBoard()
    if TargetBoard == None
        cfg.log("Board was empty, skipp", 2)
        SetStage(2000)
        return
    endif

    cflLola.SetBlockingEvent(True)
    SetObjectiveDisplayed(100)
    walkingQ.Start()
    RegisterForModEvent("cfl_WalkingEnd", "OnWalkingEnd")
    walkingQ.StartWalking(Owner, TargetBoard, cfg.ShowLeash)
Endfunction

Event OnWalkingEnd()
    walkingQ.Stop()
    UnregisterForModEvent("cfl_WalkingEnd")
    SetStage(1000)
    cflLola.SetBlockingEvent(False)
EndEvent

Event OwnerChanged()
    Alias_Owner.Clear()
    Alias_Owner.ForceRefTo(cfl_Config.GetConfig().Owner)
    Alias_T.Clear()
    Alias_T.ForceRefTo(lola.Title.GetReference())
EndEvent


ObjectReference Function GetBoard()
    string currentLoc = cflLola.CurrentHold
    cfg.Log("We are in Hold " + currentLoc)
    if currentLoc == "Whiterun"
        return BoardWhiterun
    ElseIf (currentLoc == "Solitude")
        return BoardHaafingar
    ElseIf (currentLoc == "Windhelm")
        return BoardEastmarch
    ElseIf (currentLoc == "Riften")
        return BoardRiften
    ElseIf (currentLoc == "Markarth")
        return BoardReach
    ElseIf (currentLoc == "Falkreath")
        return BoardFalkreath
        LowQ = FalkreathLow
    ElseIf (currentLoc == "Morthal")
        return BoardHjaalmarch
    ElseIf (currentLoc == "Winterhold")
        return BoardWinterhold
    ElseIf (currentLoc == "Dawnstar")
        return BoardPale
    Else
        ; We are not in a town
        return None
    endif
EndFunction


Function Init()
    cfg      = cfl_config.GetConfig()
    cflLola  = cfl_config.GetCflLola()
    walkingQ = cfg.walkQuest
    Owner    = cfg.Owner
    Player   = cfg.Player
    lola     = cfg.lola

    ; Fill Missives Quest Formlists
    _FillFormListProperties()
    _GetExternalReferences()
    _FillBoards()
    RegisterForModEvent("cfeLola_OwnerChanged", "OwnerChanged")
EndFunction

Function _GetExternalReferences()
    QuestChanceVeryHigh = Game.GetFormFromFile(0x9450, "Missives.esp") as GlobalVariable
    QuestChanceHigh     = Game.GetFormFromFile(0x1D95, "Missives.esp") as GlobalVariable
    QuestChanceMed      = Game.GetFormFromFile(0x1D94, "Missives.esp") as GlobalVariable
    QuestChanceLow      = Game.GetFormFromFile(0x1D93, "Missives.esp") as GlobalVariable
    Gold                = Game.GetFormFromFile(0xF ,"Skyrim.esm") as MiscObject
EndFunction

; ------------------------------------------------------------------------------
;                                    Boards                                     
; ------------------------------------------------------------------------------
ObjectReference Property BoardReach      Auto
ObjectReference Property BoardPale       Auto
ObjectReference Property BoardEastmarch  Auto
ObjectReference Property BoardFalkreath  Auto
ObjectReference Property BoardHaafingar  Auto
ObjectReference Property BoardHjaalmarch Auto
ObjectReference Property BoardRiften     Auto
ObjectReference Property BoardWhiterun   Auto
ObjectReference Property BoardWinterhold  Auto

Function _FillBoards()
    ; just check if we have a single empty
    ; if not empty we assume it's still filled
    if BoardReach != None
        return
    endif

    BoardReach        = Game.GetFormFromFile(0x94A3, "Missives.esp") as ObjectReference
    BoardPale         = Game.GetFormFromFile(0x94B1, "Missives.esp") as ObjectReference
    BoardEastmarch    = Game.GetFormFromFile(0x9478, "Missives.esp") as ObjectReference
    BoardFalkreath    = Game.GetFormFromFile(0x94A9, "Missives.esp") as ObjectReference
    BoardHaafingar    = Game.GetFormFromFile(0x9490, "Missives.esp") as ObjectReference
    BoardHjaalmarch   = Game.GetFormFromFile(0x94AD, "Missives.esp") as ObjectReference
    BoardRiften       = Game.GetFormFromFile(0x9492, "Missives.esp") as ObjectReference
    BoardWhiterun     = Game.GetFormFromFile(0xD66,  "Missives.esp") as ObjectReference
    BoardWinterhold   = Game.GetFormFromFile(0x94B5, "Missives.esp") as ObjectReference
Endfunction

; ------------------------------------------------------------------------------
;                                    Quests                                     
; ------------------------------------------------------------------------------

Function _FillFormListProperties()

    ; just check if we have a single empty
    ; if not empty we assume it's still filled
    if ReachVeryHigh != None
        return
    endif

    ReachVeryHigh      = Game.GetFormFromFile(0x945E, "Missives.esp") as FormList
    ReachHigh          = Game.GetFormFromFile(0x9469, "Missives.esp") as FormList
    ReachMed           = Game.GetFormFromFile(0x946C, "Missives.esp") as FormList
    ReachLow           = Game.GetFormFromFile(0x946B, "Missives.esp") as FormList

    PaleVeryHigh       = Game.GetFormFromFile(0x945A, "Missives.esp") as FormList
    PaleHigh           = Game.GetFormFromFile(0x945D, "Missives.esp") as FormList
    PaleMed            = Game.GetFormFromFile(0x945B, "Missives.esp") as FormList
    PaleLow            = Game.GetFormFromFile(0x945C, "Missives.esp") as FormList

    EastmarchVeryHigh  = Game.GetFormFromFile(0x9454, "Missives.esp") as FormList
    EastmarchHigh      = Game.GetFormFromFile(0x9453, "Missives.esp") as FormList
    EastmarchMed       = Game.GetFormFromFile(0x9452, "Missives.esp") as FormList
    EastmarchLow       = Game.GetFormFromFile(0x1D91, "Missives.esp") as FormList

    FalkreathVeryHigh  = Game.GetFormFromFile(0x9454, "Missives.esp") as FormList
    FalkreathHigh      = Game.GetFormFromFile(0x9461, "Missives.esp") as FormList
    FalkreathMed       = Game.GetFormFromFile(0x9464, "Missives.esp") as FormList
    FalkreathLow       = Game.GetFormFromFile(0x9463, "Missives.esp") as FormList

    HaafingarVeryHigh  = Game.GetFormFromFile(0x9466, "Missives.esp") as Formlist 
    HaafingarHigh      = Game.GetFormFromFile(0x9465, "Missives.esp") as Formlist 
    HaafingarMed       = Game.GetFormFromFile(0x9467, "Missives.esp") as Formlist 
    HaafingarLow       = Game.GetFormFromFile(0x9468, "Missives.esp") as Formlist 

    HjaalmarchVeryHigh = Game.GetFormFromFile(0x9456, "Missives.esp") as FormList
    HjaalmarchHigh     = Game.GetFormFromFile(0x9455, "Missives.esp") as FormList
    HjaalmarchMed      = Game.GetFormFromFile(0x9457, "Missives.esp") as FormList
    HjaalmarchLow      = Game.GetFormFromFile(0x9458, "Missives.esp") as FormList

    RiftVeryHigh       = Game.GetFormFromFile(0x946A, "Missives.esp") as FormList
    RiftHigh           = Game.GetFormFromFile(0x9469, "Missives.esp") as FormList
    RiftMed            = Game.GetFormFromFile(0x946C, "Missives.esp") as FormList
    RiftLow            = Game.GetFormFromFile(0x946B, "Missives.esp") as FormList

    WhiterunVeryHigh   = Game.GetFormFromFile(0x9451, "Missives.esp") as FormList
    WhiterunHigh       = Game.GetFormFromFile(0x1D92, "Missives.esp") as FormList
    WhiterunMed        = Game.GetFormFromFile(0x1D90, "Missives.esp") as FormList
    WhiterunLow        = Game.GetFormFromFile(0x1D8F, "Missives.esp") as FormList

    WinterholdVeryHigh = Game.GetFormFromFile(0x946E, "Missives.esp") as FormList
    WinterholdHigh     = Game.GetFormFromFile(0x946D, "Missives.esp") as FormList
    WinterholdMed      = Game.GetFormFromFile(0x946F, "Missives.esp") as FormList
    WinterholdLow      = Game.GetFormFromFile(0x9470, "Missives.esp") as FormList 
EndFunction

FormList Property ReachVeryHigh      Auto
FormList Property ReachHigh          Auto
FormList Property ReachMed           Auto
FormList Property ReachLow           Auto

FormList Property PaleVeryHigh       Auto
FormList Property PaleHigh           Auto
FormList Property PaleMed            Auto
FormList Property PaleLow            Auto

FormList Property EastmarchVeryHigh  Auto
FormList Property EastmarchHigh      Auto
FormList Property EastmarchMed       Auto
FormList Property EastmarchLow       Auto

FormList Property FalkreathVeryHigh  Auto
FormList Property FalkreathHigh      Auto
FormList Property FalkreathMed       Auto
FormList Property FalkreathLow       Auto

FormList Property HaafingarVeryHigh  Auto
FormList Property HaafingarHigh      Auto
FormList Property HaafingarMed       Auto
FormList Property HaafingarLow       Auto

FormList Property HjaalmarchVeryHigh Auto
FormList Property HjaalmarchHigh     Auto
FormList Property HjaalmarchMed      Auto
FormList Property HjaalmarchLow      Auto

FormList Property RiftVeryHigh       Auto
FormList Property RiftHigh           Auto
FormList Property RiftMed            Auto
FormList Property RiftLow            Auto

FormList Property WhiterunVeryHigh   Auto
FormList Property WhiterunHigh       Auto
FormList Property WhiterunMed        Auto
FormList Property WhiterunLow        Auto

FormList Property WinterholdVeryHigh Auto
FormList Property WinterholdHigh     Auto
FormList Property WinterholdMed      Auto
FormList Property WinterholdLow      Auto
