Scriptname cfl_MCM_MiscTask extends Quest

Int Property OID_KEY_SmallTasks_scbreakKey Auto

Function Page_SmallTasks()
EndFunction

Function Page_Tricks()
EndFunction

Bool Function SmallTasks_OnHighlight(Int option)
    Return false
EndFunction

Bool Function Tricks_OnHighlight(Int option)
    Return false
EndFunction

Bool Function SmallTasks_OnSelect(Int option)
    Return false
EndFunction

Bool Function Tricks_OnSelect(Int option)
    Return false
EndFunction

Bool Function SmallTasks_OnSliderOpen(Int option)
    Return false
EndFunction

Bool Function Tricks_OnSliderOpen(Int option)
    Return false
EndFunction

Bool Function SmallTasks_OnSliderAccept(Int option, Float value)
    Return false
EndFunction

Bool Function Tricks_OnSliderAccept(Int option, Float value)
    Return false
EndFunction

Bool Function SmallTasks_OnMenuOpen(Int option)
    Return false
EndFunction

Bool Function Tricks_OnMenuOpen(Int option)
    Return false
EndFunction

Bool Function SmallTasks_OnMenuAccept(Int option, Int index)
    Return false
EndFunction

Bool Function Tricks_OnMenuAccept(Int option, Int index)
    Return false
EndFunction
