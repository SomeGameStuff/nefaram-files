Scriptname cfl_config extends Quest Conditional

Bool Property initRunning Auto
Bool Property cflLolaActive Auto
Bool Property LolaQuestRunning Auto
Bool Property ExtensionRunning Auto
Bool Property TaskOutfitManualMode Auto
Bool Property DebugEnabled Auto
Bool Property SkoomaWhoreAvailable Auto
Bool Property SkoomaWhoreAllow Auto
Int Property Version Auto
Int Property TaskOutfitChangeKey Auto
Int Property ConfigKey Auto
Int Property DebugKey Auto
Int Property scBreakKey Auto
Int Property EndWalkKey Auto
String Property LastPlaymateFile Auto
String Property jsonConfigPath Auto
String Property DrugType Auto
String[] Property Genders Auto
Actor Property Owner Auto
Actor Property Player Auto
Actor Property Playmate Auto
cfl_Drugs Property Drugs Auto
vkjmq Property lola Auto
zadLibs Property dd Auto
cfl_TaskOutfit Property TaskOutfit Auto
cfl_TaskSleepDeny Property TaskSleepDeny Auto
cfl_LolaForSale Property lolaForSale Auto
Quest Property cflStylishOwner Auto

Function Log(String text, Int level = 0)
EndFunction

Function DebugOutput(String text)
EndFunction

Function RequestKeyRegister()
EndFunction

Function RequestReferenceLoad()
EndFunction

Function ScanForMods()
EndFunction

Function Init(cfl_MCM mcm)
EndFunction

Function InitArrays()
EndFunction

Float Function GetGameTime()
    Return Utility.GetCurrentGameTime()
EndFunction

cfl_config Function GetConfig() Global
    Return Quest.GetQuest("cfl_Config") as cfl_config
EndFunction
