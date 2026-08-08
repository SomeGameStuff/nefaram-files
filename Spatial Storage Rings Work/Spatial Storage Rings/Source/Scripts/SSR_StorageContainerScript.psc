Scriptname SSR_StorageContainerScript extends ObjectReference

String Property PluginName = "Spatial Storage Rings.esp" AutoReadOnly
Int StoredCount = 0
Bool ReturningOverflow = False

Event OnItemAdded(Form akBaseItem, Int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	If ReturningOverflow || aiItemCount <= 0
		Return
	EndIf

	GlobalVariable capacityGlobal = Game.GetFormFromFile(0x000800, PluginName) as GlobalVariable
	Int limit = 0
	If capacityGlobal
		limit = capacityGlobal.GetValueInt()
	EndIf

	If limit <= 0
		ReturnOverflow(akBaseItem, aiItemCount)
		Return
	EndIf

	StoredCount = GetAllItemsCount()
	If StoredCount > limit
		Int excess = StoredCount - limit
		If excess > aiItemCount
			excess = aiItemCount
		EndIf
		ReturnOverflow(akBaseItem, excess)
		StoredCount = GetAllItemsCount()
	EndIf
EndEvent

Event OnItemRemoved(Form akBaseItem, Int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
	If ReturningOverflow || aiItemCount <= 0
		Return
	EndIf

	StoredCount = GetAllItemsCount()
EndEvent

Int Function GetStoredItemCount()
	StoredCount = GetAllItemsCount()
	Return StoredCount
EndFunction

Function ReturnOverflow(Form akBaseItem, Int aiItemCount)
	If !akBaseItem || aiItemCount <= 0
		Return
	EndIf

	ReturningOverflow = True
	RemoveItem(akBaseItem, aiItemCount, True, Game.GetPlayer())
	ReturningOverflow = False

	Message fullMessage = Game.GetFormFromFile(0x000802, PluginName) as Message
	If fullMessage
		fullMessage.Show()
	EndIf
EndFunction
