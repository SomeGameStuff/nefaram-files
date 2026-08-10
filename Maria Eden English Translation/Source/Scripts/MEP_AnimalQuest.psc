;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 4
Scriptname MEP_AnimalQuest Extends Quest Hidden

;BEGIN ALIAS PROPERTY follower6
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_follower6 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY any_dog
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_any_dog Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Hector
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Hector Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY helper
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_helper Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Follower
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Follower Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY any_horse
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_any_horse Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY party_candidate
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_party_candidate Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY to_follow
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_to_follow Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Slave
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Slave Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY follower8
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_follower8 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY follower7
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_follower7 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Follower2
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Follower2 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Follower4
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Follower4 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY busy1
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_busy1 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Follower1
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Follower1 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY follower_horse
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_follower_horse Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Follower3
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Follower3 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY busy4
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_busy4 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY busy3
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_busy3 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY follower5
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_follower5 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY PlayersHorse
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_PlayersHorse Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY busy2
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_busy2 Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
OnPlayerLoadGame()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
Cleanup()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN CODE
scene_done(None)
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

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Faction Property MariaBusyFaction Auto
Faction Property MariaFaction_Follower Auto
Faction Property MariaFaction_NoSex Auto
Faction Property MariaFaction_TemporaryActor Auto
Faction Property MariaFaction_AnimalFriend Auto
Faction Property MEPFaction_AnimalSexObserver Auto
Faction Property MEPFaction_AnimalMaster Auto
Faction Property MEPFaction_ExOralSex Auto
Faction Property MEPFaction_ExVaginalSex Auto
Faction Property MEPFaction_ExAnalSex Auto
Faction Property MEPFaction_SexAnimal Auto
Faction Property MEPFaction_AnimalSlave Auto
Faction Property MEPFaction_KnowPlayerAnimalSlave Auto
Faction Property MariaFaction_PlayerMaster Auto
Faction Property MEPFaction_OwnedByPimp Auto
Faction property HorseStaggerFaction auto

Faction Property MEPFaction_AnimalDogFucker Auto
Faction Property MEPFaction_AnimalHorseFucker Auto
Faction Property MEPFaction_AnimalFucker Auto

Faction Property DogFaction  Auto
Faction Property PredatorFaction  Auto

Faction Property sla_Arousal  Auto

GlobalVariable Property MariaPlayerPoseID Auto
GlobalVariable Property MEPAnimalFollowerCount Auto
GlobalVariable Property MEPAnimalDogCount Auto
GlobalVariable Property MEPAnimalHorseCount Auto
GlobalVariable Property MEPAnimalGotHector Auto
GlobalVariable Property MEPCurrentSexAnimalType Auto
GlobalVariable Property MEPMasterLikeAnimals Auto
GlobalVariable Property MEPAnimalGotRidingHorse Auto
GlobalVariable Property MEPAnimalFollowerGotHorse Auto
GlobalVariable Property MEPCumDropCounter Auto

MariaSexActorBase property fucktoy auto
MariaAnimationManager Property mam Auto
MariaRestraintsManager Property mrm Auto
MariaActorEffectManager Property mem Auto
Message Property MEPAnimalSlaveMessage Auto
Message Property MEPAnimalWrongPoseMessage Auto
Message Property MEPAnimalWrongClothesMessage Auto
Message Property MEPAnimalNeedSexMessage Auto
Message Property MEPAnimalSlaveNoFreedomMessage Auto
Message Property MEPYouNeedToFuckBeforeRidingMessage Auto
Message Property MEPYouNeedToBeNakedForRidingMessage Auto
MagicEffect Property MEPLubricanEffect Auto
Spell Property MariaNoSexSpell Auto
Actor property PlayerRef auto
Keyword Property ClothingBody Auto
Keyword Property ArmorCuirass Auto
Keyword Property ActorTypeUndead Auto
Keyword Property MariaClothingKitty Auto
Keyword Property MariaClothingPony Auto
Outfit Property HorseSaddleOutfit Auto
Outfit Property MariaEdenNakedOutfit Auto
FormList property MEPFuckAnimalList Auto
FormList property MEPFuckAnimalVoiceTypes Auto
Quest Property MEPLickCum Auto
SexLabFramework Property sexlab Auto

VoiceType Property CrDeerVoice Auto
VoiceType Property CrHorseVoice Auto
VoiceType Property CrWolfVoice Auto
VoiceType Property CrGoatVoice Auto
VoiceType Property CrBearVoice Auto
VoiceType Property DLC2CrBristlebackVoice Auto  ; wildschwein
VoiceType Property CrSabreCatVoice Auto
VoiceType Property CrDogDeathHound Auto
VoiceType Property CrDogHusky Auto
VoiceType Property CrDogVoice Auto
VoiceType Property CrFoxVoice Auto

VoiceType Property CrChaurusInsectVoice Auto
VoiceType Property CrChaurusVoice Auto
VoiceType Property CrCowVoice Auto
VoiceType Property CrDragonVoice Auto
VoiceType Property CrGargoyleVoice Auto
VoiceType Property CrHagravenVoice Auto
VoiceType Property CrHorkerVoice Auto
VoiceType Property CrMammothVoice Auto
VoiceType Property CrSkeeverVoice Auto
VoiceType Property CrSprigganVoice Auto
VoiceType Property CrTrollVoice Auto
VoiceType Property CrWerewolfVoice Auto
VoiceType Property CrFrostbiteSpiderVoice Auto
VoiceType Property CrFrostbiteSpiderGiantVoice Auto
VoiceType Property CrDwarvenSpiderVoice Auto

Book Property MEPAnimalSexBook Auto

Scene property MEPAnimalMasterAdopt auto
Scene property MEPAnimalMasterBlowjob auto
Scene property MEPAnimalMasterSex auto
Scene property MEPAnimalMasterGangbang auto
Scene Property MEPAnimalHelperSex Auto

ReferenceAlias[] Property followers  Auto

GlobalVariable Property MEPZoneWithRiding Auto

int property animal_category_dog = 1 AutoReadOnly
int property animal_category_horse = 2 AutoReadOnly
int property animal_category_wolf = 3 AutoReadOnly
int property animal_category_goat = 4 AutoReadOnly
int property animal_category_bear = 5 AutoReadOnly
int property animal_category_boar = 6 AutoReadOnly
int property animal_category_sabrecat = 7 AutoReadOnly
int property animal_category_deer = 8 AutoReadOnly
int property animal_category_fox = 9 AutoReadOnly

int property animal_category_small = 50 AutoReadOnly
int property animal_category_medium = 51 AutoReadOnly
int property animal_category_big = 52 AutoReadOnly

int property animal_category_dog_like = 20 AutoReadOnly

int property new_dog = 0 AutoReadOnly
int property new_dog_simple = 1 AutoReadOnly
int property new_dog_husky = 2 AutoReadOnly
int property new_dog_deathhound = 3 AutoReadOnly
int property new_horse = 4 AutoReadOnly
int property new_horse_shadowmere = 5 AutoReadOnly
int property new_bear = 6 AutoReadOnly
int property new_deer = 7 AutoReadOnly
int property new_elk = 8 AutoReadOnly
int property new_wolf = 9 AutoReadOnly
int property new_sabrecat = 10 AutoReadOnly
int property new_goat = 11 AutoReadOnly
int property new_fox = 12 AutoReadOnly
int property new_boar = 13 AutoReadOnly

Perk Property MEPTalkToAnimalPerk Auto
Keyword[] Property DeathAnimalLocations  Auto
Spell property DLC1abDeathHoundFx auto
Spell Property MEPDeathHoundChangeFX auto
ActorBase Property DLC1EncHusky Auto

Sound Property MariaSoundCough  Auto
Sound Property LFT_FemaleWheepingSound  Auto
Sound Property LFT_FemaleBreathingSound  Auto
Sound Property LFT_GulpSound  Auto
Sound Property LFT_PeeInMouthSound  Auto
Sound Property LFT_LubriciousLPSound  Auto

Package Property MEPAnimalRapePlayerPackage Auto

quest property MEPAnimalZone auto

ReferenceAlias Property pimp Auto
ReferenceAlias Property PlayersHorse Auto

function Trace(string text, bool show = false)
	Debug.Trace("@@@ PET :" + text)
    if show
	    Debug.Notification(text)
    endif
endfunction

Function startup()
    OnPlayerLoadGame()
EndFunction

event OnInit()
    if !PlayerRef.GetItemCount(MEPAnimalSexBook) && !PlayerRef.IsInFaction(MEPFaction_AnimalFucker)
        PlayerRef.AddItem(MEPAnimalSexBook)
    endif
endevent

function OnPlayerLoadGame()
    HorseStaggerFaction = PO3_SKSEFunctions.GetFormFromEditorID("HStag_StaggerFaction") as Faction

    if PlayerRef.HasPerk(MEPTalkToAnimalPerk)
        PlayerRef.RemovePerk(MEPTalkToAnimalPerk)
    endif

    if !sexlab.AllowCreatures
        release_all()
        return
    endif

    RegisterForModEvent("MEPAnimalManager", "OnAnimalManager")
    RegisterForModEvent("MariaFuckFinished","OnFucked")
    RegisterForModEvent("MEPAnimalTriggerSex","OnTriggerSex")
    RegisterForModEvent("MEPAnimalFollow","OnTriggerFollower")
    RegisterForModEvent("MEPAnimalCreate","OnCreateFollower")
    RegisterForModEvent("MEPAnimalReleaseAll","OnReleaseAllFollowers")
    if PlayerRef.IsInFaction(MariaFaction_AnimalFriend)
        RegisterForModEvent("MariaPoseChanged","OnPoseChanged")
    endif

    update_aliases()

    PlayerRef.AddPerk(MEPTalkToAnimalPerk)
endfunction

int Function getAnimalCategory(ActorBase animal)
    VoiceType vt = animal.GetVoiceType()
    if vt == CrDogVoice || vt == CrDogHusky || vt == CrDogDeathHound
        return animal_category_dog
    elseif vt == CrHorseVoice
        return animal_category_horse
    elseif vt == CrWolfVoice
        return animal_category_wolf
    elseif vt == CrGoatVoice
        return animal_category_goat
    elseif vt == CrBearVoice
        return animal_category_bear
    elseif vt == DLC2CrBristlebackVoice
        return animal_category_boar
    elseif vt == CrSabreCatVoice
        return animal_category_sabrecat
    elseif vt == CrDeerVoice
        return animal_category_deer
    elseif vt == CrFoxVoice
        return animal_category_fox
    elseif vt == CrChaurusInsectVoice
        return animal_category_small
    elseif vt == CrChaurusVoice
        return animal_category_medium
    elseif vt == CrCowVoice
        return animal_category_big
    elseif vt == CrDragonVoice
        return animal_category_big
    elseif vt == CrGargoyleVoice
        return animal_category_big
    elseif vt == CrHagravenVoice
        return animal_category_medium
    elseif vt == CrHorkerVoice
        return animal_category_medium
    elseif vt == CrMammothVoice
        return animal_category_big
    elseif vt == CrSkeeverVoice
        return animal_category_small
    elseif vt == CrSprigganVoice
        return animal_category_medium
    elseif vt == CrTrollVoice
        return animal_category_big
    elseif vt == CrWerewolfVoice
        return animal_category_big
    elseif vt == CrFrostbiteSpiderVoice
        return animal_category_medium
    elseif vt == CrFrostbiteSpiderGiantVoice
        return animal_category_big
    elseif vt == CrDwarvenSpiderVoice
        return animal_category_medium
    endif
    return 0
EndFunction

int function register(Actor animal)
    if !animal
        Debug.TraceStack("@@@ PET : register(none)")
        return 0
    endif

    ActorBase animalBase = animal.GetLeveledActorBase()
    Trace("register " + PO3_SKSEFunctions.GetFormEditorID(animalBase))

    int animalCategory = getAnimalCategory(animalBase)
    Trace("register category " + animalCategory)

    if animalCategory == 0
        animal.RemoveFromFaction(MEPFaction_SexAnimal)
        animal.RemoveFromFaction(MEPFaction_AnimalMaster)
        return 0
    endif

    if animalBase.GetSex() == 1
        Trace("register female animal")
        animal.RemoveFromFaction(MEPFaction_SexAnimal)
        animal.RemoveFromFaction(MEPFaction_AnimalMaster)
        return 0
    endif

    Race animalRace = animalBase.GetRace()
    Trace("register race " + animalRace.GetName())

    if !sexlab.AllowedCreature(animalRace)
        Trace("register non sexlab animal")
        animal.RemoveFromFaction(MEPFaction_SexAnimal)
        animal.RemoveFromFaction(MEPFaction_AnimalMaster)
        return 0
    endif

    int curCat = animal.GetFactionRank(MEPFaction_SexAnimal)
    if curCat != animalCategory
        animal.SetFactionRank(MEPFaction_SexAnimal, animalCategory)
    endif

    if !animalRace.AllowPCDialogue()
        animalRace.SetAllowPCDialogue()
    endif

    if animalCategory == animal_category_dog || animalCategory == animal_category_wolf || animalCategory == animal_category_bear
        if animalRace.CantOpenDoors()
            animalRace.ClearCantOpenDoors()
        endif
    endif

    return animalCategory
endfunction

int function find(Actor animal)
    int x = followers.Length
    int i
    while i < x
        if followers[i].GetReference() == animal
            return i
        endif
        i += 1
    endwhile
    return -1
endfunction

bool function is_actor_valid(Actor akActor)
    return akActor != None && !akActor.GetCurrentScene() && !akActor.IsInFaction(MariaBusyFaction)
endfunction

Actor function get_sex_candidate(int preferred_animal_category = 0, Actor skip = none, bool ignore_nosex = false)
    Actor hector = Alias_Hector.GetActorReference()

    if (preferred_animal_category == animal_category_dog || preferred_animal_category == animal_category_dog_like || preferred_animal_category == 0) && hector && hector != skip && !hector.IsInFaction(MariaFaction_NoSex) && is_actor_valid(hector)
        return hector
    endif

    int x = followers.Length
    int i
    Actor first_no_sex_candidate
    while i < x
        Actor candidate = followers[i].GetActorReference()
        if candidate && candidate != skip
            if preferred_animal_category
                int category = getAnimalCategory(candidate.GetLeveledActorBase())
                if preferred_animal_category == animal_category_dog_like
                    if category != animal_category_dog && category != animal_category_wolf
                        candidate = None
                    endif
                elseif preferred_animal_category != category
                    candidate = None
                endif
            endif
            if is_actor_valid(candidate)
                if ignore_nosex
                    return candidate
                endif
                if !candidate.IsInFaction(MariaFaction_NoSex)
                    return candidate
                endif
                if !first_no_sex_candidate
                    first_no_sex_candidate = candidate
                endif
            endif
        endif
        i += 1
    endwhile
    if first_no_sex_candidate
        return first_no_sex_candidate
    endif
    return None
endfunction


; if force is set, a non master or none dog or none horse is potientially released
bool function follow(Actor animal, bool force = false)
    if animal.IsInFaction(MariaFaction_Follower)
        ; is already follower
        return true
    endif

    int animal_category = register(animal)
    if !animal_category
        ; no sex animal
        return false
    endif

    ; sort out dead animals
    update_aliases()

    MEP_AnimalFollowerAlias animal_alias

    ; search free slot
    int x = followers.Length
    int i
    while i < x && !animal_alias
        if !followers[i].GetReference()
            animal_alias = followers[i] as MEP_AnimalFollowerAlias
        endif
        i += 1
    endwhile

    if !animal_alias
        ; no free slot
        if force
            i = 0
            ; 1st try = free one non masterslot
            while i < x && !animal_alias
                Actor old_animal = followers[i].GetActorReference()
                if !old_animal.IsInFaction(MEPFaction_AnimalMaster)
                    release(old_animal)
                    animal_alias = followers[i] as MEP_AnimalFollowerAlias
                endif
                i += 1
            endwhile
            ; 2nd try = free non dog, non horse
            i = 0
            while i < x && !animal_alias
                Actor old_animal = followers[i].GetActorReference()
                int old_cat = old_animal.GetFactionRank(MEPFaction_SexAnimal)
                if old_cat != animal_category_dog && old_cat != animal_category_horse
                    release(old_animal)
                    animal_alias = followers[i] as MEP_AnimalFollowerAlias
                endif
                i += 1
            endwhile

            if animal_alias
                animal_alias.Clear()
                animal_alias.update(false)
            else
                return false
            endif
        else
            return false
        endif
    endif

    animal_alias.ForceRefTo(animal)
    animal.SetPlayerTeammate(true, false)
    if animal.GetRelationshipRank(PlayerRef) < 0
        animal.SetRelationshipRank(PlayerRef, 0)
    endif
    update_aliases()

    return true
endfunction

int function update_aliases()
    Alias_party_candidate.Clear()
    int x = followers.Length
    int i
    int masters
    int animals
    int dogs
    int horses
    bool player_is_slave_of_all_animals = PlayerRef.IsInFaction(MariaFaction_AnimalFriend)
    Actor animal
    Actor dog
    Actor hector
    Actor horse
    while i < x
        MEP_AnimalFollowerAlias animal_alias = followers[i] as MEP_AnimalFollowerAlias
        animal = animal_alias.GetActorReference()
        if animal
            if animal.IsDead() || !register(animal)
                animal_alias.update(false)
                animal_alias.Clear()
                release(animal)
                animal = None
            elseif animal.IsInFaction(MEPFaction_AnimalMaster)
                masters += 1
                animal_alias.update(true)
            elseif player_is_slave_of_all_animals
                animal.AddToFaction(MEPFaction_AnimalMaster)
                animal_alias.update(true)
                masters += 1
            else
                animal_alias.update(false)
            endif
            if animal
                animals += 1
                int animal_category = animal.GetFactionRank(MEPFaction_SexAnimal)
                Trace("update category " + animal_category)
                if !hector && animal_category == animal_category_dog && get_animal_name(animal) == "Hector"
                    hector = animal
                    dogs += 1
                elseif animal_category == animal_category_dog
                    dogs += 1
                    dog = animal
                elseif animal_category == animal_category_horse
                    horses += 1
                    horse = animal
                endif
            endif
        endif
        i += 1
    endwhile
    MEPAnimalFollowerCount.SetValueInt(animals)
    MEPAnimalDogCount.SetValueInt(dogs)
    MEPAnimalHorseCount.SetValueInt(horses)
    if masters
        PlayerRef.AddToFaction(MEPFaction_AnimalSlave)
    else
        PlayerRef.RemoveFromFaction(MEPFaction_AnimalSlave)
    endif
    if hector
        Alias_Hector.ForceRefTo(hector)
        MEPAnimalGotHector.SetValueInt(1)
    else
        MEPAnimalGotHector.SetValueInt(0)
        Alias_Hector.Clear()
    endif
    if dog
        Alias_any_dog.ForceRefTo(dog)
    else
        Alias_any_dog.Clear()
    endif
    if horse
        Alias_any_horse.ForceRefTo(horse)
        if pimp.GetActorReference()
            horse.SetFactionOwner(MariaFaction_PlayerMaster)
            horse.AddToFaction(MEPFaction_OwnedByPimp)
        else
            horse.SetFactionOwner(None)
            horse.RemoveFromFaction(MEPFaction_OwnedByPimp)
        endif
    else
        Alias_any_horse.Clear()
    endif

    horse = Alias_PlayersHorse.GetActorReference()
    if horse
        if horse.IsDead()
            PlayersHorse.Clear()
            Alias_PlayersHorse.Clear()
        else
            Alias_any_horse.ForceRefTo(horse)
            (Alias_PlayersHorse as MEP_AnimalFollowerAlias).update(horse.IsInFaction(MEPFaction_AnimalMaster))
        endif
    endif
    return animals
endfunction

bool function unfollow(Actor animal, bool force = false)
    int x = followers.Length
    int i
    while i < x
        if followers[i].GetActorReference() == animal
            if !force && !animal.IsDead() && animal.IsInFaction(MEPFaction_AnimalMaster)
                return false
            endif
            release(animal)
            (followers[i] as MEP_AnimalFollowerAlias).cleanup()
            followers[i].Clear()
            update_aliases()
            return true
        endif
        i += 1
    endwhile
    Actor horse = Alias_PlayersHorse.GetActorReference()
    if animal == horse
        (Alias_PlayersHorse as MEP_AnimalFollowerAlias).cleanup()
        PlayersHorse.Clear()
        horse.MoveToMyEditorLocation()
    endif
    return false
endfunction

function release(Actor animal)
    Trace("release " + get_animal_name(animal))
    animal.RemoveFromFaction(MEPFaction_AnimalMaster)
    animal.RemoveFromFaction(MariaFaction_Follower)
    animal.SetActorValue("WaitingForPlayer",0)
    animal.SetPlayerTeammate(false)
    if Alias_Hector.GetActorReference() == animal
        Alias_Hector.Clear()
    endif
    if Alias_any_dog.GetActorReference() == animal
        Alias_any_dog.Clear()
    endif
    if Alias_any_horse.GetActorReference() == animal
        Alias_any_horse.Clear()
    endif
    if Alias_party_candidate.GetActorReference() == animal
        Alias_party_candidate.Clear()
    endif
    StorageUtil.UnsetStringValue(animal,"name")
endfunction

function become_master(Actor animal, bool silent = false)
    if !animal
        animal = Alias_busy2.GetActorReference()
    endif
    if !animal
        Debug.TraceStack("@@@ PET : become_master(none)")
        return
    endif
    int animal_category = register(animal)
    if ! animal_category
        Trace("become_master - no category")
        return
    endif

    scene_done(None)

    if animal_category == animal_category_dog && !Alias_Hector.GetReference()
        Trace("become_master set hector")
        set_animal_name(animal, "Hector")
    endif
    if follow(animal, true)
        if !animal.IsInFaction(MEPFaction_AnimalMaster)
            animal.AddToFaction(MEPFaction_AnimalMaster)
            if !silent
                MEPAnimalSlaveMessage.Show()
            endif
            update_aliases()
        endif
    else
        Trace("become_master follow failed")
        set_animal_name(animal,"")
    endif
endfunction

Function player_becomes_animal_friend()
    update_aliases()
    RegisterForModEvent("MariaPoseChanged","OnPoseChanged")
EndFunction

function increase_rank(Actor ref, Faction fac, int amount = 1)
    int rank = ref.GetFactionRank(fac)
    if rank <= 0
        rank = amount
    elseif rank < 127
        rank += amount
    endif
endfunction

function sex_failed()
    ; trigger scenes
    MariaPlayerPoseID.SetValueInt(mam.poseSex)
    MEPCurrentSexAnimalType.SetValueInt(0)
    Utility.Wait(1)
    MariaPlayerPoseID.SetValueInt(0)
    Trace("sex failed")
endfunction

bool function fuck(Actor animal)
    if sexlab.IsActorActive(PlayerRef) || sexlab.IsActorActive(animal) || !sexlab.AllowedCreature(animal.GetLeveledActorBase().GetRace())
        sex_failed()
        return false
    endif
    if PlayerRef.IsOnMount()
        PlayerRef.Dismount()
    endif
    MEPCumDropCounter.SetValueInt(0)
    fucktoy.PreSex()
    if fucktoy.AnimalVaginalFuck(animal,PlayerRef)
        Trace("fuck")
        MEPCurrentSexAnimalType.SetValueInt(animal.GetFactionRank(MEPFaction_SexAnimal))
        increase_rank(animal, MEPFaction_ExVaginalSex)
        return true
    endif
    sex_failed()
    return false
endfunction

bool function gang_fuck(Actor animal1, Actor animal2)
    if !animal1
        animal1 = Alias_busy2.GetActorReference()
    endif
    if !animal2
        animal2 = Alias_busy3.GetActorReference()
    endif
    Trace("gangbang " + get_animal_name(animal1) + " + " + get_animal_name(animal2))
    if sexlab.IsActorActive(PlayerRef) || sexlab.IsActorActive(animal1) || sexlab.IsActorActive(animal2) || !sexlab.AllowedCreatureCombination(animal1.GetLeveledActorBase().GetRace(), animal2.GetLeveledActorBase().GetRace())
        sex_failed()
        return false
    endif
    if PlayerRef.IsOnMount()
        PlayerRef.Dismount()
    endif
    fucktoy.PreSex()
    MEPCumDropCounter.SetValueInt(0)
    if fucktoy.AnimalGroupFuck(animal1, animal2, PlayerRef)
        MEPCurrentSexAnimalType.SetValueInt(animal1.GetFactionRank(MEPFaction_SexAnimal))
        increase_rank(animal1, MEPFaction_ExVaginalSex)
        increase_rank(animal2, MEPFaction_ExVaginalSex)
        return true
    endif
    sex_failed()
    return false
endfunction

bool function analfuck(Actor animal)
    if sexlab.IsActorActive(PlayerRef) || sexlab.IsActorActive(animal) || !sexlab.AllowedCreature(animal.GetLeveledActorBase().GetRace())
        sex_failed()
        return false
    endif
    if PlayerRef.IsOnMount()
        PlayerRef.Dismount()
    endif
    fucktoy.PreSex()
    MEPCumDropCounter.SetValueInt(0)
    if fucktoy.AnimalAnalFuck(animal,PlayerRef)
        MEPCurrentSexAnimalType.SetValueInt(animal.GetFactionRank(MEPFaction_SexAnimal))
        Trace("anal fuck")
        increase_rank(animal, MEPFaction_ExAnalSex)
        return true
    endif
    sex_failed()
    return false
endfunction

bool function blowjob(Actor animal)
    if sexlab.IsActorActive(PlayerRef) || sexlab.IsActorActive(animal) || !sexlab.AllowedCreature(animal.GetLeveledActorBase().GetRace())
        sex_failed()
        return false
    endif
    if PlayerRef.IsOnMount()
        PlayerRef.Dismount()
    endif
    fucktoy.PreSex()
    MEPCumDropCounter.SetValueInt(0)
    if fucktoy.AnimalBlowjob(animal,PlayerRef)
        Trace("blowjob")
        MEPCurrentSexAnimalType.SetValueInt(animal.GetFactionRank(MEPFaction_SexAnimal))
        increase_rank(animal, MEPFaction_ExOralSex)
        return true
    endif
    sex_failed()
    return false
endfunction

bool function cunnilingus(Actor animal)
    if sexlab.IsActorActive(PlayerRef) || sexlab.IsActorActive(animal) || !sexlab.AllowedCreature(animal.GetLeveledActorBase().GetRace())
        sex_failed()
        return false
    endif
    if PlayerRef.IsOnMount()
        PlayerRef.Dismount()
    endif
    fucktoy.PreSex()
    if fucktoy.AnimalLickPussy(animal,PlayerRef)
        MEPCurrentSexAnimalType.SetValueInt(animal.GetFactionRank(MEPFaction_SexAnimal))
        return true
    endif
    sex_failed()
    return false
endfunction

bool function rape(Actor animal)
    if fucktoy.VaginalFuckOK()
        return fuck(animal)
    elseif fucktoy.AnalFuckOK()
        return analfuck(animal)
    elseif fucktoy.OralSexOK()
        return blowjob(animal)
    endif
    return false
endfunction

bool Function dick_in_mouth(Actor dog, float timer = 99999.0)
    sslBaseAnimation animation = sexlab.GetCreatureAnimationByRegistry("B_Can_B_BlwBJ")
    if !animation
        return false
    endif
    sslThreadModel Thread = sexlab.NewThread()
	if !Thread
		return false
	endIf

    int stage_count = animation.StageCount
    ;/
	float[] timers = Utility.CreateFloatArray(stage_count)
	int i
	while i < stage_count
		timers[i] = 0.1
		i += 1
	endwhile

	timers[stage_count - 1] = 99999.0
    /;

	Thread.AddActor(PlayerRef,true)
	Thread.AddActor(dog,false)
	Thread.AddAnimation(animation)
	Thread.CenterOnObject(PlayerRef)
	Thread.DisableBedUse(true)
	;Thread.SetTimers(timers)
	Thread.DisableLeadIn(true)
    Thread.AutoAdvance = false
    Thread.Stage = stage_count - 2
	return Thread.StartThread()
EndFunction

Quest callback_quest
int callback_stage

MEP_AnimalVars Property vars Auto

function scene_update_vars()
    vars.anal_plug = mrm.GetCurrentAnalPlug(PlayerRef)
    vars.vaginal_plug = mrm.GetCurrentVaginalPlug(PlayerRef)
    vars.belt = mrm.GetCurrentBelt(PlayerRef)

    vars.was_bound = mrm.AreArmsRestrained(PlayerRef) as int
    vars.was_plugged = (vars.anal_plug != None || vars.vaginal_plug != None || vars.belt != None) as int
    vars.was_gagged = mrm.IsBallGagged(PlayerRef) as int
    if vars.was_gagged
        vars.gag = mrm.GetCurrentGag(PlayerRef) as Armor
    else
        vars.gag = None
    endif
endfunction

function scene_remove_plugs()
    if vars.anal_plug || vars.vaginal_plug || vars.belt
        Debug.SendAnimationEvent(Alias_busy1.GetActorReference(),"IdleLockPick")
    endif
    if vars.belt
        mrm.UnequipRestraint(PlayerRef, vars.belt)
    endif
    if vars.anal_plug
        mrm.UnequipRestraint(PlayerRef, vars.anal_plug)
    endif
    if vars.vaginal_plug
        mrm.UnequipRestraint(PlayerRef, vars.vaginal_plug)
    endif
endfunction

function scene_restore_plugs()
    if vars.anal_plug || vars.vaginal_plug || vars.belt
        Debug.SendAnimationEvent(Alias_busy1.GetActorReference(),"IdleLockPick")
    endif
    if vars.anal_plug
        mrm.EquipRestraint(PlayerRef, vars.anal_plug)
    endif
    if vars.vaginal_plug
        mrm.EquipRestraint(PlayerRef, vars.vaginal_plug)
    endif
    if vars.belt
        mrm.UnequipRestraint(PlayerRef, vars.belt)
    endif
endfunction

function scene_remove_gag(bool add_ring_gag = true)
    if vars.gag || add_ring_gag
        Debug.SendAnimationEvent(Alias_busy1.GetActorReference(),"MariaAddGag")
    endif
    if vars.gag
        mrm.UnequipRestraint(PlayerRef, vars.gag)
    endif
    if add_ring_gag
        mrm.EquipRingGag(PlayerRef)
    endif
endfunction

function scene_restore_gag()
    if mrm.IsGagged(PlayerRef) || vars.gag
        Debug.SendAnimationEvent(Alias_busy1.GetActorReference(),"MariaAddGag")
    endif
    mrm.UnEquipGag(PlayerRef)
    if vars.gag
        mrm.EquipRestraint(PlayerRef, vars.gag)
    endif
endfunction

bool function scene_sex(Actor master, Actor animal, Quest callbackQuest, int callbackStage)
    if !animal
        animal = get_sex_candidate(animal_category_dog_like)
        if !animal
            animal = get_sex_candidate()
        endif
        if !animal
            return false
        endif
    elseif !register(animal)
        return false
    endif
    callback_quest = callbackQuest
    callback_stage = callbackStage
    Alias_busy1.ForceRefTo(master)
    Alias_busy2.ForceRefTo(animal)
    scene_update_vars()
    if master.IsOnMount()
        master.Dismount()
    endif
    bool ok = MEP_QuestManager.Start(MEPAnimalMasterSex)
    if ok
        master.AddToFaction(MEPFaction_AnimalSexObserver)
    else
        Alias_busy1.Clear()
        Alias_busy2.Clear()
    endif
    return ok
endfunction

bool function scene_blowjob(Actor master, Actor animal, Quest callbackQuest, int callbackStage)
    if !animal
        animal = get_sex_candidate(animal_category_dog_like)
        if !animal
            animal = get_sex_candidate()
        endif
        if !animal
            return false
        endif
    elseif !register(animal)
        return false
    endif
    callback_quest = callbackQuest
    callback_stage = callbackStage
    Alias_busy1.ForceRefTo(master)
    Alias_busy2.ForceRefTo(animal)
    scene_update_vars()
    if master.IsOnMount()
        master.Dismount()
    endif
    bool ok = MEP_QuestManager.Start(MEPAnimalMasterBlowjob)
    if ok
        master.AddToFaction(MEPFaction_AnimalSexObserver)
    else
        Alias_busy1.Clear()
        Alias_busy2.Clear()
    endif
    return ok
endfunction

bool function scene_gangbang(Actor animal1, Actor animal2, Actor master, Quest callbackQuest, int callbackStage)
    if !register(animal1) || !register(animal2)
        return false
    endif
    callback_quest = callbackQuest
    callback_stage = callbackStage
    Alias_busy1.ForceRefTo(master)
    Alias_busy2.ForceRefTo(animal1)
    Alias_busy3.ForceRefTo(animal2)
    scene_update_vars()
    if master.IsOnMount()
        master.Dismount()
    endif
    bool ok = MEP_QuestManager.Start(MEPAnimalMasterGangbang)
    if ok
        master.AddToFaction(MEPFaction_AnimalSexObserver)
    else
        Alias_busy1.Clear()
        Alias_busy2.Clear()
        Alias_busy3.Clear()
    endif
    return ok
endfunction

bool function scene_helper_sex(Actor master, Actor helper, Actor animal, Quest callbackQuest, int callbackStage)
    if !animal
        animal = get_sex_candidate(animal_category_dog_like)
        if !animal
            animal = get_sex_candidate()
        endif
        if !animal
            return false
        endif
    endif
    callback_quest = callbackQuest
    callback_stage = callbackStage
    Alias_busy1.ForceRefTo(master)
    Alias_busy2.ForceRefTo(animal)
    Alias_busy3.ForceRefTo(helper)
    scene_update_vars()
    bool ok = MEP_QuestManager.Start(MEPAnimalHelperSex)
    if ok
        master.AddToFaction(MEPFaction_AnimalSexObserver)
        helper.AddToFaction(MEPFaction_AnimalSexObserver)
    else
        Alias_busy1.Clear()
        Alias_busy2.Clear()
        Alias_busy3.Clear()
    endif
endfunction

; job: -1 = random, 0 = fuck, 1 = blowjob
bool function trigger_sex(Actor animal, int job = -1, Actor master = none)
    if !master
        master = pimp.GetActorReference()
    endif
    if job < 0
        job = Utility.RandomInt(0,1)
    endif
    bool ok
    if master && !PlayerRef.GetCurrentScene() && !master.GetCurrentScene() && master.IsNearPlayer() && !PlayerRef.IsInFaction(MariaBusyFaction) && !master.IsInFaction(MariaBusyFaction)
        if job == 1
            ok = scene_blowjob(master, animal, None, 0)
        else
            ok = scene_sex(master, animal, None, 0)
        endif
    else
        if job == 1
            blowjob(animal)
        else
            if fucktoy.VaginalFuckOK()
                return fuck(animal)
            elseif fucktoy.AnalFuckOK()
                return analfuck(animal)
            endif
        endif
    endif
endfunction

bool function trigger_gangbang(Actor master = none)
    if !master
        master = pimp.GetActorReference()
    endif

    Actor animal1 = get_most_aroused(animal_category_dog)
    if !animal1
        Trace("gangbang failed, no animal1")
        return false
    endif

    Actor animal2 = get_most_aroused(animal_category_dog, animal1)
    if !animal2
        Trace("gangbang failed, no animal2")
        return false
    endif

    bool ok
    if master && !PlayerRef.GetCurrentScene() && !master.GetCurrentScene() && master.IsNearPlayer() && !PlayerRef.IsInFaction(MariaBusyFaction) && !master.IsInFaction(MariaBusyFaction)
        ok = scene_gangbang(animal1, animal2, master, None, 0)
    else
        ok = gang_fuck(animal1, animal2)
    endif

    return ok
endfunction

function sex_done()
endfunction

event OnTriggerSex(string eventName, string strArg, float perform_blowjob, Form fucker)
    Actor animal = fucker as Actor
    trigger_sex(animal, (perform_blowjob == 1) as int)
endevent

bool function scene_follow(Actor master, Actor animal, Quest callbackQuest, int callbackStage)
    int animal_category = register(animal)
    if !animal_category
        return false
    endif
    callback_quest = callbackQuest
    callback_stage = callbackStage
    Alias_busy1.ForceRefTo(master)
    Alias_busy2.ForceRefTo(animal)
    scene_update_vars()
    if master.IsOnMount()
        master.Dismount()
    endif
    bool ok = MEP_QuestManager.Start(MEPAnimalMasterAdopt)
    if ok
        master.AddToFaction(MEPFaction_AnimalSexObserver)
        master.AddToFaction(MEPFaction_KnowPlayerAnimalSlave)
    else
        Alias_busy1.Clear()
        Alias_busy2.Clear()
    endif
    return ok
endfunction

function trigger_follower(Actor animal, bool silent, bool enslave = false)
    if !register(animal)
        return
    endif
    if silent
        if enslave
            become_master(animal,silent)
        else
            follow(animal)
        endif
        return
    endif

    Actor master = pimp.GetActorReference()
    if master && !PlayerRef.GetCurrentScene() && !master.GetCurrentScene() && master.IsNearPlayer()
        scene_follow(master, animal, None, 0)
    else
        if enslave
            become_master(animal,silent)
        else
            follow(animal)
        endif
    endif
endfunction

event OnTriggerFollower(string eventName, string strArg, float silent, Form newFollower)
    Actor animal = newFollower as Actor
    if register(animal) && !animal.IsInFaction(MariaFaction_Follower)
        trigger_follower(animal, silent == 1, strArg == "slave")
    endif
endevent

; type + 100 = direct type
; type 0 = ask for category
; type 1 = category
event OnCreateFollower(string eventName, string strArg, float type, Form sender)
    bool enslave = strArg == "slave"
    int selection = type as int
    Actor animal
    Actor seller = sender as Actor
    if selection >= 100
        selection -= 100
        animal = Create(type = selection,follower = true, master = enslave)
    else
        animal = Create(category = selection,follower = true, master = enslave)
    endif
    if animal && seller
        seller.AddToFaction(MEPFaction_KnowPlayerAnimalSlave)
    endif
endevent

function scene_done(Scene theScene)
    after_sex()
    if theScene == MEPAnimalMasterAdopt
        become_master(Alias_busy2.GetActorReference(), true)
    endif
    if callback_quest
        if callback_stage
            callback_quest.SetStage(callback_stage)
        else
            MEP_QuestManager.Start(callback_quest)
        endif
    endif
    callback_quest = None
    callback_stage = 0
    Actor lead = Alias_busy1.GetActorReference()
    if lead
        lead.ClearLookAt()
    endif
    Alias_busy1.Clear()
    Alias_busy2.Clear()
    Alias_busy3.Clear()
    if MEPAnimalZone.IsRunning()
        MEPAnimalZone.Stop()
        MEPAnimalZone.Start()
    endif
    Actor master = pimp.GetActorReference()
    if master && MEPCumDropCounter.GetValueInt() > 0 && master.IsNearPlayer()
        MEP_QuestManager.Start(MEPLickCum)
    endif
endfunction

function piss(Actor animal)
    if PlayerRef.IsOnMount()
        PlayerRef.Dismount()
    endif
    mam.ResetPose(PlayerRef)
    Utility.Wait(1)
    mam.SetPose(PlayerRef,mam.poseLayDown)
	MariasUtils.OpenMouth(PlayerRef)
    Debug.SendAnimationEvent(animal, "SOSBend2")
    animal.SetDontMove(true)
    animal.SetUnconscious()
    if mrm.AreArmsRestrained(PlayerRef)
        MariasUtils.PlaceInFrontOf(animal,PlayerRef,65)
    else
        MariasUtils.PlaceBehind(animal,PlayerRef,65)
        MariasUtils.RotateAway(animal,PlayerRef)
    endif
    Debug.SendAnimationEvent(animal,"idleLayStart")
    Utility.Wait(3)
	LFT_PeeInMouthSound.PlayAndWait(PlayerRef)
    animal.SetDontMove(false)
    animal.SetUnconscious(false)
	MariasUtils.CloseMouth(PlayerRef)
	mam.ResetPose(PlayerRef)
	mam.ResetPose(animal)
    Debug.SendAnimationEvent(animal, "SOSFlaccid")

    int id = ModEvent.Create("MiniNeedsSetValue")
	ModEvent.PushString(id,"Drink")
	ModEvent.PushInt(id, 60)
	ModEvent.Send(id)
	LFT_GulpSound.PlayAndWait(PlayerRef)
    Debug.SendAnimationEvent(PlayerRef,"IdleUncontrollableCough")
    MariaSoundCough.PlayAndWait(PlayerRef)
endfunction

function lickass(Actor animal)
    if PlayerRef.IsOnMount()
        PlayerRef.Dismount()
    endif
    mam.ResetPose(PlayerRef)
    Utility.Wait(1)
    mam.SetPose(PlayerRef,mam.poseLayDown)
	MariasUtils.OpenMouth(PlayerRef)
    animal.SetDontMove(true)
    animal.SetUnconscious()
    if mrm.AreArmsRestrained(PlayerRef)
        MariasUtils.PlaceInFrontOf(animal,PlayerRef,65)
    else
        MariasUtils.PlaceBehind(animal,PlayerRef,65)
        MariasUtils.RotateAway(animal,PlayerRef)
    endif
    Debug.SendAnimationEvent(animal,"idleLayStart")
    Utility.Wait(3)
	LFT_LubriciousLPSound.PlayAndWait(PlayerRef)
    animal.SetDontMove(false)
    animal.SetUnconscious(false)
	MariasUtils.CloseMouth(PlayerRef)
	mam.ResetPose(PlayerRef)
	mam.ResetPose(animal)
endfunction

function sleep(Actor animal)
    if PlayerRef.IsOnMount()
        PlayerRef.Dismount()
    endif
    mam.ResetPose(PlayerRef)
    mam.SetPose(PlayerRef,mam.poseLayDown)
	MariasUtils.OpenMouth(PlayerRef)
    animal.SetDontMove(true)
    animal.SetUnconscious()
    if mrm.AreArmsRestrained(PlayerRef)
        MariasUtils.PlaceInFrontOf(animal,PlayerRef,65)
    else
        MariasUtils.PlaceBehind(animal,PlayerRef,65)
        MariasUtils.RotateAway(animal,PlayerRef)
    endif
    Debug.SendAnimationEvent(animal,"IdleSleep")
    Utility.Wait(60)
    animal.SetDontMove(false)
    animal.SetUnconscious(false)
	MariasUtils.CloseMouth(PlayerRef)
	mam.ResetPose(PlayerRef)
	mam.ResetPose(animal)
endfunction

bool function talk(Actor victim, Actor animal)
    Actor rider = PO3_SKSEFunctions.GetRider(animal)
    if rider
        if rider == victim
            victim.Dismount()
        else
            Debug.Notification("Talk to " + rider.GetDisplayName())
            rider.Activate(victim)
        endif
        return false
    endif

    if victim == None
        victim = PlayerRef
    elseif victim != PlayerRef
        return false
    endif

    bool is_aroused
    bool should_rape

    if animal.IsDead()
        unfollow(animal)
        return false
    endif

    int animalCategory = register(animal)

    if !animalCategory
        return false
    endif

    if MEPAnimalMasterGangbang.IsPlaying()
        if animal != Alias_busy2.GetActorReference() && animal != Alias_busy3.GetActorReference()
            Trace("Talk to non gangbang partner")
            return false
        endif

        UIListMenu menu = UIExtensions.GetMenu("UIListMenu", true) as UIListMenu
        menu.ResetMenu()
        int ret
        if is_master
            menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_START_PARTY_MASTER"), 103)
        else
            menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_START_PARTY"), 103)
        endif
        menu.OpenMenu()
        int i = menu.GetResultInt()
        if i < 0
            return false
        endif
        gang_fuck(none, none)
        return true
    endif

    bool is_master = animal.IsInFaction(MEPFaction_AnimalMaster)
    bool is_follower = animal.IsInFaction(MariaFaction_Follower)
    bool player_is_slave_of_all_animals = PlayerRef.IsInFaction(MariaFaction_AnimalFriend)
    bool is_riding = PlayerRef.IsOnMount()
    bool is_naked = !MESKSEUtils.WornHasKeyword(PlayerRef,ClothingBody) && !MESKSEUtils.WornHasKeyword(PlayerRef,ArmorCuirass)
    Actor party_candidate = Alias_party_candidate.GetActorReference()
    bool is_party_animal = party_candidate == animal
    bool can_join_party
    if party_candidate && !is_party_animal
        can_join_party = sexlab.AllowedCreatureCombination(party_candidate.GetLeveledActorBase().GetRace(),animal.GetLeveledActorBase().GetRace())
    endif
    Actor master = pimp.GetActorReference()
    if master && (PlayerRef.GetCurrentScene() || master.GetCurrentScene() || !master.IsNearPlayer())
        master = None
    endif

    if animalCategory == animal_category_horse && !is_naked
        is_naked = MESKSEUtils.WornHasKeyword(PlayerRef,MariaClothingPony)
    elseif animalCategory == animal_category_dog && !is_naked
        is_naked = MESKSEUtils.WornHasKeyword(PlayerRef,MariaClothingKitty)
    endif

    if !is_riding && !is_master && player_is_slave_of_all_animals && is_follower
        become_master(animal)
        is_master = true
    endif

    bool is_riding_horse
    if animalCategory == animal_category_horse
        is_riding_horse = animal == Alias_PlayersHorse.GetActorReference()
    endif

    int pose = MariaPlayerPoseID.GetValueInt()
    if is_master && !is_riding
        if pose != 1 && pose != 5 && pose != 4 && pose != 250
            MEPAnimalWrongPoseMessage.Show()
            return false
        endif
        if !is_naked
            MEPAnimalWrongClothesMessage.Show()
            return false
        endif
        is_aroused = !animal.IsInFaction(MariaFaction_NoSex) && animal.GetFactionRank(sla_Arousal) > 50
        if is_aroused
            should_rape = !animal.GetCurrentScene() && !PlayerRef.GetCurrentScene()
        endif
    endif

    if should_rape && rape(animal)
        return true
    endif


    UIListMenu menu = UIExtensions.GetMenu("UIListMenu", true) as UIListMenu
    menu.ResetMenu()
    int ret

    bool is_gagged = mrm.IsGagged(PlayerRef)
    bool is_cuffed = mrm.IsCuffed(PlayerRef)
    bool is_blindfolded = mrm.IsBlindfolded(PlayerRef)
    bool is_pussy_blocked = mrm.IsWearingBelt(PlayerRef) || mrm.IsWearingVaginalPlug(PlayerRef)
    bool anal_ok = fucktoy.AnalFuckOK()
    bool vaginal_ok = fucktoy.VaginalFuckOK()

    if is_gagged
        if pose == mam.poseAnal
            fuck(animal)
        elseif pose == mam.poseDoggy
            analfuck(animal)
        elseif pose == mam.poseKneel
            if mrm.IsRingGagged(PlayerRef)
                blowjob(animal)
            else
                fuck(animal)
            endif
        endif
        return true
    elseif PlayerRef.IsOnMount() ; && animal.IsBeingRidden()
        menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_STOP_RIDING"), 463)
    else
        bool isWaiting = animal.GetActorValue("WaitingForPlayer") != 0

        if is_party_animal
            if is_master
                menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_STOP_PARTY_MASTER"), 102)
            else
                menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_STOP_PARTY"), 102)
            endif
        elseif party_candidate && can_join_party
            if is_master
                menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_START_PARTY_MASTER"), 103)
            else
                menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_START_PARTY"), 103)
            endif
        endif

        if !party_candidate && anal_ok
            if is_master
                menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_FUCK_ME_MASTER"),1)
                menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_LICK_CUNT_MASTER"),71)
            else
                menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_FUCK_ME"),1)
                menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_LICK_CUNT"),71)
            endif
        endif
        if !party_candidate && vaginal_ok
            if is_master
                menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_FUCK_ME_ANAL_MASTER"),100)
            else
                menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_FUCK_ME_ANAL"),100)
            endif
        endif
        if !party_candidate && vaginal_ok || anal_ok
            if is_master
                menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_INVITE_TO_PARTY_MASTER"),101)
            else
                menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_INVITE_TO_PARTY"),101)
            endif
        endif
        if !party_candidate && fucktoy.OralSexOK()
            if is_master
                menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_LET_ME_BLOW_MASTER"),2)
                menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_PISS_MASTER"),72)
                menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_LICK_ASS_MASTER"),73)
            else
                menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_LET_ME_BLOW"),2)
                menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_PISS"),72)
                menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_LICK_ASS"),73)
            endif
        endif
        if !party_candidate && !is_follower
            if is_master
                menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_FOLLOW_ME_MASTER"),3)
            else
                menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_FOLLOW_ME"),3)
            endif
        elseif !party_candidate
            if !is_master || is_riding_horse
                menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_GO_HOME"),4)
            endif
            if isWaiting
                if is_master
                    menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_FOLLOW_ME_MASTER"),6)
                else
                    menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_FOLLOW_ME"),6)
                endif
            else
                if is_master
                    menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_WAIT_HERE_MASTER"),5)
                else
                    menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_WAIT_HERE"),5)
                endif
            endif
        endif
        if !party_candidate && animalCategory == animal_category_horse && !is_cuffed && !master
            if animal.GetLeveledActorBase().GetOutfit() == HorseSaddleOutfit
                if is_master
                    menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_REMOVE_SADDLE_MASTER"),8)
                else
                    menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_REMOVE_SADDLE"),8)
                endif
            else
                if is_master
                    menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_ADD_SADDLE_MASTER"),7)
                else
                    menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_ADD_SADDLE"),7)
                endif
            endif
            if MEPZoneWithRiding.GetValueInt()
                if is_master && !is_blindfolded
                    menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_LET_ME_RIDE_MASTER"),9)
                else
                    menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_LET_ME_RIDE"),9)
                endif
            endif
        endif
        if !party_candidate && !is_master
            menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_ENSLAVE_ME"),10)
        endif
    endif

    menu.OpenMenu()
    int i = menu.GetResultInt()
    if i < 0
        return false
    endif
    if i == 1
        Alias_party_candidate.Clear()
        fuck(animal)
    elseif i == 2
        Alias_party_candidate.Clear()
        blowjob(animal)
    elseif i == 100
        Alias_party_candidate.Clear()
        analfuck(animal)
    elseif i == 101
        Alias_party_candidate.ForceRefTo(animal)
    elseif i == 102
        Alias_party_candidate.Clear()
        rape(animal)
    elseif i == 103
        Alias_party_candidate.Clear()
        gang_fuck(animal, party_candidate)
    elseif i == 3
        if master
            trigger_follower(animal, false)
        else
            follow(animal)
        endif
    elseif i == 71
        Alias_party_candidate.Clear()
        cunnilingus(animal)
    elseif i == 72
        Alias_party_candidate.Clear()
        if animalCategory != animal_category_dog
            piss(animal)
        else
            dick_in_mouth(animal)
        endif
    elseif i == 73
        Alias_party_candidate.Clear()
        lickass(animal)
    elseif i == 4
        Alias_party_candidate.Clear()
        if is_riding_horse
            animal.SetActorValue("WaitingForPlayer",2)
            animal.EvaluatePackage()
        elseif is_master
            MEPAnimalSlaveNoFreedomMessage.Show()
        else
            unfollow(animal)
        endif
        elseif i == 5
        Alias_party_candidate.Clear()
        animal.SetActorValue("WaitingForPlayer",1)
        MariasUtils.DecreaseMood(animal, PlayerRef)
        animal.EvaluatePackage()
    elseif i == 6
        Alias_party_candidate.Clear()
        animal.SetActorValue("WaitingForPlayer",0)
        animal.EvaluatePackage()
    elseif i == 7
        Alias_party_candidate.Clear()
        animal.SetOutfit(HorseSaddleOutfit)
        animal.QueueNiNodeUpdate()
    elseif i == 8
        Alias_party_candidate.Clear()
        animal.SetOutfit(MariaEdenNakedOutfit)
        animal.UnequipAll()
        animal.RemoveAllItems()
        animal.QueueNiNodeUpdate()
    elseif i == 9
        Alias_party_candidate.Clear()
        if is_master && !animal.IsInFaction(MariaFaction_NoSex)
            MEPAnimalNeedSexMessage.Show()
            return false
        endif
        mam.ResetPose(PlayerRef)
        Utility.Wait(0.2)
        animal.Activate(PlayerRef, true)
        PlayerRef.SetVehicle(animal)
    elseif i == 463
        Alias_party_candidate.Clear()
        animal.Activate(PlayerRef, true)
        PlayerRef.Dismount()
        PlayerRef.SetVehicle(None)
    elseif i == 10
        Alias_party_candidate.Clear()
        if master
            trigger_follower(animal, false)
        else
            become_master(animal)
        endif
    endif
    return true
endFunction

ActorBase function SelectAnimal(int category = -1)
    int animals
    UIListMenu menu = UIExtensions.GetMenu("UIListMenu", true) as UIListMenu
    menu.ResetMenu()
    Form[] potentials = MEPFuckAnimalList.ToArray()
    int x = potentials.Length
    int i = 0
    while i < x
        ActorBase creatureBase = potentials[i] as ActorBase
        if category <= 0 || getAnimalCategory(creatureBase) == category
            if sexlab.AllowedCreature(creatureBase.GetRace())
                menu.SetPropertyIndexInt("entryId",menu.AddEntryItem(creatureBase.GetName()),i)
                animals += 1
            endif
        endif
        i += 1
    endwhile

    if animals == 0
        return None
    endif
    menu.OpenMenu()
    i = menu.GetResultInt()
    if i < 0
        return None
    endif
    return potentials[i] as ActorBase
endfunction

Actor function Create(int type = -1, int category = -1, ObjectReference where=None, bool visible = true, bool follower = false, bool master = false, string name="")
    if !sexlab.AllowCreatures
        return None
    endif
    ActorBase newAnimalBase
    if type < 0
        newAnimalBase = SelectAnimal(category)
        if !newAnimalBase
            return None
        endif
    else
        Form[] potentials = MEPFuckAnimalList.ToArray()
        newAnimalBase = potentials[type] as ActorBase
        if !sexlab.AllowedCreature(newAnimalBase.GetRace())
            return None
        endif
    endif
    if !where
        where = PlayerRef
    endif
    Actor animal = where.PlaceActorAtMe(newAnimalBase,0)
    if !visible
        animal.DisableNoWait()
    endif
    if name != ""
        animal.SetName(name)
        animal.SetDisplayName(name)
    endif
    animal.AddToFaction(MariaFaction_TemporaryActor)
    animal.SetRelationshipRank(PlayerRef,0)
    if master
        become_master(animal, true)
    elseif follower
        follow(animal)
    endif
    return animal
endfunction

event OnAnimalManager(string eventName, string strArg, float cheatID, Form sender)
    Manager()
endevent

string function get_animal_name(Actor animal)
    if animal == Alias_Hector.GetActorReference()
        return "Hector"
    endif
    string name = StorageUtil.GetStringValue(animal,"name","")
    if name == ""
        name = animal.GetName()
    endif
    if name == ""
        name = animal.GetDisplayName()
    endif
    if name == ""
        name = animal.GetLeveledActorBase().GetRace().GetName()
    endif
    return name
endfunction

function set_animal_name(Actor animal, string name)
    if name == ""
        StorageUtil.UnsetStringValue(animal,"name")
    else
        StorageUtil.SetStringValue(animal,"name", name)
    endif
endfunction

function Manager()
    int animal_count = update_aliases()
    int i
    UIListMenu menu = UIExtensions.GetMenu("UIListMenu", true) as UIListMenu
    menu.ResetMenu()
    menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("Update"), 0)
    menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("Reset"), 10)
    menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("Repair"), 20)
    menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_SPAWN_ANIMAL"), 1)
    if animal_count
        menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_FETCH_ALL"), 2)
        if MEPAnimalDogCount.GetValueInt() > 1
            menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_START_RANDOM_PARTY"), 3)
        endif
        menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_START_RANDOM_FUCK"), 4)
        menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_START_RANDOM_BLOWJOB"), 5)
        Actor animal
        int x = followers.Length
        int menuid
        i = 0
        while i < x
            animal = followers[i].GetActorReference()
            if animal
                menuid = 200 + i
                menu.SetPropertyIndexInt("entryId",menu.AddEntryItem(get_animal_name(animal),entryHasChildren = true), menuid)
                menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$ME_FETCH_HERE", menuid), 300 + i)
                menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$ME_JUMP_THERE", menuid), 400 + i)
                menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_RENAME_ANIMAL", menuid), 500 + i)
                menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_START_RANDOM_FUCK", menuid), 600 + i)
                menu.SetPropertyIndexInt("entryId",menu.AddEntryItem("$MEP_START_RANDOM_BLOWJOB", menuid), 700 + i)
            endif
            i += 1
        endwhile
    endif

    menu.OpenMenu()
    i = menu.GetResultInt()
    if i < 0
        return
    endif
    Trace("select " + i)

    if i == 0
        OnPlayerLoadGame()
    elseif i == 1
        Create()
    elseif i == 2
        fetch_all()
    elseif i == 3
        trigger_gangbang()
    elseif i == 4
        Actor animal = get_most_aroused()
        trigger_sex(animal, 0)
    elseif i == 5
        Actor animal = get_most_aroused()
        trigger_sex(animal, 1)
    elseif i == 10
        MEP_QuestManager.StartAfterDelay(2,self)
        Stop()
    elseif i == 20
        scene_done(None)
        update_aliases()
    elseif i >= 700
        i -= 700
        Actor animal = followers[i].GetActorReference()
        trigger_sex(animal, 0)
    elseif i >= 600
        i -= 600
        Actor animal = followers[i].GetActorReference()
        trigger_sex(animal, 1)
    elseif i >= 500
        i -= 500
        Actor animal = followers[i].GetActorReference()
        UITextEntryMenu editor = UIExtensions.GetMenu("UITextEntryMenu", true) as UITextEntryMenu
        editor.ResetMenu()
        editor.SetPropertyString("text",get_animal_name(animal))
        if editor.OpenMenu()
            string s = editor.GetResultString()
            if s != ""
                animal.SetName(s)
                animal.SetDisplayName(s)
                set_animal_name(animal, s)
                if s == "Hector"
                    update_aliases()
                endif
            endif
        endif
    elseif i >= 400
        i -= 400
        PlayerRef.MoveTo(followers[i].GetActorReference())
    elseif i >= 300
        i -= 300
        followers[i].GetActorReference().MoveTo(PlayerRef)
    endif
endfunction

function cleanup()
    int x = followers.Length
    int i
    int animals
    while i < x
        Actor animal = followers[i].GetActorReference()
        if animal
            release(animal)
        endif
        i += 1
    endwhile
    PlayerRef.RemoveFromFaction(MEPFaction_AnimalSlave)
endfunction

event OnFucked(Form theVictim,Form animal,Form ref2, Form ref3, string tags,int sexType,bool victimOrgasm, bool refOrgasm)
    if theVictim == PlayerRef as Form
        MEPCurrentSexAnimalType.SetValueInt(0)
    endif
    Actor fucker = animal as Actor
    if !fucker || sexType != 4
        return
    endif

    if StringUtil.Find(tags, "Cunnilingus") >= 0
        return
    endif

    int animal_category = getAnimalCategory(fucker.GetLeveledActorBase())

    MariaNoSexSpell.Cast(fucker, fucker)
    bool loved_it = mrm.IsCuffed(PlayerRef)
    if !loved_it
        if animal_category == animal_category_dog
            loved_it = MESKSEUtils.WornHasKeyword(PlayerRef,MariaClothingKitty)
        elseif animal_category == animal_category_horse
            loved_it = MESKSEUtils.WornHasKeyword(PlayerRef,MariaClothingPony)
        endif
    endif
    if loved_it
        fucker.SetActorValue("mood", 3)
        fucker.SetRelationShipRank(PlayerRef,4)
        Debug.Notification("$MEP_HE_LOVED_IT")
    else
        Debug.Notification("$MEP_HE_LIKED_IT")
    endif

    int schlong_size
    int animal_fuck_experience = PlayerRef.GetFactionRank(MEPFaction_AnimalFucker)

    if StringUtil.Find(tags, "Anal") < 0 && StringUtil.Find(tags, "Vaginal") < 0
        if StringUtil.Find(tags, "Oral") >= 0 || StringUtil.Find(tags, "Blowjob") >= 0 || StringUtil.Find(tags, "CumInMouth") >= 0
            mem.Caughing(PlayerRef)
        endif
        return
    endif

    if animal_category == animal_category_dog
        schlong_size = 1
        increase_rank(PlayerRef, MEPFaction_AnimalDogFucker)
    elseif animal_category == animal_category_horse
        schlong_size = 2
        increase_rank(PlayerRef, MEPFaction_AnimalHorseFucker)
    elseif animal_category == animal_category_bear
        schlong_size = 3
    elseif animal_category == animal_category_deer
        schlong_size = 2
    elseif animal_category == animal_category_sabrecat
        schlong_size = 2
    elseif animal_category == animal_category_goat
        schlong_size = 1
    elseif animal_category == animal_category_fox
        schlong_size = 1
    elseif animal_category == animal_category_wolf
        schlong_size = 1
    elseif animal_category == animal_category_boar
        schlong_size = 2
    elseif animal_category == animal_category_small
        schlong_size = 1
    elseif animal_category == animal_category_medium
        schlong_size = 2
    elseif animal_category == animal_category_big
        schlong_size = 3
    else
        schlong_size = 1
    endif

    increase_rank(PlayerRef, MEPFaction_AnimalFucker, schlong_size)

    int health = 100
    int damage

    if PlayerRef.HasMagicEffect(MEPLubricanEffect)
        animal_fuck_experience = 127
    endif

    if animal_fuck_experience < 20
        MariaActorEffectManager.MoodFear(PlayerRef)
        mem.AddTears(PlayerRef)
        damage = 20 * schlong_size
    elseif animal_fuck_experience < 50
        MariaActorEffectManager.MoodFear(PlayerRef)
        mem.AddTears(PlayerRef)
        damage = 10 * schlong_size
    elseif animal_fuck_experience < 80
        MariaActorEffectManager.MoodFear(PlayerRef)
        mem.AddTears(PlayerRef)
        damage = 5 * schlong_size
    else
        MariaActorEffectManager.MoodFear(PlayerRef)
        mem.AddTears(PlayerRef)
    endif

    if damage > 0
        health = MariaActorEffectManager.DamageButDontKill(PlayerRef, damage)
    endif

    if damage > 30
        mem.Wheeping(PlayerRef)
        mam.SetPose(PlayerRef, mam.poseBleedout)
    elseif damage > 20
        mem.Breathing(PlayerRef)
        mam.SetPose(PlayerRef, mam.poseFear)
    else
        mem.Breathing(PlayerRef)
    endif
endevent

Actor function find_first(int animal_category, bool master = false, string name="")
    int x = followers.Length
    int i
    int animals
    while i < x
        Actor animal = followers[i].GetActorReference()
        if animal && animal.GetFactionRank(MEPFaction_SexAnimal) == animal_category
            if master
                if animal.IsInFaction(MEPFaction_AnimalMaster)
                    if name != ""
                        if get_animal_name(animal) == name
                            return animal
                        endif
                    else
                        return animal
                    endif
                endif
            else
                if name != ""
                    if animal.GetName() == name
                        return animal
                    endif
                else
                    return animal
                endif
            endif
        endif
        i += 1
    endwhile
    return None
endfunction

; try to keep hector, or first master, or first dog
Actor function release_all_but(bool teleport = true, int animal_category = -1, string name = "Hector")
    if animal_category < 0
        animal_category = animal_category_dog
    endif
    Actor skip = find_first(animal_category, true, name)
    if !skip
        skip = find_first(animal_category, true)
    endif
    if !skip
        skip = find_first(animal_category)
    endif
    release_all(teleport, skip)
    return skip
endfunction

; remove all animals, teleport them back or destroy them, keep skip
function release_all(bool teleport = true, Actor skip = None)
    int x = followers.Length
    int i
    int animals
    while i < x
        Actor animal = followers[i].GetActorReference()
        if animal && animal != skip
            release(animal)
            followers[i].Clear()
            if teleport
                if animal.IsInFaction(MariaFaction_TemporaryActor)
                    animal.DisableNoWait()
                    animal.Delete()
                else
                    animal.MoveToMyEditorLocation()
                endif
            endif
        endif
        i += 1
    endwhile
    update_aliases()
endfunction

function i_wanna_fuck(Actor animal)
    trigger_sex(animal)
endfunction

function follow_me(Actor npc)
    Alias_to_follow.ForceRefTo(npc)
    int x = followers.Length
    int i
    string name = npc.GetDisplayName()
    while i < x
        Actor animal = followers[i].GetActorReference()
        if animal
            Trace(get_animal_name(animal) + " follows " + name)
            followers[i].Clear()
            followers[i].ForceRefTo(animal)
        endif
        i += 1
    endwhile
endfunction

function reset_follow()
    follow_me(PlayerRef)
endfunction

function set_enable_state(bool enable, Actor skip = None)
    int x = followers.Length
    int i
    while i < x
        Actor animal = followers[i].GetActorReference()
        if animal && animal != skip
            if enable
                animal.EnableNoWait()
            else
                animal.DisableNoWait()
            endif
        endif
        i += 1
    endwhile
endfunction

function set_wait_state(bool enable, Actor skip = None)
    int x = followers.Length
    int i
    while i < x
        Actor animal = followers[i].GetActorReference()
        if animal && animal != skip
            if enable
                animal.SetActorValue("WaitingForPlayer", 1)
            else
                animal.SetActorValue("WaitingForPlayer", 0)
            endif
            animal.EvaluatePackage()
        endif
        i += 1
    endwhile
endfunction

function fetch_all(bool ingore_waiting = false)
    Cell slave_cell = PlayerRef.GetParentCell()
    bool interior = slave_cell.IsInterior()
    bool shall_move
    int x = followers.Length
    int i
    while i < x
        Actor animal = followers[i].GetActorReference()
        if animal
            shall_move = false
            if interior && animal.GetLeveledActorBase().GetRace().CantOpenDoors()
                shall_move = false
            elseif animal.GetParentCell().IsInterior() != interior
                shall_move = true
            elseif animal.GetDistance(PlayerRef) > 2000
                shall_move = true
            endif
            if shall_move && !ingore_waiting && animal.GetActorValue("WaitingForPlayer") != 0
                shall_move = false
            endif
            if shall_move
                animal.MoveTo(PlayerRef)
            endif
        endif
        i += 1
    endwhile
endfunction

Actor function get_most_aroused(int category  = 0, Actor skip = none)
    Actor sex_partner
    int sex_partner_lust
    int lust
    Actor animal

    int x = followers.Length
    int i
    while i < x
        animal = followers[i].GetActorReference()
        if animal && animal != skip
            if !category || category == animal.GetFactionRank(MEPFaction_SexAnimal)
                lust = animal.GetFactionRank(sla_Arousal)
                if !sex_partner || lust >= sex_partner_lust
                    sex_partner = animal
                    sex_partner_lust = lust
                endif
            endif
        endif
        i += 1
    endwhile
    return sex_partner
endfunction

event OnPoseChanged(Form poser,int oldPose,int newPose)
	if (newPose == 4 || newPose == 5) && poser == PlayerRef && !MESKSEUtils.WornHasKeyword(PlayerRef,ClothingBody) && !MESKSEUtils.WornHasKeyword(PlayerRef,ArmorCuirass)
		Actor animal = MariasUtils.FindNearestActorByGender(2, PlayerRef, 500)
		if animal && !animal.IsInFaction(MariaBusyFaction) && !animal.IsInFaction(MariaFaction_NoSex) && register(animal)
			rape(animal)
		endif
	endif
endevent

event OnReleaseAllFollowers(string eventName, string strArg, float silent, Form newFollower)
    release_all()
endevent

function OnStartRiding()
    Actor horse =  PO3_SKSEFunctions.GetMount(PlayerRef)
    if !horse || horse.GetActorBase().GetVoiceType() != CrHorseVoice
        return
    endif
    bool isAnimalFriend = PlayerRef.IsInFaction(MariaFaction_AnimalFriend)
    if (isAnimalFriend || horse.IsInFaction(MEPFaction_AnimalMaster) || sexlab.Stats.HadPlayerSex(horse)) && !horse.IsInFaction(MariaFaction_NoSex)
        StopRiding(horse)
        return
    endif
    if isAnimalFriend && (MESKSEUtils.WornHasKeyword(PlayerRef,ClothingBody) || MESKSEUtils.WornHasKeyword(PlayerRef,ArmorCuirass))
        StopRiding(horse)
        return
    endif
    int i = find(horse)
    if i >= 0
        followers[i].Clear()
    else
        register(horse)
    endif
    horse.SetActorValue("WaitingForPlayer", 0)
    Alias_PlayersHorse.ForceRefTo(horse)
    MEPAnimalGotRidingHorse.SetValueInt(1)
endfunction

Actor forbiddenHorse
function StopRiding(Actor horse)
    Utility.Wait(2)
    forbiddenHorse = horse
    if HorseStaggerFaction
        PlayerRef.AddToFaction(HorseStaggerFaction)
        SPE_Actor.Dismount(PlayerRef)
    else
        PlayerRef.Dismount()
    endif
endfunction

event OnAnimationEvent(ObjectReference akSource, string asEventName)
endevent

function OnStopRiding()
    if forbiddenHorse
        MariaActorEffectManager.DamageButDontKill(PlayerRef,10)
        mem.Ouch(PlayerRef, true)
        if HorseStaggerFaction
            PlayerRef.RemoveFromFaction(HorseStaggerFaction)
        else
            Debug.SendAnimationEvent(PlayerRef,"LFT_StumbleAnimation")
            Utility.Wait(3)
        endif
        if forbiddenHorse.IsInFaction(MariaFaction_NoSex)
            MEPYouNeedToBeNakedForRidingMessage.Show()
        else
            MEPYouNeedToFuckBeforeRidingMessage.Show()
        endif
        forbiddenHorse = None
    endif
endfunction

QF_Stables_00068D73 Property stables Auto


Actor function ReleaseRidingHorse()
    Actor horse = Alias_PlayersHorse.GetActorReference()
    if !horse
        return None
    endif
    MEPAnimalGotRidingHorse.SetValueInt(0)
    Alias_PlayersHorse.Clear()
    ActorBase hostler
    if horse == stables.Alias_MarkarthHorse.GetActorReference()
        hostler = stables.Alias_MarkarthHostler.GetActorReference().GetLeveledActorBase()
    elseif horse == stables.Alias_WindhelmHorse.GetActorReference()
        hostler = stables.Alias_WindhelmHostler.GetActorReference().GetLeveledActorBase()
    elseif horse == stables.Alias_WhiterunHorse.GetActorReference()
        hostler = stables.Alias_WhiterunHostler.GetActorReference().GetLeveledActorBase()
    elseif horse == stables.Alias_RiftenHorse.GetActorReference()
        hostler = stables.Alias_RiftenHostler.GetActorReference().GetLeveledActorBase()
    elseif horse == stables.Alias_SolitudeHorse.GetActorReference()
        hostler = stables.Alias_SolitudeHostler.GetActorReference().GetLeveledActorBase()
    endif
    if horse.IsDead() && !hostler
        horse.MoveToMyEditorLocation()
        Actor newHorse = horse.PlaceActorAtMe(horse.GetLeveledActorBase())
        horse.DisableNoWait()
        horse.Delete()
        horse = newHorse
    endif
    horse.RemoveFromAllFactions()
    horse.SetFactionOwner(None)
    horse.SetActorValue("WaitingForPlayer",0)
    horse.SetActorOwner(hostler)
    MEPAnimalGotRidingHorse.SetValueInt(0)
    Alias_PlayersHorse.Clear()
    return horse
endfunction

Actor function TransferHorseOwnership(Actor receiver)
    Actor horse = ReleaseRidingHorse()
    if !horse
        return None
    endif
    if horse.GetActorOwner() != None
        Actor newHorse = horse.PlaceActorAtMe(horse.GetLeveledActorBase())
        horse.MoveToMyEditorLocation()
        horse = newHorse
    endif
    horse.SetActorValue("WaitingForPlayer",0)
    horse.SetActorOwner(receiver.GetLeveledActorBase())
    return horse
endfunction

function AssignHorseToFollower(Actor follower, Actor horse)
    register(horse)
    if Alias_follower_horse.GetActorReference()
        ClearFollowerHorse()
    endif
    if PlayersHorse.GetActorReference() == horse
        PlayersHorse.Clear()
    endif
    follow(horse, true)
    horse.SetActorValue("WaitingForPlayer",0)
    horse.SetActorOwner(None)
    horse.SetFactionOwner(MariaFaction_Follower)
    Alias_follower.ForceRefTo(follower)
    Alias_follower_horse.ForceRefTo(horse)
    MEPAnimalFollowerGotHorse.SetValueInt(1)
endfunction

Function ClearFollowerHorse()
    Alias_follower.Clear()
    Actor horse = Alias_follower_horse.GetActorReference()
    if horse
        Alias_follower_horse.Clear()
        horse.SetActorOwner(None)
        horse.SetFactionOwner(None)
        horse.RemoveFromFaction(MEPFaction_AnimalMaster)
        horse.SetActorValue("WaitingForPlayer",0)
        if !horse.IsDead()
            horse.MoveToMyEditorLocation()
        else
            horse.DisableNoWait()
            horse.Delete()
        endif
    endif
    MEPAnimalFollowerGotHorse.SetValueInt(0)
EndFunction

Actor function GetFollowerHorse()
    Actor horse = Alias_follower_horse.GetActorReference()
    if horse && horse.IsDead()
        ClearFollowerHorse()
        horse = None
    endif
    if horse
        MEPAnimalFollowerGotHorse.SetValueInt(1)
    endif
    return horse
endfunction

function FollowerHorseGoHome()
    Actor horse = GetFollowerHorse()
    if horse
        horse.SetActorValue("WaitingForPlayer",2)
        horse.EvaluatePackage()
    endif
endfunction

function FollowerHorseWait()
    Actor horse = GetFollowerHorse()
    if horse
        horse.SetActorValue("WaitingForPlayer",1)
        horse.EvaluatePackage()
    endif
endfunction

function FollowerHorseFollow()
    Actor horse = GetFollowerHorse()
    if horse
        horse.SetActorValue("WaitingForPlayer",0)
        horse.EvaluatePackage()
    endif
endfunction

event OnFreePlayer(string eventName = "", string arg_s = "", float argNum = 0.0, form sender = none)
    Reset()
endevent

function Reset()
    MEP_QuestManager.StartAfterDelay(2,self)
    Stop()
endfunction

Actor leadshHolder

function before_sex()
    leadshHolder = mrm.GetLeashHolder(PlayerRef)
    if leadshHolder
        mrm.StashLeash(PlayerRef)
    endif
endfunction

function after_sex()
    if leadshHolder
         mrm.UnstashLeash(PlayerRef)
         leadshHolder = None
    endif
endfunction
