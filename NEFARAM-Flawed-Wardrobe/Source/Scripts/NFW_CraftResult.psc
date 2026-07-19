Scriptname NFW_CraftResult extends ObjectReference

FormList Property Results Auto

Bool processing = False

Event OnContainerChanged(ObjectReference akNewContainer, ObjectReference akOldContainer)
    If akNewContainer == Game.GetPlayer()
        ResolveWorkOrder()
    EndIf
EndEvent

Function ResolveWorkOrder()
    If processing
        Return
    EndIf
    processing = True
    Utility.Wait(0.1)

    Actor player = Game.GetPlayer()
    Int resultCount = Results.GetSize()
    If resultCount > 0
        Form result = Results.GetAt(Utility.RandomInt(0, resultCount - 1))
        If result
            player.AddItem(result, 1, True)
        EndIf
    EndIf
    player.RemoveItem(GetBaseObject(), 1, True)
EndFunction
