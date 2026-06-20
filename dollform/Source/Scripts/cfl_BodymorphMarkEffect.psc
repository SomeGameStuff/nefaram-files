Scriptname cfl_BodymorphMarkEffect extends ActiveMagicEffect

GlobalVariable Property MarkTierGlobal Auto
Int Property MarkTier = 1 Auto
String Property TattooSection = "Bodymorph" Auto
String Property TattooName = "" Auto
String Property FormName = "Bodymorph" Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If akTarget != Game.GetPlayer()
		Dispel()
		Return
	EndIf

	If MarkTierGlobal.GetValueInt() < MarkTier
		MarkTierGlobal.SetValue(MarkTier)
	EndIf

	If TattooName != ""
		SlaveTats.simple_add_tattoo(akTarget, TattooSection, TattooName, 0xFFFFFFFF, true, false, 0.85)
		SlaveTats.synchronize_tattoos(akTarget, true)
	EndIf

	Debug.Notification(FormName + " mark tier " + MarkTier + " settles into your body.")
	Dispel()
EndEvent
