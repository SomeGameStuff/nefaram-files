Scriptname cfl_MCM_TaskOutfitSleep extends Quest

Int Property OID_KEY_Outfit_DressKey Auto

Function Page_Outfit()
EndFunction

Bool Function Outfit_OnHighlight(Int option)
    Return false
EndFunction

Bool Function Outfit_OnSelect(Int option)
    Return false
EndFunction

Bool Function Outfit_OnSliderOpen(Int option)
    Return false
EndFunction

Bool Function Outfit_OnSliderAccept(Int option, Float value)
    Return false
EndFunction

Bool Function Outfit_OnMenuOpen(Int option)
    Return false
EndFunction

Bool Function Outfit_OnMenuAccept(Int option, Int index)
    Return false
EndFunction
