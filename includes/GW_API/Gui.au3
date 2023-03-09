
#Region Const
Global Const $WEAPON_SLOT_SCYTHE = 1
Global Const $WEAPON_SLOT_STAFF = 2
#EndRegion Const

#Region Variables
Global $BotRunning = False
Global $BotInitialized = False
Global $BoolInitResign = False

Global $MerchOpened = False
Global $HWND
Global $Runs = 0
Global $Fails = 0
Global $Seconds = 0
Global $Minutes = 0
Global $Hours = 0
Global $TotalSeconds = 0
Global $StartButton
Global $TakeBless
Global $GoldIdent
Global $SellGold
Global $selectAllBags
Global $selectAllItemTypes
Global $inventoryGold
Global $storageGold
Global $inventoryGoldCounter = 0
Global $goldies
Global $GoldiesSt
Global $CharInput
Global $Gui
Global $RunsCount
Global $FailsCount
Global $AvgTimeCount
Global $TotTimeCount
Global $StatusLabel
Global $dropCounterLabels = ObjCreate("Scripting.Dictionary")
Global $dropCounter = ObjCreate("Scripting.Dictionary")
Global $title
#EndRegion Variables


Func initGui($dropCounterDictionary)

	GUICtrlCreateGroup("Select a Character", 10, 5, 150, 43)
	$CharInput = GUICtrlCreateCombo("", 20, 20, 109, 21, $CBS_DROPDOWNLIST)
	GUICtrlSetData(-1, GetLoggedCharNames())
	GUICtrlSetOnEvent(-1, "GuiStartHandler")
	$iRefresh = GUICtrlCreateButton("", 132, 19, 22.8, 22.8, $BS_ICON)
	GUICtrlSetImage($iRefresh, "shell32.dll", -239, 0)
	GUICtrlSetOnEvent(-1, "RefreshInterface")

	$StartButton = GUICtrlCreateButton("Start", 10, 375, 150, 30)
	GUICtrlSetFont(-1, 11, 400, 0)
	GUICtrlSetOnEvent(-1, "GuiButtonHandler")

	$GoldIdent = GUICtrlCreateCheckbox("Don't Ident Golds", 180, 268, 110, 17)

	GUICtrlCreateGroup("Stats", 10, 50, 150, 80)
	GUICtrlCreateLabel("Runs:", 20, 62, 31, 15)
	$RunsCount = GUICtrlCreateLabel("0", 95, 62, 60, 15, $SS_CENTER)
	GUICtrlCreateLabel("Fails:", 20, 77, 31, 15)
	$FailsCount = GUICtrlCreateLabel("0", 95, 77, 60, 15, $SS_CENTER)
	GUICtrlCreateLabel("Average Time:", 20, 89, 65, 15)
	$AvgTimeCount = GUICtrlCreateLabel("0", 95, 89, 60, 15, $SS_CENTER)
	GUICtrlCreateLabel("Total Time:", 20, 104, 49, 15)
	$TotTimeCount = GUICtrlCreateLabel("0", 95, 104, 60, 15, $SS_CENTER)

	GUICtrlCreateGroup("All Bags", 10, 132, 150, 82)
	$selectAllBags = GUICtrlCreateRadio("", 143, 145, 10, 17)
	GUICtrlSetOnEvent(-1, "RadiosHandler")
	Global $bags[4] = [GUICtrlCreateCheckbox("Bag 1 (20 slots)", 20, 145, 110, 15), GUICtrlCreateCheckbox("Bag 2 (5/10 slots)", 20, 160, 130, 15), GUICtrlCreateCheckbox("Bag 3 (10/15 slots)", 20, 175, 130, 15), GUICtrlCreateCheckbox("Bag 4 (10/15 slots)", 20, 190, 130, 15)]

	GUICtrlCreateGroup("All Items", 10, 215, 150, 145)
	$selectAllItemTypes = GUICtrlCreateRadio("", 143, 230, 10, 17)
	GUICtrlSetOnEvent(-1, "RadiosHandler2")

	Global $itemTypes[4] = [GUICtrlCreateCheckbox("Pickup golds", 20, 230, 130, 15), GUICtrlCreateCheckbox("Pickup purples", 20, 245, 130, 15), GUICtrlCreateCheckbox("Pickup blues", 20, 260, 130, 15), GUICtrlCreateCheckbox("Pickup whites", 20, 275, 130, 15)]
	$SellGold = GUICtrlCreateCheckbox("Keep golds", 20, 290, 130, 15)
	GUICtrlCreateGroup("Drops", 180, 132, 150, 95)

	$verticalHeight = 145
	For $vKey In $dropCounterDictionary
		GUICtrlCreateLabel($dropCounterDictionary.Item($vkey) & ":", 190, $verticalHeight, 76, 15)
		$dropCounterLabels.Add($vKey, GUICtrlCreateLabel("0", 265, $verticalHeight, 40, 15, $SS_CENTER))
		$dropCounter.add($vKey, 0)
		$verticalHeight = $verticalHeight + 15
	Next

	GUICtrlCreateGroup("Coin", 180, 315, 150, 95)
	GUICtrlCreateLabel("Inventory (g): ", 190, 335, 76, 15)
	$inventoryGold = GUICtrlCreateLabel("0", 265, 335, 40, 15, $SS_CENTER)
	GUICtrlCreateLabel("Storage (g): ", 190, 355, 76, 15)
	$storageGold = GUICtrlCreateLabel("0", 265, 355, 40, 15, $SS_CENTER)


	$StatusLabel = GUICtrlCreateEdit("", 165, 11, 188, 118, BitOR(0x0040, 0x0080, 0x1000, 0x00200000))
	GUICtrlSetFont($StatusLabel, 9, 400, 0, "Arial")
	GUICtrlSetColor($StatusLabel, 4047615)
	GUICtrlSetBkColor($StatusLabel, 0)

EndFunc   ;==>initGui


Func RadiosHandler() ;Handle radios that check all checkboxes
	If (GUICtrlRead($selectAllBags) == $GUI_CHECKED) Then
		For $i = 0 To 3
			GUICtrlSetState($bags[$i], $GUI_CHECKED)
		Next
		GUICtrlSetState($selectAllBags, $GUI_UNCHECKED)
	EndIf
EndFunc   ;==>RadiosHandler

Func RadiosHandler2() ;Handle radios that check all checkboxes
	If (GUICtrlRead($selectAllItemTypes) == $GUI_CHECKED) Then
		For $i = 0 To 3
			GUICtrlSetState($itemTypes[$i], $GUI_CHECKED)
		Next
		GUICtrlSetState($selectAllItemTypes, $GUI_UNCHECKED)
	EndIf
EndFunc   ;==>RadiosHandler2

Func GuiButtonHandler() ;Handle the bot's start/pause
	If $BotRunning Then
		Out("Will pause after this run.")
		GUICtrlSetData($StartButton, "force pause NOW")
		GUICtrlSetOnEvent($StartButton, "Resign")
		$BotRunning = False
	ElseIf $BotInitialized Then
		GUICtrlSetData($StartButton, "Pause")
		$BotRunning = True
	Else
		Out("Initializing...")
		Local $CharName = GUICtrlRead($CharInput)
		If $CharName == "" Then
			If Initialize(ProcessExists("gw.exe"), True, True) = False Then
				MsgBox(0, "Error", "Guild Wars is not running.")
				Exit
			EndIf
		Else
			If Initialize($CharName, True) = False Then
				MsgBox(0, "Error", "Could not find a Guild Wars client with a character named '" & $CharName & "'")
				Exit
			EndIf
		EndIf
		$HWND = GetWindowHandle()
		GUICtrlSetState($CharInput, $GUI_DISABLE)
		Local $CharName = GetCharname()
		GUICtrlSetData($CharInput, $CharName, $CharName)
		GUICtrlSetData($StartButton, "Pause")
		WinSetTitle($Gui, "", $title & " - " & $CharName)
		$BotRunning = True
		$BotInitialized = True
		SetMaxMemory()
	EndIf
EndFunc   ;==>GuiButtonHandler

Func GuiStartHandler() ;Handle Start/Stop toggling based on character selection (preventing user from starting bot befor choosing a character)
	If (GUICtrlRead($CharInput, "") <> "") Then
		GUICtrlSetState($StartButton, $GUI_ENABLE)
		ActivateAllGUI()
	Else
		GUICtrlSetState($StartButton, $GUI_DISABLE)
		DeactivateAllGUI()
	EndIf
EndFunc   ;==>GuiStartHandler

Func ActivateAllGUI() ;Activate selectors and checkboxes (except Start/Pause button and Rendering checkbox)
	GUICtrlSetState($StartButton, $GUI_ENABLE)
	GUICtrlSetState($TakeBless, $GUI_ENABLE)
	;Checkboxes
	For $i = 0 To 3
		GUICtrlSetState($bags[$i], $GUI_ENABLE)
	Next
	For $i = 0 To 3
		GUICtrlSetState($itemTypes[$i], $GUI_ENABLE)
	Next

	GUICtrlSetState($SellGold, $GUI_ENABLE)
	GUICtrlSetState($selectAllBags, $GUI_ENABLE)
	GUICtrlSetState($selectAllItemTypes, $GUI_ENABLE)
	GUICtrlSetState($GoldIdent, $GUI_ENABLE)

EndFunc   ;==>ActivateAllGUI

Func DeactivateAllGUI($Selectors = 1) ;Deactivate selectors and checkboxes (except Start/Pause button and Rendering checkbox)
;~ Pass $Selectors as 0 to make it not deactivate selectors

	If $Selectors Then
		GUICtrlSetState($StartButton, $GUI_DISABLE)
		GUICtrlSetState($TakeBless, $GUI_DISABLE)
		For $i = 0 To 3
			GUICtrlSetState($itemTypes[$i], $GUI_DISABLE)
		Next
		GUICtrlSetState($SellGold, $GUI_DISABLE)
		GUICtrlSetState($GoldIdent, $GUI_DISABLE)
	EndIf


	For $i = 0 To 3
		GUICtrlSetState($bags[$i], $GUI_DISABLE)
	Next
	GUICtrlSetState($selectAllBags, $GUI_DISABLE)
	GUICtrlSetState($selectAllItemTypes, $GUI_DISABLE)

EndFunc   ;==>DeactivateAllGUI

Func RefreshInterface()
	Local $CharName[1]
	Local $lWinList = ProcessList("gw.exe")

	Switch $lWinList[0][0]
		Case 0
			MsgBox(16, "PreFarmer_Bot", "Please open Guild Wars and log into a character before running this program.")
			Exit
		Case Else
			For $i = 1 To $lWinList[0][0]
				MemoryOpen($lWinList[$i][1])
				$lOpenProcess = DllCall($mKernelHandle, 'int', 'OpenProcess', 'int', 0x1F0FFF, 'int', 1, 'int', $lWinList[$i][1])
				$GWHandle = $lOpenProcess[0]
				If $GWHandle Then
					$CharacterName = ScanForCharname()
					If IsString($CharacterName) Then
						ReDim $CharName[UBound($CharName) + 1]
						$CharName[$i] = $CharacterName
					EndIf
				EndIf
				$GWHandle = 0
			Next
			GUICtrlSetData($CharInput, _ArrayToString($CharName, "|"), $CharName[1])
	EndSwitch
EndFunc   ;==>RefreshInterface


Func Out($msg)
	GUICtrlSetData($StatusLabel, GUICtrlRead($StatusLabel) & "[" & @HOUR & ":" & @MIN & "]" & " " & $msg & @CRLF)
	_GUICtrlEdit_Scroll($StatusLabel, $SB_SCROLLCARET)
	_GUICtrlEdit_Scroll($StatusLabel, $SB_LINEUP)
EndFunc   ;==>Out

#Region GUI Enhancement
Func GetTime()
	Local $Time = GetInstanceUpTime()
	Local $Seconds = Floor($Time / 1000)
	Local $Minutes = Floor($Seconds / 60)
	Local $Hours = Floor($Minutes / 60)
	Local $Second = $Seconds - $Minutes * 60
	Local $Minute = $Minutes - $Hours * 60
	If $Hours = 0 Then
		If $Second < 10 Then $InstTime = $Minute & ':0' & $Second
		If $Second >= 10 Then $InstTime = $Minute & ':' & $Second
	ElseIf $Hours <> 0 Then
		If $Minutes < 10 Then
			If $Second < 10 Then $InstTime = $Hours & ':0' & $Minute & ':0' & $Second
			If $Second >= 10 Then $InstTime = $Hours & ':0' & $Minute & ':' & $Second
		ElseIf $Minutes >= 10 Then
			If $Second < 10 Then $InstTime = $Hours & ':' & $Minute & ':0' & $Second
			If $Second >= 10 Then $InstTime = $Hours & ':' & $Minute & ':' & $Second
		EndIf
	EndIf
	Return $InstTime
EndFunc   ;==>GetTime

Func AvgTime()
	Local $Time = GetInstanceUpTime()
	Local $Seconds = Floor($Time / 1000)
	$TotalSeconds += $Seconds
	Local $AvgSeconds = Floor($TotalSeconds / $Runs)
	Local $Minutes = Floor($AvgSeconds / 60)
	Local $Hours = Floor($Minutes / 60)
	Local $Second = $AvgSeconds - $Minutes * 60
	Local $Minute = $Minutes - $Hours * 60
	If $Hours = 0 Then
		If $Second < 10 Then $AvgTime = $Minute & ':0' & $Second
		If $Second >= 10 Then $AvgTime = $Minute & ':' & $Second
	ElseIf $Hours <> 0 Then
		If $Minutes < 10 Then
			If $Second < 10 Then $AvgTime = $Hours & ':0' & $Minute & ':0' & $Second
			If $Second >= 10 Then $AvgTime = $Hours & ':0' & $Minute & ':' & $Second
		ElseIf $Minutes >= 10 Then
			If $Second < 10 Then $AvgTime = $Hours & ':' & $Minute & ':0' & $Second
			If $Second >= 10 Then $AvgTime = $Hours & ':' & $Minute & ':' & $Second
		EndIf
	EndIf
	Return $AvgTime
EndFunc   ;==>AvgTime

Func TimeUpdater()
	$Seconds += 1
	If $Seconds = 60 Then
		$Minutes += 1
		$Seconds = $Seconds - 60
	EndIf
	If $Minutes = 60 Then
		$Hours += 1
		$Minutes = $Minutes - 60
	EndIf
	If $Seconds < 10 Then
		$L_Sec = "0" & $Seconds
	Else
		$L_Sec = $Seconds
	EndIf
	If $Minutes < 10 Then
		$L_Min = "0" & $Minutes
	Else
		$L_Min = $Minutes
	EndIf
	If $Hours < 10 Then
		$L_Hour = "0" & $Hours
	Else
		$L_Hour = $Hours
	EndIf
	GUICtrlSetData($TotTimeCount, $L_Hour & ":" & $L_Min & ":" & $L_Sec)
EndFunc   ;==>TimeUpdater
#EndRegion GUI Enhancement
