Scriptname LEA_TIF_MilkStatus Extends TopicInfo Hidden

Function Fragment_0(ObjectReference akSpeakerRef)
    cfl_LolaMonitor monitor = Quest.GetQuest("cfl_Config") as cfl_LolaMonitor
    if monitor != None
        Debug.MessageBox(monitor.LME_GetAssignmentDetailText())
    endif
EndFunction
