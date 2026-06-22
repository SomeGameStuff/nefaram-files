Scriptname cfl_TolfdirGrantPower Extends TopicInfo Hidden

Actor Property PlayerRef Auto
Spell Property PowerToGrant Auto
MiscObject Property Gold001 Auto
Int Property GoldCost = 100 Auto
String Property FormName = "Bodymorph Alteration" Auto

Function GrantPower()
	If !PlayerRef || !PowerToGrant
		Debug.Notification("Bodymorph Alteration dialogue is missing a required property.")
		Return
	EndIf

	If PlayerRef.HasSpell(PowerToGrant)
		Debug.Notification("You already know " + FormName + ".")
		Return
	EndIf

	If Gold001 && GoldCost > 0
		If PlayerRef.GetItemCount(Gold001) < GoldCost
			Debug.Notification("You need " + GoldCost + " gold.")
			Return
		EndIf
		PlayerRef.RemoveItem(Gold001, GoldCost, false)
	EndIf

	PlayerRef.AddSpell(PowerToGrant, false)
	Game.AdvanceSkill("Alteration", 25.0)
	Debug.Notification("Tolfdir teaches you " + FormName + ".")
EndFunction
