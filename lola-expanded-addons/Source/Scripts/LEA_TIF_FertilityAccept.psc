Scriptname LEA_TIF_FertilityAccept Extends TopicInfo Hidden

Function Fragment_0(ObjectReference akSpeakerRef)
    cfl_Drugs drugs = Quest.GetQuest("cfl_Config") as cfl_Drugs
    if drugs != None
        drugs.LFMA_AcceptFertilityEvent()
    endif
EndFunction
