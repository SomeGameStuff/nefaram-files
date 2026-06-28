Scriptname SSR_RingGreaterEffect extends ActiveMagicEffect

String Property PluginName = "Spatial Storage Rings.esp" AutoReadOnly
Int Property Capacity = 300 AutoReadOnly

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If akTarget == Game.GetPlayer()
		ApplyRingCapacity(Capacity)
	EndIf
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	If akTarget == Game.GetPlayer()
		ClearRingCapacityIfNeeded()
	EndIf
EndEvent

Function ApplyRingCapacity(Int aiCapacity)
	GlobalVariable capacityGlobal = Game.GetFormFromFile(0x000800, PluginName) as GlobalVariable
	Spell accessSpell = Game.GetFormFromFile(0x000804, PluginName) as Spell
	Actor playerRef = Game.GetPlayer()

	If capacityGlobal
		capacityGlobal.SetValue(aiCapacity)
	EndIf

	If accessSpell
		playerRef.AddSpell(accessSpell, False)
	EndIf
EndFunction

Function ClearRingCapacityIfNeeded()
	Utility.Wait(0.1)

	Actor playerRef = Game.GetPlayer()
	Keyword ringKeyword = Game.GetFormFromFile(0x000810, PluginName) as Keyword
	If ringKeyword && playerRef.WornHasKeyword(ringKeyword)
		Return
	EndIf

	GlobalVariable capacityGlobal = Game.GetFormFromFile(0x000800, PluginName) as GlobalVariable
	Spell accessSpell = Game.GetFormFromFile(0x000804, PluginName) as Spell

	If capacityGlobal
		capacityGlobal.SetValue(0)
	EndIf

	If accessSpell
		playerRef.RemoveSpell(accessSpell)
	EndIf
EndFunction
