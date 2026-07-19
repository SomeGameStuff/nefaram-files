Scriptname SKI_ConfigBase extends Quest

Int Property OPTION_FLAG_NONE = 0 AutoReadOnly
Int Property OPTION_FLAG_DISABLED = 1 AutoReadOnly
Int Property TOP_TO_BOTTOM = 0 AutoReadOnly

String Property ModName Auto
String[] Property Pages Auto

Event OnConfigInit()
EndEvent

Event OnGameReload()
EndEvent

Event OnVersionUpdate(Int newVersion)
EndEvent

Event OnPageReset(String page)
EndEvent

Event OnOptionSelect(Int option)
EndEvent

Event OnOptionSliderOpen(Int option)
EndEvent

Event OnOptionSliderAccept(Int option, Float value)
EndEvent

Function SetCursorFillMode(Int mode)
EndFunction

Function SetCursorPosition(Int position)
EndFunction

Function AddEmptyOption()
EndFunction

Function SetInfoText(String text)
EndFunction

Function AddHeaderOption(String text, Int flags = 0)
EndFunction

Int Function AddTextOption(String text, String value, Int flags = 0)
	Return 0
EndFunction

Int Function AddToggleOption(String text, Bool value, Int flags = 0)
	Return 0
EndFunction

Int Function AddSliderOption(String text, Float value, String formatString = "{0}", Int flags = 0)
	Return 0
EndFunction

Function SetSliderDialogStartValue(Float value)
EndFunction

Function SetSliderDialogDefaultValue(Float value)
EndFunction

Function SetSliderDialogRange(Float minimum, Float maximum)
EndFunction

Function SetSliderDialogInterval(Float value)
EndFunction

Function SetSliderOptionValue(Int option, Float value, String formatString = "{0}", Bool noUpdate = false)
EndFunction

Function ForcePageReset()
EndFunction
