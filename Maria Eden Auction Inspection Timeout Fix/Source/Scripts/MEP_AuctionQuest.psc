;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 28
Scriptname MEP_AuctionQuest Extends Quest Hidden

;BEGIN ALIAS PROPERTY device
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_device Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY candidate09
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_candidate09 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY auctioneer
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_auctioneer Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY startlocation
;ALIAS PROPERTY TYPE LocationAlias
LocationAlias Property Alias_startlocation Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY startentry
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_startentry Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Slave
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Slave Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Center
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Center Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY JailDoor
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_JailDoor Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY startjail
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_startjail Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY candidate05
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_candidate05 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY startcitycenter
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_startcitycenter Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY seller
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_seller Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY candidate03
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_candidate03 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Container
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Container Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY entry
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_entry Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY candidate08
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_candidate08 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY auction
;ALIAS PROPERTY TYPE LocationAlias
LocationAlias Property Alias_auction Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY candidate12
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_candidate12 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY candidate13
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_candidate13 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY hotspot
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_hotspot Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY candidate02
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_candidate02 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY candidate11
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_candidate11 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY inspector
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_inspector Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY customer
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_customer Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY slavemarker
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_slavemarker Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY slaveguard
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_slaveguard Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY startcenter
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_startcenter Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY candidate01
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_candidate01 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY escort_home
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_escort_home Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY StartCity
;ALIAS PROPERTY TYPE LocationAlias
LocationAlias Property Alias_StartCity Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY candidate10
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_candidate10 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY candidate04
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_candidate04 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY candidate06
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_candidate06 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY candidate14
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_candidate14 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Escort
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Escort Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY candidate07
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_candidate07 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY homegoer
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_homegoer Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN CODE
waiting()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_11
Function Fragment_11()
;BEGIN CODE
guestsArrived()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_17
Function Fragment_17()
;BEGIN CODE
HandoverDone()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
Startup()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_6
Function Fragment_6()
;BEGIN CODE
handOverPlayer()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_21
Function Fragment_21()
;BEGIN CODE
stopSlavery()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_22
Function Fragment_22()
;BEGIN CODE
quickstart()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_24
Function Fragment_24()
;BEGIN CODE
startInspection()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_18
Function Fragment_18()
;BEGIN CODE
Enslave()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_20
Function Fragment_20()
;BEGIN CODE
payToSeller()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_25
Function Fragment_25()
;BEGIN CODE
bidForPlayer()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_19
Function Fragment_19()
;BEGIN CODE
prepareInspection()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
begin()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_14
Function Fragment_14()
;BEGIN CODE
stripPlayer()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_4
Function Fragment_4()
;BEGIN CODE
sellPlayer()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_26
Function Fragment_26()
;BEGIN CODE
inspectionDone()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_13
Function Fragment_13()
;BEGIN CODE
startSelling()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_16
Function Fragment_16()
;BEGIN CODE
giveKey()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN CODE
putPlayerOnDevice()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_15
Function Fragment_15()
;BEGIN CODE
pay()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_7
Function Fragment_7()
;BEGIN CODE
Cleanup()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_23
Function Fragment_23()
;BEGIN CODE
startEscort()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_27
Function Fragment_27()
;BEGIN CODE
guardHandOver()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
Prepare()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_12
Function Fragment_12()
;BEGIN CODE
silence()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

; zbfxPlayerSlaveMarker = Teleport Cage Marker
; zbfxActionMarker1 = Pole (zbfxFurnitureMarkerWhipping)
; zbfxActionMarker3 = Dance Spot
; 


Scene Property MEPAuctionBegin Auto
Scene Property MEPAuctionPlayerStart Auto
Scene Property MEPAuctionSellerStart Auto
Scene Property MEPAuctionPlayerPrepare Auto
Scene Property MEPAuctionPlayerBidding Auto
Scene Property MEPAuctionPlayerSell Auto
Scene Property MEPAuctionPlayerSold Auto
Scene Property MEPAuctionEscort Auto
Scene Property MEPAuctionEscortFromSeller Auto
Scene Property MEPAuctionCustomerInspection Auto
Scene Property MEPAuctionGuardEscort Auto

Quest property MEPCitizenCollector auto
Quest Property MEPPimp  Auto  
MariaRestraintsManager property mrm auto
MariaActorManager property mam auto
Actor property PlayerRef auto
Sound Property MariaSoundCrowdAmbient  Auto  
Sound Property MariaDoorOpenSM  Auto  
ReferenceAlias[] Property customer  Auto  

Faction property MariaFaction_BrothelBoss auto
Faction property MariaFaction_ExPimp auto
Faction property JobInnkeeperFaction auto
Faction property JobHostlerFaction auto
Faction property JobMerchantFaction auto
Faction property MEPFaction_KnowPlayerSlavery auto
Faction property MariaBusyFaction auto
FormList Property MEPBrothelPimpList  Auto  
Keyword property MEPPimpKeyword auto
Keyword property MEPDeviceManagerKeyword auto
Quest property MEPDeviceManager auto
Package Property MEPAuctionGoHome Auto

Actor boss
Actor the_guard
Actor escort
Actor seller
Actor winner
Actor brothelboss
ObjectReference captivemarker
ObjectReference actionmarker
ObjectReference entry
ObjectReference whipping_device
int ambientSoundInstance
int arrivedCustomers
bool quickstart
bool entryRotated

MEP_CageDoorAlias cageDoor

import StorageUtil

function Trace(string text)
	Debug.Trace("@@ Auction :" + text)
endfunction

function Startup()
	boss = Alias_auctioneer.GetActorReference()
	the_guard = Alias_slaveguard.GetActorReference()
	escort = Alias_Escort.GetActorReference()
	seller = Alias_seller.GetActorReference()
	if seller == boss
		Alias_seller.Clear()
		seller = none
	endif
	winner = Alias_customer.GetActorReference()
	captivemarker = Alias_slavemarker.GetReference()
	actionmarker = Alias_hotspot.GetReference()
	entry = Alias_entry.GetReference()
	whipping_device = Alias_device.GetReference()
	cageDoor = Alias_jailDoor as MEP_CageDoorAlias
	cageDoor.SetAutoCloseIntervall(0)
endfunction

function cleanup()
	inspectionWatchdogArmed = false
	UnregisterForUpdate()
	MEP_MainQuest.UnsetPimp(boss)
	if entryRotated
		entry.SetAngle(entry.GetAngleX(),entry.GetAngleY(),entry.GetAngleZ() - 180)
	endif
	if escort
		escort.DisableNoWait()
		escort.Delete()
	endif
	silence()
	boss.AddToFaction(MariaFaction_ExPimp)
	FormListClear(self,"customer")
	IntListClear(self,"inspectors")

	int x = customer.length
	int i
	while i < x
		Actor npc = customer[i].GetActorReference()
		if npc
			npc.ClearLookAt()
			customer[i].Clear()
			npc.MoveToMyEditorLocation()
		endif
		i += 1
	endwhile
	Alias_customer.Clear()
	if winner
		MEP_QuestManager.Start(MEPPimpKeyword,none,winner,none,1)
	endif
endfunction

Event OnStoryScript(Keyword akKeyword, Location akLocation, ObjectReference akRef1, ObjectReference akRef2, int aiValue1, int aiValue2)
	quickstart = aiValue1 == 4711
	if !quickstart
		quickstart = Input.IsKeyPressed(1) ; escape
	endif
	if quickstart
		Trace("it will be a quickstart")
	endif
EndEvent

Function begin() ; stage 10
	if quickstart
		Trace("force quickstart")
		SetStage(39)
	else
		if seller.IsGuard()
			SetStage(12)
		elseif escort
			SetStage(11)
		else
			if seller
				MEPAuctionSellerStart.Start()
			else
				if captivemarker.GetDistance(PlayerRef) < 200
					SetStage(39)
				else
					MEPAuctionPlayerStart.Start()
				endif
			endif
		endif
	endif
EndFunction

Function startEscort() ; stage 11
	ObjectReference start = Alias_startentry.GetReference()
	if !start
		start = Alias_startcenter.GetReference()
	endif
	if !start
		start = Alias_startcitycenter.GetReference()
	endif
	if !start
		if seller
			start = seller
		else
			start = PlayerRef
		endif
	endif
	ObjectReference JailDoor = Alias_startjail.GetReference()
	if JailDoor
		MEP_EscortQuest.SetNextDestination(JailDoor)
	endif
	escort.MoveTo(start)
	escort.EnableNoWait()
	if seller
		MEPAuctionEscortFromSeller.Start()
	else
		MEPAuctionEscort.Start()
	endif
EndFunction

function guardHandOver() ; stage 12
	MEPAuctionGuardEscort.Start()
endfunction

function payToSeller(); stage 28
	if escort
		MariasUtils.Pay(escort,seller,500)
	else
		MariasUtils.Pay(boss,seller,500)
	endif
endfunction

function stopSlavery() ; stage 29
	MEPPimp.SendModEvent("MariaStopSideQuests")
endfunction

function prepare() ; stage 30
	Trace("Prepare")
	if escort
		escort.MoveToMyEditorLocation()
	endif
	if seller
		seller.MoveToMyEditorLocation()
	endif
	MEP_MainQuest.SetCurrentPimp(boss, false, true)
	MEP_DeviceManagerQuest.Manage(whipping_device)
	MEP_CageManager.Manage(cageDoor.GetReference())
	MEP_EscortQuest.SetNextDestination(whipping_device)
	MEPAuctionPlayerPrepare.Start()
endfunction

Function stripPlayer() ; stage 31
	Trace("RemoveItems from Player")
	mrm.RemoveAllButRestraints(PlayerRef,Alias_Container.GetReference())
	if cageDoor
		MEP_EscortQuest.SetNextDestination(cageDoor.GetReference())
	endif
EndFunction

Function quickstart() ; stage 39
	Trace("quickstart")
	stripPlayer()
	boss.MoveToMyEditorLocation()
	the_guard.MoveToMyEditorLocation()
	PlayerRef.MoveTo(captivemarker)
	Utility.Wait(2)
	mrm.EquipSlaveCollar(PlayerRef)
	MEP_MainQuest.SetCurrentPimp(boss, false, true)
	if cageDoor
		cageDoor.Close()
	endif
	SetStage(40)
EndFunction

Function collectCandidates(bool allowExPimps)
	Form[] npcs = FormListToArray(none,"city_managed")
	int i = npcs.length
	while i > 0
		i -= 1
		if allowExPimps || !(npcs[i] as Actor).IsInFaction(MariaFaction_ExPimp) ; skip ex pimps
			FormListAdd(self,"customer",npcs[i],false)
		endif
	endwhile

	npcs = MEPBrothelPimpList.ToArray()
	i = npcs.length
	while i > 0
		i -= 1
		if allowExPimps || !(npcs[i] as Actor).IsInFaction(MariaFaction_ExPimp)
			FormListAdd(self,"customer",npcs[i],false)
		endif
	endwhile

	npcs = FormListToArray(none,"city_follower")
	i = npcs.length
	while i > 0
		i -= 1
		if allowExPimps || !(npcs[i] as Actor).IsInFaction(MariaFaction_ExPimp)
			FormListAdd(self,"customer",npcs[i],false)
		endif
	endwhile

	npcs = mam.GetManagedNPCs()
	i = npcs.length
	while i > 0
		i -= 1
		if allowExPimps || !(npcs[i] as Actor).IsInFaction(MariaFaction_ExPimp)
			FormListAdd(self,"customer",npcs[i],false)
		endif
	endwhile

	if allowExPimps
		npcs = FormListToArray(none,"city_male")
		i = npcs.length
		while i > 0
			i -= 1
			FormListAdd(self,"customer",npcs[i],false)
		endwhile
		npcs = FormListToArray(none,"city_female")
		i = npcs.length
		while i > 0
			i -= 1
			FormListAdd(self,"customer",npcs[i],false)
		endwhile
	endif
	if seller
		FormListRemove(self,"customer",seller)
	endif
EndFunction

int candidat_count

function gone(ReferenceAlias a)
	Actor npc
	if a
		npc = a.GetActorReference()
		Trace(npc.GetDisplayName() + " has gone")
		FormListRemove(self,"customer",npc)
		a.Clear()
	endif
	if FormListCount(self,"customer")
		npc = FormListShift(self,"customer") as Actor
		int x = customer.Length
		int i
		while i < x
			if customer[i].GetActorReference() == npc
				customer[i].Clear()
				Alias_homegoer.ForceRefTo(npc)
				Trace(npc.GetDisplayName() + " will go")
				return
			endif
			i += 1
		endwhile
	endif
endfunction

Function waiting() ; stage 40
	Trace("Collect customers")
	MEPCitizenCollector.Start()

	; fill pool with candidates
	if winner
		FormListAdd(self,"customer",winner,false)
	endif

	collectCandidates(false)

	Form[] candidates = FormListToArray(self,"customer")
	candidat_count = candidates.length
	Trace("total customer count = " + candidat_count)
	if candidat_count < 6
		collectCandidates(true)
		candidates = FormListToArray(self,"customer")
		candidat_count = candidates.length
		Trace("retry customer count = " + candidat_count)
		if candidat_count < 6
			Trace("not enough customer")
			Stop()
			return
		endif
	endif

	if !winner
		UIListMenu menu = UIExtensions.GetMenu("UIListMenu", true) as UIListMenu
		menu.ResetMenu()
		int i
		while i < candidat_count
			Actor npc = candidates[i] as Actor
			menu.AddEntryItem(MariasUtils.GetFullName(npc))
			i += 1
		endwhile
		menu.OpenMenu()
		i = menu.GetResultInt()
		if i < 0
			winner = candidates[Utility.RandomInt(0,candidat_count - 1)] as Actor
		else
			winner =  candidates[i] as actor
		endif
	endif

	FormListRemove(self, "customer", winner)
	FormListInsert(self, "customer", 0, winner)

	TriggerCustomer()
EndFunction

function TriggerCustomer()
	RegisterForSingleUpdate(Utility.RandomInt(5,10))
endfunction

event OnUpdate()
	if inspectionWatchdogArmed
		inspectionWatchdogArmed = false
		if GetStage() == 73
			Trace("inspection timed out; forcing normal inspection cleanup")
			if MEPAuctionCustomerInspection.IsPlaying()
				MEPAuctionCustomerInspection.Stop()
				Utility.Wait(1.0)
			endif
			if GetStage() == 73
				SetStage(74)
			endif
		endif
		return
	endif

	int bidders = FormListCount(self,"customer")
	Trace("candidates waiting = " + bidders)
	if bidders == 0 || arrivedCustomers == customer.Length - 1
		Trace("all candidates arrived")
		SetStage(41)
		return
	else
		Actor nextCustomer
		if arrivedCustomers == 0
			nextCustomer = FormListPluck(self, "customer", 0, none) as Actor
		else
			nextCustomer = FormListPluck(self, "customer", PO3_SKSEFunctions.GenerateRandomInt(0,bidders - 1), none) as Actor
		endif
		if !nextCustomer
			Trace("all candidates arrived")
			SetStage(41)
			return
		endif
		Trace("invite " + nextCustomer.GetDisplayName())
		(customer[arrivedCustomers] as MEP_AuctionCandidateAlias).Startup(nextCustomer,entry)
	endif
endevent

function hello(ReferenceAlias candidateAlias)
	Actor candidate = candidateAlias.GetActorReference()
	Trace(candidate.GetDisplayName() + " arrived")
	MariaDoorOpenSM.Play(candidate)
	arrivedCustomers += 1
	if arrivedCustomers == 4
		Trace("Trigger crowd ambient")
		ambientSoundInstance = MariaSoundCrowdAmbient.Play(Alias_Center.GetReference())
	endif
	TriggerCustomer()
endfunction

Function guestsArrived() ; stage 41
	Trace("All guests arrived")
	MEPAuctionBegin.Start()
EndFunction

Function silence() ; stage 42
	Trace("silence")
	if ambientSoundInstance
		Sound.StopInstance(ambientSoundInstance)
		ambientSoundInstance = 0
	endif
EndFunction

Function startSelling() ; 43
	Trace("startSelling")
	SetStage(70)
EndFunction

function sellPlayer() ; stage 70
	Trace("sellPlayer")
	MEP_DeviceManagerQuest.Manage(whipping_device)
	MEP_EscortQuest.SetNextDestination(Alias_hotspot.GetReference())
	MEPAuctionPlayerSell.Start()
endfunction

function putPlayerOnDevice() ; stage 71
	MEP_DeviceManagerQuest.Manage(whipping_device)
	MEP_EscortQuest.SetNextDestination(whipping_device)
endfunction

int inspectorCount

function prepareInspection() ; stage 72
	IntListClear(self,"inspectors")
	currentCanditateNo = 0
	int i = customer.length
	while i > 0
		i -= 1
		Actor npc = customer[i].GetActorReference()
		if npc
			npc.AddToFaction(MEPFaction_KnowPlayerSlavery)
			;if PO3_SKSEFunctions.GenerateRandomInt(0,100) > 70
				IntListAdd(self,"inspectors",i,false)
			;endif
		endif
	endwhile
	SetStage(73)
endfunction

int currentCanditateNo
bool inspectionWatchdogArmed
float Property InspectionTimeoutSeconds = 90.0 AutoReadOnly

function startInspection() ; stage 73
	Trace("startInspection")
	if !IntListCount(self,"inspectors")
		inspectionWatchdogArmed = false
		UnregisterForUpdate()
		Trace("done with inspectors")
		SetStage(79)
		return
	endif

	int[] inspectors = IntListToArray(self,"inspectors")
	UIListMenu menu = UIExtensions.GetMenu("UIListMenu", true) as UIListMenu
	menu.ResetMenu()
	Actor inspector
	int i = inspectors.Length
	while i > 0
		i -= 1
		inspector = customer[inspectors[i]].GetActorReference() as Actor
		menu.SetPropertyIndexInt("entryId",menu.AddEntryItem(inspector.GetDisplayName()),inspectors[i])
	endwhile

	menu.OpenMenu()
	currentCanditateNo = menu.GetResultInt()
	if currentCanditateNo < 0
		Trace("User stops inspection")
		intListClear(self,"inspectors")
		SetStage(79)
		return
	endif

	IntListRemove(self,"inspectors", currentCanditateNo)
	inspector = customer[currentCanditateNo].GetActorReference()
	Alias_inspector.ForceRefTo(inspector)
	(customer[currentCanditateNo] as MEP_AuctionCandidateAlias).Cleanup()
	Trace(inspector.GetDisplayName() + " will inspect you")
	inspectionWatchdogArmed = true
	RegisterForSingleUpdate(InspectionTimeoutSeconds)
	MEPAuctionCustomerInspection.ForceStart()
endfunction

Function inspectionDone() ; stage 74
	inspectionWatchdogArmed = false
	UnregisterForUpdate()
	Trace("inpection done, next")
	Actor inspector = Alias_inspector.GetActorReference()
	(customer[currentCanditateNo] as MEP_AuctionCandidateAlias).Startup(inspector, none)
	Alias_inspector.Clear()
	SetStage(73)
EndFunction

function bidForPlayer() ; stage 79
	Trace("start bidding")
	MEPAuctionPlayerBidding.ForceStart()
endfunction

Function handOverPlayer() ; stage 80
	Trace("handover player")
	entry.SetAngle(entry.GetAngleX(),entry.GetAngleY(),entry.GetAngleZ() + 180)
	entryRotated = true
	int i = customer.length
	while i > 0
		i -= 1
		(customer[i] as MEP_AuctionCandidateAlias).Done()
	endwhile
	Alias_customer.ForceRefTo(winner)
	Alias_candidate01.Clear()
	FormListRemove(self,"customer",winner)
	gone(None)
	MEP_EscortQuest.SetNextDestination(whipping_device)
	MEP_DeviceManagerQuest.Manage(whipping_device)
	MEPAuctionPlayerSold.Start()
EndFunction

Function pay() ; stage 81
	MariasUtils.Pay(winner,boss,2000)
EndFunction

Function giveKey() ; stage 82
	mrm.GiveAllRequiredKeysTo(PlayerRef, winner, the_guard)
EndFunction

Function handOverDone() ; stage 85
	Trace("handover done")
	;if winner.IsInFaction(MariaFaction_BrothelBoss) || winner.IsInFaction(JobInnkeeperFaction) || winner.IsInFaction(JobHostlerFaction) || winner.IsInFaction(JobMerchantFaction)
	;	MEPAuctionEscortHome.Start()
	;else
	SetStage(90)
	;endif		
EndFunction

function Enslave() ; stage 90
	Alias_customer.Clear()
	Alias_slaveguard.Clear()
	Alias_auctioneer.Clear()
	PlayerRef.RemoveFromFaction(MariaBusyFaction)
	Stop()
endfunction
