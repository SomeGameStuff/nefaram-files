Scriptname NFW_RefitController extends ObjectReference

FormList Property Flawed25 Auto
FormList Property Clean25 Auto
FormList Property Flawed40 Auto
FormList Property Clean40 Auto
FormList Property Flawed60 Auto
FormList Property Clean60 Auto
FormList Property Flawed80 Auto
FormList Property Clean80 Auto
FormList Property Flawed100 Auto
FormList Property Clean100 Auto
Form Property LeatherStrips Auto
Form Property Charcoal Auto

Bool processing = False

Event OnContainerChanged(ObjectReference akNewContainer, ObjectReference akOldContainer)
    If akNewContainer == Game.GetPlayer()
        ProcessRefit()
    EndIf
EndEvent

Function ProcessRefit()
    If processing
        Return
    EndIf
    processing = True
    Utility.Wait(0.1)

    Actor player = Game.GetPlayer()
    Int smithing = player.GetActorValue("Smithing") as Int
    Bool converted = False

    If smithing >= 100
        converted = ConvertFirst(player, Flawed100, Clean100)
    EndIf
    If !converted && smithing >= 80
        converted = ConvertFirst(player, Flawed80, Clean80)
    EndIf
    If !converted && smithing >= 60
        converted = ConvertFirst(player, Flawed60, Clean60)
    EndIf
    If !converted && smithing >= 40
        converted = ConvertFirst(player, Flawed40, Clean40)
    EndIf
    If !converted && smithing >= 25
        converted = ConvertFirst(player, Flawed25, Clean25)
    EndIf

    If converted
        Debug.Notification("Refitted one flawed item.")
    Else
        player.AddItem(LeatherStrips, 2, True)
        player.AddItem(Charcoal, 1, True)
        Debug.Notification("No carried flawed item meets your Smithing threshold; materials refunded.")
    EndIf
    player.RemoveItem(GetBaseObject(), 1, True)
EndFunction

Bool Function ConvertFirst(Actor player, FormList flawedItems, FormList cleanItems)
    Int index = 0
    Int itemCount = flawedItems.GetSize()
    While index < itemCount
        Form flawedItem = flawedItems.GetAt(index)
        If flawedItem && player.GetItemCount(flawedItem) > 0
            Form cleanItem = cleanItems.GetAt(index)
            If cleanItem
                player.RemoveItem(flawedItem, 1, True)
                player.AddItem(cleanItem, 1, True)
                Return True
            EndIf
        EndIf
        index += 1
    EndWhile
    Return False
EndFunction
