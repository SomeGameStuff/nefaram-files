Scriptname cfl_FeralKinshipApproachEffect extends ActiveMagicEffect

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If !akTarget
		Dispel()
		Return
	EndIf
	Int token = StorageUtil.GetIntValue(akTarget, "Feral.Kinship.ApproachToken")
	Bool pathed = akTarget.PathToReference(Game.GetPlayer(), 0.75)
	Int success = 0
	If pathed && StorageUtil.GetIntValue(akTarget, "Feral.Kinship.ApproachToken") == token && akTarget.GetDistance(Game.GetPlayer()) <= 300.0
		success = 1
	EndIf
	Int handle = ModEvent.Create("FeralKinshipApproachResult")
	If handle
		ModEvent.PushForm(handle, akTarget)
		ModEvent.PushInt(handle, token)
		ModEvent.PushInt(handle, success)
		ModEvent.Send(handle)
	EndIf
EndEvent
