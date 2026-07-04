Scriptname SKI_ConfigBase extends Quest

Int Property OPTION_FLAG_NONE = 0 AutoReadOnly
Int Property OPTION_FLAG_DISABLED = 1 AutoReadOnly
Int Property OPTION_FLAG_HIDDEN = 2 AutoReadOnly
Int Property TOP_TO_BOTTOM = 0 AutoReadOnly

String Property ModName Auto
String[] Property Pages Auto

Event OnConfigInit()
EndEvent

Event OnGameReload()
EndEvent

Event OnVersionUpdate(Int a_version)
EndEvent

Event OnPageReset(String a_page)
EndEvent

Event OnOptionHighlight(Int a_option)
EndEvent

Event OnOptionSelect(Int a_option)
EndEvent

Event OnOptionSliderOpen(Int a_option)
EndEvent

Event OnOptionSliderAccept(Int a_option, Float a_value)
EndEvent

Event OnOptionMenuOpen(Int a_option)
EndEvent

Event OnOptionMenuAccept(Int a_option, Int a_index)
EndEvent

Event OnOptionKeyMapChange(Int a_option, Int a_keyCode, String a_conflictControl, String a_conflictName)
EndEvent

Function SetCursorFillMode(Int aiMode)
EndFunction

Function SetCursorPosition(Int aiPosition)
EndFunction

Function AddHeaderOption(String asText, Int aiFlags = 0)
EndFunction

Function AddEmptyOption()
EndFunction

Int Function AddTextOption(String asText, String asValue, Int aiFlags = 0)
    Return 0
EndFunction

Int Function AddToggleOption(String asText, Bool abValue, Int aiFlags = 0)
    Return 0
EndFunction

Int Function AddSliderOption(String asText, Float afValue, String asFormat = "{0}", Int aiFlags = 0)
    Return 0
EndFunction

Int Function AddMenuOption(String asText, String asValue, Int aiFlags = 0)
    Return 0
EndFunction

Function SetInfoText(String asText)
EndFunction

Function SetToggleOptionValue(Int aiOption, Bool abValue, Bool abNoUpdate = false)
EndFunction

Function SetSliderOptionValue(Int aiOption, Float afValue, String asFormat = "{0}", Bool abNoUpdate = false)
EndFunction

Function SetMenuOptionValue(Int aiOption, String asValue, Bool abNoUpdate = false)
EndFunction

Function SetKeymapOptionValue(Int aiOption, Int aiKeyCode, Bool abNoUpdate = false)
EndFunction

Function SetSliderDialogStartValue(Float afValue)
EndFunction

Function SetSliderDialogDefaultValue(Float afValue)
EndFunction

Function SetSliderDialogRange(Float afMinValue, Float afMaxValue)
EndFunction

Function SetSliderDialogInterval(Float afValue)
EndFunction

Function SetMenuDialogOptions(String[] asOptions)
EndFunction

Function SetMenuDialogStartIndex(Int aiIndex)
EndFunction

Function SetMenuDialogDefaultIndex(Int aiIndex)
EndFunction

Bool Function ShowMessage(String asMessage, Bool abWithCancel = true, String asAcceptLabel = "$Accept", String asCancelLabel = "$Cancel")
    Return true
EndFunction

Function ForcePageReset()
EndFunction
