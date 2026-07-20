Scriptname OStimExperience extends SexExpCommon

String Function ArrayToString(String[] values)
	String result = ""
	Int i = 0
	While i < values.Length
		If i > 0
			result += ","
		EndIf
		result += values[i]
		i += 1
	EndWhile
	Return result
EndFunction

Event OnInit()
	Parent.OnInit()
	Name = "OStimExperience"
	RegisterForModEvent("SexExpMcmRegister", "McmRegistered")
EndEvent

Function Register()
	UnregisterForModEvent("OStim_Start")
	UnregisterForModEvent("OStim_SceneChanged")
	UnregisterForModEvent("OStim_End")
	UnregisterForModEvent("OStim_Orgasm")
	If TheMCM.OStimInstalled
		RegisterForModEvent("OStim_Start", "OStim_Start")
		RegisterForModEvent("OStim_SceneChanged", "OStim_SceneChanged")
		RegisterForModEvent("OStim_End", "OStim_End")
		RegisterForModEvent("OStim_Orgasm", "OStim_Orgasm")
	EndIf
EndFunction

Event McmRegistered(String eventName, String strArg, Float numArg, Form sender)
	TheMCM = sender as SexExpMCM
	TheMCM.OStimExp = Self
	Register()
EndEvent

cfl_FeralMCM Function GetFeral()
	Return (Game.GetFormFromFile(0x000950, "Feral.esp") as Quest) as cfl_FeralMCM
EndFunction

Int Function GetFeralMasteryReward()
	Int reward = JsonUtil.GetIntValue("../Feral/SexIntegration", "MasteryPerMatchingScene", 12)
	If reward < 1
		Return 12
	EndIf
	Return reward
EndFunction

Event OStim_Start(String eventName, String strArg, Float numArg, Form sender)
	Actor[] actors = OThread.GetActors(0)
	StorageUtil.StringListClear(Self, "actions")
	StorageUtil.SetIntValue(Self, "actorCount", actors.Length)
	StorageUtil.SetIntValue(Self, "Feral.Qualified", 0)
	StorageUtil.SetIntValue(Self, "Feral.MatchingFamily", 0)
	orgasm = false
	If actors.Find(Game.GetPlayer()) < 0
		Return
	EndIf
	cfl_FeralMCM feral = GetFeral()
	If !feral
		Return
	EndIf
	Int family = feral.GetActiveFamily()
	If family < 1
		Return
	EndIf
	StorageUtil.SetIntValue(Self, "Feral.Qualified", family)
	Int i = 0
	While i < actors.Length
		If actors[i] && actors[i] != Game.GetPlayer() && feral.GetFamily(actors[i]) == family
			StorageUtil.SetIntValue(Self, "Feral.MatchingFamily", family)
			Return
		EndIf
		i += 1
	EndWhile
EndEvent

Event OStim_SceneChanged(String eventName, String strArg, Float numArg, Form sender)
	String[] actions = OMetadata.GetActionTypes(strArg)
	Int i = 0
	While i < actions.Length
		StorageUtil.StringListAdd(Self, "actions", actions[i])
		i += 1
	EndWhile
EndEvent

Event OStim_Orgasm(String eventName, String strArg, Float numArg, Form sender)
	orgasm = true
EndEvent

Event OStim_End(String eventName, String strArg, Float numArg, Form sender)
	String[] actions = StorageUtil.StringListToArray(Self, "actions")
	StorageUtil.StringListClear(Self, "actions")
	Int family = StorageUtil.GetIntValue(Self, "Feral.Qualified")
	Int matchingFamily = StorageUtil.GetIntValue(Self, "Feral.MatchingFamily")
	StorageUtil.SetIntValue(Self, "Feral.Qualified", 0)
	StorageUtil.SetIntValue(Self, "Feral.MatchingFamily", 0)
	If family < 1
		DebugMessage("No EXP granted because no Feral shape was active when the scene began")
		Return
	EndIf
	GrantExp(Evaluate(actions), StorageUtil.GetIntValue(Self, "actorCount"), false, OUtils.GetOStim().IsVictim(player), orgasm)
	If matchingFamily == family
		cfl_FeralMCM feral = GetFeral()
		If feral
			feral.AddActivityMastery(family, GetFeralMasteryReward(), "matching creature scene")
		EndIf
	EndIf
EndEvent
