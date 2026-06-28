Scriptname SSR_OpenStorageEffect extends ActiveMagicEffect

String Property PluginName = "Spatial Storage Rings.esp" AutoReadOnly

Event OnEffectStart(Actor akTarget, Actor akCaster)
	Actor playerRef = Game.GetPlayer()
	GlobalVariable capacityGlobal = Game.GetFormFromFile(0x000800, PluginName) as GlobalVariable

	If !capacityGlobal || capacityGlobal.GetValueInt() <= 0
		Message noRingMessage = Game.GetFormFromFile(0x000801, PluginName) as Message
		If noRingMessage
			noRingMessage.Show()
		EndIf
		Return
	EndIf

	ObjectReference storageRef = Game.GetFormFromFile(0x00080F, PluginName) as ObjectReference
	If storageRef
		storageRef.Activate(playerRef)
	EndIf
EndEvent
