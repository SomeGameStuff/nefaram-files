;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 11
Scriptname MEP_PimpHygieneQuest Extends Quest Hidden

;BEGIN ALIAS PROPERTY master
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_master Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Slave
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Slave Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_10
Function Fragment_10()
;BEGIN CODE
FinishMakeup()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN CODE
DoNails()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN CODE
DoEyes()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
DoMakeup()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_9
Function Fragment_9()
;BEGIN CODE
GiveMakeupPouch()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_8
Function Fragment_8()
;BEGIN CODE
DoEyeliner()
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

;BEGIN FRAGMENT Fragment_4
Function Fragment_4()
;BEGIN CODE
DoHairs()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_6
Function Fragment_6()
;BEGIN CODE
DoLips()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
UpdateAllTones()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Scene Property MEPPimpHygieneNewMakeup Auto
Scene Property MEPPimpHygieneNails Auto
Scene Property MEPPimpHygieneHair Auto
Scene Property MEPPimpHygieneLids Auto
Scene Property MEPPimpHygieneLips Auto
Scene Property MEPPimpHygieneEyeLiner Auto

GlobalVariable Property MEPPlayerBodyHairTone Auto
GlobalVariable Property MEPPlayerBodyLipTone Auto
GlobalVariable Property MEPPlayerBodyEyeSocketTone Auto
GlobalVariable Property MEPPlayerBodyEyelinerTone Auto
GlobalVariable Property MEPPlayerBodyNailTone Auto
Keyword Property MariaClothingNails Auto
MiscObject Property MEPCosmeticPouch Auto
Actor Property PlayerRef Auto

int Property TINT_FRECKLES = 0 AutoReadOnly
int Property TINT_LIPS = 1 AutoReadOnly
int Property TINT_CHEEKS = 2 AutoReadOnly
int Property TINT_EYELINER = 3 AutoReadOnly
int Property TINT_SOCKET_UPPER = 4 AutoReadOnly
int Property TINT_SOCKET_LOWER = 5 AutoReadOnly
int Property TINT_SKINTONE = 6 AutoReadOnly
int Property TINT_WARPAINT = 7 AutoReadOnly
int Property TINT_FROWN_LINES = 8 AutoReadOnly
int Property TINT_CHEEK_LINES = 9 AutoReadOnly

function Trace(string text)
    Debug.Trace("@@ HYGIENE :" + text)
endfunction

function Startup()
    Maintenance()
    UpdateAllTones()
endfunction

Event OnInit()
    Maintenance()
EndEvent

Event OnMenuClose(String MenuName)
    ; Wir warten kurz, bis RaceMenu alle Daten in den Actor geschrieben hat
    Utility.Wait(1.0)
    UpdateAllTones()
    ShowNailDiagnostic()
EndEvent

Function Maintenance()
    RegisterForMenu("RaceSex Menu")
    RegisterForMenu("RaceSexMenu")
EndFunction

function UpdateAllTones()
    UpdateHairTone()
    UpdateEyelinerTone()
    UpdateEyeSocketTone()
    UpdateLipTone()
    UpdateNailTone()

    ; Werte aus den Globalen Variablen auslesen
    int hairVal = MEPPlayerBodyHairTone.GetValue() as int
    int lipVal = MEPPlayerBodyLipTone.GetValue() as int
    int socketVal = MEPPlayerBodyEyeSocketTone.GetValue() as int
    int linerVal = MEPPlayerBodyEyelinerTone.GetValue() as int
    int nailVal = MEPPlayerBodyNailTone.GetValue() as int

    ; Debug-Text zusammenbauen
    string debugMsg = "Makeup-Check: "
    debugMsg += "Hair: " + hairVal
    debugMsg += " | Lips: " + lipVal
    debugMsg += " | Lids: " + socketVal
    debugMsg += " | Liner: " + linerVal
    debugMsg += " | Nails: " + nailVal

    ; Nachricht im Spiel anzeigen
    Debug.Notification(debugMsg)
endfunction

Function UpdateHairTone()
    ColorForm hairColorForm = PlayerRef.GetActorBase().GetHairColor()

    if !hairColorForm
        MEPPlayerBodyHairTone.SetValue(-1) ; Unbekannt
        return
    endif

    ; SKSE bietet Funktionen, um RGB aus der ColorForm zu ziehen
    int red = hairColorForm.GetRed()
    int green = hairColorForm.GetGreen()
    int blue = hairColorForm.GetBlue()

    ; Berechnung der Helligkeit (Durchschnitt oder Luminanz)
    float brightness = (red + green + blue) / 3.0

    ; Logik für deine Kategorien:
    ; 0 = Schwarz (sehr dunkel)
    ; 1 = Dunkel (Braun, dunkles Grau)
    ; 2 = Hell (Blond, Weiß, helles Rot)

    if brightness < 30 ; Nahezu Schwarz
        MEPPlayerBodyHairTone.SetValue(0)
    elseif brightness < 100 ; Dunklere Töne
        MEPPlayerBodyHairTone.SetValue(1)
    else ; Helle Töne
        MEPPlayerBodyHairTone.SetValue(2)
    endif
EndFunction

Function UpdateLipTone()
    int numMasks = Game.GetNumTintMasks()
    int i = 0
    int lipColor = -1
    bool found = false

    while i < numMasks
        int maskType = Game.GetNthTintMaskType(i)
        if (maskType == TINT_LIPS) || (maskType == TINT_WARPAINT &&  StringUtil.Find(Game.GetNthTintMaskTexturePath(i), "lips") >= 0)
            lipColor = Game.GetNthTintMaskColor(i)
            found = true
            i = numMasks
        endif
        i += 1
    endwhile

    if !found
        MEPPlayerBodyLipTone.SetValue(-1)
        return
    endif

    ; RGB-Werte extrahieren
    int alpha = Math.LogicalAnd(Math.RightShift(lipColor, 24), 0xFF)
    int red   = Math.LogicalAnd(Math.RightShift(lipColor, 16), 0xFF)
    int green = Math.LogicalAnd(Math.RightShift(lipColor, 8), 0xFF)
    int blue  = Math.LogicalAnd(lipColor, 0xFF)

    float baseBrightness = (red + green + blue) / 3.0
    float alphaNorm = alpha / 255.0
    float effectiveBrightness = (baseBrightness * alphaNorm) + (255.0 * (1.0 - alphaNorm))

    ; Berechnung der Rot-Dominanz
    bool isVeryRed = (red > (green + 60)) && (red > (blue + 60)) && (alpha > 150)
    bool isRed = (red > (green + 30)) && (red > (blue + 30)) && (alpha > 80)

    ; --- Logik-Entscheidung ---

    if (effectiveBrightness < 60) || isVeryRed
        ; Ergebnis 0: Sehr dunkle Lippen ODER kräftiger, deckender roter Lippenstift
        MEPPlayerBodyLipTone.SetValue(0)

    elseif (effectiveBrightness < 150) || isRed
        ; Ergebnis 1: Ziemlich dunkel (Braun/Grau) ODER moderates Rot/Rosa
        MEPPlayerBodyLipTone.SetValue(1)

    else
        ; Ergebnis 2: Hell, sehr transparent oder fast natürliche Lippenfarbe
        MEPPlayerBodyLipTone.SetValue(2)
    endif
EndFunction

Function UpdateEyelinerTone()
    int numMasks = Game.GetNumTintMasks()
    int i = 0
    int eyeColor = -1
    bool found = false

    while i < numMasks
        int maskType = Game.GetNthTintMaskType(i)
        if (maskType == TINT_EYELINER) || (maskType == TINT_WARPAINT &&  StringUtil.Find(Game.GetNthTintMaskTexturePath(i), "eyeliner") >= 0)
            eyeColor = Game.GetNthTintMaskColor(i)
            found = true
            i = numMasks
        endif
        i += 1
    endwhile

    if !found
        MEPPlayerBodyLipTone.SetValue(-1)
        return
    endif

    ; ARGB-Werte extrahieren
    int alpha = Math.LogicalAnd(Math.RightShift(eyeColor, 24), 0xFF)
    int red   = Math.LogicalAnd(Math.RightShift(eyeColor, 16), 0xFF)
    int green = Math.LogicalAnd(Math.RightShift(eyeColor, 8), 0xFF)
    int blue  = Math.LogicalAnd(eyeColor, 0xFF)

    ; Effektive Helligkeit berechnen
    float baseBrightness = (red + green + blue) / 3.0
    float alphaNorm = alpha / 255.0
    ; Simulation: Wie dunkel wirkt der Strich auf der Haut (255)
    float effectiveBrightness = (baseBrightness * alphaNorm) + (255.0 * (1.0 - alphaNorm))

    ; --- Logik-Entscheidung ---

    if (effectiveBrightness < 50)
        ; Ergebnis 0: Sehr dunkler, kräftiger Eyeliner (Tiefschwarz / Stark deckend)
        MEPPlayerBodyEyelinerTone.SetValue(0)

    elseif (effectiveBrightness < 160)
        ; Ergebnis 1: Mittel (Grau, Braun oder sehr feiner/transparenter schwarzer Strich)
        MEPPlayerBodyEyelinerTone.SetValue(1)

    else
        ; Ergebnis 2: Nahezu unsichtbar / Sehr hell / Kaum Kontrast
        MEPPlayerBodyEyelinerTone.SetValue(2)
    endif
EndFunction

Function UpdateEyeSocketTone()
    int numMasks = Game.GetNumTintMasks()
    int i = 0
    int eyeColor = -1
    bool found
    int highest_alpha

    while i < numMasks
        int maskType = Game.GetNthTintMaskType(i)
        if maskType == TINT_WARPAINT && StringUtil.Find(Game.GetNthTintMaskTexturePath(i), "eyeshadow") >= 0
            int e = Game.GetNthTintMaskColor(i)
            int a = Math.LogicalAnd(Math.RightShift(e, 24), 0xFF)
            if a > 0
                if a > highest_alpha
                    highest_alpha = a
                    eyeColor = e
                    found = true
                    Trace("found " + Game.GetNthTintMaskTexturePath(i))
                endif
            endif
        endif
        i += 1
    endwhile

    i = 0
    while i < numMasks && !found
        int maskType = Game.GetNthTintMaskType(i)
        if maskType == TINT_SOCKET_UPPER
            found = true
            eyeColor = Game.GetNthTintMaskColor(i)
            Trace("found base")
        endif
        i += 1
    endwhile

    if !found
        MEPPlayerBodyEyeSocketTone.SetValue(-1)
        return
    endif

    int alpha = Math.LogicalAnd(Math.RightShift(eyeColor, 24), 0xFF)
    int red   = Math.LogicalAnd(Math.RightShift(eyeColor, 16), 0xFF)
    int green = Math.LogicalAnd(Math.RightShift(eyeColor, 8), 0xFF)
    int blue  = Math.LogicalAnd(eyeColor, 0xFF)
    Trace("rgba=" + red + "," + green + "," + blue + "," + alpha)

    float baseBrightness = (red + green + blue) / 3.0
    float alphaNorm = alpha / 255.0
    float effectiveBrightness = (baseBrightness * alphaNorm) + (255.0 * (1.0 - alphaNorm))

    int maxRGB = red
    if green > maxRGB
        maxRGB = green
    endif
    if blue > maxRGB
        maxRGB = blue
    endif

    int minRGB = red
    if green < minRGB
        minRGB = green
    endif
    if blue < minRGB
        minRGB = blue
    endif

    int saturation = maxRGB - minRGB
    bool isStronglyColored = (saturation > 70) && (alpha > 100)

    if (effectiveBrightness < 75) || isStronglyColored
        MEPPlayerBodyEyeSocketTone.SetValue(0)
    elseif (effectiveBrightness < 185) || (saturation > 30 && alpha > 50)
        MEPPlayerBodyEyeSocketTone.SetValue(1)
    else
        MEPPlayerBodyEyeSocketTone.SetValue(2)
    endif
EndFunction

Function UpdateNailTone()
    if MESKSEUtils.WornHasKeyword(PlayerRef, MariaClothingNails)
        ; artifical nails, no way to get colors, consider as good
        MEPPlayerBodyNailTone.SetValueInt(0)
        Trace("Wearing equipable nails, skip")
        return
    endif

    int nailColor = -1

    ; try slave tats
    int template = JValue.retain(JMap.object())
    int tattoos
    string section
    string texture
    int color
    int alpha
    JMap.setStr(template, "area", "Hands")
    int matches = JValue.addToPool(JArray.object(), "find_nails")
    if SlaveTats.query_applied_tattoos(PlayerRef, template, matches)
        JValue.cleanPool("find_nails")
    else
        int i = JArray.count(matches)
        int entry
        while i > 0 && nailColor < 0
            i -= 1
            entry = JArray.getObj(matches, i)
            section = JMap.getStr(entry, "section")
            texture = JMap.getStr(entry, "texture")
            if StringUtil.Find(section,"Nail") >= 0 ||  StringUtil.Find(texture,"Nail") >= 0
                Trace("nails : slavetats")
                nailColor = JMap.getInt(entry, "color")
                alpha = Math.LogicalAnd(Math.RightShift(nailColor, 24), 0xFF)
            endif
        endwhile
        JValue.cleanPool("find_nails")
    endif

    ; try hand paint overlays (RaceMenu)
    if nailColor < 0
        int numOverlays = NiOverride.GetNumHandOverlays()
        bool isFemale = (PlayerRef.GetLeveledActorBase().GetSex() == 1)
        int j = numOverlays - 1
        while j >= 0 && nailColor < 0
            string nodeName = "Hands [Ovl" + j + "]"
            if NiOverride.HasNodeOverride(PlayerRef, isFemale, nodeName, 9, 0)
                string texturePath = NiOverride.GetNodeOverrideString(PlayerRef, isFemale, nodeName, 9, 0)
                if StringUtil.Find(texturePath, "Nail") >= 0 || StringUtil.Find(texturePath, "nail") >= 0
                    float fAlpha = NiOverride.GetNodeOverrideFloat(PlayerRef, isFemale, nodeName, 8, -1)
                    if fAlpha > 0.01
                        nailColor = NiOverride.GetNodeOverrideInt(PlayerRef, isFemale, nodeName, 7, -1)
                        alpha = (fAlpha * 255.0) as int
                    endif
                endif
            endif
            j -= 1
        endwhile
    endif

    if nailColor < 0
        MEPPlayerBodyNailTone.SetValueInt(2)
        return
    endif

    int red   = Math.LogicalAnd(Math.RightShift(nailColor, 16), 0xFF)
    int green = Math.LogicalAnd(Math.RightShift(nailColor, 8), 0xFF)
    int blue  = Math.LogicalAnd(nailColor, 0xFF)

    float brightness = (red + green + blue) / 3.0
    if brightness < 30 ; Nahezu Schwarz
        MEPPlayerBodyNailTone.SetValue(0)
    elseif brightness < 100 ; Dunklere Töne
        MEPPlayerBodyNailTone.SetValue(1)
    else ; Helle Töne
        MEPPlayerBodyNailTone.SetValue(2)
    endif
EndFunction

Function ShowNailDiagnostic()
    if MESKSEUtils.WornHasKeyword(PlayerRef, MariaClothingNails)
        Debug.Notification("Maria nail check: PASS - recognized equipable nails.")
        Debug.Trace("@@ HYGIENE NAIL DIAG : PASS equipable nails keyword")
        return
    endif

    int numOverlays = NiOverride.GetNumHandOverlays()
    bool isFemale = (PlayerRef.GetLeveledActorBase().GetSex() == 1)
    int j = numOverlays - 1
    while j >= 0
        string nodeName = "Hands [Ovl" + j + "]"
        if NiOverride.HasNodeOverride(PlayerRef, isFemale, nodeName, 9, 0)
            string texturePath = NiOverride.GetNodeOverrideString(PlayerRef, isFemale, nodeName, 9, 0)
            if StringUtil.Find(texturePath, "Nail") >= 0 || StringUtil.Find(texturePath, "nail") >= 0
                int rawColor = NiOverride.GetNodeOverrideInt(PlayerRef, isFemale, nodeName, 7, -1)
                float overlayAlpha = NiOverride.GetNodeOverrideFloat(PlayerRef, isFemale, nodeName, 8, -1)
                int red = Math.LogicalAnd(Math.RightShift(rawColor, 16), 0xFF)
                int green = Math.LogicalAnd(Math.RightShift(rawColor, 8), 0xFF)
                int blue = Math.LogicalAnd(rawColor, 0xFF)
                int brightness = ((red + green + blue) / 3.0) as int
                int alphaPercent = (overlayAlpha * 100.0) as int

                Debug.Trace("@@ HYGIENE NAIL DIAG : node=" + nodeName + ", texture=" + texturePath + ", raw=" + rawColor + ", rgb=" + red + "," + green + "," + blue + ", alpha=" + alphaPercent + ", brightness=" + brightness)
                Debug.Notification("Maria nail match: " + nodeName + ", RGB " + red + "/" + green + "/" + blue + ", alpha " + alphaPercent + "%.")
                if overlayAlpha <= 0.01
                    Debug.Notification("Maria nail check: FAIL - matching overlay is transparent.")
                elseif rawColor < 0
                    Debug.Notification("Maria nail check: FAIL - color value " + rawColor + " is treated as missing.")
                elseif brightness < 30
                    Debug.Notification("Maria nail check: PASS - brightness " + brightness + " is below 30.")
                else
                    Debug.Notification("Maria nail check: FAIL - brightness " + brightness + " must be below 30.")
                endif
                return
            endif
        endif
        j -= 1
    endwhile

    Debug.Trace("@@ HYGIENE NAIL DIAG : FAIL no visible Hand Paint texture containing Nail; slots=" + numOverlays)
    Debug.Notification("Maria nail check: FAIL - no Hand Paint texture containing 'Nail' was detected.")
EndFunction

event OnKeyDown(Int KeyCode)
	Trace("OnKeyDown " + KeyCode)
	if Utility.IsInMenuMode()
		return
	endif
    Game.ShowRaceMenu()
endevent

function GiveMakeupPouch() ; stage 15
    if PlayerRef.GetItemCount(MEPCosmeticPouch) == 0
        PlayerRef.AddItem(MEPCosmeticPouch)
    endif
    ;RegisterForKey(28) ; enter
    ;RegisterForKey(57) ; spacebar
endfunction


function DoMakeup() ; stage 20
    MEPPimpHygieneNewMakeup.Start()
endfunction

function DoNails() ; stage 21
    if !GetStageDone(20)
        SetStage(20)
    else
        MEPPimpHygieneNails.Start()
    endif
endfunction

function DoHairs() ; stage 22
    if !GetStageDone(20)
        SetStage(20)
    else
        MEPPimpHygieneHair.Start()
    endif
endfunction

function DoEyes() ; stage 23
    if !GetStageDone(20)
        SetStage(20)
    else
        MEPPimpHygieneLids.Start()
    endif
endfunction

function DoLips() ; stage 24
    if !GetStageDone(20)
        SetStage(20)
    else
        MEPPimpHygieneLips.Start()
    endif
endfunction

function DoEyeliner() ; stage 25
    if !GetStageDone(20)
        SetStage(20)
    else
        MEPPimpHygieneEyeLiner.Start()
    endif
endfunction

function FinishMakeup() ; stage 40
    UnregisterForAllKeys()
endfunction
