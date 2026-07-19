Scriptname cfl_FeralAspectEffect extends ActiveMagicEffect

Int _family
Float _first
Float _second

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If akTarget != Game.GetPlayer()
		Dispel()
		Return
	EndIf
	If StorageUtil.GetIntValue(akTarget, "Feral.AspectActive") > 0
		Debug.Notification("Feral: an aspect is already active.")
		Dispel()
		Return
	EndIf
	_family = StorageUtil.GetIntValue(akTarget, "Feral.Selected")
	If _family < 1
		Debug.Notification("Feral: select an unlocked aspect in the Feral MCM.")
		Dispel()
		Return
	EndIf
	Quest controller = Game.GetFormFromFile(0x000950, "Feral.esp") as Quest
	cfl_FeralMCM feral = controller as cfl_FeralMCM
	If !feral || feral.GetRank(_family) < 1
		Debug.Notification("Feral: that instinct is not yet awakened.")
		Dispel()
		Return
	EndIf
	Apply(akTarget)
	StorageUtil.SetIntValue(akTarget, "Feral.AspectActive", 1)
	RegisterForSingleUpdate(120.0)
EndEvent

Event OnUpdate()
	Dispel()
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	If akTarget == Game.GetPlayer() && _family > 0
		Remove(akTarget)
		StorageUtil.SetIntValue(akTarget, "Feral.AspectActive", 0)
	EndIf
EndEvent

Function Apply(Actor p)
	If _family == 1
		_first = 15.0
		_second = 25.0
		p.ModActorValue("SpeedMult", _first)
		p.ModActorValue("StaminaRateMult", _second)
	ElseIf _family == 2
		_first = 15.0
		_second = 15.0
		p.ModActorValue("Sneak", _first)
		p.ModActorValue("UnarmedDamage", _second)
	ElseIf _family == 3
		_first = 80.0
		_second = 40.0
		p.ModActorValue("DamageResist", _first)
		p.ModActorValue("Health", _second)
	ElseIf _family == 4
		_first = 50.0
		_second = 50.0
		p.ModActorValue("PoisonResist", _first)
		p.ModActorValue("DiseaseResist", _second)
	ElseIf _family == 5
		_first = 75.0
		p.ModActorValue("PoisonResist", _first)
	ElseIf _family == 6
		_first = 65.0
		p.ModActorValue("DamageResist", _first)
	ElseIf _family == 7
		_first = 20.0
		_second = 60.0
		p.ModActorValue("SpeedMult", _first)
		p.ModActorValue("Stamina", _second)
	ElseIf _family == 8
		_first = 2.0
		_second = 35.0
		p.ModActorValue("HealRate", _first)
		p.ModActorValue("FireResist", -_second)
	EndIf
EndFunction

Function Remove(Actor p)
	If _family == 1
		p.ModActorValue("SpeedMult", -_first)
		p.ModActorValue("StaminaRateMult", -_second)
	ElseIf _family == 2
		p.ModActorValue("Sneak", -_first)
		p.ModActorValue("UnarmedDamage", -_second)
	ElseIf _family == 3
		p.ModActorValue("DamageResist", -_first)
		p.ModActorValue("Health", -_second)
	ElseIf _family == 4
		p.ModActorValue("PoisonResist", -_first)
		p.ModActorValue("DiseaseResist", -_second)
	ElseIf _family == 5
		p.ModActorValue("PoisonResist", -_first)
	ElseIf _family == 6
		p.ModActorValue("DamageResist", -_first)
	ElseIf _family == 7
		p.ModActorValue("SpeedMult", -_first)
		p.ModActorValue("Stamina", -_second)
	ElseIf _family == 8
		p.ModActorValue("HealRate", -_first)
		p.ModActorValue("FireResist", _second)
	EndIf
EndFunction
