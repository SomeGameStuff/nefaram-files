Scriptname MilkQUEST extends Quest

Spell Property BeingMilkedPassive Auto
Actor[] Property MILKmaid Auto
Actor[] Property MILKslave Auto
FormList Property MME_Milks Auto

Float Function getMilkCurrent(Actor akActor)
    Return 0.0
EndFunction

Float Function getMilkMaximum(Actor akActor)
    Return 1.0
EndFunction

Function MilkCycle(Actor akActor)
EndFunction

Function MilkPlayer()
EndFunction

Function AssignSlotMaid(Actor akActor)
EndFunction

Function milking(Actor akActor, Int mode = 0, Int pump = 1, Int preparation = 1)
EndFunction
