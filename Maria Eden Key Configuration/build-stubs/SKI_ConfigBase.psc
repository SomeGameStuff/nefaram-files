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
Event OnOptionKeyMapChange(Int a_option, Int a_keyCode, String a_conflictControl, String a_conflictName)
EndEvent

Function SetCursorFillMode(Int mode)
EndFunction
Function AddHeaderOption(String text, Int flags = 0)
EndFunction
Function AddEmptyOption()
EndFunction
Int Function AddTextOption(String text, String value, Int flags = 0)
	Return 0
EndFunction
Int Function AddKeyMapOption(String text, Int keyCode, Int flags = 0)
	Return 0
EndFunction
Function SetInfoText(String text)
EndFunction
Function SetKeymapOptionValue(Int optionId, Int keyCode, Bool noUpdate = false)
EndFunction
Bool Function ShowMessage(String message, Bool withCancel = true, String acceptLabel = "$Accept", String cancelLabel = "$Cancel")
	Return true
EndFunction
Function ForcePageReset()
EndFunction
