Scriptname MEP_DumbEffect extends ActiveMagicEffect


Faction Property MEPFaction_DumbSlave Auto
Faction Property MEPFaction_HeelProfi Auto
int damageFactor = 500

event OnEffectStart(Actor akTarget, Actor akCaster)
    Debug.Notification("You are stupid now!")
    akTarget.AddToFaction(MEPFaction_DumbSlave)
    akTarget.RemoveFromFaction(MEPFaction_HeelProfi)
    ;parent.OnEffectStart(akTarget,akCaster)

    akTarget.DamageActorValue("Alchemy", damageFactor)
    akTarget.DamageActorValue("Alteration", damageFactor)
    akTarget.DamageActorValue("Block", damageFactor)
    akTarget.DamageActorValue("Conjuration", damageFactor)
    akTarget.DamageActorValue("Destruction", damageFactor)
    akTarget.DamageActorValue("Enchanting", damageFactor)
    akTarget.DamageActorValue("HeavyArmor", damageFactor)
    akTarget.DamageActorValue("LightArmor", damageFactor)
    akTarget.DamageActorValue("Lockpicking", damageFactor)
    akTarget.DamageActorValue("Marksman", damageFactor)
    akTarget.DamageActorValue("Illusion", damageFactor)
    akTarget.DamageActorValue("OneHanded", damageFactor)
    akTarget.DamageActorValue("Pickpocket", damageFactor)
    akTarget.DamageActorValue("Restoration", damageFactor)
    akTarget.DamageActorValue("Smithing", damageFactor)
    ; akTarget.DamageActorValue("Sneak", damageFactor)
    akTarget.DamageActorValue("Speechcraft", damageFactor)
    akTarget.DamageActorValue("TwoHanded", damageFactor)

    ActorBase me = akTarget.GetLeveledActorBase()
    int pc = PO3_SKSEFunctions.GetPerkCount(me)
    while pc > 0
        pc -= 1
        Perk p = PO3_SKSEFunctions.GetNthPerk(me,pc)
        Debug.Notification("Lost " + PO3_SKSEFunctions.GetFormEditorID(p))
        akTarget.RemovePerk(p)
    endwhile
    Game.SetPerkPoints(0)
endevent

event OnEffectFinish2(Actor akTarget, Actor akCaster)
    akTarget.RemoveFromFaction(MEPFaction_DumbSlave)
    akTarget.RestoreActorValue("Alchemy", damageFactor)
    akTarget.RestoreActorValue("Alteration", damageFactor)
    akTarget.RestoreActorValue("Block", damageFactor)
    akTarget.RestoreActorValue("Conjuration", damageFactor)
    akTarget.RestoreActorValue("Destruction", damageFactor)
    akTarget.RestoreActorValue("Enchanting", damageFactor)
    akTarget.RestoreActorValue("HeavyArmor", damageFactor)
    akTarget.RestoreActorValue("LightArmor", damageFactor)
    akTarget.RestoreActorValue("Lockpicking", damageFactor)
    akTarget.RestoreActorValue("Marksman", damageFactor)
    akTarget.RestoreActorValue("Illusion", damageFactor)
    akTarget.RestoreActorValue("OneHanded", damageFactor)
    akTarget.RestoreActorValue("Pickpocket", damageFactor)
    akTarget.RestoreActorValue("Restoration", damageFactor)
    akTarget.RestoreActorValue("Smithing", damageFactor)
    ; akTarget.DamageActorValue("Sneak", damageFactor)
    akTarget.RestoreActorValue("Speechcraft", damageFactor)
    akTarget.RestoreActorValue("TwoHanded", damageFactor)
endevent
