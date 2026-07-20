Scriptname cfl_FeralKinshipController extends Quest

Import PO3_Events_Form

String Property PluginName = "FeralCreatureKinship.esp" AutoReadOnly
String Property ActorListKey = "Feral.Kinship.Actors" AutoReadOnly

Bool _active
Bool _promptUsed
Bool _promptOpen
Bool _sceneActive
Int _family
Int _masteryLevel
Int _token
Int _durationSeconds
Int _approachCheckIndex
Float _startedReal
Float _nextScanReal
Float _nextApproachReal
Float _approachStartedReal
Actor _approaching
Actor _scenePartner

Event OnInit()
	RegisterEvents()
	CleanupAll(false)
	RecoverActiveShape()
EndEvent

Function RegisterEvents()
	RegisterForModEvent("FeralShapeStart", "OnFeralShapeStart")
	RegisterForModEvent("FeralShapeEnd", "OnFeralShapeEnd")
	RegisterForModEvent("FeralKinshipCleanup", "OnKinshipCleanup")
	RegisterForModEvent("FeralKinshipBroken", "OnKinshipBroken")
	RegisterForModEvent("FeralKinshipApproachResult", "OnApproachResult")
	RegisterForModEvent("HookAnimationEnd_FeralKinship", "OnKinshipSceneEnd")
	RegisterForCellFullyLoaded(Self)
EndFunction

cfl_FeralMCM Function GetFeral()
	Return (Game.GetFormFromFile(0x000950, "Feral.esp") as Quest) as cfl_FeralMCM
EndFunction

SexLabFramework Function GetSexLab()
	Return Game.GetFormFromFile(0x000D62, "SexLab.esm") as SexLabFramework
EndFunction

Spell Function GetKinshipAbility()
	Return Game.GetFormFromFile(0x000801, PluginName) as Spell
EndFunction

Spell Function GetApproachAbility()
	Return Game.GetFormFromFile(0x000804, PluginName) as Spell
EndFunction

Message Function GetApproachPrompt()
	Return Game.GetFormFromFile(0x000805, PluginName) as Message
EndFunction

Event OnFeralShapeStart(Int family, Int masteryLevel, Int token, Int durationSeconds)
	BeginShape(family, masteryLevel, token, durationSeconds)
EndEvent

Event OnFeralShapeEnd(Int family, Int token)
	If token == _token
		EndShape()
	EndIf
EndEvent

Event OnKinshipCleanup()
	_active = false
	CleanupAll(false)
EndEvent

Event OnKinshipBroken(Form targetForm, Int token)
	Actor target = targetForm as Actor
	If !target || token != _token
		Return
	EndIf
	StorageUtil.SetIntValue(target, "Feral.Kinship.BrokenToken", token)
	Spell kinship = GetKinshipAbility()
	If kinship
		target.RemoveSpell(kinship)
	EndIf
	If target == _approaching
		CancelApproach()
	EndIf
EndEvent

Event OnApproachResult(Form targetForm, Int token, Int success)
	Actor target = targetForm as Actor
	If !target || target != _approaching || token != _token
		Return
	EndIf
	Spell approach = GetApproachAbility()
	If approach
		target.RemoveSpell(approach)
	EndIf
	StorageUtil.UnsetIntValue(target, "Feral.Kinship.ApproachToken")
	_approaching = None
	If success < 1 || !_active || !ShapeStillMatches() || !IsApproachCandidate(target)
		Return
	EndIf
	_promptUsed = true
	_promptOpen = true
	Message prompt = GetApproachPrompt()
	Int choice = 1
	If prompt
		choice = prompt.Show()
	EndIf
	_promptOpen = false
	If choice != 0 || !_active || !ShapeStillMatches() || !IsApproachCandidate(target)
		Return
	EndIf
	SexLabFramework sexLab = GetSexLab()
	If !sexLab
		Debug.Notification("Feral kinship: SexLab is unavailable.")
		Return
	EndIf
	sslThreadController thread = sexLab.QuickStart(Game.GetPlayer(), target, None, None, None, None, "FeralKinship", "")
	If thread
		_sceneActive = true
		_scenePartner = target
		Float nowGame = Utility.GetCurrentGameTime()
		StorageUtil.SetFloatValue(Game.GetPlayer(), "Feral.Kinship.LastAccepted." + _family, nowGame)
	Else
		Debug.Notification("Feral kinship: SexLab could not find a valid creature scene.")
	EndIf
EndEvent

Event OnKinshipSceneEnd(Int tid, Bool hasPlayer)
	FinishScene()
EndEvent

Event OnCellFullyLoaded(Cell akCell)
	If _active
		ScanAndApplyKinship()
	EndIf
EndEvent

Event OnUpdate()
	Float now = Utility.GetCurrentRealTime()
	If _active
		If !ShapeStillMatches()
			EndShape()
		Else
			If now < _startedReal
				_startedReal = now
				_nextScanReal = now
				_nextApproachReal = now + 5.0
			EndIf
			If now >= _nextScanReal
				ScanAndApplyKinship()
				_nextScanReal = now + 10.0
			EndIf
			If _approaching && now - _approachStartedReal >= 20.0
				CancelApproach()
			EndIf
			If !_approaching && !_promptUsed && !_promptOpen && now >= _nextApproachReal
				TryStartApproach(now)
				_nextApproachReal = now + 15.0
			EndIf
		EndIf
	EndIf
	If _sceneActive
		SexLabFramework sexLab = GetSexLab()
		If !sexLab || !_scenePartner || !sexLab.IsActorActive(_scenePartner)
			FinishScene()
		EndIf
	EndIf
	If _active || _sceneActive
		RegisterForSingleUpdate(2.0)
	EndIf
EndEvent

Function RecoverActiveShape()
	cfl_FeralMCM feral = GetFeral()
	If !feral
		Return
	EndIf
	Actor player = Game.GetPlayer()
	Int family = feral.GetActiveFamily()
	Int token = StorageUtil.GetIntValue(player, "Feral.ActiveToken")
	If family > 0 && token > 0
		Int level = feral.GetMasteryLevel(family)
		BeginShape(family, level, token, feral.ShapeDurationForLevel(level))
	EndIf
EndFunction

Function BeginShape(Int family, Int masteryLevel, Int token, Int durationSeconds)
	CleanupAll(false)
	cfl_FeralMCM feral = GetFeral()
	If !feral || !feral.IsKinshipEnabled() || masteryLevel < feral.GetKinshipMinimumLevel()
		Return
	EndIf
	_family = family
	_masteryLevel = masteryLevel
	_token = token
	_durationSeconds = durationSeconds
	_active = true
	_promptUsed = false
	_promptOpen = false
	_approachCheckIndex = 0
	_startedReal = Utility.GetCurrentRealTime()
	_nextScanReal = _startedReal
	_nextApproachReal = _startedReal + 5.0
	ScanAndApplyKinship()
	RegisterForSingleUpdate(2.0)
EndFunction

Function EndShape()
	_active = false
	CancelApproach()
	CleanupAll(_sceneActive)
	_family = 0
	_masteryLevel = 0
	_token = 0
	_durationSeconds = 0
EndFunction

Bool Function ShapeStillMatches()
	Actor player = Game.GetPlayer()
	Return _active && StorageUtil.GetIntValue(player, "Feral.ActiveFamily") == _family && StorageUtil.GetIntValue(player, "Feral.ActiveToken") == _token
EndFunction

Function ScanAndApplyKinship()
	If !_active
		Return
	EndIf
	Actor[] actors = PO3_SKSEFunctions.GetActorsByProcessingLevel(0)
	Int i = 0
	While i < actors.Length
		Actor candidate = actors[i]
		If IsMatchingLoadedActor(candidate, 4096.0)
			ApplyKinship(candidate)
		EndIf
		i += 1
	EndWhile
EndFunction

Bool Function IsMatchingLoadedActor(Actor candidate, Float radius)
	Actor player = Game.GetPlayer()
	If !candidate || candidate == player || candidate.IsDead() || candidate.IsDisabled() || candidate.GetDistance(player) > radius
		Return false
	EndIf
	cfl_FeralMCM feral = GetFeral()
	Return feral && feral.GetFamily(candidate) == _family
EndFunction

Function ApplyKinship(Actor candidate)
	If StorageUtil.GetIntValue(candidate, "Feral.Kinship.BrokenToken") == _token
		Return
	EndIf
	Spell kinship = GetKinshipAbility()
	If kinship && !candidate.HasSpell(kinship)
		StorageUtil.SetIntValue(candidate, "Feral.Kinship.Token", _token)
		candidate.AddSpell(kinship, false)
		StorageUtil.FormListAdd(Game.GetPlayer(), ActorListKey, candidate, false)
	EndIf
EndFunction

Function TryStartApproach(Float now)
	cfl_FeralMCM feral = GetFeral()
	If !feral || !feral.AreKinshipApproachesEnabled() || !ApproachCooldownReady()
		Return
	EndIf
	Float elapsed = now - _startedReal
	If elapsed < 5.0 || elapsed > (_durationSeconds - 20.0)
		Return
	EndIf
	Actor candidate = FindBestApproachCandidate()
	If !candidate
		_approachCheckIndex += 1
		Return
	EndIf
	Int arousal = SloangNative.GetArousalInt(candidate)
	Int chance = 4 + _approachCheckIndex + (arousal / 20)
	Int frequency = feral.GetKinshipFrequency()
	If frequency == 0
		chance = chance / 2
	ElseIf frequency == 2
		chance = (chance * 175) / 100
	EndIf
	If chance > 20
		chance = 20
	ElseIf chance < 1
		chance = 1
	EndIf
	_approachCheckIndex += 1
	If Utility.RandomInt(1, 100) <= chance
		StartApproach(candidate, now)
	EndIf
EndFunction

Bool Function ApproachCooldownReady()
	cfl_FeralMCM feral = GetFeral()
	Float lastAccepted = StorageUtil.GetFloatValue(Game.GetPlayer(), "Feral.Kinship.LastAccepted." + _family)
	If lastAccepted <= 0.0
		Return true
	EndIf
	Float elapsedDays = Utility.GetCurrentGameTime() - lastAccepted
	If elapsedDays < 0.0
		StorageUtil.UnsetFloatValue(Game.GetPlayer(), "Feral.Kinship.LastAccepted." + _family)
		Return true
	EndIf
	Return elapsedDays >= (feral.GetKinshipCooldownHours() / 24.0)
EndFunction

Actor Function FindBestApproachCandidate()
	Actor[] actors = PO3_SKSEFunctions.GetActorsByProcessingLevel(0)
	Actor best = None
	Int bestArousal = -1
	Float bestDistance = 999999.0
	Int i = 0
	While i < actors.Length
		Actor candidate = actors[i]
		If IsApproachCandidate(candidate)
			Int arousal = SloangNative.GetArousalInt(candidate)
			Float distance = candidate.GetDistance(Game.GetPlayer())
			If arousal > bestArousal || (arousal == bestArousal && distance < bestDistance)
				best = candidate
				bestArousal = arousal
				bestDistance = distance
			EndIf
		EndIf
		i += 1
	EndWhile
	Return best
EndFunction

Bool Function IsApproachCandidate(Actor candidate)
	Actor player = Game.GetPlayer()
	If !IsMatchingLoadedActor(candidate, 1200.0) || StorageUtil.GetIntValue(candidate, "Feral.Kinship.BrokenToken") == _token
		Return false
	EndIf
	If candidate.IsInCombat() || player.IsInCombat() || candidate.IsCommandedActor() || candidate.IsPlayerTeammate() || candidate.GetCurrentScene()
		Return false
	EndIf
	If !player.HasLOS(candidate)
		Return false
	EndIf
	SexLabFramework sexLab = GetSexLab()
	Return sexLab && !sexLab.IsActorActive(player) && !sexLab.IsActorActive(candidate) && sexLab.IsValidActor(player) && sexLab.IsValidActor(candidate)
EndFunction

Function StartApproach(Actor candidate, Float now)
	Spell approach = GetApproachAbility()
	If !approach
		Return
	EndIf
	_approaching = candidate
	_approachStartedReal = now
	StorageUtil.SetIntValue(candidate, "Feral.Kinship.ApproachToken", _token)
	candidate.AddSpell(approach, false)
EndFunction

Function CancelApproach()
	If !_approaching
		Return
	EndIf
	Spell approach = GetApproachAbility()
	If approach
		_approaching.RemoveSpell(approach)
	EndIf
	StorageUtil.UnsetIntValue(_approaching, "Feral.Kinship.ApproachToken")
	_approaching = None
EndFunction

Function CleanupAll(Bool preserveScene)
	CancelApproach()
	Actor player = Game.GetPlayer()
	Spell kinship = GetKinshipAbility()
	Int count = StorageUtil.FormListCount(player, ActorListKey)
	Int i = 0
	While i < count
		Actor target = StorageUtil.FormListGet(player, ActorListKey, i) as Actor
		If target && (!preserveScene || target != _scenePartner)
			If kinship
				target.RemoveSpell(kinship)
			EndIf
			StorageUtil.UnsetIntValue(target, "Feral.Kinship.Token")
			StorageUtil.UnsetIntValue(target, "Feral.Kinship.ApproachToken")
		EndIf
		i += 1
	EndWhile
	StorageUtil.FormListClear(player, ActorListKey)
	If preserveScene && _scenePartner
		StorageUtil.FormListAdd(player, ActorListKey, _scenePartner, false)
	EndIf
EndFunction

Function FinishScene()
	If _scenePartner
		Spell kinship = GetKinshipAbility()
		If kinship
			_scenePartner.RemoveSpell(kinship)
		EndIf
		StorageUtil.UnsetIntValue(_scenePartner, "Feral.Kinship.Token")
	EndIf
	_scenePartner = None
	_sceneActive = false
	If !_active
		StorageUtil.FormListClear(Game.GetPlayer(), ActorListKey)
	EndIf
EndFunction
