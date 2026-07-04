Scriptname PD_DefeatHandler extends Quest Conditional

PD_Util Property Util Auto
PD_EventLoop Property EventLoop Auto
PD_EventManager Property EM Auto
PD_RestraintsManager Property RM Auto
PD_Config Property Config Auto
PD_FollowerManager Property FM Auto

Scene Property ApproachScene Auto
Scene Property RobberyScene Auto
Scene Property CrawlingViolationScene Auto

ReferenceAlias[] Property AggressorAliases Auto
ReferenceAlias[] Property VictimAliases Auto

Actor Property PlayerRef Auto

Actor[] Property Victims Auto Hidden
Actor[] Property Aggressors Auto Hidden

Int Property NumMaleVictims Auto Hidden
Int Property NumFemaleVictims Auto Hidden

Int Property NumMaleAggressors Auto Hidden
Int Property NumFemaleAggressors Auto Hidden

Actor[] Property SatisfiedAggressors Auto Hidden

AELStruggle struggle_api

PD_EventTemplate LastChosen

Bool DHLPSuspended = false

Bool Property Remembers = false Auto Conditional Hidden
Bool Property ShortDefeat = false Auto Conditional Hidden
Bool Property SkipRobbery = false Auto Conditional Hidden
Bool Property SkipEvents = false Auto Conditional Hidden
Bool Property RemoteReleaseOnly = false Auto Conditional Hidden

Bool Property Thane = false Auto Hidden Conditional

Bool spinlock = false
Bool escape = false
bool pairanim = false

String LAST_DEFEATED_TIME_KEY = "PD_LastDefeatedTime"
String LAST_DEFEATED_OUTCOME_KEY = "PD_LastDefeatedOutcome"

Bool Property IsHuman Auto Conditional Hidden
Bool Property UseRestraints Auto Conditional Hidden

Faction Property VictimFaction Auto
Faction Property StruggleFaction Auto

GlobalVariable Property Surrendered Auto

;krzp
Faction Property PD_AnimSelector Auto
Idle Property pa_HugA  Auto  

Function Setup()
    RegisterForSingleUpdate(0.1)
EndFunction

Event OnUpdate()
    SetStage(1)
EndEvent

Function StartDefeat()
    Util.LogInfo("Starting up defeat player victim rank = " + PlayerRef.GetFactionRank(VictimFaction))

    Acheron.DisableConsequence(true)

    Remembers = false
    ShortDefeat = false
    SkipRobbery = !Config.RM.RobberyEnabled
    SkipEvents = false
    RemoteReleaseOnly = false

    SendModEvent("PD_DefeatHandler_Start")

    escape = false

    if Config.DHLPSuspend
        Util.LogInfo("Suspending DHLP")
        DHLPSuspended = true
        SendModEvent("dhlp-Suspend")
    endIf

    ToggleBumpSpanks(false)

    if Config.ForcePlayerGender
        Util.SL.TreatAsFemale(PlayerRef)
    endIf

    RM.TrackRestraints(PlayerRef)

    if EventLoop.IsRunning()
        EventLoop.Stop()
    endIf

    ; check if first aggressor is a creature or not
    IsHuman = AggressorAliases[0].GetActorRef().HasKeywordString("ActorTypeNPC")
    UseRestraints = true
    if !IsHuman
       string raceKey = PD_Util.GetRaceKey(AggressorAliases[0].GetActorRef())
       ; Todo: Creatures using restraints could need more work. Scene PD_EventRegularRelease is
       ; intended for aggressors approaching victims and releasing restraints, but currently
       ; excluded for creatures. Would probably need some modifications, maybe in a separate copy.
       UseRestraints = raceKey == "Rieklings" || raceKey == "Falmers" || raceKey == "Giants"
    endIf
    Util.LogInfo("IsHuman: " + IsHuman + ", UseRestraints: " + UseRestraints)

    if !Config.StrugglesEnabled || RM.IsWearingRestraints(PlayerRef) || Surrendered.GetValue()
        
        ;krzp

        PlayerRef.AddToFaction(PD_AnimSelector)
        PlayerRef.SetFactionRank(PD_AnimSelector, 2)
        Util.LogInfo("Adding to faction, rank: " + PlayerRef.GetFactionRank(PD_AnimSelector))

        Actor akTarget = AggressorAliases[0].GetActorRef() as actor
        if akTarget == None
            Util.LogInfo("akTarget is None!")
            if RM.IsWearingRestraints(PlayerRef)
                RM.PlayWoundedIdle(PlayerRef)
            endIf
        else
            ;Utility.Wait(2)
            Util.LogInfo("Selected" + akTarget + "as our actor")
            AnimPair(akTarget)
        endif

        SetStage(10) ; start up robbery immediately
    else
        ApproachScene.ForceStart() ; start up struggle
    endIf
        
    spinlock = true

    Victims = PapyrusUtil.ActorArray(VictimAliases.Length)

    i = 0
    j = 0
    while i < VictimAliases.Length
        Actor victim = VictimAliases[i].GetRef() as Actor

        if victim
            if FM.IsDeviousFollower(victim) && FM.ExcludeDeviousFollowers
                FM.LetFollowerFlee(victim)
                if Acheron.IsDefeated(victim)
                    Acheron.RescueActor(victim, false)
                else
                    Acheron.PacifyActor(victim)
                endIf
            else
                Victims[j] = victim

                if Util.GetGender(victim)
                    NumFemaleVictims += 1
                else
                    NumMaleVictims += 1
                endIf
    
                RM.TrackRestraints(victim)
    
                if victim != PlayerRef
                    Util.LogInfo("Defeating " + victim.GetActorBase().GetName())
                    Acheron.DefeatActor(victim)
                endIf
    
                j += 1
            endIf
        endIf

        i += 1
    endWhile
    
    Victims = PapyrusUtil.ResizeActorArray(Victims, j)

    Util.LogInfo("Victims: " + Victims)
    
    Aggressors = PapyrusUtil.ActorArray(AggressorAliases.Length)

    float daysPassed = Utility.GetCurrentGameTime()
   
    int i = 0
    int j = 0
    while i < AggressorAliases.Length
        Actor aggressor = AggressorAliases[i].GetRef() as Actor

        if aggressor
            Acheron.RescueActor(aggressor, false)
            Acheron.PacifyActor(aggressor)
            Aggressors[j] = aggressor
            j += 1

            int aggGender = Util.GetGender(aggressor)
            if aggGender == 1
                NumFemaleAggressors += 1
            elseIf aggGender == 0
                NumMaleAggressors += 1
            endIf

            if IsHuman
                float lastSeen = StorageUtil.GetFloatValue(aggressor, LAST_DEFEATED_TIME_KEY, daysPassed - 14)

                float diff = daysPassed - lastSeen

                if diff < Config.NumDaysRemembered
                    Remembers = true
                endIf

                if diff < Config.ShortDefeatThreshold && Config.ShortDefeatThreshold > 0
                    ShortDefeat = true
                endIf
            endIf
        endIf

        i += 1
    endWhile

    if ShortDefeat && Config.ShortDefeatSkipRobbery
        SkipRobbery = true
    endIf

    if (ShortDefeat && Config.ShortDefeatSkipEvents) || (!IsHuman && !Config.CreatureContent)
        SkipEvents = true
    endIf

    if ShortDefeat && Config.ShortDefeatRemoteReleaseOnly
        RemoteReleaseOnly = true
    endIf
    
    Util.LogInfo("Remembers = " + Remembers + " ShortDefeat = " + ShortDefeat + " SkipRobbery = " + SkipRobbery + " SkipEvents = " + SkipEvents)

    Aggressors = PapyrusUtil.ResizeActorArray(Aggressors, j)
    Util.LogInfo("Aggressors: " + Aggressors)

    SatisfiedAggressors = PapyrusUtil.ActorArray(0)

    EventLoop.Start() ; just initialize the event loop (queue, etc.)

    spinlock = false
EndFunction

Function ToggleBumpSpanks(bool abToggle)
    int handle = ModEvent.Create("IPlay_ToggleBumpSpanks")
    if (handle)
        ModEvent.PushInt(handle, abToggle as int)
        ModEvent.Send(handle)
    endIf
EndFunction

Function MaybeSatisfyActors(Actor[] akAggressors)
    Actor[] NewlySatisfiedActors = new Actor[128]
    int j = 0

    int i = 0
    while i < akAggressors.length
        bool satisfied = Utility.RandomFloat(0, 1.0) <= Config.SatisfactionChance
        if satisfied
            NewlySatisfiedActors[j] = akAggressors[i]
            j += 1
        endIf
        i += 1
    endWhile

    NewlySatisfiedActors = PapyrusUtil.ResizeActorArray(NewlySatisfiedActors, j)
    SatisfiedAggressors = PapyrusUtil.MergeActorArray(SatisfiedAggressors, NewlySatisfiedActors, true)
EndFunction

Function StartStruggle(Actor akAggressor, Actor akVictim)
    if Config.StrugglesEnabled && IsHuman
        struggle_api = AELStruggle.Get()
        Util.LogInfo("Starting struggle")
        string callback = "PD_StruggleCallback" + akVictim.GetActorBase().GetName()
        Acheron.RescueActor(akVictim as Actor, false)
        If struggle_api.MakeStruggle(akAggressor, akVictim, callback, 70.0, 0.0)
            akAggressor.AddToFaction(StruggleFaction)
            
            ;krzp
            PlayerRef.AddToFaction(PD_AnimSelector)
            PlayerRef.SetFactionRank(PD_AnimSelector, 1)    
            Util.LogInfo("Adding to faction, rank: " + PlayerRef.GetFactionRank(PD_AnimSelector))
            RegisterForModEvent(callback, "OnStruggleEnd")
        Else
            Util.LogErr("There was an error starting my struggle scene")
        EndIf
    else
        Util.LogInfo("Skipping struggle")
        SetStage(10)
    endIf
EndFunction

Event OnStruggleEnd(Form akVictim, Form akAggressor, bool abVictimEscaped)
    (akAggressor as Actor).AddToFaction(StruggleFaction)
    if abVictimEscaped
        Util.LogInfo("Victim was not defeated")
        PlayerRef.RemoveFromFaction(PD_AnimSelector)
        EarlyRelease()
    else
        ;krzp
        Util.LogInfo("Victim was defeated")
        Actor akTarget = akAggressor as actor
        if akTarget == None
            Util.LogInfo("akTarget is None!")
        else
            Util.LogInfo("Selected" + akTarget + "as our actor")
        endif
        AnimPair(akTarget)
        SetStage(10)
    endIf
EndEvent

;krzp
Function AnimPair(actor akTarget)
    ;preparation & checks
    if akTarget == None
        ;our anim failed to play, fall back to the way how people who actually know how to code do it!!
        Util.LogInfo("akTarget is None in AnimPair, falling back to non-idle!")
        RM.PlayWoundedIdle(PlayerRef)
        return
    endif

    if Acheron.IsDefeated(PlayerRef)
        Acheron.RescueActor(PlayerRef, false)
    endIf
    
    Game.SetPlayerAIDriven(true)
    Game.ForceThirdPerson()
        
    akTarget.SetHeadTracking(false)
    PlayerRef.SetHeadTracking(false)
    
    ;if the player has the weapon out (case for the non-AEL struggle), remove it - otherwise everything goes BRRR
    PlayerRef.SheatheWeapon()
    while (PlayerRef.IsWeaponDrawn())
        Utility.wait(0.1)
    endwhile
    
    ;first revert to the idle for a brief second & then play our animation
    Debug.SendAnimationEvent(PlayerRef, "IdleForceDefaultState")
    Utility.wait(0.1)
    if PlayerRef.playIdleWithTarget(pa_HugA, akTarget)
        RegisterForAnimationEvent(PlayerRef, "PairEnd")
        Util.LogInfo("Animation started, faction rank: " + PlayerRef.GetFactionRank(PD_AnimSelector))
        Utility.Wait(3) ;so the idle gets picked up from a next submod
        PlayerRef.RemoveFromFaction(PD_AnimSelector)
        
        ;this was a good idea, but Skyrim's paired animation starting is a tad unreliable - 
        ;it can end up at this point in the script, but the actual animation will never play, 
        ;and the whole script hangs up waiting for an event that never comes
        ;Game.GetPlayer().WaitForAnimationEvent("PairEnd") 
        
        ;so here's an alternative animation failsafe mechanism, thanks to Frayed & naaitsab
        Float anifailsafe = 10.0
        pairanim = true
        While (pairanim && anifailsafe > 0.0)
            Utility.Wait(0.1)
            anifailsafe -= 0.1
        EndWhile
        
        if pairanim == false || anifailsafe == 0.0
            Util.LogInfo("Animation ended, rank removed: " + PlayerRef.GetFactionRank(PD_AnimSelector))
            Debug.SendAnimationEvent(PlayerRef, "PD_WriPose11")
            PlayerRef.SetHeadTracking(true)
            akTarget.SetHeadTracking(true)
        endif
    else 
        Util.LogInfo("Animation failed to start, falling back to regular programming.")
        PlayerRef.RemoveFromFaction(PD_AnimSelector)
        PlayerRef.SetHeadTracking(true)
        akTarget.SetHeadTracking(true)
        RM.PlayWoundedIdle(PlayerRef)
    endif

EndFunction

Function EarlyRelease()
    Debug.Notification("Enemies are hostile again.")
    LastChosen = none
    escape = true

    ClearVictims()
    ClearAggressors()
    Reset()
EndFunction

Function StartRobbery()
    Util.LogInfo("Starting robbery")
    
    while spinlock
        Util.LogInfo("Spinlock preventing intro from starting")
        Utility.Wait(0.5)
    endWhile

    if IsHuman && IsRobberyCapableHuman(AggressorAliases[0].GetActorRef()) && !SkipRobbery
        RobberyScene.ForceStart()
    else
        Util.LogInfo("Defeated by non-robber aggressor or robbery disabled - skipping robbery")
        StartEventLoop()
    endIf
EndFunction

Bool Function IsRobberyCapableHuman(Actor akAggressor)
    if !akAggressor
        return false
    endIf

    if !akAggressor.HasKeywordString("ActorTypeNPC")
        return false
    endIf

    if akAggressor.HasKeywordString("ActorTypeCreature") || akAggressor.HasKeywordString("ActorTypeAnimal") || akAggressor.HasKeywordString("ActorTypeUndead")
        return false
    endIf

    string raceKey = PD_Util.GetRaceKey(akAggressor)
    if raceKey == "Skeletons" || raceKey == "Draugrs"
        return false
    endIf

    return true
EndFunction

Function StartEventLoop()
    Util.LogInfo("Starting event loop")
    
    if SkipEvents
        Util.LogInfo("Skipping events and going straight to release")
        EventLoop.Reset()
        StartRelease()
        return
    endIf

    int handle = ModEvent.Create("CC_AllowHostile")

    if handle
        ModEvent.PushBool(handle, true)
        ModEvent.Send(handle)
    endIf

    EventLoop.SetStage(1) ; start the event loop for real
EndFunction

Function StartRelease()
    Util.LogInfo("Starting release event")

    LastChosen = EM.SelectReleaseEvent(RemoteReleaseOnly)

    if !LastChosen || !LastChosen.Start()
        if !EM.GetDefaultReleaseEvent().Start()
            EarlyRelease()
        endIf
    endIf
EndFunction

function OnCrawlingViolation(int aiType)
    if aiType == 0
        CrawlingViolationScene.Start()
        Util.WaitForScene(PlayerRef)
    endIf

    EarlyRelease()
endFunction

Function CleanFlags()
    if DHLPSuspended
        Util.LogInfo("Clearing DHLP Suspend")
        DHLPSuspended = false
        SendModEvent("dhlp-Resume")
    endIf
    SendModEvent("PD_DefeatHandler_End")
    SendModEvent("CC_Revert")

    if Config.ForcePlayerGender
        Util.SL.ClearForcedGender(PlayerRef)
    endIf

    Surrendered.SetValue(0)
    
    ToggleBumpSpanks(true)

    Acheron.DisableConsequence(false)
EndFunction 

Function ClearAggressors()    
    int i = 0
    Util.LogInfo("Clearing aggressors")
    float gameDaysPassed = Utility.GetCurrentGameTime()
    while i < Aggressors.Length
        if !escape
            StorageUtil.SetFloatValue(Aggressors[i], LAST_DEFEATED_TIME_KEY, gameDaysPassed)
            if LastChosen
                StorageUtil.SetStringValue(Aggressors[i], LAST_DEFEATED_OUTCOME_KEY, LastChosen.EventName)
            endIf
        endIf
        Acheron.ReleaseActor(Aggressors[i])
        i += 1
    endWhile

    CleanFlags()
EndFunction

Function ClearVictims()
    int i = 0
    Util.LogInfo("Clearing victims")
   
    while i < VictimAliases.Length
        Actor vic = VictimAliases[i].GetRef() as Actor
        if vic
            Util.LogInfo("Clearing " + vic.GetActorBase().GetName())
            RM.UnrestrainActor(vic)
            RM.UntrackRestraints(vic)
            RM.StopCrawling(vic)
            FM.ClearFollowerFlee(vic)
            if Acheron.IsDefeated(vic)
                Acheron.RescueActor(vic, true)
            else
                Acheron.ReleaseActor(vic)
            endIf
        endIf
        i += 1
    endWhile
EndFunction

Function UnequipWeapons(Actor akVictim)
    UnequipHand(akVictim, 0)
    UnequipHand(akVictim, 1)
EndFunction

Function UnequipHand(Actor akVictim, int hand)
    int itemType = akVictim.GetEquippedItemType(hand)
    
    Form item
    if itemType > 0 && (itemType < 9 || itemType > 10)
        item = akVictim.GetEquippedWeapon(!hand)
    elseIf itemType == 10
        item = akVictim.GetEquippedWeapon(!hand)
    endIf

    if item
        akVictim.UnequipItem(item, false, true)
    endIf
EndFunction

Function StripVictim(Actor akVictim)
    ; iterate through items w/ modifiable keyword and replace using json list
    ; the modified items are nostrip so SL won't touch them

    SexlabUtil.GetAPI().StripActor(akVictim, akVictim, false)
EndFunction

Function Recover(Actor akVictim)
    Acheron.RescueActor(akVictim, false)
EndFunction

Event OnAnimationEvent(ObjectReference akSource, string eventName)
  if (akSource == PlayerRef && eventName == "PairEnd")
    pairanim = false
    UnregisterForAnimationEvent(Playerref, "PairEnd")
  endIf
endEvent
