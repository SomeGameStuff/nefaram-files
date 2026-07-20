Scriptname SexLabExperience extends SexExpCommon

SexLabFramework Property SexLab Auto

Event OnInit()
	Parent.OnInit()
	Name = "SexLabExperience"
	RegisterForModEvent("SexExpMcmRegister", "McmRegistered")
EndEvent

Function Register()
	UnregisterForModEvent("AnimationEnd")
	UnregisterForModEvent("AnimationStart")
	UnregisterForModEvent("OrgasmEnd")
	UnregisterForModEvent("SexLabOrgasmSeparate")
	If TheMCM.SexLabInstalled
		SexLab = Game.GetFormFromFile(0x000D62, "SexLab.esm") as SexLabFramework
		If SexLab
			RegisterForModEvent("AnimationEnd", "OnSexLabEnd")
			RegisterForModEvent("AnimationStart", "OnSexLabStart")
			RegisterForModEvent("OrgasmEnd", "OnSexLabOrgasmEnd")
			RegisterForModEvent("SexLabOrgasmSeparate", "OnSexLabOrgasmSeparate")
		EndIf
	EndIf
EndFunction

Event McmRegistered(String eventName, String strArg, Float numArg, Form sender)
	TheMCM = sender as SexExpMCM
	TheMCM.SexLabExp = Self
	Register()
EndEvent

Int Function ScoreAnimation(sslBaseAnimation animation)
	Return Math.Floor(Evaluate(animation.GetTags()))
EndFunction

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

Function ClearQualification(Int tid)
	StorageUtil.UnsetIntValue(Self, "Feral.Qualified." + tid)
	StorageUtil.UnsetIntValue(Self, "Feral.MatchingFamily." + tid)
EndFunction

Function OnSexLabStart(String eventName, String args, Float argc, Form sender)
	orgasm = false
	Int tid = args as Int
	ClearQualification(tid)
	If !SexLab
		Return
	EndIf
	sslThreadController thread = SexLab.GetController(tid)
	If !thread || thread.FindSlot(thread.PlayerRef) == -1
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
	StorageUtil.SetIntValue(Self, "Feral.Qualified." + tid, family)
	Actor[] positions = thread.Positions
	Int i = 0
	While i < positions.Length
		Actor partner = positions[i]
		If partner && partner != thread.PlayerRef && feral.GetFamily(partner) == family
			StorageUtil.SetIntValue(Self, "Feral.MatchingFamily." + tid, family)
			Return
		EndIf
		i += 1
	EndWhile
EndFunction

Function OnSexLabOrgasmSeparate(Form actorRef, Int tid)
	sslThreadController thread = SexLab.GetController(tid)
	If thread && thread.FindSlot(thread.PlayerRef) != -1
		orgasm = true
	EndIf
EndFunction

Function OnSexLabOrgasmEnd(String eventName, String args, Float argc, Form sender)
	Int tid = args as Int
	sslThreadController thread = SexLab.GetController(tid)
	If thread && thread.FindSlot(thread.PlayerRef) != -1
		orgasm = true
	EndIf
EndFunction

Function OnSexLabEnd(String eventName, String args, Float argc, Form sender)
	If !SexLab
		Return
	EndIf
	Int tid = args as Int
	sslThreadController thread = SexLab.GetController(tid)
	If !thread || thread.FindSlot(thread.PlayerRef) == -1
		ClearQualification(tid)
		Return
	EndIf
	Int qualifiedFamily = StorageUtil.GetIntValue(Self, "Feral.Qualified." + tid)
	Int matchingFamily = StorageUtil.GetIntValue(Self, "Feral.MatchingFamily." + tid)
	ClearQualification(tid)
	If qualifiedFamily < 1
		DebugMessage("No EXP granted because no Feral shape was active when the scene began")
		Return
	EndIf
	Int expToGrant = ScoreAnimation(thread.Animation)
	GrantExp(expToGrant, thread.ActorCount, thread.HasCreature, thread.IsVictim(thread.PlayerRef), orgasm)
	If matchingFamily == qualifiedFamily
		cfl_FeralMCM feral = GetFeral()
		If feral
			feral.AddActivityMastery(matchingFamily, GetFeralMasteryReward(), "matching creature scene")
		EndIf
	EndIf
EndFunction
