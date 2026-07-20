Scriptname cfl_FeralMCM extends Quest
Int Function GetActiveFamily()
	Return 0
EndFunction
Int Function GetMasteryLevel(Int family)
	Return 0
EndFunction
Int Function GetFamily(Actor target)
	Return 0
EndFunction
Int Function ShapeDurationForLevel(Int level)
	Return 0
EndFunction
Bool Function IsKinshipEnabled()
	Return false
EndFunction
Bool Function AreKinshipApproachesEnabled()
	Return false
EndFunction
Int Function GetKinshipMinimumLevel()
	Return 10
EndFunction
Int Function GetKinshipFrequency()
	Return 1
EndFunction
Int Function GetKinshipCooldownHours()
	Return 6
EndFunction
Function AddActivityMastery(Int family, Int points, String source = "activity")
EndFunction
