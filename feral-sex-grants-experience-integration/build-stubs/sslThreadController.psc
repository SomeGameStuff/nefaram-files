Scriptname sslThreadController extends Quest
Actor Property PlayerRef Auto
Actor[] Property Positions Auto
sslBaseAnimation Property Animation Auto
Int Property ActorCount Auto
Bool Property HasCreature Auto
Int Function FindSlot(Actor target)
	Return -1
EndFunction
Bool Function IsVictim(Actor target)
	Return false
EndFunction
