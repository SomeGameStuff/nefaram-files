Scriptname MEP_MiniNeedsAlias extends ReferenceAlias

Faction Property MEPSuccubusFaction Auto
Actor Property PlayerRef Auto
Keyword Property MEPSkoomaKeyword Auto

mndController mndMiniNeeds
Form prevItem = none
int prevCount = 0
float prevTime = 0.0
Float lastSkoomaTime
int skoomaCounter

event OnInit()
    mndMiniNeeds = Quest.GetQuest("mndMiniNeeds") as mndController
    if mndMiniNeeds
        GotoState("hasNeeds")
        Debug.Notification("MiniNeeds Skooma Control enabled")
    endif
endevent

event OnPlayerLoadGame()
    mndMiniNeeds = Quest.GetQuest("mndMiniNeeds") as mndController
    if mndMiniNeeds && !mndMiniNeeds.enableSkooma
        GotoState("hasNeeds")
        Debug.Notification("MiniNeeds Skooma Control enabled")
    else
        GotoState("")
    endif
endevent

state hasNeeds
    Event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
        if akDestContainer || !akBaseItem.HasKeyword(MEPSkoomaKeyword)
            return
        endif
        if UI.IsMenuOpen("Crafting Menu") || (akBaseItem==prevItem && aiItemCount==prevCount && Utility.getCurrentRealTime() - prevTime < 500.0)
            prevItem = none
            prevCount = 0
            return
        endIf
        prevItem = akBaseItem
        prevCount = aiItemCount
        prevTime = Utility.getCurrentRealTime()
        if mndMiniNeeds.enableSkooma || PlayerRef.isInFaction(MEPSuccubusFaction)
            skoomaCounter = 0
            lastSkoomaTime = 0
            if mndMiniNeeds.enableSkooma
                mndMiniNeeds.enableSkooma = false
                ;(mndMiniNeeds.GetAliasByName("PlayerRef") as mndMiniNeedsPlayerScript).doInit()
                mndMiniNeeds.initWidgets()
	            mndMiniNeeds.calculateWidgets()
	            mndMiniNeeds.applyConfig()
            endif
            return
        endif
        if !akItemReference && !akDestContainer
            Potion food = akBaseItem as Potion
            if !food || akBaseItem==mndMiniNeeds.mndInvisibleWeight
                return
            endIf
            float now = Utility.GetCurrentGameTime()
            If mndMiniNeeds.mndSkooma.hasForm(food) && !lastSkoomaTime
                lastSkoomaTime = now
                return
            endIf
            if MariasUtils.CalcGameTimeHours(lastSkoomaTime,now) < 12
                skoomaCounter += 1
            else
                skoomaCounter = 0
            endif
            lastSkoomaTime = now
            if skoomaCounter > 1
                GotoState("")
                Debug.Notification("You are now addicted to skooma")
                ; (mndMiniNeeds.GetAliasByName("PlayerRef") as mndMiniNeedsPlayerScript).doInit()
                mndMiniNeeds.enableSkooma = true
                mndMiniNeeds.lastTimeSkooma = Math.floor(Utility.GetCurrentGameTime())
                mndMiniNeeds.initWidgets()
	            mndMiniNeeds.calculateWidgets()
	            ;mndMiniNeeds.applyConfig()
            endif
        endIf
    endevent
endstate
