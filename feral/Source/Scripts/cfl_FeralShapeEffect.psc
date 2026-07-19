Scriptname cfl_FeralShapeEffect extends ActiveMagicEffect

Import NiOverride

Int Property Family Auto
Int Property Rank Auto

String Property MorphKey = "Feral.Shapes" Auto
String Property VisibleMorphKey = "Feral.Shapes.Visible" Auto

Bool _ownsShape
Float _first
Float _second

Event OnEffectStart(Actor akTarget, Actor akCaster)
	Actor player = Game.GetPlayer()
	If akTarget != player || Family < 1 || Family > 8 || Rank < 1 || Rank > 3
		Dispel()
		Return
	EndIf
	Quest controller = Game.GetFormFromFile(0x000950, "Feral.esp") as Quest
	cfl_FeralMCM feral = controller as cfl_FeralMCM
	If !feral || feral.GetRank(Family) < Rank
		Debug.Notification("Feral: that shape has not been earned.")
		Dispel()
		Return
	EndIf
	GlobalVariable activeForm = Game.GetFormFromFile(0x000801, "Dollform.esp") as GlobalVariable
	If !activeForm
		Debug.Notification("Feral: Bodymorph Alterations is unavailable.")
		Dispel()
		Return
	EndIf
	If activeForm.GetValueInt() != 0
		Debug.Notification("Another transformation is already active. Use Return to Self first.")
		Dispel()
		Return
	EndIf
	activeForm.SetValue(100 + Family)
	StorageUtil.SetIntValue(player, "Feral.ActiveFamily", Family)
	StorageUtil.SetIntValue(player, "Feral.ActiveRank", Rank)
	_ownsShape = true
	ApplyStats(player)
	ApplyMorphs(player)
	ApplyMark(player)
	Debug.Notification("Feral " + feral.FamilyName(Family) + " shape takes hold.")
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	If !_ownsShape || akTarget != Game.GetPlayer()
		Return
	EndIf
	RemoveStats(akTarget)
	ClearVisuals(akTarget)
	GlobalVariable activeForm = Game.GetFormFromFile(0x000801, "Dollform.esp") as GlobalVariable
	If activeForm && activeForm.GetValueInt() == 100 + Family
		activeForm.SetValue(0)
	EndIf
	If StorageUtil.GetIntValue(akTarget, "Feral.ActiveFamily") == Family
		StorageUtil.SetIntValue(akTarget, "Feral.ActiveFamily", 0)
		StorageUtil.SetIntValue(akTarget, "Feral.ActiveRank", 0)
	EndIf
	_ownsShape = false
EndEvent

Float Function RankScale()
	If Rank == 1
		Return 0.50
	ElseIf Rank == 2
		Return 0.75
	EndIf
	Return 1.00
EndFunction

Function ApplyStats(Actor player)
	Float scale = RankScale()
	If Family == 1
		_first = 15.0 * scale
		_second = 25.0 * scale
		player.ModActorValue("SpeedMult", _first)
		player.ModActorValue("StaminaRateMult", _second)
	ElseIf Family == 2
		_first = 15.0 * scale
		_second = 15.0 * scale
		player.ModActorValue("Sneak", _first)
		player.ModActorValue("UnarmedDamage", _second)
	ElseIf Family == 3
		_first = 80.0 * scale
		_second = 40.0 * scale
		player.ModActorValue("DamageResist", _first)
		player.ModActorValue("Health", _second)
	ElseIf Family == 4
		_first = 50.0 * scale
		_second = 50.0 * scale
		player.ModActorValue("PoisonResist", _first)
		player.ModActorValue("DiseaseResist", _second)
	ElseIf Family == 5
		_first = 75.0 * scale
		player.ModActorValue("PoisonResist", _first)
	ElseIf Family == 6
		_first = 65.0 * scale
		player.ModActorValue("DamageResist", _first)
	ElseIf Family == 7
		_first = 20.0 * scale
		_second = 60.0 * scale
		player.ModActorValue("SpeedMult", _first)
		player.ModActorValue("Stamina", _second)
	ElseIf Family == 8
		_first = 2.0 * scale
		_second = 35.0 * scale
		player.ModActorValue("HealRate", _first)
		player.ModActorValue("FireResist", -_second)
	EndIf
EndFunction

Function RemoveStats(Actor player)
	If Family == 1
		player.ModActorValue("SpeedMult", -_first)
		player.ModActorValue("StaminaRateMult", -_second)
	ElseIf Family == 2
		player.ModActorValue("Sneak", -_first)
		player.ModActorValue("UnarmedDamage", -_second)
	ElseIf Family == 3
		player.ModActorValue("DamageResist", -_first)
		player.ModActorValue("Health", -_second)
	ElseIf Family == 4
		player.ModActorValue("PoisonResist", -_first)
		player.ModActorValue("DiseaseResist", -_second)
	ElseIf Family == 5
		player.ModActorValue("PoisonResist", -_first)
	ElseIf Family == 6
		player.ModActorValue("DamageResist", -_first)
	ElseIf Family == 7
		player.ModActorValue("SpeedMult", -_first)
		player.ModActorValue("Stamina", -_second)
	ElseIf Family == 8
		player.ModActorValue("HealRate", -_first)
		player.ModActorValue("FireResist", _second)
	EndIf
EndFunction

Function ApplyMorphs(Actor player)
	Float scale = RankScale()
	NiOverride.ClearBodyMorphKeys(player, MorphKey)
	NiOverride.ClearBodyMorphKeys(player, VisibleMorphKey)
	If Family == 1
		SetMorph(player, "MuscleLegs", 0.45 * scale)
		SetMorph(player, "CalfSize", 0.30 * scale)
		SetMorph(player, "MuscleButt", 0.30 * scale)
		SetMorph(player, "Waist", -0.18 * scale)
		SetMorph(player, "Arms", 0.15 * scale)
	ElseIf Family == 2
		SetMorph(player, "Thighs", 0.28 * scale)
		SetMorph(player, "Butt", 0.32 * scale)
		SetMorph(player, "Hips", 0.22 * scale)
		SetMorph(player, "Waist", -0.28 * scale)
		SetMorph(player, "Arms", -0.12 * scale)
	ElseIf Family == 3
		SetMorph(player, "Arms", 0.65 * scale)
		SetMorph(player, "MuscleArms", 0.75 * scale)
		SetMorph(player, "ShoulderWidth", 0.55 * scale)
		SetMorph(player, "MuscleLegs", 0.45 * scale)
		SetMorph(player, "Waist", 0.25 * scale)
	ElseIf Family == 4
		SetMorph(player, "Arms", -0.25 * scale)
		SetMorph(player, "Thighs", -0.18 * scale)
		SetMorph(player, "Waist", -0.30 * scale)
		SetMorph(player, "CalfSize", 0.18 * scale)
		SetMorph(player, "Butt", -0.12 * scale)
	ElseIf Family == 5
		SetMorph(player, "Waist", -0.55 * scale)
		SetMorph(player, "Hips", 0.38 * scale)
		SetMorph(player, "Butt", 0.45 * scale)
		SetMorph(player, "Arms", 0.20 * scale)
		SetMorph(player, "Thighs", 0.18 * scale)
	ElseIf Family == 6
		SetMorph(player, "ShoulderWidth", 0.42 * scale)
		SetMorph(player, "Arms", 0.48 * scale)
		SetMorph(player, "Waist", 0.38 * scale)
		SetMorph(player, "Thighs", 0.35 * scale)
		SetMorph(player, "CalfSize", 0.28 * scale)
	ElseIf Family == 7
		SetMorph(player, "Thighs", 0.55 * scale)
		SetMorph(player, "CalfSize", 0.48 * scale)
		SetMorph(player, "MuscleLegs", 0.75 * scale)
		SetMorph(player, "MuscleButt", 0.55 * scale)
		SetMorph(player, "Butt", 0.52 * scale)
		SetMorph(player, "Waist", -0.20 * scale)
	ElseIf Family == 8
		SetMorph(player, "Arms", 0.80 * scale)
		SetMorph(player, "MuscleArms", 0.90 * scale)
		SetMorph(player, "ShoulderWidth", 0.72 * scale)
		SetMorph(player, "MuscleLegs", 0.55 * scale)
		SetMorph(player, "Waist", 0.35 * scale)
	EndIf
	NiOverride.UpdateModelWeight(player)
	player.QueueNiNodeUpdate()
EndFunction

Function SetMorph(Actor player, String morph, Float value)
	NiOverride.SetBodyMorph(player, morph, MorphKey, PapyrusUtil.ClampFloat(value, -2.0, 3.0))
	NiOverride.SetBodyMorph(player, morph, VisibleMorphKey, PapyrusUtil.ClampFloat(value * 0.75, -2.0, 3.0))
EndFunction

Function ClearVisuals(Actor player)
	NiOverride.ClearBodyMorphKeys(player, MorphKey)
	NiOverride.ClearBodyMorphKeys(player, VisibleMorphKey)
	NiOverride.UpdateModelWeight(player)
	player.QueueNiNodeUpdate()
	String mark = MarkName()
	If mark != ""
		SlaveTats.simple_remove_tattoo(player, "Feral Shapes", mark, true, true)
		SlaveTats.synchronize_tattoos(player, true)
	EndIf
EndFunction

Function ApplyMark(Actor player)
	String mark = MarkName()
	If mark != ""
		SlaveTats.simple_add_tattoo(player, "Feral Shapes", mark, MarkColor(), true, true, 0.35 + (0.15 * Rank))
		SlaveTats.synchronize_tattoos(player, true)
	EndIf
EndFunction

String Function MarkName()
	If Family == 1
		Return "Wolf Pelt"
	ElseIf Family == 2
		Return "Sabre Stripes"
	ElseIf Family == 3
		Return "Bear Mantle"
	ElseIf Family == 4
		Return "Skeever Mottle"
	ElseIf Family == 5
		Return "Spider Chitin"
	ElseIf Family == 6
		Return "Mudcrab Carapace"
	ElseIf Family == 7
		Return "Horse Stride"
	ElseIf Family == 8
		Return "Troll Hide"
	EndIf
	Return ""
EndFunction

Int Function MarkColor()
	If Family == 1
		Return 0xFF646B73
	ElseIf Family == 2
		Return 0xFFB87932
	ElseIf Family == 3
		Return 0xFF4A2D1D
	ElseIf Family == 4
		Return 0xFF746659
	ElseIf Family == 5
		Return 0xFF3B1828
	ElseIf Family == 6
		Return 0xFF8A3D26
	ElseIf Family == 7
		Return 0xFF7A4A24
	ElseIf Family == 8
		Return 0xFF68706A
	EndIf
	Return 0xFFFFFFFF
EndFunction
