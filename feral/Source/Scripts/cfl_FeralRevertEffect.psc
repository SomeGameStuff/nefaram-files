Scriptname cfl_FeralRevertEffect extends ActiveMagicEffect

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If akCaster == Game.GetPlayer()
		Quest controller = Game.GetFormFromFile(0x000950, "Feral.esp") as Quest
		cfl_FeralMCM feral = controller as cfl_FeralMCM
		If feral
			feral.EndActiveShape()
		EndIf
	EndIf
	Dispel()
EndEvent
