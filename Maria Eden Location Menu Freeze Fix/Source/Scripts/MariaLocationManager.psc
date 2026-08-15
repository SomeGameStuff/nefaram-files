Scriptname MariaLocationManager extends quest

Formlist Property MariaLocationsWithTaverns auto
Formlist Property MariaTaverns auto
Formlist Property MariaOrcCamps auto
Formlist Property MariaHostlers auto
Formlist Property MariaMines auto
Formlist Property MariaTownsAndCities auto
FormList Property MariaInterestingLocations  Auto
FormList Property MariaPlayerHomes  Auto
FormList Property MairaCaptiveMarkers  Auto
FormList Property MairaCastleMarkers  Auto
Formlist Property MariaLocationMarkers Auto
Formlist Property MariaLocationOperators Auto
FormList Property MariaJailList  Auto

Armor Property MariaBanditRing Auto

keyword property MariaLocTypeBrothel auto
keyword property MariaLocTypeSlaveAuction auto
keyword property MariaLocTypeSlaveTraining auto
keyword property MariaLocTypeTortureChamber auto
keyword property MariaLocTypeExecution auto

MariaActorManager Property mam  Auto
MariaRestraintsManager Property mrm  Auto

message property MariaCategoryMenu auto
message property MariaBrokenLocationMenu auto
message property MariaLocationMenu auto
message property MariaSelectMarkerTypeMenu auto

ReferenceAlias property warpmarker auto
Quest property MariaCreateJumpLocation auto

MariasUtils property tools auto
Actor property PlayerRef auto
ObjectReference Property MariaDefaultStartupMarker  Auto

CaravanScript property Caravans auto

string locationKey

function Trace(string text) global
	Debug.Trace("@@ MLM :" + text)
endfunction

function Startup()
	locationKey = JsonUtil.GetStringValue("MariaManagerConfig","locationstorage","MariaCustomLocations")
	RegisterForModEvent("MariaEditCustomLocations","OnEditCustomLocations")
	RegisterForModEvent("MariaSelectJumpLocation","OnSelectJumpLocation")
	RegisterForModEvent("MariaCreateCustomLocation","OnCreateCustomLocation")
	RegisterLocations()
endfunction

function Cleanup()
	UnregisterForAllModEvents()
endfunction

event OnEditCustomLocations(string eventName, string strArg, float numArg, Form sender)
	ManageCustomLocations()
endevent

event OnCreateCustomLocation(string eventName, string strArg, float numArg, Form sender)
	ObjectReference ref = sender as ObjectReference
	if ref
		SaveCustomLocation(ref,numArg != 0)
	endif
endevent

event OnSelectJumpLocation(string eventName, string strArg, float numArg, Form sender)
	ObjectReference target = SelectJumpLocation(true)
	if target
		PlayerRef.SendModEvent("MariaResetPose")
		PlayerRef.MoveTo(target)
	endif
endevent

; returns a location marker in the same city as the player, or opens a quick menu to select one
ObjectReference function SelectMariaLocation(keyword locationType,bool forceSelection = false,bool random = false)
	ObjectReference locationMarkerMarker = none
	Location playerLocation = PlayerRef.GetCurrentLocation()
	if playerLocation
		Keyword LocTypeHabitation = Keyword.GetKeyword("LocTypeHabitation")
		Form[] markers = GetLocations(locationType)
		int i = markers.Length
		Location loc
		ObjectReference marker
		while i > 0 && !locationMarkerMarker
			i -= 1
			marker = markers[i] as ObjectReference
			loc = marker.GetEditorLocation()
			if loc && loc.IsSameLocation(playerLocation, LocTypeHabitation)
				; Found auction house in same city as player
				return marker
			endif
		endwhile
	endif
	tools.PrepareQuickMenu()
	tools.AddQuickMenuLocationEntries(GetLocations(locationType))
	return tools.DoQuickMenuForm(forceSelection,random) as ObjectReference
endfunction

ObjectReference function GetStartPosition()
	ObjectReference marker = JsonUtil.GetFormValue("MariaDefaults","quickstart") as ObjectReference
	if !marker
		marker = MariaDefaultStartupMarker
	endif
	return marker
endfunction

ObjectReference function SelectTavern()
	Form[] inns = MariaTaverns.ToArray()
	Form[] locs = MariaLocationsWithTaverns.ToArray()
	tools.PrepareQuickMenu()
	int x = inns.Length
	int z
	Location city
	while x > 0
		x -= 1
		z = x
		ObjectReference inn = inns[x] as ObjectReference
		if x >= locs.Length
			z = locs.Length
			city = none
			Location innLocation = inn.GetCurrentLocation()
			while z > 0 && city == none
				z -= 1
				city = locs[z] as Location
				if !city.IsChild(innLocation)
					city = none
				endif
			endwhile
		else
			city = locs[x] as Location
		endif
		if city
			tools.AddQuickMenuEntry(inn.GetParentCell().GetName() + " - " + city.GetName(),inn)
		else
			tools.AddQuickMenuEntry(inn.GetParentCell().GetName(),inn)
		endif
	endwhile
	return tools.DoQuickMenuForm() as ObjectReference
endfunction

Actor function SelectCaravan()
	Form[] leaders = new Form[3]
	leaders[0] = Caravans.LeaderA.GetActorReference() as Form
	leaders[1] = Caravans.LeaderB.GetActorReference() as Form
	leaders[3] = Caravans.LeaderC.GetActorReference() as Form
	Actor ref = tools.SelectObjectReference(leaders, addLocation = true) as Actor
	if ref
		if !ref.IsEnabled()
			ref.EnableNoWait()
		endif
	endif
	return ref
endfunction

ObjectReference function SelectBrothel()
	return SelectMariaLocation(MariaLocTypeBrothel)
endfunction

ObjectReference function SelectSlaveAuction()
	return SelectMariaLocation(MariaLocTypeSlaveAuction)
endfunction

ObjectReference function SelectSlaveTraining()
	return SelectMariaLocation(MariaLocTypeSlaveTraining)
endfunction

ObjectReference function SelectExecutingPlace()
	return SelectMariaLocation(MariaLocTypeExecution)
endfunction

ObjectReference function SelectCaptivePlace()
	return tools.SelectObjectReference(MairaCaptiveMarkers.ToArray(), addLocation = true)
endfunction

ObjectReference function SelectOrcCamp()
	return tools.SelectObjectReference(MariaOrcCamps.ToArray(), addLocation = true)
endfunction

ObjectReference function SelectJumpLocation(bool allowCreateCustomLocation = false)
	ObjectReference wpmarker = warpmarker.GetReference()

	; NEFARAM: Do not synchronously call GetKeywords() on every registered
	; location before opening the UI. On the large NEFARAM registry that native
	; pre-scan can hang the game before the first menu is displayed. The shipped
	; location plugins are deterministic, so use their presence to expose the
	; matching categories. Category selection still filters the registered
	; markers with GetLocations(), preserving the original destinations.
	bool hasBrothels = Game.GetModByName("MariaWhoreLocations.esp") != 255
	bool hasSlaveLocations = Game.GetModByName("MariaSlaveLocations.esp") != 255
	bool hasAuctions = hasSlaveLocations
	bool hasTrainings = hasSlaveLocations
	bool hasTorture = hasSlaveLocations
	bool hasKillers = hasSlaveLocations
	Trace("SelectJumpLocation safe menu; registered markers=" + MariaLocationMarkers.GetSize())

	while true
		UIListMenu menu = tools.PrepareQuickMenu()
		if allowCreateCustomLocation
			tools.AddQuickMenuEntry("$ME_CREATE_CUSTOM_LOC",MariaCreateJumpLocation)
		endif

		tools.AddQuickMenuEntry("$ME_SQ_TAVERN",MariaTaverns)
		tools.AddQuickMenuEntry("$ME_SQ_CITIES",MariaTownsAndCities)
		tools.AddQuickMenuEntry("$ME_MANAGED_NPCS",PlayerRef)

		tools.AddQuickMenuEntry("$ME_INTERESTING_NPCS",MariaCategoryMenu)

		tools.AddQuickMenuEntry("$ME_LOC_PLAYERHOMES",MariaPlayerHomes)
		tools.AddQuickMenuEntry("$ME_SQ_MARKER",wpmarker)
		tools.AddQuickMenuEntry("$ME_SQ_CUSTLOC",tools)
		if hasBrothels
			tools.AddQuickMenuEntry("$ME_SQ_BROTHEL",MariaLocTypeBrothel)
		endif

		if hasAuctions
			tools.AddQuickMenuEntry("$ME_SQ_AUCTIONS",MariaLocTypeSlaveAuction)
		elseif Game.GetModByName("SimpleSlavery.esp") != 255
			tools.AddQuickMenuEntry("$ME_SQ_AUCTIONS",MariaLocTypeSlaveAuction)
		endif

		if hasTrainings
			tools.AddQuickMenuEntry("$ME_SQ_TRAININGS",MariaLocTypeSlaveTraining)
		endif
		if hasTorture
			tools.AddQuickMenuEntry("$ME_TORTURE_HOUSES",MariaLocTypeTortureChamber)
		endif
		if hasKillers
			tools.AddQuickMenuEntry("$ME_KILLINGZONES",MariaLocTypeExecution)
		endif
		tools.AddQuickMenuEntry("$ME_XLOCATIONS",MariaInterestingLocations)
		tools.AddQuickMenuEntry("$ME_SA_HOSTLERS",MariaHostlers)
		tools.AddQuickMenuEntry("$ME_SA_MINERS",MariaMines)
		tools.AddQuickMenuEntry("$ME_SA_ORCS",MariaOrcCamps)
		tools.AddQuickMenuEntry("$ME_SA_CARAVANS",Caravans)
		tools.AddQuickMenuEntry("$ME_LOC_CASTLES",MairaCastleMarkers)
		tools.AddQuickMenuEntry("$ME_LOC_CAPTIVES",MairaCaptiveMarkers)
		tools.AddQuickMenuEntry("$ME_LOC_JAILS",MariaJailList)
		; tools.AddQuickMenuEntry("Default Maria Startup",MariaDefaultStartupMarker)

		Location loc = PlayerRef.GetCurrentLocation()
		ObjectReference mapMarker
		ObjectReference horseMarker
		if loc
			mapMarker = MESKSEUtils.GetLocationMapMarker(loc)
			if mapMarker
				tools.AddQuickMenuEntry("$ME_CURRENT_MAP_MARKER",mapMarker)
			endif
			horseMarker = MESKSEUtils.GetLocationHorseMarker(loc)
			if horseMarker
				tools.AddQuickMenuEntry("$ME_CURRENT_HORSE_MARKER",horseMarker)
			endif
		endif
		;tools.AddQuickMenuEntry("Cell",PlayerRef)

		Form selection = tools.DoQuickMenuForm()
		if selection == none
			return none
		elseif selection == MariaDefaultStartupMarker
			return MariaDefaultStartupMarker
		elseif selection == MariaCreateJumpLocation
			Trace("Create new location")
			MariaCreateJumpLocation.Start()
			return none
		elseif selection == PlayerRef
			Actor npc = mam.SelectManagedNPCSimple(false,false)
			if npc != none
				if !npc.IsEnabled()
					npc.EnableNoWait()
				endif
				return npc
			endif
		ElseIf selection == MariaCategoryMenu
			Actor npc = mam.SelectInterestingNPC()
			if npc != none
				if !npc.IsEnabled()
					npc.EnableNoWait()
				endif
				return npc
			endif
		elseif selection == wpmarker
			return wpmarker
		elseif selection == tools
			return SelectCustomLocation()
		elseif selection == MariaLocTypeBrothel
			ObjectReference ref = SelectBrothel()
			if ref
				return ref
			endif
		elseif selection == MariaLocTypeSlaveAuction
			if !hasAuctions
				PlayerRef.SendModEvent("SSLV Entry")
				return none
			else
				ObjectReference ref = SelectSlaveAuction()
				if ref
					return ref
				endif
			endif
		elseif selection == MariaLocTypeSlaveTraining
			ObjectReference ref = SelectSlaveTraining()
			if ref
				return ref
			endif
		elseif selection == MariaLocTypeTortureChamber
			ObjectReference ref = SelectMariaLocation(MariaLocTypeTortureChamber)
			if ref
				return ref
			endif
		elseif selection == MariaLocTypeExecution
			ObjectReference ref = SelectExecutingPlace()
			if ref
				return ref
			endif
		elseif selection == MariaHostlers
			ObjectReference ref = tools.SelectObjectReference(MariaHostlers.ToArray(),addLocation = true)
			if ref
				if !ref.IsEnabled()
					ref.EnableNoWait()
				endif
				return ref
			endif
		elseif selection == MariaMines
			ObjectReference ref = tools.SelectObjectReference(MariaMines.ToArray(),addLocation = true)
			if ref
				if !ref.IsEnabled()
					ref.EnableNoWait()
				endif
				return ref
			endif
		elseif selection == Caravans
			Actor boss = SelectCaravan()
			if boss
				return boss
			endif
		elseif selection == MariaPlayerHomes
			ObjectReference ref = tools.SelectObjectReference(MariaPlayerHomes.ToArray(),addLocation = true)
			if ref
				return ref
			endif
		elseif selection == MairaCastleMarkers
			ObjectReference ref = tools.SelectObjectReference(MairaCastleMarkers.ToArray(),addLocation = true)
			if ref
				return ref
			endif
		elseif selection == MariaJailList
			ObjectReference ref = tools.SelectObjectReference(MariaJailList.ToArray(),addLocation = true)
			if ref
				return ref
			endif
		elseif selection == MairaCaptiveMarkers
			ObjectReference ref = SelectCaptivePlace()
			if ref
				return ref
			endif
		elseif selection == MariaOrcCamps
			ObjectReference ref = SelectOrcCamp()
			if ref
				if !ref.IsEnabled()
					ref.EnableNoWait()
				endif
				return ref
			endif
		elseif selection == MariaInterestingLocations
			ObjectReference ref = tools.SelectObjectReference(MariaInterestingLocations.ToArray(),addLocation = true)
			if ref
				if !ref.IsEnabled()
					ref.EnableNoWait()
				endif
				return ref
			endif
		elseif selection == MariaTownsAndCities
			ObjectReference ref = tools.SelectObjectReference(MariaTownsAndCities.ToArray(),addLocation = true)
			if ref
				if !ref.IsEnabled()
					ref.EnableNoWait()
				endif
				return ref
			endif
		elseif selection == PlayerRef
			string[] cellNames = JsonUtil.StringListToArray(locationKey,"cells")
			string cellName = tools.PerformQuickMenuString(cellNames)
			if cellName != ""
				Debug.CenterOnCellAndWait(cellName)
			endif
			return none
		elseif selection == MariaTaverns
			selection = SelectTavern()
			if selection
				return selection as ObjectReference
			endif
		elseif selection == mapMarker
			return mapMarker
		elseif selection == horseMarker
			return horseMarker
		endif
	endwhile
endfunction

function RegisterLocations()
	Form[] operators = MariaHostlers.ToArray()
	int i = 0
	int m = operators.Length
	while i < m
		Actor ref = operators[i] as Actor
		if ref == none
			Trace("MariaHostlers[" + i + "] is broken")
		else
			RegisterLocation(ref,ref)
		endif
		i += 1
	endwhile

	operators = MariaTaverns.ToArray()
	i = 0
	m = operators.Length
	while i < m
		ObjectReference ref = operators[i] as ObjectReference
		if ref == none
			Trace("MariaTaverns[" + i + "] is broken")
		else
			RegisterLocation(ref)
		endif
		i += 1
	endwhile

	operators = MariaMines.ToArray()
	i = 0
	m = operators.Length
	while i < m
		Actor ref = operators[i] as Actor
		if ref == none
			Trace("MariaMines[" + i + "] is broken")
		else
			RegisterLocation(ref,ref)
		endif
		i += 1
	endwhile
endfunction

; #############################################################################################

string function GetText(String oldText)
	uitextentrymenu tmenu = uiextensions.GetMenu("uitextentrymenu", true) as uitextentrymenu
	tmenu.ResetMenu()
	tmenu.SetPropertyString("text", oldText)
	tmenu.UpdateTextEntryString()
	if tmenu.OpenMenu(none, none)
		return tmenu.GetResultString()
	endIf
	return ""
endFunction

function SaveCustomLocations()
	JsonUtil.Save(locationKey, false)
	debug.Notification(locationKey + " updated")
endFunction

int function SelectLocationCategory(Bool managerMode)
	Trace("SelectLocationCategory ")
	String[] categories = JsonUtil.StringListToArray(locationKey, "categories")
	Trace(categories)
	Trace("categories="+JsonUtil.StringListToArray(locationKey, "categories"))
	Trace("maria_names="+JsonUtil.StringListToArray(locationKey, "maria_names"))
	Trace("skoomahall_names="+JsonUtil.StringListToArray(locationKey, "skoomahall_names"))
	Trace("taverns_names="+JsonUtil.StringListToArray(locationKey, "taverns_names"))

	uilistmenu menu = uiextensions.GetMenu("uilistmenu", true) as uilistmenu
	menu.ResetMenu()
	Int i = 0
	Int x = categories.length
	while i < x
		menu.AddEntryItem(categories[i], -1, -1, false)
		i += 1
	endWhile
	if managerMode
		menu.AddEntryItem("$ME_ADD_CATEGORY", -1, -1, false)
	endIf
	if x > 0
		menu.OpenMenu(none, none)
		i = menu.GetResultInt()
		if i < 0
			return -1
		elseIf i == categories.length
			String newCat = GetText("")
			if newCat != "" && categories.find(newCat, 0) < 0
				i = JsonUtil.StringListAdd(locationKey, "categories", newCat, true)
				SaveCustomLocations()
				return i
			endIf
			return -1
		else
			return i
		endIf
	else
		return -1
	endif
endFunction

Int function SelectCustomLocationFromCategory(String category)
	uilistmenu menu = uiextensions.GetMenu("uilistmenu", true) as uilistmenu
	String[] location_names = JsonUtil.StringListToArray(locationKey, category + "_names")
	menu.ResetMenu()
	Int i = 0
	Int x = location_names.length
	while i < x
		menu.AddEntryItem(location_names[i], -1, -1, false)
		i += 1
	endWhile
	menu.OpenMenu(none, none)
	return menu.GetResultInt()
endFunction

function ManageCustomLocations()
	while true
		Int categoryIndex = SelectLocationCategory(true)
		if categoryIndex >= 0
			Int i = MariaCategoryMenu.Show()
			if i == 1 ; rename category
				String category = JsonUtil.StringListGet(locationKey, "categories", categoryIndex)
				String newCategory = GetText(category)
				if newCategory != "" && newCategory != category && !JsonUtil.StringListHas(locationKey, "categories", newCategory)
					form[] location_markers = JsonUtil.FormListToArray(locationKey, category + "_markers")
					String[] location_names = JsonUtil.StringListToArray(locationKey, category + "_names")
					JsonUtil.StringListClear(locationKey, category + "_names")
					JsonUtil.FormListClear(locationKey, category + "_markers")
					JsonUtil.StringListCopy(locationKey, newCategory + "_names", location_names)
					JsonUtil.FormListCopy(locationKey, category + "_markers", location_markers)
					JsonUtil.StringListRemoveAt(locationKey, "categories", categoryIndex)
					JsonUtil.StringListAdd(locationKey, "categories", newCategory, true)
					SaveCustomLocations()
				endIf
			elseIf i == 2 ; delete category
				String category = JsonUtil.StringListGet(locationKey, "categories", categoryIndex)
				JsonUtil.StringListClear(locationKey, category + "_names")
				JsonUtil.FormListClear(locationKey, category + "_markers")
				JsonUtil.StringListRemoveAt(locationKey, "categories", categoryIndex)
				SaveCustomLocations()
			elseIf i == 3 ; manage category
				Int locationIndex = SelectCustomLocationFromCategory(categoryIndex as String)
				if locationIndex >= 0
					String category = JsonUtil.StringListGet(locationKey, "categories", categoryIndex)
					ObjectReference marker = JsonUtil.FormListGet(locationKey, category + "_markers", locationIndex) as ObjectReference
					if marker == none
						if MariaBrokenLocationMenu.Show() == 1
							JsonUtil.FormListRemoveAt(locationKey, category + "_names", locationIndex)
							JsonUtil.FormListRemoveAt(locationKey, category + "_markers", locationIndex)
							SaveCustomLocations()
						endIf
					else
						i = MariaLocationMenu.Show()
						if i == 1 ; rename location
							String name = JsonUtil.StringListGet(locationKey, category + "_names", locationIndex)
							String newName = GetText(name)
							if newName != "" && newName != name && !JsonUtil.StringListHas(locationKey, category + "_names", newName)
								JsonUtil.StringListRemoveAt(locationKey, category + "_names", locationIndex)
								JsonUtil.FormListRemoveAt(locationKey, category + "_markers", locationIndex)
								JsonUtil.StringListAdd(locationKey, category + "_names", newName, true)
								JsonUtil.FormListAdd(locationKey, category + "_markers", marker as form, true)
								SaveCustomLocations()
							endIf
						elseIf i == 2 ; delete location
							JsonUtil.StringListRemoveAt(locationKey, category + "_names", locationIndex)
							JsonUtil.FormListRemoveAt(locationKey, category + "_markers", locationIndex)
							SaveCustomLocations()
						elseIf i == 3 ; jump
							PlayerRef.MoveTo(marker, 0.000000, 0.000000, 0.000000, true)
							while !PlayerRef.Is3DLoaded()
								utility.Wait(0.500000)
							endWhile
							utility.Wait(0.500000)
						endIf
					endIf
				endIf
			else
				return
			endIf
		else
			return
		endIf
	endWhile
endFunction

ObjectReference function SelectCustomLocation()
	Int categoryIndex = SelectLocationCategory(false)
	if categoryIndex >= 0
		String category = JsonUtil.StringListGet(locationKey, "categories", categoryIndex)
		Int locationIndex = SelectCustomLocationFromCategory(category)
		if locationIndex >= 0
			ObjectReference marker = JsonUtil.FormListGet(locationKey, category + "_markers", locationIndex) as ObjectReference
			if marker != none
				return marker
			elseIf MariaBrokenLocationMenu.Show() == 1
				JsonUtil.FormListRemoveAt(locationKey, category + "_names", locationIndex)
				JsonUtil.FormListRemoveAt(locationKey, category + "_markers", locationIndex)
				SaveCustomLocations()
			endIf
		endIf
	endIf
	return none
endFunction

function SaveCustomLocation(ObjectReference marker,bool askforStartPos)
	if askforStartPos
		int i = MariaSelectMarkerTypeMenu.Show()
		if i == 0
			return
		elseif i == 1
			JsonUtil.SetFormValue("MariaDefaults","quickstart",marker)
			JsonUtil.Save("MariaDefaults")
			return
		endif
	endif
	Int categoryIndex = SelectLocationCategory(true)
	if categoryIndex >= 0
		String name = marker.GetParentCell().GetName()
		if name == ""
			Location loc = marker.GetCurrentLocation()
			if loc
				name = loc.GetName()
			endIf
		endIf
		name = GetText(name)
		String category = JsonUtil.StringListGet(locationKey, "categories", categoryIndex)
		if name != "" && !JsonUtil.StringListHas(locationKey, category + "_names", name)
			JsonUtil.StringListAdd(locationKey, category + "_names", name, true)
			JsonUtil.FormListAdd(locationKey, category + "_markers", marker as form, true)
			SaveCustomLocations()
		endIf
	endIf
endFunction

function RegisterLocation(ObjectReference locationMarker,Actor operator = none)
	if !MariaLocationMarkers.HasForm(locationMarker)
		MariaLocationMarkers.AddForm(locationMarker)
		MariaLocationOperators.AddForm(operator)
	endif
endfunction

Form[] function GetLocations(keyword locationType)
	StorageUtil.FormListClear(self,"markers")
	Form[] locations = MariaLocationMarkers.ToArray()
	int i = locations.Length
	if !i
		return none
	endif
	while i > 0
		i -= 1
		ObjectReference marker = locations[i] as ObjectReference
		if marker && marker.GetCurrentLocation() && marker.GetCurrentLocation().HasKeyword(locationType)
			StorageUtil.FormListAdd(self,"markers",marker)
		endif
	endwhile
	Form[] markers = StorageUtil.FormListToArray(self,"markers")
	StorageUtil.FormListClear(self,"markers")
	return markers
endfunction

Actor function GetOperator(ObjectReference locationMarker)
	int i = MariaLocationMarkers.Find(locationMarker)
	if i >= 0
		return MariaLocationOperators.GetAt(i) as Actor
	endif
endfunction

Form[] function GetOperators(Faction fac)
	StorageUtil.FormListClear(self,"operators")
	int i = MariaLocationOperators.GetSize()
	while i > 0
		i -= 1
		Actor operator = MariaLocationOperators.GetAt(i) as Actor
		if operator.IsInFaction(fac)
			StorageUtil.FormListAdd(self,"operators",MariaLocationOperators.GetAt(i))
		endif
	endwhile
	Form[] operators = StorageUtil.FormListToArray(self,"operators")
	StorageUtil.FormListClear(self,"operators")
	return operators
endfunction

ObjectReference function GetOperatorLocation(Actor operator)
	int i = MariaLocationOperators.Find(operator)
	if i >= 0
		return MariaLocationMarkers.GetAt(i) as ObjectReference
	endif
endfunction

Actor function GetRandomOperator(keyword locationType)
	StorageUtil.FormListClear(self,"operators")
	Form[] locations = MariaLocationMarkers.ToArray()
	int i = locations.Length
	while i > 0
		i -= 1
		ObjectReference marker = locations[i] as ObjectReference
		if marker && marker.GetCurrentLocation().HasKeyword(locationType)
			StorageUtil.FormListAdd(self,"operators",MariaLocationOperators.GetAt(i))
		endif
	endwhile
	if !StorageUtil.FormListCount(self,"operators")
		return none
	endif
	Form[] operators = StorageUtil.FormListToArray(self,"operators")
	StorageUtil.FormListClear(self,"operators")
	return operators[Utility.RandomInt(0,operators.Length)] as Actor
endfunction
