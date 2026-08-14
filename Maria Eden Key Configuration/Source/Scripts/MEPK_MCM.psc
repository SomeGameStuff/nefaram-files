Scriptname MEPK_MCM extends SKI_ConfigBase

String Property HotkeyFile = "MariaHotkeys" AutoReadOnly
Quest Property MariaMainQuest Auto

Int _startOption
Int _numpadPresetOption
Int _unbindAllOption
Int _displayOption

Int _actionOption
Int _poseMenuOption
Int _resetPoseOption
Int _mouthOption
Int _eyesOption
Int _cameraOption
Int _bodyOption

Int _kneelOption
Int _presentVaginaOption
Int _presentRearOption
Int _allFoursOption
Int _spreadOption
Int _lieDownOption
Int _surrenderOption
Int _gulpOption
Int _crawlOption
Int _offerCaneOption
Int _stripteaseOption
Int _readyOption
Int _masturbateOption

Int Function GetVersion()
	Return 4
EndFunction

Event OnConfigInit()
	ModName = "Maria Eden Key Configuration"
	Pages = New String[3]
	Pages[0] = "Start and Presets"
	Pages[1] = "Menu Keys"
	Pages[2] = "Pose Keys"
	ApplyRecommendedMenuDefaults()
EndEvent

Event OnVersionUpdate(Int a_version)
	If a_version >= 4
		ApplyRecommendedMenuDefaults()
	EndIf
EndEvent

Event OnGameReload()
	Parent.OnGameReload()
EndEvent

Event OnPageReset(String a_page)
	ResetOptionIds()
	SetCursorFillMode(TOP_TO_BOTTOM)

	If a_page == Pages[0]
		DrawStartPage()
	ElseIf a_page == Pages[1]
		DrawMenuKeysPage()
	ElseIf a_page == Pages[2]
		DrawPoseKeysPage()
	EndIf
EndEvent

Function DrawStartPage()
	AddHeaderOption("Maria Eden status")
	ResolveMariaMain()
	If MariaMainQuest == None
		_displayOption = AddTextOption("Framework", "Not found", OPTION_FLAG_DISABLED)
	ElseIf MariaMainQuest.GetStage() >= 50
		_displayOption = AddTextOption("Framework", "Ready", OPTION_FLAG_DISABLED)
	ElseIf MariaMainQuest.GetStage() >= 1
		_displayOption = AddTextOption("Framework", "Starting", OPTION_FLAG_DISABLED)
	Else
		_displayOption = AddTextOption("Framework", "Not initialized", OPTION_FLAG_DISABLED)
		_startOption = AddTextOption("Initialize framework", "Start")
	EndIf
	_displayOption = AddTextOption("How story content starts", "See help below", OPTION_FLAG_DISABLED)
	_displayOption = AddTextOption("New game", "Choose a Maria start", OPTION_FLAG_DISABLED)
	_displayOption = AddTextOption("Existing game", "Use Maria dialogue/events", OPTION_FLAG_DISABLED)

	AddHeaderOption("Recommended pose shortcuts")
	_displayOption = AddTextOption("Numpad Enter", "Action menu", OPTION_FLAG_DISABLED)
	_displayOption = AddTextOption("Numpad Decimal", "Pose menu", OPTION_FLAG_DISABLED)
	_numpadPresetOption = AddTextOption("Apply numpad pose keys", "Apply")
	_unbindAllOption = AddTextOption("Unbind all pose keys", "Apply")
	_displayOption = AddTextOption("Numpad 1", "Surrender", OPTION_FLAG_DISABLED)
	_displayOption = AddTextOption("Numpad 2", "Kneel", OPTION_FLAG_DISABLED)
	_displayOption = AddTextOption("Numpad 3", "All fours", OPTION_FLAG_DISABLED)
	_displayOption = AddTextOption("Numpad 4", "Present vagina", OPTION_FLAG_DISABLED)
	_displayOption = AddTextOption("Numpad 5", "Ready stance", OPTION_FLAG_DISABLED)
	_displayOption = AddTextOption("Numpad 6", "Present rear", OPTION_FLAG_DISABLED)
	_displayOption = AddTextOption("Numpad 7", "Crawl", OPTION_FLAG_DISABLED)
	_displayOption = AddTextOption("Numpad 8", "Striptease", OPTION_FLAG_DISABLED)
	_displayOption = AddTextOption("Numpad 9", "Masturbate", OPTION_FLAG_DISABLED)
	_displayOption = AddTextOption("Numpad 0", "Lie down", OPTION_FLAG_DISABLED)
	_displayOption = AddTextOption("Left unbound", "Spread, gulp, offer cane", OPTION_FLAG_DISABLED)
EndFunction

Function DrawMenuKeysPage()
	AddHeaderOption("Maria menus")
	_actionOption = AddKeyMapOption("Action menu (activities and interactions)", ReadGeneralKey("keyboard_actionmenu", 156))
	_poseMenuOption = AddKeyMapOption("Pose menu (choose from a list)", ReadGeneralKey("keyboard_posemenu", 83))
	_resetPoseOption = AddKeyMapOption("Return to normal pose", ReadGeneralKey("keyboard_defaultpose", 36))

	AddHeaderOption("Other controls")
	_mouthOption = AddKeyMapOption("Toggle mouth", ReadGeneralKey("keyboard_openmouth", 24))
	_eyesOption = AddKeyMapOption("Toggle eyes", ReadGeneralKey("keyboard_closeeyes", 18))
	_cameraOption = AddKeyMapOption("Toggle Maria camera", ReadGeneralKey("keyboard_togglecam", 44))
	_bodyOption = AddKeyMapOption("Body-control menu", ReadGeneralKey("keyboard_body_control", 51))
	_displayOption = AddTextOption("Action, camera, body changes", "Apply after save reload", OPTION_FLAG_DISABLED)
EndFunction

Function DrawPoseKeysPage()
	AddHeaderOption("Optional one-key poses")
	_kneelOption = AddKeyMapOption("Kneel", ReadPoseKey("kneel.json"))
	_presentVaginaOption = AddKeyMapOption("Present vagina", ReadPoseKey("present_vagina.json"))
	_presentRearOption = AddKeyMapOption("Present rear", ReadPoseKey("present_ars.json"))
	_allFoursOption = AddKeyMapOption("All fours", ReadPoseKey("on_all_fours.json"))
	_spreadOption = AddKeyMapOption("All fours, spread", ReadPoseKey("assfuck.json"))
	_lieDownOption = AddKeyMapOption("Lie down", ReadPoseKey("laying.json"))
	_surrenderOption = AddKeyMapOption("Surrender", ReadPoseKey("surrender.json"))
	_gulpOption = AddKeyMapOption("Gulp or cough", ReadPoseKey("gulp.json"))
	_crawlOption = AddKeyMapOption("Crawl", ReadPoseKey("crawling.json"))
	_offerCaneOption = AddKeyMapOption("Offer cane", ReadPoseKey("kneel_give_cane.json"))
	_stripteaseOption = AddKeyMapOption("Striptease", ReadPoseKey("striptease.json"))
	_readyOption = AddKeyMapOption("Ready stance", ReadPoseKey("stand_ready.json"))
	_masturbateOption = AddKeyMapOption("Masturbate", ReadPoseKey("masturbate.json"))
	_displayOption = AddTextOption("Tip", "Unmap keys you do not need", OPTION_FLAG_DISABLED)
EndFunction

Event OnOptionKeyMapChange(Int a_option, Int a_keyCode, String a_conflictControl, String a_conflictName)
	If !AcceptConflict(a_conflictControl, a_conflictName)
		Return
	EndIf

	If a_option == _actionOption
		SaveGeneralKey(a_option, "keyboard_actionmenu", a_keyCode, false)
	ElseIf a_option == _poseMenuOption
		SaveGeneralKey(a_option, "keyboard_posemenu", a_keyCode, true)
	ElseIf a_option == _resetPoseOption
		SaveGeneralKey(a_option, "keyboard_defaultpose", a_keyCode, true)
	ElseIf a_option == _mouthOption
		SaveGeneralKey(a_option, "keyboard_openmouth", a_keyCode, true)
	ElseIf a_option == _eyesOption
		SaveGeneralKey(a_option, "keyboard_closeeyes", a_keyCode, true)
	ElseIf a_option == _cameraOption
		SaveGeneralKey(a_option, "keyboard_togglecam", a_keyCode, false)
	ElseIf a_option == _bodyOption
		SaveGeneralKey(a_option, "keyboard_body_control", a_keyCode, false)
	ElseIf a_option == _kneelOption
		SavePoseKey(a_option, "kneel.json", a_keyCode)
	ElseIf a_option == _presentVaginaOption
		SavePoseKey(a_option, "present_vagina.json", a_keyCode)
	ElseIf a_option == _presentRearOption
		SavePoseKey(a_option, "present_ars.json", a_keyCode)
	ElseIf a_option == _allFoursOption
		SavePoseKey(a_option, "on_all_fours.json", a_keyCode)
	ElseIf a_option == _spreadOption
		SavePoseKey(a_option, "assfuck.json", a_keyCode)
	ElseIf a_option == _lieDownOption
		SavePoseKey(a_option, "laying.json", a_keyCode)
	ElseIf a_option == _surrenderOption
		SavePoseKey(a_option, "surrender.json", a_keyCode)
	ElseIf a_option == _gulpOption
		SavePoseKey(a_option, "gulp.json", a_keyCode)
	ElseIf a_option == _crawlOption
		SavePoseKey(a_option, "crawling.json", a_keyCode)
	ElseIf a_option == _offerCaneOption
		SavePoseKey(a_option, "kneel_give_cane.json", a_keyCode)
	ElseIf a_option == _stripteaseOption
		SavePoseKey(a_option, "striptease.json", a_keyCode)
	ElseIf a_option == _readyOption
		SavePoseKey(a_option, "stand_ready.json", a_keyCode)
	ElseIf a_option == _masturbateOption
		SavePoseKey(a_option, "masturbate.json", a_keyCode)
	EndIf
EndEvent

Event OnOptionSelect(Int a_option)
	If a_option == _numpadPresetOption
		ApplyNumpadPreset()
	ElseIf a_option == _unbindAllOption
		UnbindAllPoseKeys()
	ElseIf a_option == _startOption
		InitializeFramework()
	EndIf
EndEvent

Event OnOptionHighlight(Int a_option)
	If a_option == _numpadPresetOption
		SetInfoText("Assigns Numpad 0 through 9 exactly as listed on this page, then reloads Maria's pose shortcuts.")
	ElseIf a_option == _unbindAllOption
		SetInfoText("Removes every one-key pose shortcut. The pose menu remains available if you assign its key on the Menu Keys page.")
	ElseIf a_option == _startOption
		SetInfoText("Starts Maria Eden's core framework only. New-game story scenarios are selected through Skyrim Unbound.")
	ElseIf a_option == _actionOption
		SetInfoText("Opens Maria Eden's activities and interaction menu. Choose an unused key; the change applies after reloading your save.")
	ElseIf a_option == _poseMenuOption
		SetInfoText("Opens a list of Maria poses, so individual pose shortcuts are optional.")
	Else
		SetInfoText("")
	EndIf
EndEvent

Bool Function AcceptConflict(String conflictControl, String conflictName)
	If conflictControl == "" && conflictName == ""
		Return true
	EndIf
	String promptText = "This key is already assigned"
	If conflictControl != ""
		promptText += " to " + conflictControl
	EndIf
	If conflictName != ""
		promptText += " by " + conflictName
	EndIf
	promptText += ". Use it anyway?"
	Return ShowMessage(promptText)
EndFunction

Function ApplyRecommendedMenuDefaults()
	Int actionKey = JsonUtil.GetIntValue(HotkeyFile, "keyboard_actionmenu", 16)
	Int poseMenuKey = JsonUtil.GetIntValue(HotkeyFile, "keyboard_posemenu", 25)
	Bool changed = false
	If actionKey == 0 || actionKey == 16
		JsonUtil.SetIntValue(HotkeyFile, "keyboard_actionmenu", 156)
		changed = true
	EndIf
	If poseMenuKey == 25
		JsonUtil.SetIntValue(HotkeyFile, "keyboard_posemenu", 83)
		changed = true
	EndIf
	If changed
		JsonUtil.Save(HotkeyFile, true)
	EndIf
EndFunction

Int Function ReadGeneralKey(String keyName, Int defaultValue)
	Return DisplayKey(JsonUtil.GetIntValue(HotkeyFile, keyName, defaultValue))
EndFunction

Int Function ReadPoseKey(String fileName)
	Return DisplayKey(JsonUtil.GetIntValue("MariaPoses/" + fileName, "hotkey", 0))
EndFunction

Int Function DisplayKey(Int storedValue)
	If storedValue <= 0
		Return -1
	EndIf
	Return storedValue
EndFunction

Int Function StoredKey(Int displayValue)
	If displayValue < 0
		Return 0
	EndIf
	Return displayValue
EndFunction

Function SaveGeneralKey(Int optionId, String keyName, Int keyCode, Bool reloadPoses)
	JsonUtil.SetIntValue(HotkeyFile, keyName, StoredKey(keyCode))
	JsonUtil.Save(HotkeyFile, true)
	SetKeymapOptionValue(optionId, keyCode)
	If reloadPoses
		ReloadMariaPoseKeys(false)
	Else
		Debug.Notification("Maria Eden key saved. Reload your save to apply it.")
	EndIf
EndFunction

Function SavePoseKey(Int optionId, String fileName, Int keyCode)
	WritePoseKey(fileName, StoredKey(keyCode))
	SetKeymapOptionValue(optionId, keyCode)
	ReloadMariaPoseKeys(false)
EndFunction

Function WritePoseKey(String fileName, Int keyCode)
	String pathName = "MariaPoses/" + fileName
	JsonUtil.SetIntValue(pathName, "hotkey", keyCode)
	JsonUtil.Save(pathName, true)
EndFunction

Function ApplyNumpadPreset()
	WritePoseKey("kneel.json", 80)
	WritePoseKey("present_vagina.json", 75)
	WritePoseKey("present_ars.json", 77)
	WritePoseKey("on_all_fours.json", 81)
	WritePoseKey("assfuck.json", 0)
	WritePoseKey("laying.json", 82)
	WritePoseKey("surrender.json", 79)
	WritePoseKey("gulp.json", 0)
	WritePoseKey("crawling.json", 71)
	WritePoseKey("kneel_give_cane.json", 0)
	WritePoseKey("striptease.json", 72)
	WritePoseKey("stand_ready.json", 76)
	WritePoseKey("masturbate.json", 73)
	ReloadMariaPoseKeys(false)
	Debug.Notification("Maria Eden numpad pose keys applied: Numpad 0 through 9.")
	ForcePageReset()
EndFunction

Function UnbindAllPoseKeys()
	WritePoseKey("kneel.json", 0)
	WritePoseKey("present_vagina.json", 0)
	WritePoseKey("present_ars.json", 0)
	WritePoseKey("on_all_fours.json", 0)
	WritePoseKey("assfuck.json", 0)
	WritePoseKey("laying.json", 0)
	WritePoseKey("surrender.json", 0)
	WritePoseKey("gulp.json", 0)
	WritePoseKey("crawling.json", 0)
	WritePoseKey("kneel_give_cane.json", 0)
	WritePoseKey("striptease.json", 0)
	WritePoseKey("stand_ready.json", 0)
	WritePoseKey("masturbate.json", 0)
	ReloadMariaPoseKeys(false)
	Debug.Notification("All Maria Eden one-key pose shortcuts are now unbound.")
	ForcePageReset()
EndFunction

Function ResolveMariaMain()
	If MariaMainQuest == None
		MariaMainQuest = Quest.GetQuest("MariaMain")
	EndIf
EndFunction

Function ReloadMariaPoseKeys(Bool notify)
	ResolveMariaMain()
	MariaAnimationManager manager = MariaMainQuest as MariaAnimationManager
	If manager
		manager.LoadAnimations(true)
		If notify
			Debug.Notification("Maria Eden pose shortcuts reloaded.")
		EndIf
	ElseIf notify
		Debug.Notification("Maria Eden's framework was not found.")
	EndIf
EndFunction

Function InitializeFramework()
	ResolveMariaMain()
	If MariaMainQuest == None
		Debug.Notification("Maria Eden's framework quest was not found.")
	ElseIf MariaMainQuest.GetStage() < 1
		MariaMainQuest.SetStage(1)
		Debug.Notification("Maria Eden framework initialization started.")
	Else
		Debug.Notification("Maria Eden's framework is already running.")
	EndIf
	ForcePageReset()
EndFunction

Function ResetOptionIds()
	_startOption = -1
	_numpadPresetOption = -1
	_unbindAllOption = -1
	_actionOption = -1
	_poseMenuOption = -1
	_resetPoseOption = -1
	_mouthOption = -1
	_eyesOption = -1
	_cameraOption = -1
	_bodyOption = -1
	_kneelOption = -1
	_presentVaginaOption = -1
	_presentRearOption = -1
	_allFoursOption = -1
	_spreadOption = -1
	_lieDownOption = -1
	_surrenderOption = -1
	_gulpOption = -1
	_crawlOption = -1
	_offerCaneOption = -1
	_stripteaseOption = -1
	_readyOption = -1
	_masturbateOption = -1
EndFunction
