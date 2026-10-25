; Compile-only contract checked against installed SkyUI/MCM Recorder.
Scriptname SKI_ConfigBase extends Quest

Int Property OPTION_FLAG_NONE = 0 AutoReadOnly
Int Property OPTION_FLAG_DISABLED = 1 AutoReadOnly
Int Property TOP_TO_BOTTOM = 2 AutoReadOnly
String Property ModName Auto
String[] Property Pages Auto
String Property CurrentPage
	String Function Get()
		Return ""
	EndFunction
EndProperty

Int Function GetVersion()
	Return 1
EndFunction
Function OnVersionUpdate(Int aiVersion)
EndFunction
Function OnConfigInit()
EndFunction
Function OnPageReset(String page)
EndFunction
Function OnOptionSelect(Int option)
EndFunction
Function OnOptionHighlight(Int option)
EndFunction
Function SetCursorFillMode(Int mode)
EndFunction
Function SetCursorPosition(Int position)
EndFunction
Int Function AddEmptyOption()
	Return 0
EndFunction
Int Function AddHeaderOption(String text, Int flags = 0)
	Return 0
EndFunction
Int Function AddTextOption(String text, String value, Int flags = 0)
	Return 0
EndFunction
Function SetInfoText(String text)
EndFunction
Function ForcePageReset()
EndFunction
