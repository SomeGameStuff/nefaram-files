Scriptname SexExpCommon extends Form
SexExpMCM Property TheMCM Auto Hidden
String Property Name Auto Hidden
Actor Property player Auto Hidden
Bool Property orgasm Auto
Event OnInit()
EndEvent
Function DebugMessage(String message)
EndFunction
Int Function Evaluate(String[] tags)
	Return 0
EndFunction
Function GrantExp(Int amount, Int actorCount = 1, Bool hasCreature = false, Bool expLoss = false, Bool hadOrgasm = true)
EndFunction
