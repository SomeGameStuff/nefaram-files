Scriptname NVLC_Controller extends Quest

Race Property DLC1VampireBeastRace Auto
Keyword Property LocTypeCity Auto
Keyword Property LocTypeTown Auto
Keyword Property LocTypeHabitation Auto
Keyword Property ActorTypeNPC Auto
GlobalVariable Property GameDaysPassed Auto
GlobalVariable Property NVLC_Heat Auto
GlobalVariable Property NVLC_Humanity Auto
GlobalVariable Property NVLC_Corruption Auto
GlobalVariable Property NVLC_LastTransformTime Auto
GlobalVariable Property NVLC_CrashSeverity Auto
ActorBase Property NVLC_DawnguardHunter Auto

Float Property UpdateIntervalGameHours = 0.0333333 Auto
Float Property HeatDecayPerDay = 5.0 Auto
Float Property AmbushCooldownDays = 1.0 Auto
Float Property MinorCrashHours = 2.0 Auto
Float Property ModerateCrashHours = 2.0 Auto
Float Property SevereCrashHours = 4.0 Auto

Bool trackingTransform = False
Float transformStartDay = 0.0
Float lastQuietDecayDay = 0.0
Float lastAmbushDay = 0.0
Int humanoidKillsThisTransform = 0

Int activeCrashTier = 0
Float activeCrashEndDay = 0.0
Float activeSpeedDelta = 0.0
Float activeStaminaRateDelta = 0.0
Float activeMagickaRateDelta = 0.0
Float activeSpeechDelta = 0.0
Float activeDamageResistDelta = 0.0
Float activeMagicResistDelta = 0.0

Int activeHumanityTier = 0
Float humanitySpeechDelta = 0.0
Float humanityMagickaRateDelta = 0.0
Float humanityDamageResistDelta = 0.0

Event OnInit()
	Maintenance()
EndEvent

Event OnPlayerLoadGame()
	Maintenance()
EndEvent

Function Maintenance()
	If NVLC_Humanity && NVLC_Humanity.GetValue() <= 0.0
		NVLC_Humanity.SetValue(100.0)
	EndIf
	If GameDaysPassed
		lastQuietDecayDay = GameDaysPassed.GetValue()
	EndIf
	RegisterForSingleUpdateGameTime(UpdateIntervalGameHours)
	RegisterForActorAction(6)
EndFunction

Event OnUpdateGameTime()
	Actor playerRef = Game.GetPlayer()
	Float nowDay = GetNowDay()
	Bool isLord = IsPlayerVampireLord(playerRef)

	If isLord && !trackingTransform
		StartTransform(nowDay, playerRef)
	ElseIf !isLord && trackingTransform
		EndTransform(nowDay, playerRef)
	EndIf

	If activeCrashTier > 0 && nowDay >= activeCrashEndDay
		ClearCrash(playerRef)
	EndIf

	DecayHeat(nowDay)
	ApplyHumanityState(playerRef)
	TryAmbush(nowDay, playerRef)
	RegisterForSingleUpdateGameTime(UpdateIntervalGameHours)
EndEvent

Event OnActorAction(Int actionType, Actor akActor, Form source, Int slot)
	If actionType != 6 || !trackingTransform
		Return
	EndIf
	If akActor != Game.GetPlayer()
		Return
	EndIf
	Actor victim = source as Actor
	If victim && IsHumanoid(victim)
		humanoidKillsThisTransform += 1
		ModHumanity(-1.0)
		ModHeat(3.0)
	EndIf
EndEvent

Function StartTransform(Float nowDay, Actor playerRef)
	trackingTransform = True
	transformStartDay = nowDay
	humanoidKillsThisTransform = 0
	If NVLC_LastTransformTime
		NVLC_LastTransformTime.SetValue(nowDay)
	EndIf
	ModHumanity(-1.0)
	If IsPublicPlace(playerRef)
		ModHeat(15.0)
	ElseIf IsDaylight()
		ModHeat(10.0)
	Else
		ModHeat(5.0)
	EndIf
	Debug.Trace("[NVLC] Vampire Lord transform started. Heat=" + NVLC_Heat.GetValue() + " Humanity=" + NVLC_Humanity.GetValue())
EndFunction

Function EndTransform(Float nowDay, Actor playerRef)
	trackingTransform = False
	Float seconds = (nowDay - transformStartDay) * 86400.0
	Int crashTier = 0
	If seconds >= 120.0
		crashTier = 3
		ModHumanity(-2.0)
	ElseIf seconds >= 30.0
		crashTier = 2
	ElseIf humanoidKillsThisTransform > 0
		crashTier = 1
	EndIf
	If humanoidKillsThisTransform >= 3 && crashTier < 3
		crashTier += 1
	EndIf
	If IsDaylight() && crashTier < 3
		crashTier += 1
	EndIf
	ApplyCrash(playerRef, crashTier, nowDay)
	Debug.Trace("[NVLC] Vampire Lord reverted after " + seconds + "s. Crash=" + crashTier + " kills=" + humanoidKillsThisTransform)
EndFunction

Function ApplyCrash(Actor playerRef, Int tier, Float nowDay)
	ClearCrash(playerRef)
	activeCrashTier = tier
	If NVLC_CrashSeverity
		NVLC_CrashSeverity.SetValue(tier as Float)
	EndIf
	If tier <= 0
		Return
	EndIf
	If tier == 1
		activeSpeedDelta = -10.0
		activeStaminaRateDelta = -15.0
		activeMagickaRateDelta = -15.0
		activeCrashEndDay = nowDay + (MinorCrashHours / 24.0)
	ElseIf tier == 2
		activeStaminaRateDelta = -20.0
		activeMagickaRateDelta = -20.0
		activeSpeechDelta = -25.0
		activeCrashEndDay = nowDay + (ModerateCrashHours / 24.0)
	Else
		activeStaminaRateDelta = -35.0
		activeMagickaRateDelta = -35.0
		activeSpeechDelta = -50.0
		activeDamageResistDelta = -25.0
		activeMagicResistDelta = -15.0
		activeCrashEndDay = nowDay + (SevereCrashHours / 24.0)
	EndIf
	ApplyActorDelta(playerRef, activeSpeedDelta, activeStaminaRateDelta, activeMagickaRateDelta, activeSpeechDelta, activeDamageResistDelta, activeMagicResistDelta)
EndFunction

Function ClearCrash(Actor playerRef)
	If activeCrashTier <= 0
		Return
	EndIf
	ApplyActorDelta(playerRef, -activeSpeedDelta, -activeStaminaRateDelta, -activeMagickaRateDelta, -activeSpeechDelta, -activeDamageResistDelta, -activeMagicResistDelta)
	activeCrashTier = 0
	activeCrashEndDay = 0.0
	activeSpeedDelta = 0.0
	activeStaminaRateDelta = 0.0
	activeMagickaRateDelta = 0.0
	activeSpeechDelta = 0.0
	activeDamageResistDelta = 0.0
	activeMagicResistDelta = 0.0
	If NVLC_CrashSeverity
		NVLC_CrashSeverity.SetValue(0.0)
	EndIf
EndFunction

Function ApplyActorDelta(Actor playerRef, Float speedDelta, Float staminaRateDelta, Float magickaRateDelta, Float speechDelta, Float damageResistDelta, Float magicResistDelta)
	If speedDelta != 0.0
		playerRef.ModActorValue("SpeedMult", speedDelta)
	EndIf
	If staminaRateDelta != 0.0
		playerRef.ModActorValue("StaminaRateMult", staminaRateDelta)
	EndIf
	If magickaRateDelta != 0.0
		playerRef.ModActorValue("MagickaRateMult", magickaRateDelta)
	EndIf
	If speechDelta != 0.0
		playerRef.ModActorValue("Speechcraft", speechDelta)
	EndIf
	If damageResistDelta != 0.0
		playerRef.ModActorValue("DamageResist", damageResistDelta)
	EndIf
	If magicResistDelta != 0.0
		playerRef.ModActorValue("MagicResist", magicResistDelta)
	EndIf
EndFunction

Function ApplyHumanityState(Actor playerRef)
	Float humanity = NVLC_Humanity.GetValue()
	Int tier = 0
	If humanity < 25.0
		tier = 2
	ElseIf humanity < 50.0
		tier = 1
	EndIf
	If tier == activeHumanityTier
		Return
	EndIf
	If activeHumanityTier > 0
		playerRef.ModActorValue("Speechcraft", -humanitySpeechDelta)
		playerRef.ModActorValue("MagickaRateMult", -humanityMagickaRateDelta)
		playerRef.ModActorValue("DamageResist", -humanityDamageResistDelta)
	EndIf
	activeHumanityTier = tier
	humanitySpeechDelta = 0.0
	humanityMagickaRateDelta = 0.0
	humanityDamageResistDelta = 0.0
	If tier == 1
		humanitySpeechDelta = -10.0
		humanityMagickaRateDelta = -10.0
	ElseIf tier == 2
		humanitySpeechDelta = -25.0
		humanityMagickaRateDelta = -20.0
		humanityDamageResistDelta = -15.0
	EndIf
	If tier > 0
		playerRef.ModActorValue("Speechcraft", humanitySpeechDelta)
		playerRef.ModActorValue("MagickaRateMult", humanityMagickaRateDelta)
		playerRef.ModActorValue("DamageResist", humanityDamageResistDelta)
	EndIf
EndFunction

Function DecayHeat(Float nowDay)
	If trackingTransform
		lastQuietDecayDay = nowDay
		Return
	EndIf
	If nowDay - lastQuietDecayDay >= 1.0
		ModHeat(-HeatDecayPerDay)
		lastQuietDecayDay = nowDay
	EndIf
EndFunction

Function TryAmbush(Float nowDay, Actor playerRef)
	If !NVLC_DawnguardHunter || trackingTransform
		Return
	EndIf
	Float heat = NVLC_Heat.GetValue()
	If heat < 50.0 || nowDay - lastAmbushDay < AmbushCooldownDays
		Return
	EndIf
	Int chance = 8
	If heat >= 100.0
		chance = 18
	EndIf
	If Utility.RandomInt(1, 100) <= chance
		Actor hunter = playerRef.PlaceActorAtMe(NVLC_DawnguardHunter, 4)
		If hunter
			hunter.StartCombat(playerRef)
			lastAmbushDay = nowDay
			Debug.Trace("[NVLC] Dawnguard heat ambush spawned. Heat=" + heat)
		EndIf
	EndIf
EndFunction

Bool Function IsPlayerVampireLord(Actor playerRef)
	Return DLC1VampireBeastRace && playerRef.GetRace() == DLC1VampireBeastRace
EndFunction

Bool Function IsHumanoid(Actor targetRef)
	Return targetRef && targetRef.HasKeyword(ActorTypeNPC)
EndFunction

Bool Function IsPublicPlace(Actor playerRef)
	Location currentLocation = playerRef.GetCurrentLocation()
	If currentLocation
		If currentLocation.HasKeyword(LocTypeCity) || currentLocation.HasKeyword(LocTypeTown) || currentLocation.HasKeyword(LocTypeHabitation)
			Return True
		EndIf
	EndIf
	Cell currentCell = playerRef.GetParentCell()
	Return currentCell && currentCell.IsInterior()
EndFunction

Bool Function IsDaylight()
	Float hour = Utility.GetCurrentGameTime()
	hour = (hour - Math.Floor(hour)) * 24.0
	Return hour >= 6.0 && hour < 19.0
EndFunction

Float Function GetNowDay()
	If GameDaysPassed
		Return GameDaysPassed.GetValue()
	EndIf
	Return Utility.GetCurrentGameTime()
EndFunction

Function ModHeat(Float amount)
	If !NVLC_Heat
		Return
	EndIf
	Float value = NVLC_Heat.GetValue() + amount
	If value < 0.0
		value = 0.0
	EndIf
	NVLC_Heat.SetValue(value)
EndFunction

Function ModHumanity(Float amount)
	If !NVLC_Humanity
		Return
	EndIf
	Float value = NVLC_Humanity.GetValue() + amount
	If value < 0.0
		value = 0.0
	ElseIf value > 100.0
		value = 100.0
	EndIf
	NVLC_Humanity.SetValue(value)
	If NVLC_Corruption
		NVLC_Corruption.SetValue(100.0 - value)
	EndIf
EndFunction
