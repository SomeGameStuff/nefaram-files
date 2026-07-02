Scriptname cfl_lolaMain extends Quest

; ------------------------------------------------------------------------------
;                                  Properties                                   
; ------------------------------------------------------------------------------

ReferenceAlias Property Alias_Owner Auto
ReferenceAlias Property Alias_Playmate Auto
ReferenceAlias Property Alias_T Auto

bool              Property StartedEyeCandy = False    Auto
cfl_config        Property cfg                        Auto
vkjmq             Property lola                       Auto
ObjectReference[] Property AllowedToActivate          Auto
float             Property DaysInCurrentHold          Auto
string            Property _lastHold = "Tamriel"      Auto
string            Property LocationClass = "Adventuring" Auto

Actor Player
float holdStart

bool Property EyeCandyActive
    bool function get()
        return (cfg.Player.HasMagicEffect(cfg.EyeCandyEffect) && cfg.Player.HasMagicEffect(cfg.EyeCandyEffectExtended))
    endFunction
endProperty

bool Property PlaymateSameSex
    bool function get()
        if(Playmate)
            return (Playmate != None && Player.GetActorBase().GetSex() == Playmate.GetActorBase().GetSex())
        endif
        return false
    endFunction
endProperty

Actor Property Playmate
    Actor function get()
        return cfg.Playmate
    endFunction
endProperty

String Property CurrentHold
    String function get()
        if Player.IsInLocation(cfg.LocWhiterun)
            return "Whiterun"
        elseif Player.IsInLocation(cfg.LocSolitude)
            return "Solitude"
        elseif Player.IsInLocation(cfg.LocWindhelm)
            return "Windhelm"
        elseif Player.IsInLocation(cfg.LocRiften)
            return "Riften"
        elseif Player.IsInLocation(cfg.LocMarkarth)
            return "Markarth"
        elseif Player.IsInLocation(cfg.LocFalkreath)
            return "Falkreath"
        elseif Player.IsInLocation(cfg.LocMorthal)
            return "Morthal"
        elseif Player.IsInLocation(cfg.LocWinterhold)
            return "Winterhold"
        elseif Player.IsInLocation(cfg.LocDawnstar)
            return "Dawnstar"
        ; elseif currentLoc == cfg.LocRavenRock
        ;     return "RavenRock"
        ; elseif currentLoc == cfg.LocSkaalVillage
        ;     return "SkaalVillage"
        else
            return "Tamriel"
        endif
    endFunction
endProperty


String function getCurrentHold() Global
    Actor refPlayer = Game.GetPlayer()
    cfl_config tempcfg = cfl_config.GetConfig()
    if refPlayer.IsInLocation(tempcfg.LocWhiterun)
        return "Whiterun"
    elseif refPlayer.IsInLocation(tempcfg.LocSolitude)
        return "Solitude"
    elseif refPlayer.IsInLocation(tempcfg.LocWindhelm)
        return "Windhelm"
    elseif refPlayer.IsInLocation(tempcfg.LocRiften)
        return "Riften"
    elseif refPlayer.IsInLocation(tempcfg.LocMarkarth)
        return "Markarth"
    elseif refPlayer.IsInLocation(tempcfg.LocFalkreath)
        return "Falkreath"
    elseif refPlayer.IsInLocation(tempcfg.LocMorthal)
        return "Morthal"
    elseif refPlayer.IsInLocation(tempcfg.LocWinterhold)
        return "Winterhold"
    elseif refPlayer.IsInLocation(tempcfg.LocDawnstar)
        return "Dawnstar"
    ; elseif currentLoc == cfg.LocRavenRock
    ;     return "RavenRock"
    ; elseif currentLoc == cfg.LocSkaalVillage
    ;     return "SkaalVillage"
    else
        return "Tamriel"
    endif
endFunction

Bool Function inWhiterun()
    return "Whiterun" == CurrentHold
endFunction

Bool Function inSolitude()
    return "Solitude" == CurrentHold
endFunction

Bool Function inMarkarth()
    return "Markarth" == CurrentHold
endFunction

Bool Function inWindhelm()
    return "Windhelm" == CurrentHold
endFunction

Bool Function inRiften()
    return "Riften" == CurrentHold
endFunction



Bool Property SLS_Kennel_Available
    Bool function get()
        string hold = CurrentHold
        bool rh = (hold == "Riften" || hold == "Whiterun" || hold == "Markarth" || hold == "Solitude" || hold == "Windhelm")
        return (cfg.SLSAvailable && cfg.SLSAllow && rh)
    endFunction
endProperty

Bool Property SLS_is_Player_In_Kennel
    Bool function get()
        if (!cfg.SLSAvailable)
            cfg.Log("SLS not Available", 1)
            return False
        endif

        location current = Player.GetCurrentLocation()
        cfg.DebugOutput(current)
        if current.HasKeyword(cfg.SLSKennelKW)
            cfg.Log("Player in SLS Kennel")
            return True
        endif
        return False
    endFunction
endProperty

Bool Property isLolaBlocked
    Bool function get()
        return (lola.SuspendAll || lola.BlockEvents)
    endFunction
endProperty

Bool Property isPlayerBusy
    Bool function get()
        return (cfg.dd.IsAnimating(Player) || Player.GetCurrentScene() != none)
    endFunction
endProperty

Bool Property LongTasksRunning
    Bool function get()
        Quest lolaProstitution = Quest.GetQuest("vkjPimpedBasic")
        Bool pimpedRunning = lolaProstitution.IsRunning() && lolaProstitution.GetStage() >= 5
        Quest roadTrip = Quest.GetQuest("vkjRoadTrip")
        return (roadTrip.IsRunning() || pimpedRunning || CFL_LongAddonTaskRunning())
    endFunction
endProperty

Bool Function CFL_IsActiveTaskQuest(string questName, int minStage = 0, int maxStage = 64999)
    Quest taskQuest = Quest.GetQuest(questName)
    if taskQuest == None || !taskQuest.IsRunning()
        return false
    endif

    int stage = taskQuest.GetStage()
    return stage >= minStage && stage <= maxStage
EndFunction

Bool Function CFL_LongAddonTaskRunning()
    if CFL_IsActiveTaskQuest("cfl_SalesPet", 10)
        return true
    elseif CFL_IsActiveTaskQuest("cfl_PublicWhore", 0)
        return true
    elseif CFL_IsActiveTaskQuest("cfl_PublicService", 0)
        return true
    elseif CFL_IsActiveTaskQuest("cfl_Missives", 10)
        return true
    elseif CFL_IsActiveTaskQuest("cfl_ChangeTown", 10)
        return true
    elseif CFL_IsActiveTaskQuest("cfl_SlaveCaravan", 10)
        return true
    elseif CFL_IsActiveTaskQuest("cfl_SlaveCaravanStarter", 10)
        return true
    elseif CFL_IsActiveTaskQuest("cfl_LolaBuysAHouse", 10)
        return true
    elseif CFL_IsActiveTaskQuest("cfl_DungeonBait", 10)
        return true
    endif
    return false
EndFunction



Bool Property dhlpSuspended = False Auto
Bool Property dhlpSuspendedExternal = False Auto

Bool function isAllowedToActivate(ObjectReference ref)
    ;cfg.DebugOutput(AllowedToActivate)
    if (!ref || !AllowedToActivate)
        return False
    endif
    return (AllowedToActivate.find(ref) >= 0)
EndFunction

Function AddAllowedToActivate(ObjectReference ref)
    if !ref
        return
    endif
    if !AllowedToActivate
        AllowedToActivate = PapyrusUtil.ObjRefArray(1)
        AllowedToActivate[0] = ref
        return
    endif
    AllowedToActivate = PapyrusUtil.PushObjRef(AllowedToActivate, ref)
endfunction

Function ClearAllowedToActivate()
    ObjectReference[] Null
    AllowedToActivate = Null
EndFunction

; ------------------------------------------------------------------------------
;                                   Functions                                   
; ------------------------------------------------------------------------------


Function SetBlockingEvent(bool block)
    lola.SetBlockEvents(block)
EndFunction

Function dhlpSuspend()
    if !dhlpSuspendedExternal
        SendModEvent("dhlp-Suspend")
    endif
Endfunction

Function dhlpResume()
    if !dhlpSuspendedExternal
        SendModEvent("dhlp-Resume")
    endif
Endfunction

Function StartEyeCandy()
    if EyeCandyActive
        return
    endif
    cfg.lola.Strip()
    cfg.lolaTrick.DoEyeCandy()
    ;check if long eye candy is active or not
    if EyeCandyActive
        StartedEyeCandy = True
    endif
Endfunction

Function StopEyeCandyEarly()
    if (!EyeCandyActive || !StartedEyeCandy)
        return
    endif
    cfg.lolaTrick.DispelEyeCandy()
    StartedEyeCandy = False
Endfunction

Bool Function isLolaGaggedRunning()
    return (lola.GagQuest.IsRunning() && lola.GagQuest.GetStage() != 10)
Endfunction 


GlobalVariable Function GetCurrentHoldDebtVar()
    string hold = CurrentHold
    if hold == "Riften"
        return cfg.DebtRiften
    elseif hold == "Markarth"
        return cfg.DebtMarkarth
    elseif hold == "Solitude"
        return cfg.DebtSolitude
    elseif hold == "Windhelm"
        return cfg.DebtWindhelm
    elseif hold == "Whiterun"
        return cfg.DebtWhiterun
    endif
    return None
endFunction

; ------------------------------------------------------------------------------
;                              Follower Functions                               
; ------------------------------------------------------------------------------


Function _DismissFollower(Actor who)
    cfg.DebugOutput("Dismiss Follower")
    int Handle = Modevent.Create("cfl_DismissFollower")
    If (Handle)
		ModEvent.PushForm(Handle, who as Form)
		ModEvent.Send(Handle)
	Endif
EndFunction

Function _AddFollower(Actor who)
    int Handle = Modevent.Create("cfl_AddFollower")
    If (Handle)
		ModEvent.PushForm(Handle, who as Form)
		ModEvent.Send(Handle)
	Endif
EndFunction

Function DismissFollower(Actor who)
    cfg.DebugOutput("Dismiss Follower")
    cfe_FollowerFramework q = Quest.GetQuest("cfl_FollowerFramework") as cfe_FollowerFramework
    if !q.isRunning()
        q.Start()
        Utility.Wait(3)
    endif
    q.DismissFollower(who)
EndFunction

Function AddFollower(Actor who)
    cfg.DebugOutput("Add Follower")
    cfe_FollowerFramework q = Quest.GetQuest("cfl_FollowerFramework") as cfe_FollowerFramework
    if !q.isRunning()
        q.Start()
        Utility.Wait(3)
    endif
    q.AddFollower(who)
EndFunction


; ------------------------------------------------------------------------------
;                                    Scanner                                    
; ------------------------------------------------------------------------------
Actor Function ScanForPotentialLolaActor(int gender = 0)

    cfg.cflNpcScanner.Start()
    Utility.Wait(5)
    ReferenceAlias pot = cfg.cflNpcScanner.GetAliasByName("PotentialFollower") as ReferenceAlias
    Actor res = pot.GetActorRef()
    cfg.cflNpcScanner.Stop()
    ConsoleUtil.PrintMessage(res)
    if res
        return res
    endif

    ; ; Actor res = cfg.sexlab.FindAvailableActorByFaction(cfg.PotentialFollower, Player, Radius=5000, FindGender=gender, IgnoreRef1=cfg.Owner, IgnoreRef2=cfg.Playmate)
    ; res = cfg.sexlab.FindAvailableActorByFaction(cfg.PotentialFollower, Player)
    ; ConsoleUtil.PrintMessage(res)
    ; if res
    ;     return res
    ; endif
    ; res = cfg.sexlab.FindAvailableActorByFaction(cfg.PotentialHireling, Player, Radius=5000, FindGender=gender, IgnoreRef1=cfg.Owner, IgnoreRef2=cfg.Playmate)
    ; ConsoleUtil.PrintMessage(res)
    ; Actor[] p = new Actor[3]
    ; p[0] = cfg.Owner

    ; Actor[] r = cfg.sexlab.FindAvailablePartners(p, 3)
    ; ConsoleUtil.PrintMessage(r)

    ; ConsoleUtil.PrintMessage(cfg.sexlab.FindAvailableActor(Player))

    ; return res
EndFunction


; ------------------------------------------------------------------------------
;                              Internal functions                               
; ------------------------------------------------------------------------------
;Check if Location is Hold City
String Function GetHoldLocation(location currentLoc)
    cfg.DebugOutput("Checking in location for Hold") + currentLoc
    if Player.IsInLocation(cfg.LocWhiterun)
        return "Whiterun"
    elseif Player.IsInLocation(cfg.LocSolitude)
        return "Solitude"
    elseif Player.IsInLocation(cfg.LocWindhelm)
        return "Windhelm"
    elseif Player.IsInLocation(cfg.LocRiften)
        return "Riften"
    elseif Player.IsInLocation(cfg.LocMarkarth)
        return "Markarth"
    elseif Player.IsInLocation(cfg.LocFalkreath)
        return "Falkreath"
    elseif Player.IsInLocation(cfg.LocMorthal)
        return "Morthal"
    elseif Player.IsInLocation(cfg.LocWinterhold)
        return "Winterhold"
    elseif Player.IsInLocation(cfg.LocDawnstar)
        return "Dawnstar"
    ; elseif currentLoc == cfg.LocRavenRock
    ;     return "RavenRock"
    ; elseif currentLoc == cfg.LocSkaalVillage
    ;     return "SkaalVillage"
    else
        return "Tamriel"
    endif
Endfunction


String Function GetLocationType(location currentLoc)
    cfg.DebugOutput("Checking in location for Hold") + currentLoc
    if currentLoc == cfg.LocWhiterun
        return "Whiterun"
    elseif currentLoc == cfg.LocSolitude
        return "Solitude"
    elseif currentLoc == cfg.LocWindhelm
        return "Windhelm"
    elseif Player.IsInLocation(cfg.LocRiften)
        return "Riften"
    elseif currentLoc == cfg.LocMarkarth
        return "Markarth"
    elseif currentLoc == cfg.LocFalkreath
        return "Falkreath"
    elseif currentLoc == cfg.LocMorthal
        return "Morthal"
    elseif currentLoc == cfg.LocWinterhold
        return "Winterhold"
    elseif currentLoc == cfg.LocDawnstar
        return "Dawnstar"
    ; elseif currentLoc == cfg.LocRavenRock
    ;     return "RavenRock"
    ; elseif currentLoc == cfg.LocSkaalVillage
    ;     return "SkaalVillage"
    else
        return "Tamriel"
    endif
Endfunction


; ------------------------------------------------------------------------------
;                           External Mod Integrations                           
; ------------------------------------------------------------------------------

; Sends player to a kennel.
; Either directly specify a kennel via Hold or provide an actor. Player will be sent to the kennel with the corresponding CrimeFaction
; Holds: Whiterun, Solitude, Markarth, Windhelm or Riften
Function SendPlayerToSLSKennel(string hold)
    Int Handle = ModEvent.Create("_SLS_SendToKennel")
	If (Handle)
		ModEvent.PushForm(Handle, None)
        ModEvent.PushString(Handle, hold)
		ModEvent.Send(Handle)
	Endif
Endfunction

; If called from a topic script, the topic flag should be OnEnd with very short response text or the sound play function can hang.
Function GenericDance(actor target, int duration=-1)
    int danceTime = duration
	if danceTime == -1
		danceTime = lola.MCM.DanceDuration
	endif
    
	Idle danceIdle = lola.SelectDance()

	if danceIdle == lola.I_Dances[0]; The lame Cicero dance
		danceTime = 7
	endif
	
	Actor observer = target
	if (target != none)
		observer = target
		lola.ActorFacePlayer(observer)
		observer.SetLookAt(Player)
		lola.Watcher.ForceRefTo(observer)
	endif

	if lola.IsKneeling
		lola.EndKneel()
	endif
	bool wasHoldingItems = (Player.GetEquippedWeapon() != none) || (player.GetEquippedWeapon(true) != none) || (Player.GetEquippedShield() != none)
	if wasHoldingItems
		lola.UnequipHands()
	endif
	
	int musInstanceID = 0
	if lola.MCM.DanceMusicOption == 1
		musInstanceID = lola.DanceMusic.Play(Player)
	elseif lola.MCM.DanceMusicOption == 2
		musInstanceID = lola.DanceMusicCustom.Play(Player)
	endif

	Player.PlayIdle(danceIdle)
	Game.ForceThirdPerson()
	Game.DisablePlayerControls(False, True, True, False, True, True, True, True)
	if danceTime < 8
		lola.WaitEndOnCombat(danceTime)
	else
		lola.DanceCommentsQuest.Start()
		if !lola.WaitEndOnCombat(10)
			lola.ActorFacePlayer(observer)
			bool clapOnly = True
			if clapOnly
				Debug.SendAnimationEvent(observer, "IdleApplaud2")
			else
				observer.Say(lola.DanceComments); first comment after 10 seconds
			endif
			if danceTime >= 25
				if !lola.WaitEndOnCombat(15)
					lola.ActorFacePlayer(observer)
					if clapOnly
						Debug.SendAnimationEvent(observer, "IdleApplaud2")
					else
						; second comment after 15 more seconds
						observer.Say(lola.DanceComments)

					endif
					lola.WaitEndOnCombat(danceTime - 25)
				endif
			else
				lola.WaitEndOnCombat(danceTime - 10)
			endif
		endif
		lola.DanceCommentsQuest.Stop()
	endif

	Player.PlayIdle(lola.IdleDef)
	;Debug.SendAnimationEvent(PlayerRef, "IdleForceDefaultState")

	Game.EnablePlayerControls()
	observer.ClearLookAt()
	lola.Watcher.Clear()
	lola.MCM.TimesDanced = lola.MCM.TimesDanced + 1
	
	if lola.MCM.DanceMusicOption > 0
		Sound.StopInstance(musInstanceID)
	endif
EndFunction
; ------------------------------------------------------------------------------
;                               Lola Punishments                                
; ------------------------------------------------------------------------------



; ------------------------------------------------------------------------------
;                               Generic Responses                               
; ------------------------------------------------------------------------------
Function RebelliousResponse()
    lola.PunishForMinor()
EndFunction

Function SubmissiveResponse()
    if !lola.IsVerySubmissive
        lola.SmallReward()
    endif
EndFunction


Function GiveTownLoan(int loan)
    GlobalVariable debtVar = GetCurrentHoldDebtVar()
    if !debtVar
        cfg.Log("We are not in a valid Town", 1)
        return
    endif

    cfg.Player.Additem(cfg.Gold, loan)
    int debt = debtVar.GetValueInt()
    debtVar.SetValueInt(debt + loan)


endFunction

; ------------------------------------------------------------------------------
;                                    Events                                     
; ------------------------------------------------------------------------------
Event OnInit()

EndEvent


Event OnUpdate()
    CheckMovingToNextHold()
    CheckForPublicService()
    CheckForDefinedPlaymates()
    RegisterForSingleUpdate(60)
EndEvent

Function CheckForDefinedPlaymates()
    if (!cfg.PotentialPlaymates || cfg.PotentialPlaymates.Length < 3)
        cfg.TrickPMSPossible = False
        return
    endif
    cfg.TrickPMSPossible = True
EndFunction

Function CheckForPublicService()
    GlobalVariable debtVar = GetCurrentHoldDebtVar()
    
    if !debtVar
        cfg.DebugOutput("Checking debt but var is null" )
        cfg.DebtInCurrentTown = False
        return
    endif
    int debt = debtVar.GetValueInt()
    cfg.DebugOutput("debt in town: " + debt)
    if debt > 0
        cfg.DebtInCurrentTown = True
    else
        cfg.DebtInCurrentTown = False
    endif
EndFunction

Function CheckMovingToNextHold()
    string hold = CurrentHold
    float time = cfg.GetGameTime()
    if _lastHold != hold
        cfg.Log("Hold Changed, Reset Time")
        cfg.chtNext = time + cfg.chtMinTimeInHold
        cfg.scNext = time + cfg.chtMinTimeInHold
        _lastHold = hold
    endif
    ; Check for Public Service

EndFunction

Event OnReloadReferences()
    cfg.Log("lola_Monitor: Reference Reload")
    SetReferences()
    ResetModEvents()
EndEvent

Event OwnerChanged()
    cfg.OwnerStart = cfg.GameDaysPassed.GetValue()
    cfg.LoSNextStart = cfg.OwnerStart + cfg.LoSMinKeepTime
    Alias_Owner.Clear()
    Alias_Owner.ForceRefTo(cfg.Owner)
    Alias_T = GetAliasByName("T") as ReferenceAlias
    Alias_T.Clear()
    Alias_T.ForceRefTo(lola.Title.GetReference())
EndEvent

Event onPlaymateChange()
    Alias_Playmate.Clear()
    Alias_Playmate.ForceRefTo(cfg.Playmate)
EndEvent

Event OnDhlpSuspend(string eventName, string strArg, float numArg, Form sender)
	dhlpSuspended = true
	if (sender != self); suspend from another mod
		; Stop new events from starting during DHLP-Suspend
        dhlpSuspendedExternal = True
	endif
EndEvent

Event OnDhlpResume(string eventName, string strArg, float numArg, Form sender)
	dhlpSuspended = false
    dhlpSuspendedExternal = false
EndEvent


; ------------------------------------------------------------------------------
;                                 Base Function                                 
; ------------------------------------------------------------------------------

Function Init()
    SetReferences()
    RegisterEvents()
EndFunction

Function SetReferences()
    cfg = cfl_config.GetConfig()
    Player = Game.GetPlayer()
    lola = cfg.lola
EndFunction

Function RegisterEvents()
    cfg.Log("Register Events for Lola Main")
    RegisterForModEvent("cfeLola_TechReloadReferences", "OnReloadReferences")
	RegisterForModEvent("dhlp-Suspend", "OnDhlpSuspend")
	RegisterForModEvent("dhlp-Resume", "OnDhlpResume")
	RegisterForModEvent("cfeLola_OwnerChanged", "OwnerChanged")
    RegisterForSingleUpdate(60)
EndFunction

Function UnregisterEvents()
    UnregisterForModEvent("cfeLola_TechReloadReferences")
EndFunction

Function ResetModEvents()
    UnregisterEvents()
    RegisterEvents()
EndFunction
