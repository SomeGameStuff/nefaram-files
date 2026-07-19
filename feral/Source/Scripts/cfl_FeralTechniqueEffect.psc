Scriptname cfl_FeralTechniqueEffect extends ActiveMagicEffect

Int Property Family Auto

Bool _applied
Float _first
Float _second
Float _third
Float _fourth

Event OnEffectStart(Actor akTarget, Actor akCaster)
	Actor player = Game.GetPlayer()
	Quest controller = Game.GetFormFromFile(0x000950, "Feral.esp") as Quest
	cfl_FeralMCM feral = controller as cfl_FeralMCM
	If akTarget != player || akCaster != player || !feral || feral.GetActiveFamily() != Family || feral.GetMasteryLevel(Family) < 50
		Debug.Notification("Feral: this technique requires its matching active shape at mastery level 50.")
		Dispel()
		Return
	EndIf
	Float now = Utility.GetCurrentRealTime()
	Float readyAt = StorageUtil.GetFloatValue(player, "Feral.TechniqueReady." + Family)
	Float remaining = readyAt - now
	If remaining > 60.0
		; GetCurrentRealTime resets on application restart; a larger value belongs to a prior session.
		StorageUtil.UnsetFloatValue(player, "Feral.TechniqueReady." + Family)
	ElseIf remaining > 0.0
		Debug.Notification("Feral: that instinct needs " + Math.Ceiling(remaining) + " more seconds.")
		Dispel()
		Return
	EndIf
	StorageUtil.SetFloatValue(player, "Feral.TechniqueReady." + Family, now + 60.0)
	Int level = feral.GetMasteryLevel(Family)
	Bool apex = level >= 100
	_applied = true
	If Family == 1
		Spell howl = Game.GetForm(0x000CF791) as Spell
		If apex
			howl = Game.GetForm(0x000CF793) as Spell
		EndIf
		If howl
			howl.Cast(player, player)
		EndIf
	ElseIf Family == 2
		Spell vanish = Game.GetForm(0x00027EB6) as Spell
		If vanish
			vanish.Cast(player, player)
		EndIf
		_first = 0.25
		If apex
			_first = 0.50
		EndIf
		player.ModActorValue("AttackDamageMult", _first)
	ElseIf Family == 3
		_first = 50.0
		_second = 50.0
		If apex
			_first = 80.0
			_second = 100.0
		EndIf
		player.ModActorValue("UnarmedDamage", _first)
		player.ModActorValue("StaggerResist", _second)
	ElseIf Family == 4
		Spell plague = Game.GetForm(0x0004CCF9) as Spell
		If apex
			plague = Game.GetForm(0x0004CCFA) as Spell
		EndIf
		If plague
			plague.Cast(player, None)
		EndIf
	ElseIf Family == 5
		Spell web = Game.GetForm(0x0005AD5F) as Spell
		If web
			web.Cast(player, None)
		EndIf
	ElseIf Family == 6
		_first = 300.0
		_second = 50.0
		_third = -40.0
		If apex
			_first = 500.0
			_second = 75.0
			_third = -30.0
			_fourth = 25.0
		EndIf
		player.ModActorValue("DamageResist", _first)
		player.ModActorValue("Block", _second)
		player.ModActorValue("SpeedMult", _third)
		player.ModActorValue("MagicResist", _fourth)
	ElseIf Family == 7
		_first = 40.0
		_second = 200.0
		_third = 25.0
		If apex
			_first = 60.0
			_second = 300.0
			_third = 40.0
			Spell slowTime = Game.GetForm(0x00048AD0) as Spell
			If slowTime
				slowTime.Cast(player, player)
			EndIf
		EndIf
		player.ModActorValue("SpeedMult", _first)
		player.ModActorValue("StaminaRateMult", _second)
		player.ModActorValue("Marksman", _third)
	ElseIf Family == 8
		_first = 8.0
		_second = -50.0
		If apex
			_first = 15.0
			_second = -75.0
		EndIf
		player.ModActorValue("HealRate", _first)
		player.ModActorValue("FireResist", _second)
	EndIf
	player.ModActorValue("CarryWeight", 0.01)
	player.ModActorValue("CarryWeight", -0.01)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	If !_applied || akTarget != Game.GetPlayer()
		Return
	EndIf
	_applied = false
	If Family == 2
		akTarget.ModActorValue("AttackDamageMult", -_first)
	ElseIf Family == 3
		akTarget.ModActorValue("UnarmedDamage", -_first)
		akTarget.ModActorValue("StaggerResist", -_second)
	ElseIf Family == 6
		akTarget.ModActorValue("DamageResist", -_first)
		akTarget.ModActorValue("Block", -_second)
		akTarget.ModActorValue("SpeedMult", -_third)
		akTarget.ModActorValue("MagicResist", -_fourth)
	ElseIf Family == 7
		akTarget.ModActorValue("SpeedMult", -_first)
		akTarget.ModActorValue("StaminaRateMult", -_second)
		akTarget.ModActorValue("Marksman", -_third)
	ElseIf Family == 8
		akTarget.ModActorValue("HealRate", -_first)
		akTarget.ModActorValue("FireResist", -_second)
	EndIf
	akTarget.ModActorValue("CarryWeight", 0.01)
	akTarget.ModActorValue("CarryWeight", -0.01)
EndEvent
