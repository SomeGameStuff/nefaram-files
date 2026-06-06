Scriptname SPEWeaponSpeedScript extends SPEPlayerOnlyAbility
{Accounts for the weapon speed bug and tries to manage the bug fix ability to minimize conflicts with other mods.}

;weapon speeds are reduced when hardcore mode is on
GlobalVariable Property SPEHardcoreMode Auto

;global variable for customizing weapon speed behavior
GlobalVariable Property SPEWeaponSpeed Auto

;the maximum increase in weapon speed above normal before the bug fix ability gets removed
GlobalVariable Property SPEWeaponSpeedTolerance Auto

;these abilities affect weapon speed
Perk Property SPEFightingStance Auto
Perk Property SPEDualSavagery Auto
Perk Property SPEGreatSwings Auto
Perk Property SPEBladesman Auto
Perk Property SPEWeaponMaster Auto
MagicEffect Property SPERaceKhajiitSkoomaEffect Auto
MagicEffect Property VoiceElementalFury Auto
Spell Property SPERaceKhajiitSkoomaFrenzy Auto
MagicEffect Property SPEPerkCounterattackHasteEffect Auto
MagicEffect Property SPEPerkRiposteEffect Auto
Spell Property SPEPerkCounterattack Auto
Spell Property SPEPerkRiposte Auto

;the bug fix ability
Spell Property SPEWeaponSpeedFixAb Auto

float hasteValue ;expected weapon speed from perks, should be relatively static
bool recalculate = true ;when this is true, expected haste from perks is recalculated

Function Initialize()
	RegisterForModEvent("SPE_UpdateHaste", "UpdateHaste")
EndFunction

Event OnUpdate()
	If recalculate
		recalculate = false
		CalculateHaste()
	Else
		ApplyHaste()
	EndIf
EndEvent

Event OnMagicEffectApply(ObjectReference akCaster, MagicEffect akEffect)
	If akEffect == VoiceElementalFury
		PlayerRef.RemoveSpell(SPEWeaponSpeedFixAb)
		RegisterForSingleUpdate(15)
	ElseIf akEffect == SPERaceKhajiitSkoomaEffect || akEffect == SPEPerkCounterattackHasteEffect || akEffect == SPEPerkRiposteEffect
		RegisterForSingleUpdate(0)
	EndIf
EndEvent

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	recalculate = true
	RegisterForSingleUpdate(0)
EndEvent

Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	recalculate = true
	RegisterForSingleUpdate(0)
EndEvent

Function UpdateHaste(string eventName, string strArg, float numArg, Form sender)
	CalculateHaste()
EndFunction

Function ApplyHaste()
	If SPEWeaponSpeed.GetValue() == 1 ;auto manage is on
		float expectedHaste = hasteValue
		If PlayerRef.HasSpell(SPERaceKhajiitSkoomaFrenzy)
			expectedHaste += 1.0
		EndIf
		
		If PlayerRef.HasSpell(SPEWeaponSpeedFixAb)
			expectedHaste += 1.0
		EndIf
		
		If PlayerRef.HasMagicEffect(SPEPerkRiposteEffect) || PlayerRef.HasMagicEffect(SPEPerkCounterattackHasteEffect)
			expectedHaste += 1.5
		EndIf
		
		If PlayerRef.GetAV("WeaponSpeedMult") >= expectedHaste ;too much haste
			PlayerRef.RemoveSpell(SPEWeaponSpeedFixAb)
		ElseIf !PlayerRef.HasSpell(SPEWeaponSpeedFixAb)
			PlayerRef.AddSpell(SPEWeaponSpeedFixAb, false)
		EndIf
		
		;this part is in case of the unexpected, like changing equipment after shouting
		If PlayerRef.HasMagicEffect(VoiceElementalFury) ;shout active, keep updating until it's gone
			RegisterForSingleUpdate(1)
		EndIf
		
	ElseIf SPEWeaponSpeed.GetValue() == 3 || SPEWeaponSpeed.GetValue() == 0 ;bug fix is off
		PlayerRef.RemoveSpell(SPEWeaponSpeedFixAb)
	ElseIf SPEWeaponSpeed.GetValue() == 2 ;bug fix is on
		If !PlayerRef.HasSpell(SPEWeaponSpeedFixAb)
			PlayerRef.AddSpell(SPEWeaponSpeedFixAb, false)
		EndIf
	EndIf
EndFunction

Function CalculateHaste()
	;set up the script during downtime so it runs faster during combat
	hasteValue = SPEWeaponSpeedTolerance.GetValue()
	If SPEHardcoreMode.GetValue() == 0
		
		If PlayerRef.HasPerk(SPEWeaponMaster) && PlayerRef.GetEquippedItemType(1) == 1 && PlayerRef.GetEquippedItemType(0) == 1
			hasteValue += 0.15
		EndIf
		
		If PlayerRef.HasPerk(SPEFightingStance)
			hasteValue += 0.15
		EndIf
		
		If PlayerRef.HasPerk(SPEBladesman)
			If (PlayerRef.GetEquippedItemType(1) == 1) || (PlayerRef.GetEquippedItemType(0) == 1)
				hasteValue += 0.30
			Else
				hasteValue += 0.15
			EndIf
		EndIf
		
		If PlayerRef.HasPerk(SPEGreatSwings)
			If PlayerRef.GetEquippedItemType(1) == 5
				hasteValue += 0.30
			Else
				hasteValue += 0.15
			EndIf
		EndIf
		
		If PlayerRef.HasPerk(SPEDualSavagery)
			If PlayerRef.GetEquippedItemType(1) <= 4 && PlayerRef.GetEquippedItemType(0) <= 4 && (PlayerRef.GetEquippedItemType(0) > 0 || PlayerRef.GetEquippedItemType(1) == 0)
				hasteValue += 0.35
			EndIf
		EndIf
	Else
		
		If PlayerRef.HasPerk(SPEWeaponMaster) && PlayerRef.GetEquippedItemType(1) == 1 && PlayerRef.GetEquippedItemType(0) == 1
			hasteValue += 0.04
		EndIf
		
		If PlayerRef.HasPerk(SPEFightingStance)
			hasteValue += 0.04
		EndIf
		
		If PlayerRef.HasPerk(SPEBladesman)
			If (PlayerRef.GetEquippedItemType(1) == 1) || (PlayerRef.GetEquippedItemType(0) == 1)
				hasteValue += 0.08
			Else
				hasteValue += 0.04
			EndIf
		EndIf
		
		If PlayerRef.HasPerk(SPEGreatSwings)
			If PlayerRef.GetEquippedItemType(1) == 5
				hasteValue += 0.08
			Else
				hasteValue += 0.04
			EndIf
		EndIf
		
		If PlayerRef.HasPerk(SPEDualSavagery)
			If PlayerRef.GetEquippedItemType(1) <= 4 && PlayerRef.GetEquippedItemType(0) <= 4 && (PlayerRef.GetEquippedItemType(0) > 0 || PlayerRef.GetEquippedItemType(1) == 0)
				hasteValue += 0.1
			EndIf
		EndIf
	EndIf
	ApplyHaste()
EndFunction
