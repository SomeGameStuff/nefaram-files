Scriptname cfl_LolaMonitor extends Quest

Float Property LBP_NextEventTime = 0.0 Auto

Function Init()
EndFunction

String Function LME_GetAssignmentStatusText()
    Return ""
EndFunction

String Function LME_GetAssignmentDetailText()
    Return ""
EndFunction

Bool Function LME_CanTurnInMilk()
    Return False
EndFunction

Bool Function LME_TurnInMilk()
    Return False
EndFunction

Bool Function LBP_AcceptPotionEvent()
    Return False
EndFunction
