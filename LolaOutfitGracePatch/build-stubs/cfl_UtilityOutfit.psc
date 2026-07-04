Scriptname cfl_UtilityOutfit extends Quest

Bool Function DefaultOutfitsSetupCorrectly()
    return True
EndFunction

Function EquipOutfit(Actor who, string filename, int id = -1, bool handleDD = True, bool OverwriteDD = True)
EndFunction

String Function GetOutfitName(string filename, int id)
    return ""
EndFunction

int Function GetRandomOutfitID(string filename)
    return 0
EndFunction

Bool Function HasBrokenVersion(string file = "", int outfitId = -1)
    return False
EndFunction

Bool Function HasSluttyVersion(string file = "", int outfitId = -1)
    return False
EndFunction

Bool Function IdExits(string filename, int id)
    return True
EndFunction

Form[] Function LoadOutfit(string filename, int id = -1)
    Form[] result
    return result
EndFunction

Function RemoveOutfit(Actor who, string filename, int id, bool destroy = false)
EndFunction

Function RestoreActorOutfit(Actor npc)
EndFunction

Function SaveActorOutfit(Actor npc)
EndFunction

Form[] Function GetWornOutfit(Actor target, bool IncludeDD = False, bool GetDDInventory = False) Global
    Form[] result
    return result
EndFunction

Function StripActor(Actor target, bool destroy = False) Global
EndFunction
