Scriptname cfl_FeralKinshipEffect extends ActiveMagicEffect

Import PO3_Events_AME

Actor _target
Float _aggressionDelta
Int _token
Bool _applied

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If !akTarget
		Dispel()
		Return
	EndIf
	_target = akTarget
	_token = StorageUtil.GetIntValue(akTarget, "Feral.Kinship.Token")
	_aggressionDelta = -akTarget.GetActorValue("Aggression")
	If _aggressionDelta != 0.0
		akTarget.ModActorValue("Aggression", _aggressionDelta)
	EndIf
	akTarget.StopCombat()
	akTarget.StopCombatAlarm()
	RegisterForHitEventEx(Self)
	_applied = true
EndEvent

Event OnHitEx(ObjectReference akAggressor, Form akSource, Projectile akProjectile, Bool abPowerAttack, Bool abSneakAttack, Bool abBashAttack, Bool abHitBlocked)
	Actor aggressor = akAggressor as Actor
	If !_applied || !aggressor
		Return
	EndIf
	If aggressor == Game.GetPlayer() || aggressor.IsPlayerTeammate()
		Int handle = ModEvent.Create("FeralKinshipBroken")
		If handle
			ModEvent.PushForm(handle, _target)
			ModEvent.PushInt(handle, _token)
			ModEvent.Send(handle)
		EndIf
	EndIf
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	UnregisterForAllHitEventsEx(Self)
	If _applied && akTarget && _aggressionDelta != 0.0
		akTarget.ModActorValue("Aggression", -_aggressionDelta)
	EndIf
	_applied = false
EndEvent
