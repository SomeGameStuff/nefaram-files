Scriptname vkjPlayerAliasScript extends ReferenceAlias

vkjMQ Property MQ Auto
vkjMCM Property MCM Auto
Actor Property PlayerRef Auto
Faction Property PlayerFaction Auto
MiscObject Property Gold Auto
MiscObject Property Lockpick Auto
FormList Property KeyList Auto
MiscObject Property Dragonbone Auto
LocationRefType Property BossContainer Auto
Quest Property FindTreasureQuest Auto
Keyword Property KwShout Auto
Topic Property vkjNoShoutingComments Auto
String Property LEAConfigPath = "../LolaExpandedAddons/Config.json" Auto

Event OnPlayerLoadGame()
	AddInventoryEventFilter(Gold)
	AddInventoryEventFilter(Lockpick)
	AddInventoryEventFilter(KeyList)
	AddInventoryEventFilter(Dragonbone)
	MQ.Maintenance()
EndEvent

Event OnLocationChange(Location akOldLoc, Location akNewLoc)
	MQ.SetOldLoc(akOldLoc, akNewLoc)
EndEvent

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	if akBaseObject == MQ.CollarTag
		Debug.MessageBox(MQ.CollarInscription)
		PlayerRef.Unequipitem(akBaseObject, abSilent=true)
	elseif (akBaseObject as Ammo)
		MQ.SetEquippedArrows(akBaseObject as Ammo)
	endif
EndEvent

Event OnItemAdded(Form item, int itemCount, ObjectReference itemRef, ObjectReference srcContainer)
	if item == Dragonbone
		Quest dragonboneQuest = Quest.GetQuest("vkjDragonboneQuest")
		if dragonboneQuest.GetStage() == 0
			dragonboneQuest.SetStage(10)
		endif
		return
	endif

	; No swiping stuff from owner
	if (srcContainer != none) && (srcContainer == MQ.OwnerRef)
		if item == Gold
			if MCM.NoSwipingGold
				Debug.Notification("Your " + MQ.OwnerTitle + " doesn't share gold!")
				PlayerRef.RemoveItem(item, itemCount, true, MQ.OwnerRef)
				return
			elseif MCM.PlayerExpenseGold > 0
				int playerGold = PlayerRef.GetItemCount(Gold)
				if (playerGold - itemCount) >= MCM.PlayerExpenseGold
					Debug.Notification(MQ.OwnerTitle + " doesn't share gold when you already have enough")
					PlayerRef.RemoveItem(item, itemCount, true, MQ.OwnerRef)
				elseif playerGold > MCM.PlayerExpenseGold
					PlayerRef.RemoveItem(item, (playerGold - MCM.PlayerExpenseGold), true, MQ.OwnerRef)
				endif
				return
			else
				return; Allow full access to gold in owner's inventory
			endif
		endif
		if MCM.NoSwipingKeys && KeyList.HasForm(item)
			Debug.Notification("Hands off your " + MQ.OwnerTitle + "'s " + item.GetName() + "s!")
			PlayerRef.RemoveItem(item, itemCount, true, MQ.OwnerRef)
			return
		endif
	endif

	; Check for boss container for the treasure quest.  Lola Expanded Addons
	; also allows configurable fallback completion for valuable dungeon loot.
	if (srcContainer != none) && (srcContainer.HasRefType(BossContainer) || LEA_TreasureFallbackAllowed(item, itemCount, srcContainer))
		int tombRaiderStage = FindTreasureQuest.GetCurrentStageID()
		if (tombRaiderStage >= 10) && (tombRaiderStage < 20)
			FindTreasureQuest.SetStage(20)
		endif
	endif

	if MQ.SuspendAll
		return
	endif

	; Keys
	if KeyList.HasForm(item)
		if MCM.OwnerTakesKeys
			PlayerRef.RemoveItem(item, itemCount, true, MQ.OwnerRef)
		endif
		return
	endif
	
	; Lockpicks
	if item == Lockpick
		if MCM.AllowedLockpicks >= 0
			int extra = PlayerRef.GetItemCount(Lockpick) - MCM.AllowedLockpicks
			if extra > 0
				PlayerRef.RemoveItem(item, extra, true, MQ.OwnerRef)
			endif
		endif
		return
	endif	
	
	; Do not share gold if player has no gold in inventory, because various mods will take the player's possessions,
	; put them in a container, then give everything back at some point (SLUTS escrow chest, Body Search, Cidhna Pirates).
	; The gold is already in player inventory at this point, so we compare that amount against what was received rather than 0.
	if item == Gold && (MQ.PauseGoldSharing || (PlayerRef.GetItemCount(Gold) == itemCount))
		return
	endif
	
	; Gold
	if (srcContainer == none)
		if (item == Gold) && MCM.ShareAllGold && (MCM.OwnerGoldShare > 0)
			float ownerShare = MCM.OwnerGoldShare / 100.0
			int ownerTakes = ((itemCount * ownerShare) + 0.51) as int
			if MCM.PlayerExpenseGold > 0
				int playerGold = PlayerRef.GetItemCount(Gold)
				int ownerReduction = MCM.PlayerExpenseGold - playerGold + ownerTakes
				if (ownerTakes - ownerReduction) <= 0
					return
				elseif ownerReduction > 0
					ownerTakes -= ownerReduction
				endif
			endif
			PlayerRef.RemoveItem(Gold, ownerTakes, true, MQ.OwnerRef)
		endif
		return
	endif

	if PlayerOwnsContainer(srcContainer)
		;Debug.Notification("That's mine!")
		return
	endif

	if item == Gold
		if MCM.OwnerGoldShare > 0
			float ownerShare = MCM.OwnerGoldShare / 100.0
			int ownerTakes = ((itemCount * ownerShare) + 0.51) as int
			if MCM.PlayerExpenseGold > 0
				int playerGold = PlayerRef.GetItemCount(Gold)
				int ownerReduction = MCM.PlayerExpenseGold - playerGold + ownerTakes
				if (ownerTakes - ownerReduction) <= 0
					return
				elseif ownerReduction > 0
					ownerTakes -= ownerReduction
				endif
			endif
			;Debug.Notification("Not mine.  Owner takes " + ownerTakes + ".")
			PlayerRef.RemoveItem(Gold, ownerTakes, true, MQ.OwnerRef)
		endif
		return
	endif
EndEvent

; Check player ownership of a container
Bool Function PlayerOwnsContainer(ObjectReference srcContainer)
	ActorBase actorOwner = srcContainer.GetActorOwner()
	if actorOwner && (actorOwner == PlayerRef.GetActorBase())
		return true
	endif
	Faction factionOwner = srcContainer.GetFactionOwner()
	if factionOwner
		if factionOwner == PlayerFaction
			return true
		elseif PlayerRef.IsInFaction(factionOwner)
			return true
		endif
		return false
	endif

	; If the srcContainer doesn't have an explicit owner, check the parent cell's owner
	actorOwner = srcContainer.GetParentCell().GetActorOwner()
	if actorOwner && (actorOwner == PlayerRef.GetActorBase())
		return true
	endif
	factionOwner = srcContainer.GetParentCell().GetFactionOwner()
	if factionOwner && (factionOwner == PlayerFaction)
		return true
	endif
	
	; Hunterborn caches and SLUTS Escrow chests belong to the player
	string containerName = srcContainer.GetBaseObject().GetName()
	if (containerName == "Hunter's Cache") || (containerName == "Escrow Chest") || (containerName == "S.L.U.T.S. Escrow")
		return true
	endif

	return false
EndFunction

Bool Function LEA_TreasureFallbackAllowed(Form item, int itemCount, ObjectReference srcContainer)
	int tombRaiderStage = FindTreasureQuest.GetCurrentStageID()
	if (tombRaiderStage < 10) || (tombRaiderStage >= 20)
		return false
	endif

	int mode = JsonUtil.GetIntValue(LEAConfigPath, "treasure.fallbackMode", 1)
	if mode <= 0
		return false
	endif

	if srcContainer == MQ.OwnerRef
		return false
	endif

	if PlayerOwnsContainer(srcContainer)
		return false
	endif

	if mode >= 2
		return true
	endif

	int minGold = JsonUtil.GetIntValue(LEAConfigPath, "treasure.minGold", 100)
	if item == Gold && itemCount >= minGold
		return true
	endif

	int minValue = JsonUtil.GetIntValue(LEAConfigPath, "treasure.minItemValue", 250)
	int lootValue = item.GetGoldValue() * itemCount
	return lootValue >= minValue
EndFunction

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
	if MQ.ReportHitsOnPlayer; && (MQ.WeaponCane == akSource)
		MQ.PlayerWasHit(akAggressor, akSource)
		;MiscUtil.PrintConsole("PC hit by " + weap.GetName() + ", " + abPowerAttack)
	endif
EndEvent

Event OnSpellCast(Form akSpell)
	if MQ.SuspendAll || PlayerRef.IsInCombat()
		return
	endif
	
	if MCM.NoShoutingInTown && akSpell.HasKeyword(KwShout) && MQ.IsInTown() && MQ.OwnerRef.GetDistance(PlayerRef) < 5120.0
		MQ.HurtAndStagger(1)
		MQ.UpdateSubmissionScore(-5)
		MQ.GagQuest.SetStage(0)
		MQ.GagQuest.SetStage(10)
		MQ.OwnerRef.Say(vkjNoShoutingComments)
	endif
EndEvent
