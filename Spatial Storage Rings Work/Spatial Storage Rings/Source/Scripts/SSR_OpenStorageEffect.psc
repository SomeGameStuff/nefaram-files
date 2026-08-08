Scriptname SSR_OpenStorageEffect extends ActiveMagicEffect

String Property PluginName = "Spatial Storage Rings.esp" AutoReadOnly

Event OnEffectStart(Actor akTarget, Actor akCaster)
	Actor playerRef = Game.GetPlayer()
	GlobalVariable capacityGlobal = Game.GetFormFromFile(0x000800, PluginName) as GlobalVariable
	Int capacity = 0
	If capacityGlobal
		capacity = capacityGlobal.GetValueInt()
	EndIf

	If capacity <= 0
		Message noRingMessage = Game.GetFormFromFile(0x000801, PluginName) as Message
		If noRingMessage
			noRingMessage.Show()
		EndIf
		Return
	EndIf

	ObjectReference storageRef = Game.GetFormFromFile(0x00080F, PluginName) as ObjectReference
	If storageRef
		SSR_StorageContainerScript storageScript = storageRef as SSR_StorageContainerScript
		Int storedCount = 0
		If storageScript
			storedCount = storageScript.GetStoredItemCount()
		EndIf

		Int available = capacity - storedCount
		If available < 0
			available = 0
		EndIf

		Debug.Notification("Spatial Storage: " + available + " / " + capacity + " slots available")
		storageRef.Activate(playerRef)
	EndIf
EndEvent
