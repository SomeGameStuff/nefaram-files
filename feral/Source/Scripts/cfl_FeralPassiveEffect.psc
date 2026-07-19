Scriptname cfl_FeralPassiveEffect extends ActiveMagicEffect

Int Property Family Auto
Int Property Rank Auto

Float _first
Float _second
Bool _applied

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If akTarget != Game.GetPlayer() || Family < 1 || Family > 8 || Rank < 1 || Rank > 3
		Dispel()
		Return
	EndIf
	Apply(akTarget)
	_applied = true
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	If _applied && akTarget == Game.GetPlayer()
		Remove(akTarget)
		_applied = false
	EndIf
EndEvent

Function Apply(Actor player)
	If Family == 1
		_first = 2.0 * Rank
		_second = 3.0 * Rank
		player.ModActorValue("SpeedMult", _first)
		player.ModActorValue("StaminaRateMult", _second)
	ElseIf Family == 2
		_first = 5.0 * Rank
		_second = 2.0 * Rank
		player.ModActorValue("StaminaRateMult", _first)
		player.ModActorValue("UnarmedDamage", _second)
	ElseIf Family == 3
		_first = 8.0 * Rank
		_second = 8.0 * Rank
		player.ModActorValue("Health", _first)
		player.ModActorValue("DamageResist", _second)
	ElseIf Family == 4
		_first = 8.0 * Rank
		_second = 8.0 * Rank
		player.ModActorValue("PoisonResist", _first)
		player.ModActorValue("DiseaseResist", _second)
	ElseIf Family == 5
		_first = 12.0 * Rank
		player.ModActorValue("PoisonResist", _first)
	ElseIf Family == 6
		_first = 10.0 * Rank
		player.ModActorValue("DamageResist", _first)
	ElseIf Family == 7
		_first = 10.0 * Rank
		_second = 8.0 * Rank
		player.ModActorValue("Stamina", _first)
		player.ModActorValue("CarryWeight", _second)
	ElseIf Family == 8
		_first = 0.25 * Rank
		_second = 3.0 * Rank
		player.ModActorValue("HealRate", _first)
		player.ModActorValue("MeleeDamage", _second)
	EndIf
EndFunction

Function Remove(Actor player)
	If Family == 1
		player.ModActorValue("SpeedMult", -_first)
		player.ModActorValue("StaminaRateMult", -_second)
	ElseIf Family == 2
		player.ModActorValue("StaminaRateMult", -_first)
		player.ModActorValue("UnarmedDamage", -_second)
	ElseIf Family == 3
		player.ModActorValue("Health", -_first)
		player.ModActorValue("DamageResist", -_second)
	ElseIf Family == 4
		player.ModActorValue("PoisonResist", -_first)
		player.ModActorValue("DiseaseResist", -_second)
	ElseIf Family == 5
		player.ModActorValue("PoisonResist", -_first)
	ElseIf Family == 6
		player.ModActorValue("DamageResist", -_first)
	ElseIf Family == 7
		player.ModActorValue("Stamina", -_first)
		player.ModActorValue("CarryWeight", -_second)
	ElseIf Family == 8
		player.ModActorValue("HealRate", -_first)
		player.ModActorValue("MeleeDamage", -_second)
	EndIf
EndFunction
