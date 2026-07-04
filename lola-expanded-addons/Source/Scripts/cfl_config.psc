Scriptname cfl_config extends Quest  Conditional

; ------------------------------------------------------------------------------
;                                  Description                                  
; ------------------------------------------------------------------------------

; This File acts as a main hub between external References and Config Vars
; This is to avoid several Places to share Magic Numbers or load
; and maintaing double external References

; ------------------------------------------------------------------------------
;                                General Options                                
; ------------------------------------------------------------------------------
int Property Version = 2 Auto
int Property CurrentVersion = 2 Auto

bool   Property InitialStartupDone   = False                                          Auto
int    Property logLevel             = 0                                              Auto
bool   Property logDisplayConsole    = True                                           Auto
string Property jsonConfigPath       = "../cfe_Lola/Config.json"                      Auto
string Property _PathOutfitBase      = "../cfe_Lola/Outfits/"                         Auto
string Property OutfitProfile        = "default"                                      Auto
string Property PathActorOutfit      = "../cfe_Lola/ActorOutfits/"                    Auto
string Property PathScannedCells     = "../cfe_Lola/Scanned_Cells.json"               Auto
string Property PathCellRebuildFiles = "../cfe_Lola/RebuildCells/"                    Auto
string Property PathFurnitures       = "../cfe_Lola/Furnitures/DefinedFurniture.json" Auto
string Property PathFurnituresZAZ    = "../cfe_Lola/Furnitures/zaz.json"              Auto
string Property PathFurnitures3DM    = "../cfe_Lola/Furnitures/DM3.json"              Auto
string Property PathFurnituresDDC    = "../cfe_Lola/Furnitures/DDC.json"              Auto
bool   Property DebugEnabled         = True Auto Conditional
bool   Property DebugLogging         = False Auto Conditional
bool   Property DebugTraceMessages   = True Auto

String Property ConstSlaveOutfit           = "SlaveOutfits"  Auto
String Property ConstOwnerOutfit           = "OwnerOutfits/" Auto
String Property ConstOwnerOutfitAdventure  = "Adventuring"   Auto
String Property ConstOwnerOutfitCity       = "Capital"       Auto
String Property ConstOwnerOutfitSettlement = "Settlement"    Auto
String Property ConstOwnerOutfitHome       = "PlayerHome"    Auto

String Property PathMarkerBase = "../cfe_Lola/ModifiedMarker/" Auto
String Property PathPlaymateBase = "../cfe_Lola/Playmates/" Auto

string Property PathOutfitBase
    string function get()
        return _PathOutfitBase + OutfitProfile + "/"
    endfunction
endproperty

bool cflLolaRunning = false
bool Property ExtensionRunning = false Auto Conditional

bool           Property cflLolaActive     = False             Auto Conditional
float          Property StartTime         = 0.0               Auto
float          Property OwnerStart        = 0.0               Auto
GlobalVariable Property Timescale                             Auto
GlobalVariable Property GameDaysPassed                        Auto
Scene Property OwnerGenerixSandbox Auto

; ------------------------------------------------------------------------------
;                               General Settings                                
; ------------------------------------------------------------------------------
int            Property DebugKey          = 87                Auto ; default F11
int            Property ConfigKey         = 66                Auto ; default F8
int            Property EndWalkKey        = 46                Auto ; default F11
int            Property LolaScanTimer     = 20                Auto
int            Property DebugSelectedMenu = 0                 Auto 
bool           Property PlaymateAllow     = True              Auto Conditional
bool           Property ShowLeash         = True              Auto
float          Property walkingLeashRange = 300.0             Auto
string         Property LastPlaymateFile  = ""                Auto

; ------------------------------------------------------------------------------
;                                     Drugs                                     
; ------------------------------------------------------------------------------
bool Property DrugAllow = True  Auto
; bool Property DrugAllowSkoomaWh = True  Auto
; bool Property DrugAllowSLSDrugs = True  Auto
string property DrugType = "Vanilla only" Auto



; ------------------------------------------------------------------------------
;                                    Tricks                                     
; ------------------------------------------------------------------------------
GlobalVariable Property cfeTrickprobability Auto ;int ;50.0
bool Property cfeTricksEnabled = True Auto Conditional

; ------------------------------------------------------------------------------
;                                 Tattoo Trick                                  
; ------------------------------------------------------------------------------

bool           Property TaskTattooEnable   = True  Auto Conditional
GlobalVariable Property TaskTattooPropability      Auto ;int ;50
float          Property TaskTattooCD       = 24.0  Auto Conditional
float          Property TaskTattooMax      = 1.0   Auto
bool           Property TaskTattooPlaymate = True  Auto

bool           Property TrickDrugEnabled       = True  Auto Conditional
GlobalVariable Property TrickDrugPropability           Auto ;int ;50
float          Property TrickDrugCD            = 5.0   Auto Conditional
float          Property TrickDrugDrugCount     = 3.0   Auto


; ------------------------------------------------------------------------------
;                               PlaymateSwapTrick                               
; ------------------------------------------------------------------------------
bool           Property TrickPMSEnabled = True  Auto Conditional
GlobalVariable Property TrickPMSPropability Auto ;int ;25
float          Property TrickPMSCD = 14.0   Auto Conditional
bool           Property TrickPMSPossible = False   Auto Conditional

    
    
    ; ------------------------------------------------------------------------------
    ;                                 Quest Configs                                 
    ; ------------------------------------------------------------------------------
    
    
    
    ; ---------------------------------- Outfit ------------------------------------
int   Property TaskOutfitChangeKey                 = 47    Auto ; Default V
float Property TaskOutfitLevel1Threshold           = 20.0  Auto
float Property TaskOutfitLevel2Threshold           = 70.0  Auto 
int   Property TaskOutfitCheckTimeSeconds          = 60    Auto 
int   Property TaskOutfitCheckTimeLocChangeSeconds = 20    Auto
Bool  Property TaskOutfitAllowPlaymate             = True  Auto
int   Property TaskOutfitMaxWarnings               = 3     Auto
Bool  Property TaskOutfitIgnoreFitForAJarl         = False Auto
Bool  Property TaskOutfitNudityRuleWorkaround      = False Auto
Bool  Property TaskOutfitSuspendCheck              = False Auto
Bool  Property TaskOutfitManualMode                = False Auto
Bool  Property TaskOutfitPause                     = False Auto


; -------------------------------- OutfitStart ---------------------------------

GlobalVariable Property TaskOutfitPriceDiscount           Auto ;int ;500
GlobalVariable Property TaskOutfitPriceFull               Auto ;int ;2000
float          Property TaskOutfitGetPkgTime      = 24.0  Auto
bool           Property TaskOutfitEnable          = True  Auto Conditional
float          Property TaskOutfitMinWearTimeOver = 0.0   Auto Conditional
float          Property TaskOutfitCancleCD        = 48.0  Auto Conditional
float          Property TaskOutfitMinWearTime     = 168.0 Auto

; -------------------------------- OutfitVariants ---------------------------------

bool  Property OutfitEnableSluttify     = True Auto Conditional
GlobalVariable Property SluttifyPropability Auto ;int ;75
bool  Property OutfitEnableBreaking     = True Auto Conditional
float Property OutfitSlutifyCoolDown    = 0.5 Auto Conditional
float Property OutfitProbBreakHeavy     = 5.0  Auto Conditional
float Property OutfitProbBreakLight     = 10.0 Auto Conditional
float Property OutfitProbBreakCloothing = 15.0 Auto Conditional


; -------------------------------- Sleep Deny ----------------------------------

Bool  Property TaskSleepDenyEnabled          = True Auto Conditional
Float Property TaskSleepDenyMinScoreStart    = 20.0 Auto Conditional
Bool  Property TaskSleepAllowPlaymate        = True  Auto
Bool  Property TaskSleepHandleOwnerVamire    = false Auto Conditional
Bool  Property TaskSleepPaused               = False Auto
Float Property TaskSleepMasterMaxDaysWithout = 5.0   Auto
Float Property TaskSleepMasterMinH           = 8.0   Auto
Float Property TaskSleepMasterMinTiredness   = 25.0  Auto
Float Property TaskSleepMinScoreReward       = 75.0  Auto
Float Property TaskSleepMaxScoreBoundOnly    = 25.0  Auto
Float Property TaskSleepBedSearchTime        = 1.0   Auto
Float Property TaskSleepMasterUpdateinGameH  = 3.0   Auto
Int   Property EventChance                   = 80    Auto
Bool  Property TaskSleepKennelKeepgifts      = False Auto

int   Property TaskSleepFurnitureChance      = 75    Auto
int   Property TaskSleepGroundChance         = 50    Auto
int   Property TaskSleepGroundBoundChance    = 50    Auto
int   Property TaskSleepRewardChance         = 50    Auto
int   Property TaskSleepKennelChance         = 10    Auto

; --------------------------------- Sales Pet ----------------------------------
Bool  Property AllowSalesPet         = True   Auto Conditional
GlobalVariable Property SalesPropability Auto ;int ;75.0
Bool  Property SalesAllowPlaymate    = True   Auto Conditional
Float Property SalesPetCoolDown      = 7.0    Auto 
Float Property SalesDeviceDifficulty = 30.0   Auto
Float Property SaleMinSubScore       = 50.0   Auto Conditional
Float Property SalesDeviceMercyTimer = 2.0    Auto
Float Property SalesTaskTime         = 8.0    Auto
Float Property SalesCustomerCooldown = 2.0    Auto
; Sale change = 1 -(100-Base * 100-upsell) = 75%
Float Property SaleBaseProability    = 50.0   Auto
Float Property UpSaleBaseProability  = 50.0   Auto
Float Property SaleBaseFail          = 33.0   Auto
Float Property SaleBaseCritical      = 25.0   Auto
; criticial fail == BaseFail * Critical =  8% default


; -------------------------------- LolaOnSale ----------------------------------
GlobalVariable Property LoSProbability Auto ;int ;75
bool    Property allowLolaOnSale            = True  Auto Conditional
float   Property LoSSearchBuyerMaxTimeDays  = 7.0     Auto
int     Property LoSGenderOnly              = -1      Auto
float   Property LoSBuyInterestChance       = 75.0    Auto
float   Property LoSScoreLoss               = -0.5    Auto
float   Property LoSPrice                   = 1000.0  Auto
float   Property LoSMinContractTime         = 14.0    Auto Conditional
float   Property LoSMinBorder               = 10.0    Auto Conditional
float   Property LoSMaxBorder               = 75.0    Auto Conditional
bool    Property LoSEnabled                 = True    Auto Conditional
bool    Property LoSUseSlaveCaravan         = False    Auto Conditional
float   Property LoSMinKeepTime             = 7.0     Auto

; ------------------------------------------------------------------------------
;                                    Petplay                                    
; ------------------------------------------------------------------------------
float property petplayPlaytime = 3.0 Auto

; ------------------------------------------------------------------------------
;                                   Missives                                    
; ------------------------------------------------------------------------------
GlobalVariable Property MissivesProbability Auto ;int ;75
bool    Property allowMissives       = True  Auto Conditional
float   Property misMaxQuests        = 2.0   Auto
float   Property misQuestTime        = 7.0   Auto
float   Property misGoldReward       = 0.2   Auto
float   Property misTargetGold       = 150.0 Auto
float   Property misCooldown         = 14.0  Auto
float   Property misStartSubPoint    = 35.0  Auto Conditional
bool    Property misWalkToBoard      = True  Auto Conditional

; ------------------------------------------------------------------------------
;                                  ChangeTown                                   
; ------------------------------------------------------------------------------
; shares Variables with Slave Caravan
bool  Property chtAllowTask         = True  Auto Conditional
GlobalVariable Property chtProbability Auto ;int ;75
float Property chtMinTimeInHold     = 7.0   Auto
float Property chtTaskTime          = 3.0   Auto

; ------------------------------------------------------------------------------
;                                 Slave Caravan                                 
; ------------------------------------------------------------------------------
; This Quest reuses timings from change town. it will be either this or the other
bool           Property scAllowTask     = True    Auto Conditional
GlobalVariable Property scProbability             Auto ;int ;75
bool           Property scAllowPlaymate = True    Auto Conditional
float          Property scEventTimer    = 2.0     Auto
float          Property scEventChance   = 50.0    Auto
int            Property scBreakKey      = 45      Auto

; ------------------------------------------------------------------------------
;                               Lola Buys a House                               
; ------------------------------------------------------------------------------
bool           Property LbaHEnabled            = True Auto Conditional
GlobalVariable Property LbaHProbability               Auto ;int ;50
bool           Property LbaHSLSFreeWeek        = True Auto
float          Property LbaHCoolDown           = 60.0 Auto Conditional
float          Property LbaHMinContractTime    = 14.0 Auto Conditional
float          Property LbaHMinSubmissionScore = 60.0 Auto Conditional
float          Property LbaHBuyTime            = 14.0 Auto Conditional

; ------------------------------------------------------------------------------
;                                 PublicService                                 
; ------------------------------------------------------------------------------
Bool           Property PSAllowRandomLoan       = True Auto Conditional
GlobalVariable Property PSProbability                  Auto ;int ;25
float          Property PSCoolDownPublicService = 14.0 Auto Conditional
float          Property PSMaxLoanCD             = 24.0 Auto Conditional


; ------------------------------------------------------------------------------
;                                 Dungeon Bait                                  
; ------------------------------------------------------------------------------
Bool Property DungeonBaitAllow Auto Conditional
Bool Property DungeonBaitActive Auto Conditional
Bool Property DungeonBaitPlaymateAllow Auto Conditional
Bool Property DungeonBaitMaxRounds Auto Conditional



; ------------------------------------------------------------------------------
;                                   Next Vars                                   
; ------------------------------------------------------------------------------
float Property scNext          = 999.0 Auto Conditional
float Property chtNext         = 999.0 Auto Conditional
float Property misNextStart    = 0.0   Auto Conditional
float Property LoSNextStart    = 0.0   Auto Conditional
Float Property NextSalesPet    = 0.0   Auto Conditional
float Property TaskOutfitNext  = 0.0   Auto Conditional
float Property TaskTattooNext  = 0.0   Auto Conditional
float Property TrickDrugNext   = 0.0   Auto Conditional
float Property TrickSlutifyNext = 0.0   Auto Conditional
float Property TrickPMSNext    = 0.0   Auto Conditional
float Property LbaHNext        = 0.0   Auto Conditional
; Public Service to Reduce Debt
float Property PSNext          = 0.0   Auto Conditional
float Property PSLoanNext      = 0.0   Auto Conditional

; ------------------------------------------------------------------------------
;                                Stylish Master                                 
; ------------------------------------------------------------------------------
float Property StylishMasterKeepOutfitTime = 3.0 Auto
Bool Property StylishMasterAutoStart = False Auto
Bool Property StylishMasterFemaleOnly = False Auto


; ------------------------------------------------------------------------------
;                              Do not Copy to json                              
; ------------------------------------------------------------------------------
Bool Property StylishMasterRunning = False Auto
Actor[] Property PotentialPlaymates Auto

; ------------------------------------------------------------------------------
;                                    Markers                                    
; ------------------------------------------------------------------------------
float Property Marker_Solitude_Whoredisplay1_X = 0.0 Auto
float Property Marker_Solitude_Whoredisplay1_Y = 0.0 Auto
float Property Marker_Solitude_Whoredisplay1_Z = 0.0 Auto
float Property Marker_Solitude_Whoredisplay2_X = 0.0 Auto
float Property Marker_Solitude_Whoredisplay2_Y = 0.0 Auto
float Property Marker_Solitude_Whoredisplay2_Z = 0.0 Auto

float Property Marker_Markarth_Whoredisplay1_X = 0.0 Auto
float Property Marker_Markarth_Whoredisplay1_Y = 0.0 Auto
float Property Marker_Markarth_Whoredisplay1_Z = 0.0 Auto
float Property Marker_Markarth_Whoredisplay2_X = 0.0 Auto
float Property Marker_Markarth_Whoredisplay2_Y = 0.0 Auto
float Property Marker_Markarth_Whoredisplay2_Z = 0.0 Auto

float Property Marker_Riften_Whoredisplay1_X = 0.0 Auto
float Property Marker_Riften_Whoredisplay1_Y = 0.0 Auto
float Property Marker_Riften_Whoredisplay1_Z = 0.0 Auto
float Property Marker_Riften_Whoredisplay2_X = 0.0 Auto
float Property Marker_Riften_Whoredisplay2_Y = 0.0 Auto
float Property Marker_Riften_Whoredisplay2_Z = 0.0 Auto

float Property Marker_Whiterun_Whoredisplay1_X = 0.0 Auto
float Property Marker_Whiterun_Whoredisplay1_Y = 0.0 Auto
float Property Marker_Whiterun_Whoredisplay1_Z = 0.0 Auto
float Property Marker_Whiterun_Whoredisplay2_X = 0.0 Auto
float Property Marker_Whiterun_Whoredisplay2_Y = 0.0 Auto
float Property Marker_Whiterun_Whoredisplay2_Z = 0.0 Auto

float Property Marker_Windhelm_Whoredisplay1_X = 0.0 Auto
float Property Marker_Windhelm_Whoredisplay1_Y = 0.0 Auto
float Property Marker_Windhelm_Whoredisplay1_Z = 0.0 Auto
float Property Marker_Windhelm_Whoredisplay2_X = 0.0 Auto
float Property Marker_Windhelm_Whoredisplay2_Y = 0.0 Auto
float Property Marker_Windhelm_Whoredisplay2_Z = 0.0 Auto

; ------------------------------------------------------------------------------
;                                     Menus                                     
; ------------------------------------------------------------------------------
string[] Property Genders Auto



; ------------------------------------------------------------------------------
;                                 Generic Items                                 
; ------------------------------------------------------------------------------
MiscObject Property Gold Auto 

; ------------------------------------------------------------------------------
;                               Furniture Utility                               
; ------------------------------------------------------------------------------

; Background Scanner is Active
Bool Property FurnitureScannerActive = False Auto
; Store Data For Rebuild
Bool Property FurnitureScannerStorePosition = False Auto
; Use Cell Scanner Results
Bool Property FurnitureUseCellScannedResults = False Auto

; ------------------------------------------------------------------------------
;                                     Tasks                                     
; ------------------------------------------------------------------------------

cfl_TaskOutfit         Property TaskOutfit         Auto
cfl_TaskOutfitStarter  Property TaskOutfitStarter  Auto
cfl_TaskSleepDeny      Property TaskSleepDeny      Auto
cfl_TaskSleepFurniture Property TaskSleepFurniture Auto
cfl_TaskSleepGround    Property TaskSleepGround    Auto
cfl_TaskSleepReward    Property TaskSleepReward    Auto
cfl_TaskSleepSLSKennel Property TaskSleepKennel    Auto
cfl_TaskSleepBedSearch Property TaskSleepBedSearch Auto
cfl_SalesPet           Property TaskSalesPet       Auto
cfl_LolaForSale        Property lolaForSale        Auto
Quest                  Property cflNpcScanner      Auto
cfl_PublicWhore        Property cflPublicWhore     Auto
cfl_PublicService      Property cflPublicService   Auto
Quest                  Property cflStylishOwner    Auto

cfl_LocationTracker    Property locationTracker    Auto
cfl_WalkToQuest        Property walkQuest          Auto
cfl_SlaveCaravan       Property caravanQuest       Auto
cfl_SingleWalk         Property singleWalkQuest    Auto
cfl_Leash              Property leashQ             Auto
cfl_CommonNpcs         Property cflNpcs            Auto
cfl_Marker             Property cflMarker          Auto  
cfl_drugs              Property Drugs              Auto
cfl_LolaMonitor        Property LolaMonitor        Auto

; ------------------------------------------------------------------------------
;                                Mod Integration                                
; ------------------------------------------------------------------------------

bool property ModRapeTatsAllow     = True  Auto Conditional
bool property DM3Allow             = True  Auto Conditional
bool property ZAZAllow             = True  Auto Conditional
bool property DDCAllow             = True  Auto Conditional
bool property SLSAllow             = True  Auto Conditional
bool property SimSlavAllow         = True  Auto Conditional
bool property PamaBeatupAllow      = True  Auto Conditional
bool property SkoomaWhoreAllow     = True  Auto Conditional
bool property PublicWhoreAllow     = True  Auto Conditional
bool property FSMAllow             = True  Auto Conditional


bool property DM3Available         = false Auto Conditional
bool property ModRapeTatsAvailable = false Auto Conditional
bool property ZAZAvailable         = false Auto Conditional
bool property DDCAvailable         = false Auto Conditional
bool property SLSAvailable         = false Auto Conditional
bool property SimSlavAvailable     = false Auto Conditional
bool property PamaBeatupAvailable  = false Auto Conditional
bool property ModMissivesAvailable = false Auto Conditional
bool property SkoomaWhoreAvailable = false Auto Conditional
bool property PublicWhoreAvailable = false Auto Conditional
bool property FSMAvailable         = false Auto Conditional

;bool property MMEAvailable         = false Auto Conditional

; ------------------------------------------------------------------------------
;                           Public Whore Integration                            
; ------------------------------------------------------------------------------
int property minClientQuota  = 4   Auto		;Minimum clients to assign per reporting period
int property maxClientQuota  = 10   Auto		;Maximum clients to assign per reporting period
int property minGoldQuota    = 200 Auto		;Minimum gold to assign per reporting period
int property maxGoldQuota    = 500 Auto		;Maximum gold to assign per reporting period
int property reportingPeriod = 1    Auto		;Number of days the player has to meet quota





; ------------------------------------------------------------------------------
;                              External Properties                            
; ------------------------------------------------------------------------------

ImageSpaceModifier Property FadeToBlackImg Auto
ImageSpaceModifier Property FadeToBlackHoldImg Auto
ImageSpaceModifier Property FadeToBlackBackImg Auto

; ------------------------------- Lola Effects ---------------------------------
MagicEffect Property EyeCandyEffect Auto
MagicEffect Property EyeCandyEffectExtended Auto

; --------------------------------- Furniture ----------------------------------
Keyword Property KW_DM3Furniture = None Auto
Faction Property FAC_DM3RandomiseActor = None Auto

; ZAZ
Keyword Property KW_ZAZFurniture = None Auto
Faction Property FAC_ZAZIsAnimating = None Auto

; Contraptions
Keyword Property KW_DDCFurniture = None Auto
Keyword Property KW_DeviousDevice = None Auto

; Sexlab
Keyword Property SexlabNoStrip Auto

; ------------------------------------------------------------------------------
;                               General Factions                                
; ------------------------------------------------------------------------------

Faction Property PotentialFollower Auto
Faction Property PotentialHireling Auto
; Faction Property CurrentFollower Auto
; Faction Property CurrentHireling Auto

; ------------------------------------------------------------------------------
;                                      SLS                                      
; ------------------------------------------------------------------------------
Location property SLSLocationKennel Auto
keyword property SLSKennelKW Auto

; ------------------------------------------------------------------------------
;                                   Locations                                   
; ------------------------------------------------------------------------------


;MainHolds
Location Property LocWhiterun          Auto ; 00018A56
Location Property LocSolitude          Auto ;00018A5A
Location Property LocWindhelm          Auto ; 00018A57
Location Property LocRiften            Auto ; 00018A58
Location Property LocMarkarth          Auto ; 00018A59
; Minor Holds
Location Property LocDawnstar          Auto; 00018A50
Location Property LocFalkreath         Auto; 00018A49
Location Property LocMorthal           Auto ; 00018A53
Location Property LocWinterhold        Auto ; 00018A51
Location Property LocSkaalVillage      Auto ; 143BB
Location Property LocRavenRock         Auto ; 143B9

; villiages
Location Property LocKarthwasten       Auto ;00018A54
Location Property LocHelgen            Auto ; 00018A4A
Location Property LocIvarstead         Auto ;00018A4B
Location Property LocShorsStone        Auto ;00018A4C
Location Property LocDragonBridge      Auto ; 00018A46
Location Property LocDarkWaterCrossing Auto ; 00018A4D
Location Property LocDarkKynesgrove    Auto ; 00018A4E
Location Property LocNightgateInn      Auto ; 00018A4F
Location Property LocStoneshill        Auto ; 00018A52
Location Property LocOldHroldan        Auto ; 00018A55

; ------------------------------------------------------------------------------
;                                  Animations                                   
; ------------------------------------------------------------------------------
; Animations
String Property DefaultAnimation = "IdleForceDefaultState" Auto
String[] Property GroundSleepingAnimations Auto
String[] Property BoundAnimations Auto
String Property sGroundSleepingAnimations = "IdleWounded_02" Auto
String Property sBoundAnimations = "ZazAPCAO051;ZazAPCAO052;ZazAPCAO053;ZazAPCAO054;ZazAPCAO055" Auto
; ------------------------------------------------------------------------------
;                                 Internal APIS                                 
; ------------------------------------------------------------------------------

cfl_lolaMain Property cflLola Auto
cfl_UtilityOutfit Property utOutfit Auto
cfl_UtilityFurniture Property utFurniture Auto
cfl_UtilityDD Property utDD Auto
cfl_GenericScenes Property cflScenes Auto
cfl_NPCAliasTracker Property AliasTracker Auto
cfl_generic_fg Property GenericFG Auto
Quest Property CellScanner Auto

; ------------------------------------------------------------------------------
;                                     APIS                                      
; ------------------------------------------------------------------------------
zadLibs Property dd Auto
zadDeviceLists Property ddRNG Auto
SexLabFramework Property sexlab Auto
vkjmq Property lola Auto
vkjMCM Property lolaConfig Auto
vkjTrick Property lolaTrick Auto
vkjStrongHand Property StrongHand Auto
;SLS_Init Property SLSInit Auto

FormList Property lolaQuestList Auto
FormList Property addonQuestList Auto

; ------------------------------------------------------------------------------
;                             Kal Compability Stuff                             
; ------------------------------------------------------------------------------
Quest   Property kal_InnSleep            Auto
keyword Property kal_Eequipment_AN       Auto
keyword Property kal_Eequipment_Animated Auto
keyword Property kal_Eequipment_VA       Auto
keyword Property kal_Eequipment_BR       Auto
keyword Property kal_Eequipment_BO       Auto

Function load0kalReferences()
    kal_InnSleep            = Quest.GetQuest("0kal_InnSleep")
    kal_Eequipment_Animated = Game.GetFormFromFile(0xB0D6 ,"kal_LolaAddon.esp") as Keyword
    kal_Eequipment_VA       = Game.GetFormFromFile(0xC119 ,"kal_LolaAddon.esp") as Keyword
    kal_Eequipment_AN       = Game.GetFormFromFile(0xC119 ,"kal_LolaAddon.esp") as Keyword
    kal_Eequipment_BR       = Game.GetFormFromFile(0xC11A ,"kal_LolaAddon.esp") as Keyword
    kal_Eequipment_BO       = Game.GetFormFromFile(0xC11B ,"kal_LolaAddon.esp") as Keyword
EndFunction

; ------------------------------------------------------------------------------
;                                  Debt Stuff                                   
; ------------------------------------------------------------------------------
; Hold debts
Bool Property DebtInCurrentTown = False Auto Conditional
GlobalVariable Property DebtWhiterun Auto
GlobalVariable Property DebtMarkarth Auto
GlobalVariable Property DebtWindhelm Auto
GlobalVariable Property DebtRiften Auto
GlobalVariable Property DebtSolitude Auto


; ------------------------------------------------------------------------------
;                                Lola Properties                                
; ------------------------------------------------------------------------------


bool property LolaQuestRunning
    bool function get()
        return lola.IsRunning()
    endFunction
endProperty

float property SubmissionScore
    float function get()
        return lola.GetScore()
    endFunction
endProperty

Actor property Playmate
    Actor function get()
        return lola.PlaymateRef
    endFunction
endProperty

Actor property Owner
    Actor function get()
        return lola.OwnerRef
    endFunction
endProperty

Actor property Player Auto

; ------------------------------------------------------------------------------
;                              Random CFG Options                               
; ------------------------------------------------------------------------------

String Function GetRanomAnimation(string animations)
    String[] entries = PapyrusUtil.StringSplit(animations)
    int max = entries.Length - 1
    int rng = Utility.RandomInt(0, max)
    return entries[rng]
Endfunction


String Function AniamtionGetLocking()
    return "IdleLockPick"
EndFunction

String Function GetSleepingGroundAnimation()
    string animations = "IdleWounded_02,IdleLaydownEnter"
    return GetRanomAnimation(animations)
Endfunction

String Function GetGroundBoundAnimation()
    string animations = "ZazAPCAO051,ZazAPCAO052,ZazAPCAO053,ZazAPCAO054,ZazAPCAO055"
    return GetRanomAnimation(animations)
Endfunction

String Function TakeAnimation()
    return "IdleTake"
EndFunction


; ------------------------------------------------------------------------------
;                                   Functions                                   
; ------------------------------------------------------------------------------

Function RegisterModEvents()
    RegisterForModEvent("cfeLola_TechReloadReferences", "OnReloadReferences")
    RegisterForModEvent("cfeLola_LolaStart", "OnLolaStart")
    RegisterForModEvent("cfeLola_LolaStop", "OnLolaStop")
EndFunction

Function UnregisterModEvents()
    UnregisterForModEvent("cfeLola_TechReloadReferences")
EndFunction

Function ResetModEvents()
    UnregisterModEvents()
    RegisterModEvents()
EndFunction

Function SetReferences()

    Player = Game.GetPlayer()
    Set_DefaultVars()
    InitArrays()
    SetInternalReferences()
    SetExternalReferences()
EndFunction

Function Set_DefaultVars()
    Log("Set Default Vars")
    PathActorOutfit = "../cfe_Lola/ActorOutfits/"
Endfunction

Function SetGeneralReferences()

EndFunction

Function InitArrays()
    Log("Init Base Arrays")
    GroundSleepingAnimations = new String[1]
    GroundSleepingAnimations[0] = "IdleWounded_02"
    BoundAnimations = new String[5]
    BoundAnimations[0] = "ZazAPCAO051"
    BoundAnimations[1] = "ZazAPCAO052"
    BoundAnimations[2] = "ZazAPCAO053"
    BoundAnimations[3] = "ZazAPCAO054"
    BoundAnimations[4] = "ZazAPCAO055"

    Genders = new string[3]
    Genders[0] = "Both"
    Genders[1] = "Male"
    Genders[2] = "Female"


Endfunction

; ------------------------------------------------------------------------------
;                           Optional Mod Integration                            
; ------------------------------------------------------------------------------

Function ScanForMods()

    ModRapeTatsAvailable = Quest.GetQuest("rapeTattoos")

    Log("Check for Furniture Mods")
    ; Furniture Stuff
    KW_DM3Furniture = Game.GetFormFromFile(0x00182B ,"dse-display-model.esp") as Keyword
    KW_ZaZFurniture = Game.GetFormFromFile(0x00762B ,"ZaZAnimationPack.esm") as Keyword
    KW_DDCFurniture = Game.GetFormFromFile(0x0022FF ,"Devious Devices - Contraptions.esm") as Keyword
    if KW_DM3Furniture != None
        DM3Available = True
        FAC_DM3RandomiseActor = Game.GetFormFromFile(0x006968 ,"dse-display-model.esp") as Faction
    endif
    if KW_ZAZFurniture != None
        ZAZAvailable = true
        FAC_ZAZIsAnimating = Game.GetFormFromFile(0x00E2B7 ,"ZaZAnimationPack.esm") as Faction
    endif
    if KW_DDCFurniture != None
        DDCAvailable = true
        utFurniture.FillDDCDevices()
    endif

    ;SLS
    SLSLocationKennel = Game.GetFormFromFile(0x550CE ,"SL Survival.esp") as location
    if SLSLocationKennel != None
        SLSKennelKW = Game.GetFormFromFile(0x550CF ,"SL Survival.esp") as keyword
        SLSAvailable = True
        ;SLSInit = Quest.GetQuest("_SLS_Main") as SLS_Init
    endif

    Log("Check for Misc Mods")
    PamaBeatupAvailable = Quest.GetQuest("pama_PBU") != None
    ModMissivesAvailable = Quest.GetQuest("_M_MCM") != None
    SkoomaWhoreAvailable = Quest.GetQuest("SLSW") != None
    PublicWhoreAvailable = cfl_PW.PWAvailable()
    FSMAvailable = Quest.GetQuest("fsm_MCMQuest") != None
    SimSlavAvailable = Quest.GetQuest("SimpleSlavery") != None


    SetExternalReferences()
Endfunction

; ------------------------------------------------------------------------------
;                          External References to APIS                          
; ------------------------------------------------------------------------------

Function SetInternalReferences()
    Log("Load Internal Quests")

    cflLola                 = Quest.GetQuest("cfl_Main") as cfl_lolaMain
    utOutfit                = Quest.GetQuest("cfl_Config") as cfl_UtilityOutfit
    locationTracker         = Quest.GetQuest("cfl_PlayerLocation") as cfl_LocationTracker
    utFurniture             = Quest.GetQuest("cfl_Config") as cfl_UtilityFurniture
    utDD                    = Quest.GetQuest("cfl_Config") as cfl_UtilityDD
    cflScenes               = Quest.GetQuest("cfl_Scenes") as cfl_GenericScenes
    AliasTracker            = Quest.GetQuest("cfl_NPCAliasTracker") as cfl_NPCAliasTracker

    CellScanner             = Quest.GetQuest("cfl_CellScanner")

    walkQuest               = Quest.GetQuest("cfl_WalkToQuest") as cfl_WalkToQuest
    singleWalkQuest         = Quest.GetQuest("cfl_SingleWalkTo") as cfl_SingleWalk
    leashQ                  = Quest.GetQuest("cfl_Leash") as cfl_Leash
    caravanQuest            = Quest.GetQuest("cfl_SlaveCaravan") as cfl_SlaveCaravan
    cflNpcs                 = Quest.GetQuest("cfl_config") as cfl_CommonNPCs
    cflMarker               = Quest.GetQuest("cfl_config") as cfl_Marker

    ; Tasks
    Log("Load Internal Tasks")
    TaskOutfit              = Quest.GetQuest("cfl_TaskOutfit") as cfl_TaskOutfit
    TaskOutfitStarter       = Quest.GetQuest("cfl_TaskOutfitStarter") as cfl_TaskOutfitStarter
    TaskSleepDeny           = Quest.GetQuest("cfl_TaskSleepDeny") as cfl_TaskSleepDeny
    TaskSalesPet            = Quest.GetQuest("cfl_SalesPet") as cfl_SalesPet
    TaskSleepFurniture      = Quest.GetQuest("cfl_TaskSleepFurniture") as cfl_TaskSleepFurniture
    TaskSleepGround         = Quest.GetQuest("cfl_TaskSleepGround") as cfl_TaskSleepGround
    TaskSleepReward         = Quest.GetQuest("cfl_TaskSleepReward") as cfl_TaskSleepReward
    TaskSleepKennel         = Quest.GetQuest("cfl_TaskSleepSLSKennel") as cfl_TaskSleepSLSKennel
    TaskSleepBedSearch      = Quest.GetQuest("cfl_TaskSleepBedSearch") as cfl_TaskSleepBedSearch
    lolaForSale             = Quest.GetQuest("cfl_LolaForSale") as cfl_LolaForSale
    cflStylishOwner         = Quest.GetQuest("cfl_StylishMaster")

    Log("Load Internal Integrations")
    GenericFG               = Quest.GetQuest("cfl_generic_fg") as cfl_generic_fg
    cflNpcScanner           = Quest.GetQuest("cfl_NPCScanner")
    Drugs                   = Quest.GetQuest("cfl_config") as cfl_Drugs
    LolaMonitor             = Quest.GetQuest("cfl_config") as cfl_LolaMonitor
    cflPublicWhore          = Quest.GetQuest("cfl_PublicWhore") as cfl_PublicWhore
    cflPublicService        = Quest.GetQuest("cfl_PublicService") as cfl_PublicService

    Log("Load Internal Global Vars")
    TaskOutfitPriceFull     = Game.GetFormFromFile(0x001DA8,"cfl_LolaAddon.esp") as GlobalVariable
    TaskOutfitPriceDiscount = Game.GetFormFromFile(0x001DA7,"cfl_LolaAddon.esp") as GlobalVariable
    
    cfeTrickprobability     = Game.GetFormFromFile(0x2CF8F,"cfl_LolaAddon.esp") as GlobalVariable
    TaskTattooPropability   = Game.GetFormFromFile(0x2CF90,"cfl_LolaAddon.esp") as GlobalVariable
    SalesPropability        = Game.GetFormFromFile(0x2CF91,"cfl_LolaAddon.esp") as GlobalVariable
    LoSProbability          = Game.GetFormFromFile(0x2CF92,"cfl_LolaAddon.esp") as GlobalVariable
    MissivesProbability     = Game.GetFormFromFile(0x2CF93,"cfl_LolaAddon.esp") as GlobalVariable
    chtProbability          = Game.GetFormFromFile(0x2CF94,"cfl_LolaAddon.esp") as GlobalVariable
    scProbability           = Game.GetFormFromFile(0x2CF95,"cfl_LolaAddon.esp") as GlobalVariable
    TrickDrugPropability    = Game.GetFormFromFile(0x4172F,"cfl_LolaAddon.esp") as GlobalVariable
    LbaHProbability         = Game.GetFormFromFile(0x4750C,"cfl_LolaAddon.esp") as GlobalVariable
    PSProbability           = Game.GetFormFromFile(0x4750B,"cfl_LolaAddon.esp") as GlobalVariable
    SluttifyPropability      = Game.GetFormFromFile(0x5EB9D,"cfl_LolaAddon.esp") as GlobalVariable

    DebtWhiterun           = Game.GetFormFromFile(0x4460C,"cfl_LolaAddon.esp") as GlobalVariable
    DebtMarkarth           = Game.GetFormFromFile(0x4460D,"cfl_LolaAddon.esp") as GlobalVariable
    DebtSolitude           = Game.GetFormFromFile(0x44610,"cfl_LolaAddon.esp") as GlobalVariable
    DebtRiften             = Game.GetFormFromFile(0x44611,"cfl_LolaAddon.esp") as GlobalVariable
    DebtWindhelm           = Game.GetFormFromFile(0x44612,"cfl_LolaAddon.esp") as GlobalVariable

    Log("Start Internal Misc Loading and Filling")
    OwnerGenerixSandbox = Game.GetFormFromFile(0x47510 ,"cfl_LolaAddon.esp") as Scene
    addonQuestList = Game.GetFormFromFile(0x02FE5E ,"cfl_LolaAddon.esp")      as Formlist


    FillMarkers()
    if useFnis
        ;cfl_FNIS.SetAnimationProperties()
    endif
    Log("Fill Generic NPCs and Marker")
    cflNpcs.FillNPCs()
    cflMarker.FillAllMarker()
    Log("Load and Init Drugs")
    Drugs.Init()
    Log("Load and Init Lola Monitor")
    if LolaMonitor != None
        LolaMonitor.Init()
    endif

EndFunction


Function SetExternalReferences()
    ; Libs
    Log("Load External Quests")
    dd                      = Quest.GetQuest("zadQuest") as zadLibs
    ddRng                   = Quest.GetQuest("zadxQuest") as zadDeviceLists
    sexlab                  = Quest.GetQuest("SexLabQuestFramework") as SexLabFramework
    lola                    = Quest.GetQuest("vkjMQ") as vkjmq
    lolaConfig              = lola.MCM
    lolaTrick               = Quest.GetQuest("vkjTrick") as vkjTrick

    Log("Load External Effects")
    ; Eye Candy Effect
    EyeCandyEffect          = Game.GetFormFromFile(0x052429,"submissivelola_est.esp") as MagicEffect
    ; Extended Eye Candy Effect
    EyeCandyEffectExtended  = Game.GetFormFromFile(0x05DF6F,"submissivelola_est.esp") as MagicEffect
    ;GVars
    
    Log("Load External Global Vars")
    Timescale               = Game.GetFormFromFile(0x3A, "Skyrim.esm") as GlobalVariable
    
    Log("Load Misc Stuff")
    GameDaysPassed          = Game.GetFormFromFile(0x39, "Skyrim.esm") as GlobalVariable
    Gold                   = Game.GetFormFromFile(0xF, "Skyrim.esm")  as MiscObject

    FadeToBlackImg          = Game.GetFormFromFile(0xF756D, "Skyrim.esm") As ImageSpaceModifier
    FadeToBlackHoldImg      = Game.GetFormFromFile(0xF756E, "Skyrim.esm") As ImageSpaceModifier
    FadeToBlackBackImg      = Game.GetFormFromFile(0xF756F, "Skyrim.esm") As ImageSpaceModifier

    PotentialFollower       = Game.GetFormFromFile(0x5C84D, "Skyrim.esm") As Faction
    PotentialHireling       = Game.GetFormFromFile(0xBCC9A, "Skyrim.esm") As Faction

    SexlabNoStrip = Game.GetFormFromFile(0x02F16E, "SexLab.esm") As Keyword 

    ;lolaQuestList  = Game.GetFormFromFile(0x05C6B6 ,"submissivelola_est.esp") as Formlist

    SetLocation()

    Log("Load 0kal References")
    load0kalReferences()

    DebugOutput("Config External References loaded")
EndFunction

Function SetLocation()
    Log("Load External Loactions Information")
    ;MainHolds
    LocWhiterun           = Game.GetFormFromFile(0x00018A56 ,"Skyrim.esm") as location ; 00018A56
    LocSolitude           = Game.GetFormFromFile(0x00018A5A ,"Skyrim.esm") as location ; 00018A5A
    LocWindhelm           = Game.GetFormFromFile(0x00018A57 ,"Skyrim.esm") as location ; 00018A57
    LocRiften             = Game.GetFormFromFile(0x00018A58 ,"Skyrim.esm") as location ; 00018A58
    LocMarkarth           = Game.GetFormFromFile(0x00018A59 ,"Skyrim.esm") as location ; 00018A59
    ; Minor Holds
    LocDawnstar           = Game.GetFormFromFile(0x00018A50 ,"Skyrim.esm") as location ; 00018A50
    LocFalkreath          = Game.GetFormFromFile(0x00018A49 ,"Skyrim.esm") as location ; 00018A49
    LocMorthal            = Game.GetFormFromFile(0x00018A53 ,"Skyrim.esm") as location ; 00018A53
    LocWinterhold         = Game.GetFormFromFile(0x00018A51 ,"Skyrim.esm") as location ; 00018A51
    ;LocSkaalVillage      = Game.GetFormFromFile(0x000143BB ,"Skyrim.esm") as location ; 143BB
    ;LocRavenRock         = Game.GetFormFromFile(0x000143B9 ,"Skyrim.esm") as location ; 143B9

    ; villiages
    LocKarthwasten        = Game.GetFormFromFile(0x00018A54 ,"Skyrim.esm") as location ; 00018A54
    LocHelgen             = Game.GetFormFromFile(0x00018A4A ,"Skyrim.esm") as location ; 00018A4A
    LocIvarstead          = Game.GetFormFromFile(0x00018A4B ,"Skyrim.esm") as location ; 00018A4B
    LocShorsStone         = Game.GetFormFromFile(0x00018A4C ,"Skyrim.esm") as location ; 00018A4C
    LocDragonBridge       = Game.GetFormFromFile(0x00018A46 ,"Skyrim.esm") as location ; 00018A46
    LocDarkWaterCrossing  = Game.GetFormFromFile(0x00018A4D ,"Skyrim.esm") as location ; 00018A4D
    LocDarkKynesgrove     = Game.GetFormFromFile(0x00018A4E ,"Skyrim.esm") as location ; 00018A4E
    LocNightgateInn       = Game.GetFormFromFile(0x00018A4F ,"Skyrim.esm") as location ; 00018A4F
    LocStoneshill         = Game.GetFormFromFile(0x00018A52 ,"Skyrim.esm") as location ; 00018A52
    LocOldHroldan         = Game.GetFormFromFile(0x00018A55 ,"Skyrim.esm") as location ; 00018A55
Endfunction

; ------------------------------------------------------------------------------
;                                  Animations                                   
; ------------------------------------------------------------------------------

; shamelessly stolen from DDF
; thanks to the author and great work
    ; --------------------------------------------------------------------------
    ;                                Properties                                 
    ; --------------------------------------------------------------------------
Int  Property modID          Auto
Int  Property mtIdleBase     Auto
Int  Property mtBase         Auto
Int  Property mtxBase        Auto
Int  Property sneakBase      Auto
Int  Property sneakmtBase    Auto
Int  Property h2heqp         Auto
Int  Property h2hidle        Auto
Int  Property h2hatkpow      Auto
Int  Property h2hatk         Auto
Int  Property h2hstag        Auto
Int  Property jump           Auto
Int  Property sprint         Auto
Int  Property shout1         Auto
Int  Property mtturn         Auto

Bool Property useFnis = True Auto

; ------------------------------------------------------------------------------
;                                    Markers                                    
; ------------------------------------------------------------------------------
ObjectReference Property MarkerSolitude   Auto
ObjectReference Property MarkerRiften     Auto
ObjectReference Property MarkerWhiterun   Auto
ObjectReference Property MarkerWindhelm   Auto
ObjectReference Property MarkerMarkarth   Auto
ObjectReference Property MarkerFalkreath  Auto
ObjectReference Property MarkerMorthal    Auto
ObjectReference Property MarkerWinterhold Auto
ObjectReference Property MarkerDawnstar   Auto

; ObjectReference Property MarkerSolitudeWhoreDisplay1  Auto
; ObjectReference Property MarkerSolitudeWhoreDisplay2  Auto
; ObjectReference Property MarkerMarkarthWhoreDisplay1  Auto
; ObjectReference Property MarkerMarkarthWhoreDisplay2  Auto
; ObjectReference Property MarkerWhiterunWhoreDisplay1  Auto
; ObjectReference Property MarkerWhiterunWhoreDisplay2  Auto
; ObjectReference Property MarkerWindhelmWhoreDisplay1  Auto
; ObjectReference Property MarkerWindhelmWhoreDisplay2  Auto
; ObjectReference Property MarkerRiftenWhoreDisplay1  Auto
; ObjectReference Property MarkerRiftenWhoreDisplay2  Auto

Function FillMarkers()
    Log("Load Internal Markers")
    MarkerSolitude   = Game.GetFormFromFile(0x1584A ,"cfl_LolaAddon.esp") as ObjectReference
    MarkerRiften     = Game.GetFormFromFile(0x15839 ,"cfl_LolaAddon.esp") as ObjectReference
    MarkerWhiterun   = Game.GetFormFromFile(0x1584B ,"cfl_LolaAddon.esp") as ObjectReference
    MarkerWindhelm   = Game.GetFormFromFile(0x1584C ,"cfl_LolaAddon.esp") as ObjectReference
    MarkerMarkarth   = Game.GetFormFromFile(0x15830 ,"cfl_LolaAddon.esp") as ObjectReference
    MarkerFalkreath  = Game.GetFormFromFile(0x1584E ,"cfl_LolaAddon.esp") as ObjectReference
    MarkerMorthal    = Game.GetFormFromFile(0x1584F ,"cfl_LolaAddon.esp") as ObjectReference
    MarkerWinterhold = Game.GetFormFromFile(0x15850 ,"cfl_LolaAddon.esp") as ObjectReference
    MarkerDawnstar   = Game.GetFormFromFile(0x1584D ,"cfl_LolaAddon.esp") as ObjectReference
EndFunction


; ------------------------------------------------------------------------------
;                              General References                               
; ------------------------------------------------------------------------------

Function RequestReferenceLoad()
    Log("Requesting Reference Reload")
    SetReferences()
    RegisterModEvents()
    Int Handle = ModEvent.Create("cfeLola_TechReloadReferences")
	If (Handle)
		ModEvent.Send(Handle)
	Endif
    ; SetExternalReferences()
    ; ScanForMods()
Endfunction

Function RequestKeyRegister()
    Log("Requesting Reference Reload")
    Int Handle = ModEvent.Create("cfeLola_TechReloadKeys")
	If (Handle)
		ModEvent.Send(Handle)
	Endif
Endfunction



; ------------------------------------------------------------------------------
;                                  Log Output                                   
; ------------------------------------------------------------------------------

; level 0: Info, 1: Warning, 2: Error
Function Log(string text, int level=0)
    ; Debug.OpenUserLog("cfl_lola")
    ; Debug.TraceUser("cfl_lola", text)
    ; if level >= logLevel
    ;     string logMessage = "[cfl]: " + text
    ;     Debug.Trace(logMessage, level)
    ;     if logDisplayConsole
    ;ConsoleUtil.PrintMessage(logMessage)
    ;     endif
    ; endif
    string logMessage = "[cfl]: " + text
    Debug.Trace(logMessage)
Endfunction

Function DebugOutput(string text)
    Debug.Trace("[cfl-Debug]:" + text)
Endfunction

Auto State Debug
Function DebugOutput(string text)

    Debug.Trace("[cfl-Debug]:" + text)
Endfunction
EndState

float Function GetGameTime()
    return GameDaysPassed.GetValue()
EndFunction

; ------------------------------------------------------------------------------
;                               Global functions                                
; ------------------------------------------------------------------------------

cfl_config Function GetConfig() global
    return Quest.GetQuest("cfl_Config") as cfl_config
Endfunction

cfl_lolaMain Function GetCflLola() global
    return Quest.GetQuest("cfl_Main") as cfl_lolaMain
Endfunction


; ------------------------------------------------------------------------------
;                                    Events                                     
; ------------------------------------------------------------------------------
; Event OnInit()
;     Init(self)
; EndEvent


Function StartLolaExtension()
    Debug.Notification("Prepare Init coffee Lola Extenstion")
    Log("Prepare Init coffee Lola Extenstion")

    if cflLola.isRunning()
        Log("Lola Extension already running")
        Return
    endif

    Debug.Notification("Start Init coffee Lola Extenstion")
    Log("Prepare Init coffee Lola Extenstion")

    cflLola.Start()

    SetReferences()
    RegisterModEvents()
    ; Init the Other Functions

    if !cflLola.isRunning()
        Log("Lola Extension did not start", 2)
        Return
    endif

    locationTracker.Start()
    AliasTracker.Start()
    AliasTracker.Init()
    utFurniture.Init()
    utOutfit.Init()
    utDD.Init()
    cflLola.Init()

    (Quest.GetQuest("cfl_Config") as cfl_Configurator).Init()
    InitialStartupDone = True
    Utility.Wait(2)
    Debug.Notification("Lola Extension is searching for external Mods")
    Log("Check External Mods")
    ScanForMods()
    Log("Lola Extension Installed")
    Debug.Notification("Lola Extension Installed")
    cflLolaActive = True
EndFunction

Function StopLolaExtension()
    utFurniture.CleanUp()
    cflLola.Stop()
    AliasTracker.Stop()
    locationTracker.Stop()
    walkQuest.Stop()
    singleWalkQuest.Stop()
    cflStylishOwner.Stop()


    TaskOutfit.Stop()
    TaskOutfitStarter.Stop()
    TaskSleepDeny.Stop()
    TaskSalesPet.Stop()
    TaskSleepFurniture.Stop()
    TaskSleepGround.Stop()
    TaskSleepReward.Stop()
    TaskSleepKennel.Stop()
    TaskSleepBedSearch.Stop()
    lolaForSale.Stop()
    cflPublicWhore.Stop()
    cflPublicService.Stop()


endFunction

Event OnReloadReferences()
    Log("cfl_Config: Reference Reload")
    if LolaMonitor == None
        LolaMonitor = Quest.GetQuest("cfl_config") as cfl_LolaMonitor
    endif
    if LolaMonitor != None
        LolaMonitor.Init()
    endif
EndEvent

Event OnLolaStart()
    Log("Lola start detected")
    If cflLolaRunning
        ExtensionRunning = True
        Log("Addon Already running, just set Extension running")
        Debug.Notification("Extension already Running. Set as Active")
        return
    endif
    StartTime = GameDaysPassed.GetValue()
    OwnerStart = StartTime

    ; Lola on Sale preperation
    LoSNextStart = OwnerStart + LoSMinKeepTime

    cflLolaRunning = True
    ExtensionRunning = True
    Log("Lola start detected, call init")
    StartLolaExtension()
    FillLolaQuestForm()
Endevent

Event OnLolaStop()
    cflLolaRunning = False
    ExtensionRunning = False
    cflLolaActive = False
    StopLolaExtension()
Endevent

Function FillLolaQuestForm()
    addonQuestList = Game.GetFormFromFile(0x02FE5E ,"cfl_LolaAddon.esp") as Formlist
    ;lolaQuestList  = Game.GetFormFromFile(0x05C6B6 ,"submissivelola_est.esp") as Formlist
    
    DebugOutput("Fill Lola Quest Form")
    DebugOutput(addonQuestList)
    DebugOutput(lolaQuestList)
    
    int i = 0
    Quest q
    While (i < addonQuestList.GetSize())
        q = addonQuestList.GetAt(i) as Quest
        if lolaQuestList.Find(q) > 0
            lolaQuestList.AddForm(q)
        endif
        ; code
        i += 1
    EndWhile
EndFunction

; ------------------------------------------------------------------------------
;                                  Init Chain                                   
; ------------------------------------------------------------------------------

bool Property initRunning = False Auto
Function Init(Form from, bool wait = true)
    Log("init called from " + from)
    if initRunning
        Log("Init already running")
        Return
    endif
    initRunning = True
    
    Log("Wait 60 Seconds to give External Mods the Chance to fully load first")
    RegisterForSingleUpdate(60)
EndFunction

Event OnUpdate()
    Init_External_Stuff()
EndEvent

Function Init_External_Stuff()
    Log("Starting Full Init for Coffees Lola Extension")
    SetReferences()

    Utility.wait(2)
    Log("Init Utility DD")
    utDD.Init()
    utFurniture.Init()
    Log("Init Utility Furniture")
    utOutfit.Init()
    Log("Init Utility Outfit")

    Log("Register For Mod Events")
    RegisterModEvents()
    Log("Fill Lola Quest Formlist")
    FillLolaQuestForm()
    Log("Init Configurator")
    (Quest.GetQuest("cfl_Config") as cfl_Configurator).Init()
    Log("Scan For External Mods")
    ScanForMods()
    initRunning = False
    Log("Lola Extension Init Done")
    Debug.Notification("Lola Extension Init Done")

    if LolaQuestRunning
        Debug.Notification("Detect Lola already Running")
        SimulateLolaStart()
        Debug.Notification("Try Starting up the Addon by Simulating a fresh Start")
    endif

EndFunction

Function SimulateLolaStart()
    int handle = ModEvent.Create("cfeLola_LolaStart")
    If (Handle)
        ModEvent.Send(Handle)
    Endif
EndFunction

; ------------------------------------------------------------------------------
;                                  Const stuff                                  
; ------------------------------------------------------------------------------

String Property OUTFITJSONID = "0" Auto
String Property OUTFITJSONNEXT = "0" Auto

Int Property OUTFITSLUTTYPREFIX = 10000 Auto
Int Property OUTFITBREAKPREFIX = 20000 Auto
String Property OUTFITCLASSADVENTURE = "Adventuring" Auto
String Property OUTFITCLASSCAPITAL = "Capital" Auto
String Property OUTFITCLASSINN = "Inn" Auto
String Property OUTFITCLASSSETTLEMENT = "Settlement" Auto
String Property OUTFITCLASSHOME = "PlayerHome" Auto
