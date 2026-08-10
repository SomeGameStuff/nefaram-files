Scriptname MEPFarmerSlaverySlaveAlias extends ReferenceAlias

Event OnPlayerLoadGame()
    (GetOwningQuest() as MEP_FarmerSlaveryQuest).Register()
EndEvent

Event OnTimer(int aiTimerID)
    (GetOwningQuest() as MEP_FarmerSlaveryQuest).OnTimer(aiTimerID)
EndEvent

Event OnTimerNoMenuMode(int aiTimerID)
    OnTimer(aiTimerID)
EndEvent

Event OnTimerMenuMode(int aiTimerID)
    OnTimer(aiTimerID)
EndEvent

Event OnTimerGameTime(int aiTimerID)
    OnTimer(aiTimerID)
EndEvent
