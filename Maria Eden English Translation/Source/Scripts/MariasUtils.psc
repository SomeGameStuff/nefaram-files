Scriptname MariasUtils extends Quest

Form function GetFormFromMod(int id,string mod) global
	if Game.GetModByName(mod) != 255
		return Game.GetFormFromFile(id, mod)
	else
		return none
	endif
endfunction

form[] function GetClothes(Actor act) global
	StorageUtil.FormListClear(act,"tmpCl")
	int slotsChecked
    slotsChecked += 0x00100000;ignore reserved slots
    ; slotsChecked += 0x00200000
    slotsChecked += 0x80000000;ignore reserved slots
	int thisSlot = 0x01
	int x = 0
    while thisSlot < 0x80000000
		if Math.LogicalAnd(slotsChecked, thisSlot) != thisSlot
			Armor f = act.GetWornForm(thisSlot) as Armor
			if f
				StorageUtil.FormListAdd(act,"tmpCl",f,false)
				slotsChecked += f.GetSlotMask()
			else
				slotsChecked += thisSlot
			endif
		endif
		thisSlot *= 2 ;double the number to move on to the next slot
	endwhile
	form[] clothes = StorageUtil.FormListToArray(act,"tmpCl")
	StorageUtil.FormListClear(act,"tmpCl")
	return clothes
endfunction

function EquipFormList(Actor act,bool locked,Form[] list) global
	if list
		int i = list.Length
		while i>0
			i-=1
			if list[i] != none
				act.EquipItem(list[i],locked,true)
			endif
		endwhile
	endif
endfunction

; 26 = clothes
; 41 = weapons
function RemoveItems(ObjectReference act,int formTyp,ObjectReference destinationContainer = none) global
	Form[] forms = act.GetContainerForms()
	Int iFormIndex = forms.length
	while iFormIndex > 0
		iFormIndex -= 1
		if forms[iFormIndex].GetType() == formTyp
			act.RemoveItem(forms[iFormIndex],1,true,destinationContainer)
		endIf
	endwhile
endfunction

function PlaceRelative(ObjectReference actorToMove, ObjectReference actor2, Float afDistance = 45.0, Float afRotZ = 0.0, Float afOffsetX = 0.0, Float afOffsetY = 0.0, Float afOffsetZ = 0.0) Global
	bool warp = actorToMove.GetParentCell() != actor2.GetParentCell()
	if warp
		actorToMove.DisableNoWait()
	endif
	actorToMove.MoveTo(actor2, afDistance * Math.Sin(actor2.GetAngleZ() + afRotZ) + afOffsetX, afDistance * Math.Cos(actor2.GetAngleZ() + afRotZ) + afOffsetY, afOffsetZ, false)
	if warp
		actorToMove.EnableNoWait()
		if actorToMove.GetType() == 62
			(actorToMove as Actor).EvaluatePackage()
		endif
	endif
endfunction

function PlaceRelativeAndLookTo(ObjectReference actorToMove, ObjectReference actor2, Float afDistance = 45.0, Float afRotZ = 0.0, Float afOffsetX = 0.0, Float afOffsetY = 0.0, Float afOffsetZ = 0.0) Global
	bool warp = actorToMove.GetParentCell() != actor2.GetParentCell()
	float zOffset = actorToMove.GetHeadingAngle(actor2)
	if warp
		actorToMove.DisableNoWait()
	endif
	actorToMove.SetAngle(actorToMove.GetAngleX(), actorToMove.GetAngleY(), actorToMove.GetAngleZ() + zOffset)
	actorToMove.MoveTo(actor2, afDistance * Math.Sin(actor2.GetAngleZ() + afRotZ) + afOffsetX, afDistance * Math.Cos(actor2.GetAngleZ() + afRotZ) + afOffsetY, afOffsetZ, false)
	if warp
		actorToMove.EnableNoWait()
		if actorToMove.GetType() == 62
			(actorToMove as Actor).EvaluatePackage()
		endif
	endif
endfunction

function MoveRefToPositionRelativeTo(ObjectReference akSubject, ObjectReference akTarget, float OffsetDistance = 0.0, float OffsetAngle = 0.0, bool FaceTarget = false) global
	; http://www.creationkit.com/Movement_Relative_to_Another_Object
	float AngleZ = akTarget.GetAngleZ() + OffsetAngle
	float OffsetX = OffsetDistance * Math.Sin(AngleZ)
	float OffsetY = OffsetDistance * Math.Cos(AngleZ)
	bool warp = akSubject.GetParentCell() != akTarget.GetParentCell()
	if warp
		akSubject.DisableNoWait()
	endif
	if FaceTarget
		akSubject.SetAngle(akSubject.GetAngleX(), akSubject.GetAngleY(), akSubject.GetAngleZ() +  akSubject.GetHeadingAngle(akTarget))
	endif
	akSubject.MoveTo(akTarget, OffsetX, OffsetY, 0.0)
	if warp
		akSubject.EnableNoWait()
		if akSubject.GetType() == 62
			(akSubject as Actor).EvaluatePackage()
		endif
	endif
endfunction

function Translate(ObjectReference toMove, ObjectReference dst, float offset, float rotation) global
	float anglez = dst.GetAngleZ()
	float anglex = dst.GetAngleX() * -1
	float offsetz = offset * math.sin(anglex)
	float tempfloat = offset * math.cos(anglex)
	float offsetx = tempfloat * math.sin(anglez)
	float offsety = tempfloat * math.cos(anglez)
	float posx = dst.GetPositionX() + offsetx
	float posy = dst.GetPositionY() + offsety
	float posz = dst.GetPositionZ() + offsetz
	toMove.MoveTo(dst, offsetx, offsety, offsetz)
	toMove.SetAngle(0.0, 0.0, dst.getAngleZ()+rotation)
	;toMove.SetAngle(dst.GetAngleX(), dst.GetAngleY(), dst.GetAngleZ()+rotation)
	;toMove.TranslateTo(posx, posy, posz, 0, 0, dst.GetAngleZ()+rotation, 90.0, 25.0)
endfunction

function PlaceAtDoor(ObjectReference marker,ObjectReference theDoor,bool comingIn = true) global
	float angle = theDoor.GetAngleZ()
	marker.SetAngle(marker.GetAngleX(), marker.GetAngleY(), angle - 90)
	marker.MoveTo(theDoor, 0, 0, -45, abMatchRotation = false)
	angle = marker.GetAngleZ()
	float xoffset = 80 * math.sin(angle)
	float yoffset = 80 * math.cos(angle)
	marker.SetPosition(marker.GetPositionX() + xoffset,marker.GetPositionY() + yoffset,marker.GetPositionZ())
	if !comingIn
		marker.SetAngle(marker.GetAngleX(), marker.GetAngleY(), marker.GetAngleZ() + 180)
	endif
endfunction

bool function SpawnAtNearestDoor(ObjectReference object) global
	ObjectReference theDoor = MESKSEUtils.FindNearestExitDoor(Game.GetPlayer())
	if theDoor
		PlaceAtDoor(object,theDoor,true)
		return true
	endif
	return false
endFunction

function FastPlaceInFrontOfAndFaceTo(ObjectReference actorToMove,ObjectReference actor2,int distance = 100) global
	float angle = actor2.GetAngleZ()
	float xoffset = distance * math.sin(angle)
	float yoffset = distance * math.cos(angle)
	actorToMove.SetAngle(actorToMove.GetAngleX(), actorToMove.GetAngleY(), angle)
	actorToMove.MoveTo(actor2, xoffset, yoffset, abMatchRotation = false)
endfunction

function FastPlaceInFrontOf(ObjectReference actorToMove,ObjectReference actor2,int distance = 100) global
	float angle = actor2.GetAngleZ()
	float xoffset = distance * math.sin(angle)
	float yoffset = distance * math.cos(angle)
	actorToMove.SetAngle(actorToMove.GetAngleX(), actorToMove.GetAngleY(), angle - 180)
	actorToMove.MoveTo(actor2, xoffset, yoffset, abMatchRotation = false)
endfunction

function PlaceInFrontOf(ObjectReference actorToMove,ObjectReference actor2,int distance = 100) global
	float angle = actor2.GetAngleZ()
	float xoffset = distance * math.sin(angle)
	float yoffset = distance * math.cos(angle)
	bool warp = actor2.GetParentCell() != actorToMove.GetParentCell()
	if warp
		actorToMove.DisableNoWait()
	endif
	actorToMove.SetAngle(actorToMove.GetAngleX(), actorToMove.GetAngleY(), angle - 180)
	actorToMove.MoveTo(actor2, xoffset, yoffset, abMatchRotation = false)
	if warp
		actorToMove.EnableNoWait()
		if actorToMove.GetType() == 62
			(actorToMove as Actor).EvaluatePackage()
		endif
	endif
endfunction

function MoveForward(ObjectReference actorToMove,int distance = 100) global
	float angle = actorToMove.GetAngleZ()
	float xoffset = distance * math.sin(angle)
	float yoffset = distance * math.cos(angle)
	actorToMove.SetPosition(actorToMove.GetPositionX() + xoffset,actorToMove.GetPositionY() + yoffset,actorToMove.GetPositionZ())
endfunction

function FastPlaceBehindOf(ObjectReference actorToMove,ObjectReference actor2,int distance = 100) global
	float angle = actor2.GetAngleZ()
	float xoffset = -(distance * math.sin(angle))
	float yoffset = -(distance * math.cos(angle))
	actorToMove.MoveTo(actor2, xoffset, yoffset, abMatchRotation = true)
endfunction

function PlaceBehind(ObjectReference actorToMove,ObjectReference actor2,int distance = 100) global
	if actor2 != none && actorToMove != none
		float angle = actor2.GetAngleZ()
		float xoffset = -(distance * math.sin(angle))
		float yoffset = -(distance * math.cos(angle))
		bool warp = actor2.GetParentCell() != actorToMove.GetParentCell()
		if warp
			actorToMove.DisableNoWait()
		endif
		actorToMove.MoveTo(actor2, xoffset, yoffset, abMatchRotation = true)
		if warp
			actorToMove.EnableNoWait()
			if actorToMove.GetType() == 62
				(actorToMove as Actor).EvaluatePackage()
			endif
		endif
	endif
endfunction

function RotateTo(ObjectReference actorToRotate,ObjectReference actor2) global
	if !actorToRotate || !actor2
		Return
	endif
	float zOffset = actorToRotate.GetHeadingAngle(actor2)
	actorToRotate.SetAngle(actorToRotate.GetAngleX(), actorToRotate.GetAngleY(), actorToRotate.GetAngleZ() + zOffset)
	;actorToRotate.TranslateTo(actorToRotate.GetPositionX(), actorToRotate.GetPositionY(), actorToRotate.GetPositionZ(), actorToRotate.GetAngleX(), actorToRotate.GetAngleY(), actorToRotate.GetAngleZ() + zOffset, 10.0, 0.0)
	;actorToRotate.TranslateTo(actorToRotate.GetPositionX(), actorToRotate.GetPositionY(), actorToRotate.GetPositionZ(), actorToRotate.GetAngleX(), actorToRotate.GetAngleY(), actor2.GetAngleZ() + 180.0, 10.0, 0.0)
	;actorToRotate.TranslateTo(actorToRotate.X+2,actorToRotate.Y,actorToRotate.Z,actorToRotate.GetAngleX(), actorToRotate.GetAngleY(), actorToRotate.GetAngleZ() + zOffset,100,0)
endfunction

function RotateTogether(ObjectReference actorToRotate,ObjectReference actor2) global
	float zOffset = actorToRotate.GetHeadingAngle(actor2)
	actorToRotate.SetAngle(actorToRotate.GetAngleX(), actorToRotate.GetAngleY(), actorToRotate.GetAngleZ() + zOffset)
	;actorToRotate.TranslateTo(actorToRotate.X+2,actorToRotate.Y,actorToRotate.Z,actorToRotate.GetAngleX(), actorToRotate.GetAngleY(), actorToRotate.GetAngleZ() + zOffset,100,0)
	zOffset = actor2.GetHeadingAngle(actorToRotate)
	actor2.SetAngle(actor2.GetAngleX(), actor2.GetAngleY(), actor2.GetAngleZ() + zOffset)
	;actor2.TranslateTo(actor2.X+2,actor2.Y,actor2.Z,actor2.GetAngleX(), actor2.GetAngleY(), actor2.GetAngleZ() + zOffset,100,0)
endfunction

function RotateAway(ObjectReference actorToRotate,ObjectReference actor2) global
	;actorToRotate.TranslateTo(actorToRotate.X+2,actorToRotate.Y,actorToRotate.Z,actorToRotate.GetAngleX(), actorToRotate.GetAngleY(), actor2.GetAngleZ(),100,0)
	actorToRotate.SetAngle(actorToRotate.GetAngleX(), actorToRotate.GetAngleY(), actor2.GetAngleZ())
endfunction

function CloseMCM() global
    UI.Invoke("Journal Menu", "_root.QuestJournalFader.Menu_mc.ConfigPanelClose") ; mcm
    UI.Invoke("Journal Menu", "_root.QuestJournalFader.Menu_mc.CloseMenu") ; quest journal
endfunction

function OpenInventory() global
    UI.InvokeString("HUD Menu", "_global.skse.OpenMenu", "InventoryMenu")
endfunction

bool function IsActorWounded(Actor act) Global
	;Package curActorPackage = act.GetCurrentPackage()
	; CWFortSoldierWoundedPackage = 0xfd82c
	;return curActorPackage == none || curActorPackage.GetFormID() != 0xfd82c

	; ClothesArmBandages == 0x4f006 , ClothesHeadBandages == 0x4f000
	return act.IsEquipped(Game.GetForm(0x4f006)) || act.IsEquipped(Game.GetForm(0x4f000))
endfunction

float function CalcGameTimeOffsetSeconds(int seconds,float starttime = 0.0) global
	;GlobalVariable TimeScale = Game.GetForm(0x3a) as GlobalVariable
	if !starttime
		starttime = Utility.GetCurrentGameTime()
	endif
	;return starttime + seconds * TimeScale.GetValue() / 86400.0
	return starttime + ((seconds as float) / 86400.0)
endFunction

float function CalcGameTimeOffsetMinutes(int minutes,float starttime = 0.0) global
	if !starttime
		starttime = Utility.GetCurrentGameTime()
	endif
	return starttime + ((minutes as float) / 1440.0)
endFunction

float function CalcRealGameTimeOffsetMinutes(int minutes,float starttime = 0.0) global
	GlobalVariable TimeScale = Game.GetForm(0x3a) as GlobalVariable
	if !starttime
		starttime = Utility.GetCurrentGameTime()
	endif
	return starttime + ((minutes as float) * TimeScale.GetValue()) / 1440.0
endFunction

float function CalcGameTimeOffsetHours(int hours,float starttime = 0.0) global
	;GlobalVariable TimeScale = Game.GetForm(0x3a) as GlobalVariable
	if !starttime
		starttime = Utility.GetCurrentGameTime()
	endif
	;return starttime + minutes * TimeScale.GetValue() / 1440.0
	return starttime + ((hours as float) / 24.0)
endFunction

int function CalcGameTimeSeconds(float starttime,float endtime = 0.0) global
	;GlobalVariable TimeScale = Game.GetForm(0x3a) as GlobalVariable
	if endtime == 0.0
		endtime = Utility.GetCurrentGameTime()
	endif
	;return (((endtime - starttime) * 86400.0)  / TimeScale.GetValue()) as int
	return ((endtime - starttime) * 86400.0) as int
endfunction

int function CalcGameTimeMinutes(float starttime,float endtime = 0.0) global
	if endtime == 0.0
		endtime = Utility.GetCurrentGameTime()
	endif
	return ((endtime - starttime) * 1440.0) as int
endfunction

int function CalcRealGameTimeMinutes(float starttime,float endtime = 0.0) global
	GlobalVariable TimeScale = Game.GetForm(0x3a) as GlobalVariable
	if endtime == 0.0
		endtime = Utility.GetCurrentGameTime()
	endif
	return (((endtime - starttime) * 1440.0)  / TimeScale.GetValue()) as int
endfunction

int function CalcGameTimeHours(float starttime,float endtime = 0.0) global
	;GlobalVariable TimeScale = Game.GetForm(0x3a) as GlobalVariable
	if endtime == 0.0
		endtime = Utility.GetCurrentGameTime()
	endif
	;return (((endtime - starttime) * 24.0)  / TimeScale.GetValue()) as int
	return ((endtime - starttime) * 24.0) as int
endfunction

int function CalcGameTimeDays(float starttime,float endtime = 0.0) global
	GlobalVariable TimeScale = Game.GetForm(0x3a) as GlobalVariable
	if endtime == 0.0
		endtime = Utility.GetCurrentGameTime()
	endif
	;return ((endtime - starttime)  / TimeScale.GetValue()) as int
	return (endtime - starttime) as int
endfunction

Weapon function EquipCane(Actor act) global
	Weapon cane = PO3_SKSEFunctions.GetFormFromEditorID("zbfWeaponCane") as Weapon
	Ammo am = PO3_SKSEFunctions.GetEquippedAmmo(act)
	if am
		act.UnEquipItem(am)
	endif
	act.EquipItem(cane)
	return cane
endfunction

function UnequipCane(Actor act) global
	Weapon cane = PO3_SKSEFunctions.GetFormFromEditorID("zbfWeaponCane") as Weapon
	act.UnequipItem(cane)
endfunction

function TransferCane(Actor from,Actor to) global
	Weapon cane = PO3_SKSEFunctions.GetFormFromEditorID("zbfWeaponCane") as Weapon
	from.UnEquipItem(cane)
	from.RemoveItem(cane,1)
	to.AddItem(cane)
	if to != Game.GetPlayer()
		to.EquipItem(cane)
		Ammo am = PO3_SKSEFunctions.GetEquippedAmmo(to)
		if am
			to.UnEquipItem(am)
		endif
	endif
endfunction

function GiveCane(Actor from,Actor to) global
	Weapon cane = PO3_SKSEFunctions.GetFormFromEditorID("zbfWeaponCane") as Weapon
	from.UnEquipItem(cane)
	from.RemoveItem(cane,1)
	to.EquipItem(cane)
	Ammo am = PO3_SKSEFunctions.GetEquippedAmmo(to)
	if am
		to.UnEquipItem(am)
	endif
endfunction

string function GetModNameOf(Form f) global
	return Game.GetModName(Math.LogicalAnd(Math.RightShift(f.GetFormID(), 24), 255))
endfunction

string function GetModID(Form f) global
	return Math.LogicalAnd(f.GetFormID(),16777215) as string
endfunction

string function GetUniqueID(Form f) global
	int fid = f.GetFormID()
	return Math.LogicalAnd(fid,16777215) + "|" + Game.GetModName(Math.RightShift(fid,24))
endfunction

string Function GetBestName(Form f)  global
	if !f
		return "none"
	endif
	string name
	ObjectReference obj = f as ObjectReference
	if obj
		name = obj.GetDisplayName()
		if name == ""
			name = obj.GetName()
		endif
		if name == ""
			f = obj.GetBaseObject()
		endif
	endif
	if name == ""
		name = f.GetName()
	endif
	if name == ""
		name = PO3_SKSEFunctions.GetFormEditorID(f)
	endif
	if name == ""
		int fid = f.GetFormID()
		name = Game.GetModName(Math.LogicalAnd(Math.RightShift(fid, 24), 255)) + " : 0x" + MESKSEUtils.StringToHex(Math.LogicalAnd(fid,16777215))
	endif
	return name
EndFunction

function StartErection(Actor npc) global
	Debug.SendAnimationEvent(npc, "SOSFastErect")
	;/
	Debug.SendAnimationEvent(npc, "SOSBend"+Schlong)
	if !npc.GetLeveledActorBase().GetSex()
		Spell SOS_ErectionNPCSpell = MariasUtils.GetFormFromMod(0x030110E4,"Schlongs of Skyrim.esp") as Spell
		if SOS_ErectionNPCSpell
			;Debug.SendAnimationEvent(sexPartner, "SOSBend9")
			SOS_ErectionNPCSpell.Cast(npc,npc)
		endif
	endif
	/;
endfunction

function StopErection(Actor npc) global
	if !npc.GetLeveledActorBase().GetSex()
		Debug.SendAnimationEvent(npc, "SOSFlaccid")
	endif
endfunction

ObjectReference function SaveLocation(Actor PlayerRef = none) global
	if PlayerRef
		return PlayerRef.PlaceAtMe(Game.GetForm(0x34))
	else
		return Game.GetPlayer().PlaceAtMe(Game.GetForm(0x34))
	endif
endfunction

function ReturnToSavedLocation(ObjectReference marker,Actor PlayerRef=none,Actor Escort1 = none,Actor Escort2 = none) global
	if !marker
		return
	endif
	if PlayerRef
		PlayerRef.MoveTo(marker)
		Utility.Wait(2)
		if Escort1
			PlaceInFrontOf(Escort1,PlayerRef)
		endif
		if Escort2
			PlaceBehind(Escort2,PlayerRef)
		endif
	else
		if Escort1
			Escort1.MoveTo(marker)
		endif
		if Escort2
			Escort2.MoveTo(marker)
		endif
	endif
	marker.Disable()
	marker.Delete()
endfunction

function CoinSound(ObjectReference soundCenter = none) global
	if !soundCenter
		soundCenter = Game.GetPlayer()
	endif
	Sound ITMGoldDown = Game.GetForm(0x334AB) as Sound
	Sound.SetInstanceVolume(ITMGoldDown.Play(soundCenter),1)
endFunction

function Pay(Actor from,Actor to,int gold) global
	Debug.Trace("@@ payment: " + from.GetDisplayName() + " pays " + gold as string + " to " + to.GetDisplayName())
	from.RemoveItem(Game.GetForm(0xf),gold,false)
	to.AddItem(Game.GetForm(0xf),gold)
	CoinSound(to)
	int handle = ModEvent.Create("MariaPaymentEvent")
	ModEvent.PushForm(handle, from)
	ModEvent.PushForm(handle, to)
	ModEvent.PushInt(handle, gold)
	ModEvent.Send(handle)
endFunction

function DropCoin(Actor giver,Actor taker = none) global
	Form septim = Game.GetForm(0xf)
	Debug.SendAnimationEvent(giver,"IdleGive")
	giver.AddItem(septim,1)
	ObjectReference coin = giver.DropObject(septim)
	if taker
		coin.SetActorOwner(taker.GetLeveledActorBase())
	else
		coin.SetActorOwner(none)
	endif
	coin.SetFactionOwner(none)
endFunction

function IncreaseMood(Actor npc,Actor related = none) global
	string uname = GetUserDisplayName(npc)
	Debug.Notification(uname + " liked that")
	;Debug.TraceStack("#################### yes :-)")
	int mood = npc.GetActorValue("mood") as int
	if mood == 3
		if related
			int relation = npc.GetRelationShipRank(related)
			if relation < 4
				relation += 1
				Debug.Trace("@@ social: " + uname + " relation rank " + relation as string)
				npc.SetRelationShipRank(related,relation)
			endif
		endif
	elseif mood == 0
		Debug.Trace("@@ social: " + uname + " becomes happy")
		npc.SetActorValue("mood",3)
	else
		Debug.Trace("@@ social: " + uname + " becomes neutral")
		npc.SetActorValue("mood",0)
	endif
endfunction

function DecreaseMood(Actor npc,Actor related = none,int minValue = -1) global
	string uname = GetUserDisplayName(npc)
	Debug.Notification(uname + " did not like that")
	Debug.TraceStack("#################### nono :-(")
	int mood = npc.GetActorValue("mood") as int
	if mood == 3
		Debug.Trace("@@ social: " + uname + " becomes neutral")
		npc.SetActorValue("mood",0)
	elseif mood == 1
		if related
			int relation = npc.GetRelationShipRank(related)
			if relation > minValue
				relation -= 1
				Debug.Trace("@@ social: " + uname + " relation rank " + relation as string)
				npc.SetRelationShipRank(related,relation)
			endif
		endif
	elseif mood == 0
		Debug.Trace("@@ social: " + uname + " becomes angry")
		npc.SetActorValue("mood",1)
	else
		Debug.Trace("@@ social: " + uname + " becomes neutral")
		npc.SetActorValue("mood",0)
	endif
endfunction

function BecomesAngry(Actor npc, Actor related, int relationshipRank) global
	string uname = GetUserDisplayName(npc)
	Debug.Notification(uname + " is angry")
	npc.SetActorValue("mood",1)
	npc.SetRelationShipRank(related,relationshipRank)
endfunction

string function GetRelationShipText(int rank) global
	if rank == 0
		return "$ME_STAT_RELATION_0"
	elseif rank == 1
		return "$ME_STAT_RELATION_1"
	elseif rank == 2
		return "$ME_STAT_RELATION_2"
	elseif rank == 3
		return "$ME_STAT_RELATION_3"
	elseif rank == 4
		return "$ME_STAT_RELATION_4"
	elseif rank == -1
		return "$ME_STAT_RELATION_M1"
	elseif rank == -2
		return "$ME_STAT_RELATION_M2"
	elseif rank == -3
		return "$ME_STAT_RELATION_M3"
	elseif rank == -4
		return "$ME_STAT_RELATION_M4"
	else
		return "unknown :" + rank as string
	endif
endfunction
string function GetMoodText(int mood) global
	if mood == 0
		return "$ME_MOOD_0"
	elseif mood == 1
		return "$ME_MOOD_1"
	elseif mood == 2
		return "$ME_MOOD_2"
	elseif mood == 3
		return "$ME_MOOD_3"
	elseif mood == 4
		return "$ME_MOOD_4"
	elseif mood == 5
		return "$ME_MOOD_5"
	elseif mood == 6
		return "$ME_MOOD_6"
	elseif mood == 7
		return "$ME_MOOD_7"
	endif
endfunction

ObjectReference function DropMarkerAt(ObjectReference markerLocation,string name = "") global
	Form cache
	ObjectReference marker
	if name != ""
		cache = markerLocation.GetParentCell()
		marker = StorageUtil.GetFormValue(cache,name) as ObjectReference
		if marker
			marker.MoveTo(markerLocation)
			return marker
		endif
	endif
	marker = markerLocation.PlaceAtMe(Game.GetForm(0x34),abForcePersist = true)
	if cache
		marker.SetName(name)
		StorageUtil.SetFormValue(cache,name,marker)
	endif
	return marker
endfunction

ObjectReference function GetMarker(ObjectReference markerLocation,string name) global
	Form cache = markerLocation.GetParentCell()
	return StorageUtil.GetFormValue(cache,name) as ObjectReference
endFunction

function OpenMouth(Actor victim) global
	MfgConsoleFunc.SetPhoneme(victim, 1, 100)
	MfgConsoleFunc.SetPhoneme(victim, 11, 70)
endfunction

function CloseMouth(Actor victim) global
	int i
	while i <= 15
		MfgConsoleFunc.SetPhonemeModifier(victim, 0, i, 0)
		i += 1
	endWhile
endfunction


string function GetFullName(ObjectReference theActor) global
	if theActor
		string loc
		Cell c = theActor.GetParentCell()
		if c && c.IsInterior()
			loc = c.GetName()
		endif
		if loc == "" && theActor.GetCurrentLocation()
			loc = theActor.GetCurrentLocation().GetName()
		endif
		if loc == "" && theActor.GetEditorLocation()
			loc = theActor.GetEditorLocation().GetName()
		endif
		string name = theActor.GetDisplayName()
		if loc != ""
			name += " - " + loc
		endif
		return name
	else
		return ""
	endif
endfunction

Form function QuickMenuSelectForm(Form[] items,bool random = false)
	if !items
		return none
	endif
	int m = items.Length
	if m < 1
		return none
	endif
	if m < 2
		return items[0]
	endif
	if random
		return items[Utility.RandomInt(0,m - 1)]
	endif
	PrepareQuickMenu()
	int i = 0
	while i < m
		AddQuickMenuEntry(items[i].GetName(),items[i])
		i += 1
	endwhile
	return DoQuickMenuForm()
endfunction

Form function QuickMenuSelectQuest(Form[] items,bool random = false)
	if !items
		return none
	endif
	int m = items.Length
	if m < 1
		return none
	endif
	if m < 2
		return items[0]
	endif
	if random
		return items[Utility.RandomInt(0,m - 1)]
	endif
	PrepareQuickMenu()
	int i = 0
	while i < m
		string name
		Quest q = items[i] as Quest
		if !q
			Keyword k = items[i] as Keyword
			name = k.GetString()
			string n = MESKSEUtils.ReplaceString(name,"Keyword","")
			q = Quest.GetQuest(n)
		endif
		if q
			name = q.GetName()
		endif
		AddQuickMenuEntry(name,items[i])
		i += 1
	endwhile
	return DoQuickMenuForm()
endfunction

Actor function QuickMenuSelectActor(Form[] actors,bool random = false)
	if !actors
		return none
	endif
	int m = actors.Length
	if m < 1
		return none
	endif
	if m < 2
		return actors[0] as Actor
	endif
	if random
		return actors[Utility.RandomInt(0,m - 1)] as Actor
	endif
	PrepareQuickMenu()
	int i = 0
	while i < m
		AddQuickMenuEntry(GetFullName(actors[i] as ObjectReference),actors[i])
		i += 1
	endwhile
	return DoQuickMenuForm() as Actor
endfunction

int function QuickMenu(string menuitems,bool random = false)
	return PerformQuickMenu(zbfUtil.ArgString(menuitems),random)
endfunction

string function QuickMenuString(string menuitems,bool random = false)
	return PerformQuickMenuString(zbfUtil.ArgString(menuitems),random)
endfunction

ObjectReference function SelectObjectReference(Form[] refs,bool forceSelection = false,bool random = false,bool addLocation = false,Form filter = none)
	PrepareQuickMenu()
	if addLocation
		AddQuickMenuObjectWithLocationEntries(refs,filter)
	else
		AddQuickMenuObjectEntries(refs,filter)
	endif
	return DoQuickMenuForm(forceSelection,random) as ObjectReference
endfunction

ObjectReference function SelectListReference(Form[] refs,bool forceSelection = false,bool random = false)
	PrepareQuickMenu()
	AddQuickMenuEntries(refs)
	return DoQuickMenuForm(forceSelection,random) as ObjectReference
endfunction

ObjectReference function SelectFormListReference(FormList list,bool forceSelection = false,bool random = false)
	return SelectListReference(list.ToArray(),forceSelection,random)
endfunction

int function PerformQuickMenu(string[] menuitems,bool random = false)
	if !menuitems
		return -1
	endif
	int m = menuitems.Length
	if m < 1
		return -1
	endif
	if m < 2
		return 0
	endif
	if random
		return Utility.RandomInt(0,m - 1)
	endif
	PrepareQuickMenu()
	int i = 0
	while i < m
		AddQuickMenuEntry(menuitems[i])
		i += 1
	endwhile
	return DoQuickMenuInt()
endfunction

string function PerformQuickMenuString(string[] menuitems,bool random = false)
	int i = PerformQuickMenu(menuitems,random)
	if i < 0
		return ""
	endif
	return menuitems[i]
endfunction

UIListMenu qmenu

UIListMenu function PrepareQuickMenu(string firstEntry = "",Form f = none)
	qmenu = UIExtensions.GetMenu("UIListMenu", true) as UIListMenu
	qmenu.ResetMenu()
	StorageUtil.StringListClear(self,"quickmenu")
	StorageUtil.FormListClear(self,"quickmenu")
	quickMenuResult = none
	if firstEntry != ""
		AddQuickMenuEntry(firstEntry,f)
	endif
	return qmenu
endfunction

function AddQuickMenuEntry(string entry,Form f = none)
	if entry == "" && f
		entry = f.GetName()
		if entry == ""
			entry = f as string
		endif
	endif
	qmenu.AddEntryItem(entry)
	StorageUtil.StringListAdd(self,"quickmenu",entry)
	StorageUtil.FormListAdd(self,"quickmenu",f)
endfunction

int function GetQuickMenuItemCount()
	return StorageUtil.StringListCount(self,"quickmenu")
endfunction

function AddQuickMenuEntries(Form[] entries)
	if entries
		int i = entries.Length
		while i > 0
			i -= 1
			AddQuickMenuEntry("",entries[i])
		endwhile
	endif
endfunction

function AddQuickMenuLocationEntries(Form[] entries,Form filter = none)
	if entries
		int i = entries.Length
		while i > 0
			i -= 1
			ObjectReference obj = entries[i] as ObjectReference
			if obj && obj != filter
				AddQuickMenuEntry(obj.GetCurrentLocation().GetName(),obj)
			endif
		endwhile
	endif
endfunction

function AddQuickMenuObjectEntries(Form[] entries,Form filter = none)
	if entries
		int i = entries.Length
		while i > 0
			i -= 1
			ObjectReference obj = entries[i] as ObjectReference
			if obj && obj != filter
				AddQuickMenuEntry(obj.GetDisplayName(),obj)
			endif
		endwhile
	endif
endfunction

function AddQuickMenuObjectWithLocationEntries(Form[] entries,Form filter = none)
	if entries
		int i = entries.Length
		while i > 0
			i -= 1
			ObjectReference obj = entries[i] as ObjectReference
			if obj && obj != filter
				AddQuickMenuEntry(GetFullName(obj),obj)
			endif
		endwhile
	endif
endfunction

Form quickMenuResult
int quickMenuSelection
string quickMenuString

string function EnterText(string current_text="")
	UITextEntryMenu menu = UIExtensions.GetMenu("UITextEntryMenu", true) as UITextEntryMenu
	menu.ResetMenu()
	if current_text != ""
		menu.SetPropertyString("text",current_text)
		menu.UpdateTextEntryString()
	endif
	if !menu.OpenMenu()
		return ""
	endif
	return menu.GetResultString()
endfunction

form function GetLastQuickMenuForm()
	return quickMenuResult
endfunction

string function DoQuickMenu(bool forceSelection = false,bool random = false)
	DoQuickMenuInt(forceSelection,random)
	return quickMenuString
endfunction

form function DoQuickMenuForm(bool forceSelection = false,bool random = false)
	DoQuickMenuInt(forceSelection,random)
	return quickMenuResult
endfunction

int function DoQuickMenuInt(bool forceSelection = false,bool random = false)
	quickMenuResult = none
	quickMenuSelection = -1
	quickMenuString = ""
	int i = StorageUtil.StringListCount(self,"quickmenu")
	if !i
		return quickMenuSelection
	elseif i == 1 && random
		quickMenuSelection = 0
		quickMenuResult = StorageUtil.FormListGet(self,"quickmenu",quickMenuSelection)
		quickMenuString = StorageUtil.StringListGet(self,"quickmenu",quickMenuSelection)
		StorageUtil.StringListClear(self,"quickmenu")
		StorageUtil.FormListClear(self,"quickmenu")
		return quickMenuSelection
	elseif random
		quickMenuSelection = Utility.RandomInt(0,i - 1)
		quickMenuResult = StorageUtil.FormListGet(self,"quickmenu",quickMenuSelection)
		quickMenuString = StorageUtil.StringListGet(self,"quickmenu",quickMenuSelection)
		StorageUtil.StringListClear(self,"quickmenu")
		StorageUtil.FormListClear(self,"quickmenu")
		return quickMenuSelection
	endif
	while true
		qmenu.OpenMenu()
		quickMenuSelection = qmenu.GetResultInt()
		if quickMenuSelection < 0 && !forceSelection
			StorageUtil.StringListClear(self,"quickmenu")
			StorageUtil.FormListClear(self,"quickmenu")
			return quickMenuSelection
		endif
		if quickMenuSelection >= 0
			quickMenuResult = StorageUtil.FormListGet(self,"quickmenu",quickMenuSelection)
			quickMenuString = StorageUtil.StringListGet(self,"quickmenu",quickMenuSelection)
			StorageUtil.StringListClear(self,"quickmenu")
			StorageUtil.FormListClear(self,"quickmenu")
			return quickMenuSelection
		endif
	endwhile
endfunction

ObjectReference function GetCurrentFurniture(Actor npc) global
	if npc.GetSitState() == 3
		ObjectReference furn = npc.GetFurnitureReference()
		if furn && furn.GetDistance(npc) < 500
			return furn
		endif
	endif
	return none
endfunction

; moves a to b if distance is to high
function MoveAToB(ObjectReference a,ObjectReference b,int maxDist=500) global
	Cell aCell = a.GetParentCell()
	Cell bCell = b.GetParentCell()
	bool aIsInside = aCell.IsInterior()
	bool bIsInside = bCell.IsInterior()
	if (aCell != bCell && aIsInside != bIsInside) || (a.GetDistance(b) > maxDist)
		if bIsInside
			b.DisableNoWait()
			a.MoveTo(b)
			float angle = b.GetAngleZ()
			float xoffset = 80 * math.sin(angle)
			float yoffset = 80 * math.cos(angle)
			; push b forward for short distance
			b.SetPosition(b.GetPositionX() + xoffset,b.GetPositionY() + yoffset,b.GetPositionZ())
			b.EnableNoWait()
		else
			; outside, it is secure to teleport behind
			float angle = b.GetAngleZ()
			float xoffset = -(80 * math.sin(angle))
			float yoffset = -(80 * math.cos(angle))
			a.MoveTo(b, xoffset, yoffset, abMatchRotation = true)
		endif
	endif
endfunction

function IncreaseFactionRank(Actor a,Faction f) global
	a.SetFactionRank(f, a.GetFactionRank(f) + 1)
endfunction

function DecreaseFactionRank(Actor a,Faction f) global
	a.SetFactionRank(f, a.GetFactionRank(f) - 1)
endfunction

FormList Property MariaBedList  Auto

; returns any furniture where the actor can sleep, ignore used beds and bedrolls
; it prefers beds on same floor
ObjectReference function FindBed(ObjectReference CenterRef = none, float Radius = 500.0)
	if !CenterRef
		CenterRef = Game.GetPlayer()
	endif

	ObjectReference[] beds = PO3_SKSEFunctions.FindAllReferencesOfType(CenterRef, MariaBedList, Radius)
	int x = beds.Length
	int i
	ObjectReference bestBed
	float bestDistance
	float distance
	ObjectReference bed

	; first prio: find on same floor
	while i < x
		bed = beds[i]
		if bed.IsFurnitureInUse() || !bed.IsEnabled() || !bed.Is3DLoaded()
			beds[i] = none ; disable for next prio
		elseif Math.Abs(CenterRef.GetPositionZ() - bed.GetPositionZ()) <= 15
			distance = bed.GetDistance(CenterRef)
			if !bestBed || distance < bestDistance
				bestBed = bed
				bestDistance = distance
			endif
			beds[i] = none ; disable for next prio
		endif
		i += 1
	endwhile

	if bestBed
		return bestBed
	endif

	; next prio: find on any floor
	i = 0
	while i < x
		bed = beds[i]
		if bed
			distance = bed.GetDistance(CenterRef)
			if !bestBed || distance < bestDistance
				bestBed = bed
				bestDistance = distance
			endif
		endif
		i += 1
	endwhile

	return bestBed
endfunction

ObjectReference function FindNearestFurniture(ObjectReference CenterRef = none, bool preferBed = true, int Radius = 1000) global
	if !CenterRef
		CenterRef = Game.GetPlayer()
	endif

	ObjectReference[] objects = MESKSEUtils.CollectRefsByType(CenterRef, 40, radius)
	int x = objects.Length
	int i

	int nearestBed = -1
	int nearestFurniture = -1
	while i < x && (nearestBed < 0 || nearestFurniture < 0)
		ObjectReference object = objects[i]
		if !object.IsFurnitureInUse()
			if nearestFurniture < 0
				nearestFurniture = i
			endif
			if nearestBed < 0 && PO3_SKSEFunctions.GetFurnitureType(object.GetBaseObject() as Furniture) == 3
				nearestBed = i
			endif
		endif
		i += 1
	endwhile
	if nearestBed >= 0 && preferBed
		return objects[nearestBed]
	endif
	if nearestFurniture >= 0
		return objects[nearestFurniture]
	endif
	return none
endfunction

ObjectReference function FindNearestBed(ObjectReference CenterRef = none, int Radius = 1000) global
	if !CenterRef
		CenterRef = Game.GetPlayer()
	endif

	ObjectReference[] objects = MESKSEUtils.CollectRefsByType(CenterRef, 40, radius)
	int x = objects.Length
	int i

	while i < x
		ObjectReference object = objects[i]
		if !object.IsFurnitureInUse() && PO3_SKSEFunctions.GetFurnitureType(object.GetBaseObject() as Furniture) == 3
			return object
		endif
		i += 1
	endwhile
	return none
endfunction

function PlaceOnBed(ObjectReference ref,ObjectReference bed, bool closeLinkedDoor) global
	int z = JsonUtil.GetIntValue("MariaDefaults","SexBedOffsetZ",40)
	;ref.MoveTo(bed,0,0,z,true)
	ref.SetPosition(bed.X,bed.Y,bed.Z + z)
	ref.SetAngle(bed.GetAngleX(),bed.GetAngleY(),bed.GetAngleZ())
	if closeLinkedDoor
		Keyword LinkCustom01 = Keyword.GetKeyword("LinkCustom01")
		ObjectReference linkedDoor = bed.GetLinkedRef(LinkCustom01)
		if linkedDoor
			linkedDoor.SetOpen(false)
		endif
	endif
endfunction

bool function IsAnimal(Actor actorRef) global
	Keyword ActorTypeCreature = Keyword.GetKeyword("ActorTypeCreature")
	return actorRef.HasKeyWordString(ActorTypeCreature)
endfunction

; 0 = male, 1 = female, 2 = animal
int function GetGender(Actor actorRef) global
	if IsAnimal(actorRef)
		return 2
	endif
	return actorRef.GetLeveledActorBase().GetSex()
endfunction

bool function IsValidSexActor(Actor actorRef) global
	return !actorRef.IsChild() \
		&& actorRef.IsEnabled() \
		&& actorRef.Is3DLoaded() \
		&& !IsActorWounded(actorRef)
endfunction

; returns the nearest actor preferrable on the same floor
; No childs, no wounded actors, no dead or disabled actors
; gender == 2 -> animal
Actor function FindNearestActorByGender(int gender, ObjectReference CenterRef = none, float Radius = 3000.0, Actor ignore1 = none, Actor ignore2 = none, Actor ignore3 = none) global
	if !CenterRef
		CenterRef = Game.GetPlayer()
	endif
	ObjectReference[] refs = PO3_SKSEFunctions.FindAllReferencesOfFormType(CenterRef, 43, Radius)
	int x = refs.Length
	int i
	Actor bestRef
	float bestDistance
	float distance
	Actor ref

	; first prio: find on same floor
	while i < x
		ref = refs[i] as Actor
		if !ref \
			|| ref == ignore1 \
			|| ref == ignore2 \
			|| ref == ignore3 \
			|| ref.IsDead() \
			|| ref.IsChild() \
			|| !ref.Is3DLoaded() \
			|| (gender < 0 || GetGender(ref) != gender) \
			|| (gender < 2 && IsActorWounded(ref))
			refs[i] = none ; disable for next prio
		elseif Math.Abs(CenterRef.GetPositionZ() - ref.GetPositionZ()) <= 15
			distance = ref.GetDistance(CenterRef)
			if !bestRef || distance < bestDistance
				bestRef = ref
				bestDistance = distance
			endif
			refs[i] = none ; disable for next prio
		endif
		i += 1
	endwhile

	if bestRef
		return bestRef
	endif

	; next prio: find on any floor
	i = 0
	while i < x
		ref = refs[i] as Actor
		if ref
			distance = ref.GetDistance(CenterRef)
			if !bestRef || distance < bestDistance
				bestRef = ref
				bestDistance = distance
			endif
		endif
		i += 1
	endwhile

	return bestRef
endfunction

bool function equipBestWeaponSet(Actor npc, Actor enemy = none) global
	; calculate best ammo
	Ammo bestArrow
	Ammo bestBolt
	float bestBoltDamage
	float bestArrowDamage
	bool preferSwords = enemy && npc.GetDistance(enemy) < 400

	Form[] amm = PO3_SKSEFunctions.AddItemsOfTypeToArray(npc,42)
	int i = amm.Length
	while i > 0
		i -= 1
		Ammo a = amm[i] as Ammo
		; take amount into account : 1 heavy arrow is less good then 10 light
		; so add amount as factor
		int amount = npc.GetItemCount(a)
		float d = a.GetDamage() * (amount / 2)
		if a.IsBolt()
			if !bestBolt || bestBoltDamage < d
				bestBolt = a
				bestBoltDamage = d
			endif
		else
			if !bestArrow || bestArrowDamage < d
				bestArrow = a
				bestArrowDamage = d
			endif
		endif
	endwhile

	; now detect best weapons
	Weapon bestBow
	int bestBowDamage
	Weapon bestCrossBow
	int bestCrossBowDamage
	Weapon bestOneHanded
	int bestOneHandedDamage
	Weapon bestTwoHanded
	int bestTwoHandedDamage

	Form[] weapons = PO3_SKSEFunctions.AddItemsOfTypeToArray(npc,41)
	i = weapons.Length
	while i > 0
		i -= 1
		Weapon wpn = weapons[0] as Weapon
		int weaponType = wpn.GetWeaponType()
		; critical damage is nice but chance is low, reduce factor
		int weaponDamage = wpn.GetBaseDamage() + ( wpn.GetCritDamage() / 3)
		if weaponType == 9
			if !bestCrossBow || bestCrossBowDamage < weaponDamage
				bestCrossBow = wpn
				bestCrossBowDamage = weaponDamage
			endif
		elseif weaponType == 7
			if !bestBow || bestBowDamage < weaponDamage
				bestBow = wpn
				bestBowDamage = weaponDamage
			endif
		elseif wpn.GetEquipType().GetFormID() == 0x00013F45
			if !bestTwoHanded || bestTwoHandedDamage < weaponDamage
				bestTwoHanded = wpn
				bestTwoHandedDamage = weaponDamage
			endif
		elseif !bestOneHanded || bestOneHandedDamage < weaponDamage
			bestOneHanded = wpn
			bestOneHandedDamage = weaponDamage
		endif
	endwhile

	if preferSwords && (bestOneHanded || bestTwoHanded)
		; combatant to near for arrows, equip sword
		bestBow = none
		bestCrossBow = none
	endif

	; now check the skills
	float Marksman = npc.GetActorValue("Marksman")
	float OneHanded = npc.GetActorValue("OneHanded")
	float TwoHanded = npc.GetActorValue("TwoHanded")
	if Marksman > OneHanded
		if Marksman > TwoHanded
			if bestBow && !bestArrow
				bestBow = none
			endif
			if bestCrossBow && !bestBolt
				bestCrossBow = none
			endif
			if bestBow && bestCrossBow
				if (bestBowDamage + bestArrowDamage) > (bestCrossBowDamage + bestBoltDamage)
					npc.EquipItem(bestBow)
					npc.EquipItem(bestArrow)
					return true
				endif
				npc.EquipItem(bestCrossBow)
				npc.EquipItem(bestBolt)
				return true
			endif
		elseif bestTwoHanded
			npc.EquipItem(bestTwoHanded)
			return true
		endif
	endif
	if OneHanded > TwoHanded && bestOneHanded
		npc.EquipItem(bestOneHanded)
		return true
	endif
	if bestTwoHanded
		npc.EquipItem(bestTwoHanded)
		return true
	endif
	return false
endfunction

ObjectReference function GetPunishmentMarker() global
	return (Quest.GetQuest("MariaMain") as MariaMainQuest).Alias_punishmentmarker.GetReference()
endfunction

ObjectReference function GetDebugMarker() global
	return (Quest.GetQuest("MariaMain") as MariaMainQuest).Alias_debugmarker.GetReference()
endfunction

ObjectReference function FindWhippingDevice(ObjectReference center = none,int radius = 3000) global
	if !center
		center = Game.GetPlayer()
	endif
	; FormType.kFurniture
	return MESKSEUtils.FindNearestRefOfTypeByKeyword(center,40,Keyword.GetKeyword("zbfFurnitureWhippingDevice"))
endfunction

ObjectReference function PlacePunishmentMarkerInFrontOf(ObjectReference furnOrActor,int distance=120, ObjectReference marker = none) global
	if !marker
		marker = GetPunishmentMarker()
	endif
	MariasUtils.PlaceInFrontOf(marker,furnOrActor,distance)
endfunction

function MoveToFurnitureInteraction(ObjectReference akObject, ObjectReference akFurniture, Float afOffset = 0.0) global
	Float distance = 100.0
	Float angle = 0.0

	If akFurniture.HasKeywordString("zbfFurnitureWhippingFromBack") || (akFurniture as Actor) != none
		angle = 180.0
	EndIf

	angle = akFurniture.GetAngleZ() + angle
	akObject.MoveTo(akFurniture, distance * Math.Sin(angle), distance * Math.Cos(angle), 0, abMatchRotation = False)

	angle = akObject.GetHeadingAngle(akFurniture)
	akObject.SetAngle(akObject.GetAngleX(), akObject.GetAngleY(), akObject.GetAngleZ() + angle + afOffset)
EndFunction

ObjectReference function PreparePunishmentMarker(ObjectReference furnOrActor,ObjectReference marker = none) global
	return None
endfunction

bool function Lock(ObjectReference obj,string semaphore) global
	int attempts = 20
	while attempts > 0 && StorageUtil.GetIntValue(obj, semaphore)
		Utility.Wait(0.3)
		attempts -= 1
	endwhile
	if ! StorageUtil.GetIntValue(obj, semaphore)
		StorageUtil.SetIntValue(obj, semaphore, 1)
		return true
	endif
	Debug.TraceStack("@@ semaphore : unable to lock " + semaphore + " for " + obj)
	return false
endfunction

function Unlock(ObjectReference obj,string semaphore) global
	StorageUtil.UnsetIntValue(obj, semaphore)
endfunction

string function GetUserDisplayName(Actor npc) global
	string name = npc.GetDisplayName()
	if name == ""
		name = npc.GetName()
	endif
	if name == ""
		name = npc.GetLeveledActorBase().GetName()
	endif
	if name == ""
		name = PO3_SKSEFunctions.GetFormEditorID(npc)
	endif
	if name == ""
		name = npc as String
	endif
	return name
endfunction

bool function IsFreezing(Actor npc) global
	float warmthRating = npc.GetActorValue(Survival_GlobalFunctions.WarmthRatingAV())
	; https://en.uesp.net/wiki/Skyrim:Cold#Warmth
	return warmthRating > 299
	; Survival_ColdNeedValue
endfunction

; Positioniert ein existierendes Objekt relativ zu einem Ziel.
;
; Parameter:
; akObjToMove: Das Objekt, das bewegt werden soll (Player, NPC, Kiste...)
; akTargetRef: Das Bezugsobjekt (Ankerpunkt)
; fDistance:   Distanz zum Ziel (Positiv = Davor, Negativ = Dahinter)
; bFaceAway:   TRUE = Objekt schaut in die gleiche Richtung wie das Ziel.
;              FALSE = Objekt dreht sich um und schaut das Ziel an.
;
Function PositionObjectRelative(ObjectReference akObjToMove, ObjectReference akTargetRef, float fDistance, bool bFaceAway) Global

    If !akObjToMove || !akTargetRef
        Return
    EndIf

    ; 1. Winkel des Ziels holen
    float fRefAngle = akTargetRef.GetAngleZ()

    ; 2. Berechnung der Offsets
    ; MoveTo akzeptiert Offsets, aber diese beziehen sich auf das GLOBALE Koordinatensystem (Nord/Süd),
    ; nicht auf die lokale Blickrichtung des Ziels.
    ; Daher müssen wir Trigonometrie nutzen, um "Vorwärts" in X/Y zu zerlegen.
    float fOffsetX = fDistance * Math.Sin(fRefAngle)
    float fOffsetY = fDistance * Math.Cos(fRefAngle)

    ; 3. Rotation bestimmen
    ; Wir übergeben 'false' an MoveTo für die Rotation und setzen sie manuell,
    ; um volle Kontrolle zu haben.
    float fNewAngle = fRefAngle

    If !bFaceAway
        fNewAngle += 180.0
        ; Winkel normalisieren (Kosmetik, Engine ist das egal)
        If fNewAngle >= 360.0
            fNewAngle -= 360.0
        EndIf
    EndIf

    ; 4. Bewegung ausführen
    ; MoveTo(Target, X-Offset, Y-Offset, Z-Offset, MatchRotation)
    ; Wir nutzen MatchRotation = False, damit wir den Winkel gleich selbst setzen können.
    akObjToMove.MoveTo(akTargetRef, fOffsetX, fOffsetY, 0.0, false)

    ; 5. Endgültige Rotation anwenden
    ; Wir behalten X und Y Rotation bei (wichtig bei Physik-Objekten), ändern nur Z (Gieren)
    akObjToMove.SetAngle(akObjToMove.GetAngleX(), akObjToMove.GetAngleY(), fNewAngle)

EndFunction

; Erstellt einen XMarkerHeading relativ zu einem Zielobjekt
;
; Parameter:
; akTargetRef: Das Bezugsobjekt (Tür, Actor, Kiste...)
; fDistance:   Wie weit VOR dem Objekt soll der Marker stehen? (z.B. 80.0)
; bFaceAway:   TRUE = Marker schaut in die gleiche Richtung wie das Objekt (vom Objekt weg).
;              FALSE = Marker dreht sich um 180 Grad und schaut das Objekt an.
;
; Return:      Die Referenz des neu erstellten Markers
ObjectReference Function CreateRelativeMarker(ObjectReference akTargetRef, float fDistance, bool bFaceAway) Global

    If !akTargetRef
        Return None
    EndIf

    ; 4. Marker erstellen (XMarkerHeading FormID: 0x0000003B)
    Form xMarkerForm = Game.GetFormFromFile(0x0000003B, "Skyrim.esm")

    ; Marker wird initial beim Ziel erstellt
    ObjectReference newMarker = akTargetRef.PlaceAtMe(xMarkerForm)

	PositionObjectRelative(newMarker,akTargetRef,fDistance,bFaceAway)
    Return newMarker
EndFunction

Function MoveToDialoguePosition(Actor me,Actor other, Float fDistance = 120.0) global
    Float meAngleZ = me.GetAngleZ()
	other.MoveTo(me, fDistance * Math.Sin(meAngleZ), fDistance * Math.Cos(meAngleZ), 0.0)
	other.SetAngle(0.0, 0.0, meAngleZ + 180.0)
EndFunction
