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

	Int newCount = StoredCount + aiItemCount
	If newCount > limit
		Int excess = newCount - limit
		If excess > aiItemCount
			excess = aiItemCount
		EndIf
		ReturnOverflow(akBaseItem, excess)
		StoredCount = newCount - excess
	Else
		StoredCount = newCount
	EndIf
EndEvent

Event OnItemRemoved(Form akBaseItem, Int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
	If ReturningOverflow || aiItemCount <= 0
		Return
	EndIf

	StoredCount -= aiItemCount
	If StoredCount < 0
		StoredCount = 0
	EndIf
EndEvent

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
