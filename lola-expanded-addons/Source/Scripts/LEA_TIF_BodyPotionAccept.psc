Scriptname LEA_TIF_BodyPotionAccept Extends TopicInfo Hidden

Function Fragment_0(ObjectReference akSpeakerRef)
    cfl_LolaMonitor monitor = Quest.GetQuest("cfl_Config") as cfl_LolaMonitor
    if monitor != None
        monitor.LBP_AcceptPotionEvent()
    endif
EndFunction
