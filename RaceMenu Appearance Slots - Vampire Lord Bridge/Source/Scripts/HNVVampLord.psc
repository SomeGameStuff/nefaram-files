Scriptname HNVVampLord extends ReferenceAlias

Quest Property HNVAMainQ Auto
Race Property DLC1VampireBeastRace auto
Race Property WerewolfBeastRace auto
HNVAMain Property questRef Auto
Keyword Property VampireKeyword auto
GlobalVariable Property ArmorCheck Auto
GlobalVariable Property HNVVampireCheck Auto

Bool _applyingAppearance = false

Int Function RAS_MCMQuestFormID()
	Return 0x000805
EndFunction

Function ApplyAppearanceSlot(Int aiSlot)
	If _applyingAppearance
		Return
	EndIf

	_applyingAppearance = true
	Quest rasQuest = Game.GetFormFromFile(RAS_MCMQuestFormID(), "RMAppSlots.esp") as Quest
	ras_AppearanceSlotsMCM rasQuestScript = rasQuest as ras_AppearanceSlotsMCM

	If rasQuestScript
		rasQuestScript.ApplySlot(aiSlot)
	EndIf
	Utility.Wait(1.0)
	_applyingAppearance = false
EndFunction

Event OnRaceSwitchComplete()
	If _applyingAppearance
		Return
	EndIf

	If GetActorRef().GetRace() == DLC1VampireBeastRace
		Utility.Wait(2.0)
		HNVVampireCheck.SetValue(1)
		If ArmorCheck.GetValue() == 1
			questRef.HNVEquipVLSet()
		EndIf
		Utility.Wait(0.25)
		ApplyAppearanceSlot(2)
	ElseIf Game.GetPlayer().HasKeyword(VampireKeyword) && GetActorRef().GetRace() != DLC1VampireBeastRace && GetActorRef().GetRace() != WerewolfBeastRace
		If ArmorCheck.GetValue() == 1
			questRef.HNVReturnVLSet()
		EndIf
		Utility.Wait(0.25)
		ApplyAppearanceSlot(1)
	ElseIf HNVVampireCheck.GetValue() == 1 && GetActorRef().GetRace() != DLC1VampireBeastRace && GetActorRef().GetRace() != WerewolfBeastRace
		If ArmorCheck.GetValue() == 1
			questRef.HNVReturnVLSet()
		EndIf
		HNVVampireCheck.SetValue(0)
		Utility.Wait(0.25)
		ApplyAppearanceSlot(1)
	EndIf
EndEvent
