Scriptname cfl_DollformMarkEffect extends ActiveMagicEffect

GlobalVariable Property cfl_DollformMarkTier Auto
Int Property MarkTier = 1 Auto
String Property TattooSection = "Dollform" Auto
String Property TattooName = "Porcelain Lines" Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If akTarget != Game.GetPlayer()
		Dispel()
		Return
	EndIf

	If cfl_DollformMarkTier.GetValueInt() < MarkTier
		cfl_DollformMarkTier.SetValue(MarkTier)
	EndIf

	SlaveTats.simple_add_tattoo(akTarget, TattooSection, TattooName, 0xFFFFFFFF, true, false, 0.85)
	Debug.Notification("The Dollform mark settles permanently into your skin.")
	Dispel()
EndEvent
