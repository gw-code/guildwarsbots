#Region Include
#include "includes/GW_Api.au3"
#EndRegion Include


Opt("GUIOnEventMode", True)
Opt("GUICloseOnESC", False)
$title = "CoF Farmer"
$Gui = GUICreate($title & " - Dervish Edition", 362, 420, -1, -1)

Local $dropCounterDictionary = ObjCreate("Scripting.Dictionary")
$dropCounterDictionary.Add($ITEM_ID_BONES, "Bones")
$dropCounterDictionary.Add($ITEM_ID_DUST, "Dust")
$dropCounterDictionary.Add($ITEM_ID_Golden_Rin_Relic, "Rin")
$dropCounterDictionary.Add($ITEM_ID_Diesa, "Diesa")

Local $dropKeys = $dropCounterDictionary.Keys
_ArrayConcatenate($wontSell, $dropKeys)

initGui($dropCounterDictionary)

$TakeBless = GUICtrlCreateCheckbox("Take Blessing", 180, 248, 110, 17)

#Region Disable GUI
DeactivateAllGUI()
#EndRegion Disable GUI


GUISetOnEvent($GUI_EVENT_CLOSE, "_exit")
GUISetState(@SW_SHOW)

#Region Loops
Out("Ready to start.")
While Not $BotRunning
	Sleep(100)
WEnd

AdlibRegister("TimeUpdater", 1000)
While 1
	GUICtrlSetData($storageGold, GetGoldStorage())
	GUICtrlSetData($inventoryGold, GetGoldCharacter())
	If Not $BotRunning Then
		AdlibUnRegister("TimeUpdater")
		Out("Bot is paused.")
		GUICtrlSetState($StartButton, $GUI_ENABLE)
		GUICtrlSetData($StartButton, "Start")
		GUICtrlSetOnEvent($StartButton, "GuiButtonHandler")
		While Not $BotRunning
			Sleep(100)
		WEnd
		AdlibRegister("TimeUpdater", 1000)
	EndIf
	MainLoop()
WEnd

Func MainLoop()
	Local $Gron = GetNearestNPCToCoords(-19090, 17980)
	DeactivateAllGUI(0)

	If ((GetMapID() == $MAP_ID_DOOMLORE) And ($BoolInitResign)) Then
		Zone_Fast_Way()

	Else
		If isInventoryFull() Then
			GoToNPC($Gron)
			Dialog($THIRD_DIALOG)
			IdentItemToMerchant()
			SellItemToMerchant()
		EndIf
		DepositGold()
		Setup()
		Zone_Fast_Way()

	EndIf
	Out("Entering Cathedral")
	If GUICtrlRead($TakeBless) == $GUI_CHECKED Then GoToNPC(GetNearestNPCToCoords(-18250, -8595))
	If GUICtrlRead($TakeBless) == $GUI_CHECKED Then Out("Taking Blessing.")
	Sleep(100)
	Dialog(132)
	Sleep(100)

	AggroAndPrepare()
	Out("Killing Cryptos.")
	Kill()
	If GetIsDead(-2) Then
		$Fails += 1
		Out("Run failed: Dead.")
		GUICtrlSetData($FailsCount, $Fails)
	Else
		$Runs += 1
		Out("Run completed in " & GetTime() & ".")
		GUICtrlSetData($RunsCount, $Runs)
		GUICtrlSetData($AvgTimeCount, AvgTime())
	EndIf
	Out("Returning to Doomlore.")
	Resign()
	RndSleep(1000)
	ReturnToOutpost()
	WaitMapLoading($MAP_ID_DOOMLORE)
EndFunc   ;==>MainLoop

#EndRegion Loops

#Region Bot init Functions
Func Setup() ;Travels to Doomlore, leaves group and switch to normal mode
	Local $Gron = GetNearestNPCToCoords(-19090, 17980)
	If GetMapID() <> $MAP_ID_DOOMLORE Then
		Out("Traveling to Doomlore.")
		Travel($MAP_ID_DOOMLORE)
	EndIf
	SwitchMode(0)
	RndSleep(100)
	SetUpFastWay()

	$BoolInitResign = True
EndFunc   ;==>Setup

Func SetUpFastWay() ;Setup resign and starts farm
	GUICtrlSetData($storageGold, GetGoldStorage())
	GUICtrlSetData($inventoryGold, GetGoldCharacter())
	LoadSkillTemplate("OgCjkqqLrSihdftXYijhOXhX7XA")

	Local $Gron = GetNearestNPCToCoords(-19090, 17980)

	Out("Setting up resign.")
	GoToNPC($Gron)
	Dialog($FIRST_DIALOG)
	RndSleep(GetPing() + 250)
	Dialog($SECOND_DIALOG)
	WaitMapLoading($MAP_ID_COF)
	Move(-19300, -8250)
	RndSleep(2500)
	WaitMapLoading($MAP_ID_DOOMLORE)
	RndSleep(100)
	Return True
EndFunc   ;==>SetUpFastWay

Func Zone_Fast_Way() ;Starts farm
	Out("Zoning.")
	; InventoryCheck()
	isInventoryFull()

	Local $Gron = GetNearestNPCToCoords(-19090, 17980)

	If isInventoryFull() Then
		GoToNPC($Gron)
		Dialog($THIRD_DIALOG)
		IdentItemToMerchant()
		SellItemToMerchant()
	EndIf
	GoToNPC($Gron)
	Dialog($FIRST_DIALOG)
	RndSleep(GetPing() + 250)
	Dialog($SECOND_DIALOG)
	WaitMapLoading($MAP_ID_COF)
	Return True
EndFunc   ;==>Zone_Fast_Way

#EndRegion Bot init Functions

#Region Combat Functions
Func AggroAndPrepare() ;Prepares players with enchants and aggro mobs
	MoveTo(-16850, -8930)
	UseSkill($iau, -2)
	UseSkillExCoF($vop)
	UseSkillExCoF($grenths)
	UseSkillExCoF($vos)
	UseSkillExCoF($mystic)
	MoveTo(-15220, -8950)
EndFunc   ;==>AggroAndPrepare

Func CheckVoS() ;Checks the Vow of Silence still active all time
	If IsRecharged($vos) Then
		UseSkillExCoF($pious)
		UseSkillExCoF($grenths)
		UseSkillExCoF($vos)
	EndIf
EndFunc   ;==>CheckVoS

Func Kill() ;Kills mobs
	If GetMapLoading() == 2 Then Disconnected()
	If GetIsDead(-2) Then Return
	While GetNumberOfFoesInRangeOfAgent(-2, 1000) > 0
		If GetMapLoading() == 2 Then Disconnected()
		If GetIsDead(-2) Then Return
		CheckVoS()
		TargetNearestEnemy()
		If GetHasCondition(GetCurrentTarget()) And GetSkillbarSkillAdrenaline($reap) >= 120 Then
			UseSkill($reap, -1)
			RndSleep(800)
			ContinueLoop
		EndIf
		If GetSkillbarSkillAdrenaline($crippling) >= 150 Then
			UseSkill($crippling, -1)
			RndSleep(800)
			ContinueLoop
		EndIf
		Sleep(100)
		TargetNearestEnemy()
		Attack(-1)
	WEnd
	RndSleep(200)
	If Not isInventoryFull() Then PickUpLoot()
EndFunc   ;==>Kill

Func UseSkillExCoF($lSkill, $lTgt = -2, $aTimeout = 3000) ;Uses a skill and wait for it to be used.
	If GetIsDead(-2) Then Return
	If Not IsRecharged($lSkill) Then Return
	Local $Skill = GetSkillByID(GetSkillBarSkillID($lSkill, 0))
	Local $Energy = StringReplace(StringReplace(StringReplace(StringMid(DllStructGetData($Skill, 'Unknown4'), 6, 1), 'C', '25'), 'B', '15'), 'A', '10')
	If GetEnergy(-2) < $Energy Then Return
	Local $lAftercast = DllStructGetData($Skill, 'Aftercast')
	Local $lDeadlock = TimerInit()
	UseSkill($lSkill, $lTgt)
	Do
		Sleep(50)
		If GetIsDead(-2) = 1 Then Return
	Until (Not IsRecharged($lSkill)) Or (TimerDiff($lDeadlock) > $aTimeout)
	Sleep($lAftercast * 1000)
EndFunc   ;==>UseSkillExCoF

#Region Player & Mobs Interactions Functions
Func GetNumberOfFoesInRangeOfAgent($aAgent = -2, $aRange = 1250)
	If GetMapLoading() == 2 Then Disconnected()
	Local $lAgent, $lDistance
	Local $lCount = 0, $lAgentArray = GetAgentArray(0xDB)
	If Not IsDllStruct($aAgent) Then $aAgent = GetAgentByID($aAgent)
	For $i = 0 To $lAgentArray[0]
		$lAgent = $lAgentArray[$i]
		If BitAND(DllStructGetData($lAgent, 'typemap'), 262144) Then
			If StringLeft(GetAgentName($lAgent), 7) <> "Servant" Then ContinueLoop
		EndIf
		If DllStructGetData($lAgent, 'Allegiance') <> 3 Then ContinueLoop
		If DllStructGetData($lAgent, 'HP') <= 0 Then ContinueLoop
		If BitAND(DllStructGetData($lAgent, 'Effects'), 0x0010) > 0 Then ContinueLoop
		$lDistance = GetDistance($lAgent)
		If $lDistance > $aRange Then ContinueLoop
		$lCount += 1
	Next
	Return $lCount
EndFunc   ;==>GetNumberOfFoesInRangeOfAgent
#EndRegion Player & Mobs Interactions Functions
#EndRegion Combat Functions

#Region Environnement Interactions Functions
Func PickUpLoot()
	If GetMapLoading() == 2 Then Disconnected()
	Local $lMe, $lAgent, $lItem
	Local $lBlockedTimer
	Local $lBlockedCount = 0
	Local $lItemExists = True
	GUICtrlSetData($storageGold, GetGoldStorage())
	GUICtrlSetData($inventoryGold, GetGoldCharacter())
	For $i = 1 To GetMaxAgents()
		If GetMapLoading() == 2 Then Disconnected()
		$lMe = GetAgentByID(-2)
		If DllStructGetData($lMe, 'HP') <= 0.0 Then Return
		$lAgent = GetAgentByID($i)
		If Not GetIsMovable($lAgent) Then ContinueLoop
		If Not GetCanPickUp($lAgent) Then ContinueLoop
		$lItem = GetItemByAgentID($i)
		If CanPickUp($lItem) Then
			Do
				If GetMapLoading() == 2 Then Disconnected()

				PickUpItem($lItem)
				$m = DllStructGetData($lItem, 'ModelID')
				For $vKey In $dropCounterLabels
					If ($m == $vkey) Then
						$dropCounter.Item($vkey) = $dropCounter.Item($vkey) + DllStructGetData($lItem, 'Quantity')
						GUICtrlSetData($dropCounterLabels.Item($vkey), $dropCounter.Item($vkey))
					EndIf
				Next
				Sleep(GetPing())
				Do
					Sleep(100)
					$lMe = GetAgentByID(-2)
				Until DllStructGetData($lMe, 'MoveX') == 0 And DllStructGetData($lMe, 'MoveY') == 0
				$lBlockedTimer = TimerInit()
				Do
					Sleep(3)
					$lItemExists = IsDllStruct(GetAgentByID($i))
				Until Not $lItemExists Or TimerDiff($lBlockedTimer) > Random(5000, 7500, 1)
				If $lItemExists Then $lBlockedCount += 1
			Until Not $lItemExists Or $lBlockedCount > 5
		EndIf
		GUICtrlSetData($inventoryGold, GetGoldCharacter())
	Next
EndFunc   ;==>PickUpLoot

Func CheckArrayPscon($ModelID) ;Checks if loot's modelID is a pcons model (return True if it is)
	For $p = 0 To (UBound($Array_pscon) - 1)
		If ($ModelID == $Array_pscon[$p]) Then Return True
	Next
EndFunc   ;==>CheckArrayPscon
#EndRegion Environnement Interactions Functions

#Region Map interaction Functions
Func Travel($map)
	If GetMapID() <> $map Then
		TravelTo($map)
		WaitMapLoading($map)
	EndIf
EndFunc  
#EndRegion Map interaction Functions

#Region Sell Functions

Func SellItemToMerchant() ;Sell authorized items in authorized bags
	For $i = 0 To 3
		If (GUICtrlRead($bags[$i]) == $GUI_CHECKED) Then
			Sell($i + 1)
		EndIf
	Next
EndFunc   ;==>SellItemToMerchant
#EndRegion Sell Functions

Func CanIdent($aitem) ;Lists the unauthorized items to be sold and check if the item input can be sold
	Local $lItemID = DllStructGetData($aitem, 'ID')
	Local $iRarity = GetRarity($lItemID)
	If $iRarity == $RARITY_Gold Then
		If GUICtrlRead($GoldIdent) == $GUI_CHECKED Then
			Return False
		Else
			Return True
		EndIf
	EndIf
	Switch DllStructGetData($aitem, "iRarity")
		Case $RARITY_Purple, $RARITY_Blue, $RARITY_White
			Return False
		Case Else
			Return True
	EndSwitch
EndFunc   ;==>CanIdent

Func IdentItemToMerchant() ;Ident items in authorized bags
	For $i = 0 To 3

		If (GUICtrlRead($bags[$i]) == $GUI_CHECKED) Then
			Ident($i + 1)
		EndIf
	Next
EndFunc   ;==>IdentItemToMerchant

Func Logfile($STRING)
	$FILE = FileOpen("log - " & GUICtrlRead($CharInput) & ".txt", 1)
	FileWrite($FILE, $STRING & @CRLF)
	FileClose($FILE)
EndFunc   ;==>Logfile

Func _exit()
	Exit
EndFunc   ;==>_exit
