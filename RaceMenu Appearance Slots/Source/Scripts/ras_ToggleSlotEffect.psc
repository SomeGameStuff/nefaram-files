Scriptname ras_ToggleSlotEffect extends ActiveMagicEffect

Quest Property ras_MCMQuest Auto
Actor Property PlayerRef Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If akTarget != PlayerRef
		Dispel()
		Return
	EndIf

	If ras_MCMQuest && !ras_MCMQuest.IsRunning()
		ras_MCMQuest.Start()
	EndIf

	ras_AppearanceSlotsMCM mcm = ras_MCMQuest as ras_AppearanceSlotsMCM
	If mcm
		mcm.ToggleSlot()
	Else
		Debug.Notification("RaceMenu Appearance Slots MCM quest is unavailable.")
	EndIf
EndEvent
