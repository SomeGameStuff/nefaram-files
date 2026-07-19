Scriptname cfl_FeralShapeEffect extends ActiveMagicEffect

Import NiOverride

Int Property Family Auto
Int Property Rank Auto

String Property MorphKey = "Feral.Shapes" Auto
String Property VisibleMorphKey = "Feral.Shapes.Visible" Auto

Bool _ownsShape
Int _activeToken
Bool _addedCosmetic
Bool _equippedCosmetic
Armor _cosmetic
Float _first
Float _second
Float _third
Float _fourth
Float _fifth
Float _expression
Float _milestoneFirst
Float _milestoneSecond
Float _milestoneThird
Float _milestoneFourth
Int _masteryLevel

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
	If !feral.CanBeginShape()
		Debug.Notification("Feral: transformation fatigue remains for " + feral.GetFatigueSecondsRemaining() + " seconds.")
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
	BeginActiveShape(player, activeForm)
	StorageUtil.SetIntValue(player, "Feral.ActiveFamily", Family)
	StorageUtil.SetIntValue(player, "Feral.ActiveRank", Rank)
	StorageUtil.SetIntValue(player, "Feral.ActiveToken", _activeToken)
	_expression = feral.GetExpressionScale(Family)
	_masteryLevel = feral.GetMasteryLevel(Family)
	StorageUtil.SetFloatValue(player, "Feral.ActiveExpression", _expression)
	_ownsShape = true
	ApplyStats(player)
	ApplyMilestoneTraits(player)
	ApplyMorphs(player)
	ApplyMark(player)
	EffectShader entryShader = Game.GetForm(0x000EBEC5) as EffectShader
	If entryShader
		entryShader.Play(player, 1.2)
	EndIf
	Sound transformSound = Game.GetForm(0x00051936) as Sound
	If transformSound
		transformSound.Play(player)
	EndIf
	Game.ShakeCamera(player, 0.35, 0.45)
	feral.RecordWitnessedTransformation(Family, _activeToken)
	Debug.Notification("Feral " + feral.FamilyName(Family) + " shape takes hold.")
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	If !_ownsShape || akTarget != Game.GetPlayer()
		Return
	EndIf
	_ownsShape = false
	Spell activeTechnique = Game.GetFormFromFile(0x000A10 + (Family - 1), "Feral.esp") as Spell
	If activeTechnique
		akTarget.DispelSpell(activeTechnique)
	EndIf
	RemoveStats(akTarget)
	RemoveMilestoneTraits(akTarget)
	GlobalVariable activeForm = Game.GetFormFromFile(0x000801, "Dollform.esp") as GlobalVariable
	Bool ownsCurrentShape = IsActiveInstance(activeForm)
	If ownsCurrentShape
		ClearVisuals(akTarget)
		RemoveCosmetic(akTarget)
	EndIf
	EffectShader exitShader = Game.GetForm(0x000EBECD) as EffectShader
	If exitShader && ownsCurrentShape
		exitShader.Play(akTarget, 0.8)
	EndIf
	If ownsCurrentShape
		Game.ShakeCamera(akTarget, 0.18, 0.25)
		activeForm.SetValue(0)
		StorageUtil.SetIntValue(akTarget, "Feral.ActiveFamily", 0)
		StorageUtil.SetIntValue(akTarget, "Feral.ActiveRank", 0)
		StorageUtil.SetIntValue(akTarget, "Feral.ActiveToken", 0)
		StorageUtil.UnsetFloatValue(akTarget, "Feral.ActiveExpression")
		Quest controller = Game.GetFormFromFile(0x000950, "Feral.esp") as Quest
		cfl_FeralMCM feral = controller as cfl_FeralMCM
		If feral
			feral.AddShapeTime(Family, GetTimeElapsed())
			feral.StartFeralFatigue()
		EndIf
	EndIf
EndEvent

Function BeginActiveShape(Actor player, GlobalVariable activeForm)
	_activeToken = StorageUtil.GetIntValue(player, "Feral.LastShapeToken") + 1
	If _activeToken > 90000
		_activeToken = 1
	EndIf
	StorageUtil.SetIntValue(player, "Feral.LastShapeToken", _activeToken)
	activeForm.SetValue(((100 + Family) * 100000) + _activeToken)
EndFunction

Function ApplyMilestoneTraits(Actor player)
	If _masteryLevel >= 25
		If Family == 1
			_milestoneFirst = 20.0
			player.ModActorValue("StaminaRateMult", _milestoneFirst)
		ElseIf Family == 2
			_milestoneFirst = -50.0
			player.ModActorValue("MovementNoiseMult", _milestoneFirst)
		ElseIf Family == 3
			_milestoneFirst = 50.0
			player.ModActorValue("DamageResist", _milestoneFirst)
		ElseIf Family == 4
			_milestoneFirst = 100.0
			player.ModActorValue("DiseaseResist", _milestoneFirst)
		ElseIf Family == 5
			_milestoneFirst = 10.0
			_milestoneSecond = 20.0
			player.ModActorValue("UnarmedDamage", _milestoneFirst)
			player.ModActorValue("PoisonResist", _milestoneSecond)
		ElseIf Family == 6
			_milestoneFirst = 50.0
			player.ModActorValue("DamageResist", _milestoneFirst)
		ElseIf Family == 7
			_milestoneFirst = 25.0
			_milestoneSecond = -0.50
			player.ModActorValue("StaminaRateMult", _milestoneFirst)
			player.ModActorValue("FallDamageMod", _milestoneSecond)
		ElseIf Family == 8
			_milestoneFirst = 1.0
			player.ModActorValue("HealRate", _milestoneFirst)
		EndIf
	EndIf
	If _masteryLevel >= 75
		If Family == 1
			_milestoneSecond = 75.0
			player.ModActorValue("DetectLifeRange", _milestoneSecond)
		ElseIf Family == 2
			_milestoneSecond = 0.25
			player.ModActorValue("AttackDamageMult", _milestoneSecond)
		ElseIf Family == 3
			_milestoneSecond = 100.0
			player.ModActorValue("StaggerResist", _milestoneSecond)
		ElseIf Family == 4
			_milestoneSecond = 20.0
			_milestoneThird = 10.0
			player.ModActorValue("Sneak", _milestoneSecond)
			player.ModActorValue("SpeedMult", _milestoneThird)
		ElseIf Family == 5
			_milestoneThird = 15.0
			player.ModActorValue("MagicResist", _milestoneThird)
		ElseIf Family == 6
			_milestoneSecond = 20.0
			_milestoneThird = 20.0
			player.ModActorValue("Block", _milestoneSecond)
			player.ModActorValue("StaggerResist", _milestoneThird)
		ElseIf Family == 7
			_milestoneThird = 20.0
			player.ModActorValue("Marksman", _milestoneThird)
		ElseIf Family == 8
			_milestoneSecond = 50.0
			_milestoneThird = 25.0
			player.ModActorValue("DamageResist", _milestoneSecond)
			player.ModActorValue("MeleeDamage", _milestoneThird)
		EndIf
	EndIf
	player.ModActorValue("CarryWeight", 0.01)
	player.ModActorValue("CarryWeight", -0.01)
EndFunction

Function RemoveMilestoneTraits(Actor player)
	If Family == 1
		player.ModActorValue("StaminaRateMult", -_milestoneFirst)
		player.ModActorValue("DetectLifeRange", -_milestoneSecond)
	ElseIf Family == 2
		player.ModActorValue("MovementNoiseMult", -_milestoneFirst)
		player.ModActorValue("AttackDamageMult", -_milestoneSecond)
	ElseIf Family == 3
		player.ModActorValue("DamageResist", -_milestoneFirst)
		player.ModActorValue("StaggerResist", -_milestoneSecond)
	ElseIf Family == 4
		player.ModActorValue("DiseaseResist", -_milestoneFirst)
		player.ModActorValue("Sneak", -_milestoneSecond)
		player.ModActorValue("SpeedMult", -_milestoneThird)
	ElseIf Family == 5
		player.ModActorValue("UnarmedDamage", -_milestoneFirst)
		player.ModActorValue("PoisonResist", -_milestoneSecond)
		player.ModActorValue("MagicResist", -_milestoneThird)
	ElseIf Family == 6
		player.ModActorValue("DamageResist", -_milestoneFirst)
		player.ModActorValue("Block", -_milestoneSecond)
		player.ModActorValue("StaggerResist", -_milestoneThird)
	ElseIf Family == 7
		player.ModActorValue("StaminaRateMult", -_milestoneFirst)
		player.ModActorValue("FallDamageMod", -_milestoneSecond)
		player.ModActorValue("Marksman", -_milestoneThird)
	ElseIf Family == 8
		player.ModActorValue("HealRate", -_milestoneFirst)
		player.ModActorValue("DamageResist", -_milestoneSecond)
		player.ModActorValue("MeleeDamage", -_milestoneThird)
	EndIf
	player.ModActorValue("CarryWeight", 0.01)
	player.ModActorValue("CarryWeight", -0.01)
EndFunction

Bool Function IsActiveInstance(GlobalVariable activeForm)
	If !activeForm
		Return false
	EndIf
	Int activeValue = activeForm.GetValueInt()
	Return ActiveFormId(activeValue) == 100 + Family && ActiveToken(activeValue) == _activeToken
EndFunction

Int Function ActiveFormId(Int activeValue)
	If activeValue >= 100000
		Return activeValue / 100000
	EndIf
	Return activeValue
EndFunction

Int Function ActiveToken(Int activeValue)
	If activeValue >= 100000
		Return activeValue - ((activeValue / 100000) * 100000)
	EndIf
	Return 0
EndFunction

Float Function RankScale()
	If _expression > 0.0
		Return _expression
	EndIf
	Quest controller = Game.GetFormFromFile(0x000950, "Feral.esp") as Quest
	cfl_FeralMCM feral = controller as cfl_FeralMCM
	If feral
		Return feral.GetExpressionScale(Family)
	EndIf
	Return 0.25
EndFunction

Function ApplyCosmetic(Actor player)
	If Rank != 3
		Return
	EndIf
	String configKey = "Family" + Family + "Rank3"
	String pluginName = JsonUtil.GetStringValue("../Feral/Cosmetics", configKey + "Plugin")
	Int formID = JsonUtil.GetIntValue("../Feral/Cosmetics", configKey + "FormID")
	If pluginName == "" || formID <= 0
		Return
	EndIf
	_cosmetic = Game.GetFormFromFile(formID, pluginName) as Armor
	If !_cosmetic
		Return
	EndIf
	If player.GetItemCount(_cosmetic) < 1
		player.AddItem(_cosmetic, 1, true)
		_addedCosmetic = true
	EndIf
	If !player.IsEquipped(_cosmetic)
		player.EquipItem(_cosmetic, false, true)
		_equippedCosmetic = true
	EndIf
	StorageUtil.SetFormValue(player, "Feral.ActiveCosmetic", _cosmetic)
	StorageUtil.SetIntValue(player, "Feral.ActiveCosmeticAdded", _addedCosmetic as Int)
	StorageUtil.SetIntValue(player, "Feral.ActiveCosmeticEquipped", _equippedCosmetic as Int)
EndFunction

Function RemoveCosmetic(Actor player)
	If !_cosmetic
		Return
	EndIf
	If _equippedCosmetic && player.IsEquipped(_cosmetic)
		player.UnequipItem(_cosmetic, false, true)
	EndIf
	If _addedCosmetic && player.GetItemCount(_cosmetic) > 0
		player.RemoveItem(_cosmetic, 1, true)
	EndIf
	StorageUtil.UnsetFormValue(player, "Feral.ActiveCosmetic")
	StorageUtil.UnsetIntValue(player, "Feral.ActiveCosmeticAdded")
	StorageUtil.UnsetIntValue(player, "Feral.ActiveCosmeticEquipped")
	_cosmetic = None
	_addedCosmetic = false
	_equippedCosmetic = false
EndFunction

Function ApplyStats(Actor player)
	Float scale = RankScale()
	If Family == 1
		_first = 12.0 * scale
		_second = 35.0 * scale
		_third = 15.0 * scale
		player.ModActorValue("SpeedMult", _first)
		player.ModActorValue("StaminaRateMult", _second)
		player.ModActorValue("UnarmedDamage", _third)
	ElseIf Family == 2
		_first = 25.0 * scale
		_second = 25.0 * scale
		_third = 0.10 * scale
		player.ModActorValue("Sneak", _first)
		player.ModActorValue("UnarmedDamage", _second)
		player.ModActorValue("WeaponSpeedMult", _third)
	ElseIf Family == 3
		_first = 100.0 * scale
		_second = 50.0 * scale
		_third = 25.0 * scale
		player.ModActorValue("DamageResist", _first)
		player.ModActorValue("Health", _second)
		player.ModActorValue("StaggerResist", _third)
	ElseIf Family == 4
		_first = 60.0 * scale
		_second = 60.0 * scale
		_third = 20.0 * scale
		_fourth = 30.0 * scale
		player.ModActorValue("PoisonResist", _first)
		player.ModActorValue("DiseaseResist", _second)
		player.ModActorValue("Sneak", _third)
		player.ModActorValue("CarryWeight", _fourth)
	ElseIf Family == 5
		_first = 80.0 * scale
		_second = 30.0 * scale
		_third = 15.0 * scale
		player.ModActorValue("PoisonResist", _first)
		player.ModActorValue("UnarmedDamage", _second)
		player.ModActorValue("SpeedMult", _third)
	ElseIf Family == 6
		_first = 140.0 * scale
		_second = 20.0 * scale
		_third = 30.0 * scale
		_fourth = 8.0 * scale
		player.ModActorValue("DamageResist", _first)
		player.ModActorValue("Block", _second)
		player.ModActorValue("StaggerResist", _third)
		player.ModActorValue("SpeedMult", -_fourth)
	ElseIf Family == 7
		_first = 15.0 * scale
		_second = 80.0 * scale
		_third = 20.0 * scale
		player.ModActorValue("SpeedMult", _first)
		player.ModActorValue("Stamina", _second)
		player.ModActorValue("Marksman", _third)
	ElseIf Family == 8
		_first = 2.0 * scale
		_second = 25.0 * scale
		_third = 60.0 * scale
		_fourth = 40.0 * scale
		_fifth = 8.0 * scale
		player.ModActorValue("HealRate", _first)
		player.ModActorValue("MeleeDamage", _second)
		player.ModActorValue("Health", _third)
		player.ModActorValue("FireResist", -_fourth)
		player.ModActorValue("SpeedMult", -_fifth)
	EndIf
	player.ModActorValue("CarryWeight", 0.01)
	player.ModActorValue("CarryWeight", -0.01)
EndFunction

Function RemoveStats(Actor player)
	If Family == 1
		player.ModActorValue("SpeedMult", -_first)
		player.ModActorValue("StaminaRateMult", -_second)
		player.ModActorValue("UnarmedDamage", -_third)
	ElseIf Family == 2
		player.ModActorValue("Sneak", -_first)
		player.ModActorValue("UnarmedDamage", -_second)
		player.ModActorValue("WeaponSpeedMult", -_third)
	ElseIf Family == 3
		player.ModActorValue("DamageResist", -_first)
		player.ModActorValue("Health", -_second)
		player.ModActorValue("StaggerResist", -_third)
	ElseIf Family == 4
		player.ModActorValue("PoisonResist", -_first)
		player.ModActorValue("DiseaseResist", -_second)
		player.ModActorValue("Sneak", -_third)
		player.ModActorValue("CarryWeight", -_fourth)
	ElseIf Family == 5
		player.ModActorValue("PoisonResist", -_first)
		player.ModActorValue("UnarmedDamage", -_second)
		player.ModActorValue("SpeedMult", -_third)
	ElseIf Family == 6
		player.ModActorValue("DamageResist", -_first)
		player.ModActorValue("Block", -_second)
		player.ModActorValue("StaggerResist", -_third)
		player.ModActorValue("SpeedMult", _fourth)
	ElseIf Family == 7
		player.ModActorValue("SpeedMult", -_first)
		player.ModActorValue("Stamina", -_second)
		player.ModActorValue("Marksman", -_third)
	ElseIf Family == 8
		player.ModActorValue("HealRate", -_first)
		player.ModActorValue("MeleeDamage", -_second)
		player.ModActorValue("Health", -_third)
		player.ModActorValue("FireResist", _fourth)
		player.ModActorValue("SpeedMult", _fifth)
	EndIf
	player.ModActorValue("CarryWeight", 0.01)
	player.ModActorValue("CarryWeight", -0.01)
EndFunction

Function ApplyMorphs(Actor player)
	Float scale = RankScale()
	NiOverride.ClearBodyMorphKeys(player, MorphKey)
	NiOverride.ClearBodyMorphKeys(player, VisibleMorphKey)
	If Family == 1
		SetMorph(player, "MuscleLegs", 0.58 * scale)
		SetMorph(player, "MuscleMoreLegs_v2", 0.42 * scale)
		SetMorph(player, "Thighs", 0.32 * scale)
		SetMorph(player, "ThighOutsideThicc_v2", 0.30 * scale)
		SetMorph(player, "CalfSize", 0.42 * scale)
		SetMorph(player, "CalfFBThicc_v2", 0.32 * scale)
		SetMorph(player, "MuscleButt", 0.38 * scale)
		SetMorph(player, "Butt", 0.22 * scale)
		SetMorph(player, "Waist", -0.25 * scale)
		SetMorph(player, "Belly", -0.12 * scale)
		SetMorph(player, "Arms", 0.20 * scale)
		SetMorph(player, "ShoulderWidth", 0.16 * scale)
	ElseIf Family == 2
		SetMorph(player, "Thighs", 0.38 * scale)
		SetMorph(player, "ThighInsideThicc_v2", 0.20 * scale)
		SetMorph(player, "MuscleLegs", 0.28 * scale)
		SetMorph(player, "CalfSize", 0.24 * scale)
		SetMorph(player, "Butt", 0.42 * scale)
		SetMorph(player, "RoundAss", 0.30 * scale)
		SetMorph(player, "Hips", 0.32 * scale)
		SetMorph(player, "HipUpperWidth", 0.22 * scale)
		SetMorph(player, "Waist", -0.42 * scale)
		SetMorph(player, "Belly", -0.18 * scale)
		SetMorph(player, "Arms", -0.18 * scale)
		SetMorph(player, "ShoulderWidth", -0.10 * scale)
	ElseIf Family == 3
		SetMorph(player, "Arms", 0.82 * scale)
		SetMorph(player, "MuscleArms", 0.95 * scale)
		SetMorph(player, "MuscleMoreArms_v2", 0.62 * scale)
		SetMorph(player, "ShoulderWidth", 0.72 * scale)
		SetMorph(player, "MuscleAbs", 0.45 * scale)
		SetMorph(player, "MuscleLegs", 0.62 * scale)
		SetMorph(player, "MuscleMoreLegs_v2", 0.48 * scale)
		SetMorph(player, "Thighs", 0.38 * scale)
		SetMorph(player, "CalfSize", 0.32 * scale)
		SetMorph(player, "Waist", 0.38 * scale)
		SetMorph(player, "Belly", 0.18 * scale)
		SetMorph(player, "Butt", 0.28 * scale)
	ElseIf Family == 4
		SetMorph(player, "Arms", -0.32 * scale)
		SetMorph(player, "MuscleArms", -0.30 * scale)
		SetMorph(player, "ShoulderWidth", -0.20 * scale)
		SetMorph(player, "Thighs", -0.22 * scale)
		SetMorph(player, "ChubbyLegs", -0.22 * scale)
		SetMorph(player, "Waist", -0.38 * scale)
		SetMorph(player, "Belly", -0.24 * scale)
		SetMorph(player, "CalfSize", 0.24 * scale)
		SetMorph(player, "CalfFBThicc_v2", 0.20 * scale)
		SetMorph(player, "Butt", -0.18 * scale)
		SetMorph(player, "Hips", -0.12 * scale)
	ElseIf Family == 5
		SetMorph(player, "Waist", -0.68 * scale)
		SetMorph(player, "Belly", -0.28 * scale)
		SetMorph(player, "Hips", 0.52 * scale)
		SetMorph(player, "HipUpperWidth", 0.38 * scale)
		SetMorph(player, "Butt", 0.55 * scale)
		SetMorph(player, "BigButt", 0.26 * scale)
		SetMorph(player, "Thighs", 0.28 * scale)
		SetMorph(player, "ThighOutsideThicc_v2", 0.24 * scale)
		SetMorph(player, "Arms", 0.30 * scale)
		SetMorph(player, "MuscleArms", 0.28 * scale)
		SetMorph(player, "ShoulderWidth", 0.20 * scale)
	ElseIf Family == 6
		SetMorph(player, "ShoulderWidth", 0.62 * scale)
		SetMorph(player, "Arms", 0.58 * scale)
		SetMorph(player, "MuscleArms", 0.45 * scale)
		SetMorph(player, "Waist", 0.52 * scale)
		SetMorph(player, "Belly", 0.28 * scale)
		SetMorph(player, "Hips", 0.38 * scale)
		SetMorph(player, "Thighs", 0.48 * scale)
		SetMorph(player, "ChubbyLegs", 0.30 * scale)
		SetMorph(player, "CalfSize", 0.40 * scale)
		SetMorph(player, "Butt", 0.30 * scale)
		SetMorph(player, "MuscleButt", 0.24 * scale)
	ElseIf Family == 7
		SetMorph(player, "Thighs", 0.42 * scale)
		SetMorph(player, "ThighOutsideThicc_v2", 0.22 * scale)
		SetMorph(player, "CalfSize", 0.46 * scale)
		SetMorph(player, "CalfFBThicc_v2", 0.40 * scale)
		SetMorph(player, "MuscleLegs", 0.68 * scale)
		SetMorph(player, "MuscleMoreLegs_v2", 0.52 * scale)
		SetMorph(player, "MuscleButt", 0.38 * scale)
		SetMorph(player, "Butt", 0.34 * scale)
		SetMorph(player, "Hips", 0.20 * scale)
		SetMorph(player, "Waist", -0.32 * scale)
		SetMorph(player, "Belly", -0.20 * scale)
		SetMorph(player, "Arms", -0.12 * scale)
	ElseIf Family == 8
		SetMorph(player, "Arms", 0.95 * scale)
		SetMorph(player, "MuscleArms", 1.05 * scale)
		SetMorph(player, "MuscleMoreArms_v2", 0.78 * scale)
		SetMorph(player, "ShoulderWidth", 0.86 * scale)
		SetMorph(player, "MuscleAbs", 0.58 * scale)
		SetMorph(player, "MuscleLegs", 0.72 * scale)
		SetMorph(player, "MuscleMoreLegs_v2", 0.55 * scale)
		SetMorph(player, "Thighs", 0.46 * scale)
		SetMorph(player, "CalfSize", 0.38 * scale)
		SetMorph(player, "Waist", 0.48 * scale)
		SetMorph(player, "Belly", 0.24 * scale)
		SetMorph(player, "Butt", 0.32 * scale)
	EndIf
	NiOverride.UpdateModelWeight(player)
EndFunction

Function SetMorph(Actor player, String morph, Float value)
	NiOverride.SetBodyMorph(player, morph, MorphKey, PapyrusUtil.ClampFloat(value, -2.0, 3.0))
	NiOverride.SetBodyMorph(player, morph, VisibleMorphKey, PapyrusUtil.ClampFloat(value * 0.75, -2.0, 3.0))
EndFunction

Function ClearVisuals(Actor player)
	NiOverride.ClearBodyMorphKeys(player, MorphKey)
	NiOverride.ClearBodyMorphKeys(player, VisibleMorphKey)
	NiOverride.UpdateModelWeight(player)
	String baseMark = BaseMarkName()
	If baseMark != ""
		SlaveTats.simple_remove_tattoo(player, "Feral Shapes", baseMark + " I", true, true)
		SlaveTats.simple_remove_tattoo(player, "Feral Shapes", baseMark + " II", true, true)
		SlaveTats.simple_remove_tattoo(player, "Feral Shapes", baseMark + " III", true, true)
		SlaveTats.synchronize_tattoos(player, true)
	EndIf
EndFunction

Function ApplyMark(Actor player)
	String mark = MarkName()
	If mark != ""
		SlaveTats.simple_add_tattoo(player, "Feral Shapes", mark, MarkColor(), true, true, MarkOpacity())
		SlaveTats.synchronize_tattoos(player, true)
	EndIf
EndFunction

String Function MarkName()
	String baseMark = BaseMarkName()
	If baseMark == ""
		Return ""
	EndIf
	Return baseMark + " III"
EndFunction

String Function BaseMarkName()
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
		Return "Stag Dappling"
	ElseIf Family == 8
		Return "Troll Hide"
	EndIf
	Return ""
EndFunction

Float Function MarkOpacity()
	Return 0.25 + (0.65 * RankScale())
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
