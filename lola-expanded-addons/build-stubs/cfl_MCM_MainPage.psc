Scriptname cfl_MCM_MainPage extends Quest

Int Property OID_KEY_MainSetting_ConfigKey Auto
Int Property OID_KEY_Debug_DebugKey Auto
Int Property OID_KEY_MainSetting_EndWalkKey Auto

Function Page_MainSetting()
EndFunction

Function Page_SystemPage()
EndFunction

Function Page_Debug()
EndFunction

Bool Function MainSetting_OnHighlight(Int option)
    Return false
EndFunction

Bool Function Debug_OnHighlight(Int option)
    Return false
EndFunction

Bool Function SystemPage_OnHighlight(Int option)
    Return false
EndFunction

Bool Function MainSetting_OnSelect(Int option)
    Return false
EndFunction

Bool Function SystemPage_OnSelect(Int option)
    Return false
EndFunction

Bool Function Debug_OnSelect(Int option)
    Return false
EndFunction

Bool Function MainSetting_OnSliderOpen(Int option)
    Return false
EndFunction

Bool Function Debug_OnSliderOpen(Int option)
    Return false
EndFunction

Bool Function SystemPage_OnSliderOpen(Int option)
    Return false
EndFunction

Bool Function MainSetting_OnSliderAccept(Int option, Float value)
    Return false
EndFunction

Bool Function SystemPage_OnSliderAccept(Int option, Float value)
    Return false
EndFunction

Bool Function Debug_OnSliderAccept(Int option, Float value)
    Return false
EndFunction

Bool Function MainSetting_OnMenuOpen(Int option)
    Return false
EndFunction

Bool Function Debug_OnMenuOpen(Int option)
    Return false
EndFunction

Bool Function SystemPage_OnMenuOpen(Int option)
    Return false
EndFunction

Bool Function MainSetting_OnMenuAccept(Int option, Int index)
    Return false
EndFunction

Bool Function Debug_OnMenuAccept(Int option, Int index)
    Return false
EndFunction

Bool Function SystemPage_OnMenuAccept(Int option, Int index)
    Return false
EndFunction
