Scriptname SlaveTats Hidden

Bool Function simple_add_tattoo(Actor akActor, String asSection, String asName, Int aiColor, Bool abLast, Bool abSilent, Float afAlpha) Global
	Return false
EndFunction

Bool Function simple_remove_tattoo(Actor akActor, String asSection, String asName, Bool abLast, Bool abSilent) Global
	Return false
EndFunction

; Actual installed API's second argument is silent, not immediate.
Bool Function synchronize_tattoos(Actor akActor, Bool abSilent) Global
	Return false
EndFunction
