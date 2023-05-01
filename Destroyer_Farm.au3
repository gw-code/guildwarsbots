#Region Include
#include "includes/GW_Api.au3"
#EndRegion Include


Opt("GUIOnEventMode", True)
Opt("GUICloseOnESC", False)
$title = "Destroyer Core Farmer"
$Gui = GUICreate($title & " - Ranger Edition", 362, 420, -1, -1)
Local $dropCounterDictionary = ObjCreate("Scripting.Dictionary")
$dropCounterDictionary.Add($ITEM_ID_Destroyer_Core, "Dcores")

Local $dropKeys = $dropCounterDictionary.Keys
_ArrayConcatenate($wontSell, $dropKeys)

initGui($dropCounterDictionary)

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
	Setup()
	MainLoop()
WEnd

Func MainLoop()
	DeactivateAllGUI(0)
	DepositGold()
	AggroAndPrepare()
	Kill()
	$died = 0
	If GetIsDead(-2) Then
		$Fails += 1
		Out("Run failed: Dead.")
		GUICtrlSetData($FailsCount, $Fails)
		GUICtrlSetData($AvgTimeCount, AvgTime())
		$died = 1
	Else
		$Runs += 1
		Out("Run completed in " & GetTime() & ".")
		GUICtrlSetData($RunsCount, $Runs)
		GUICtrlSetData($AvgTimeCount, AvgTime())
	EndIf
	Out("Returning to CTC.")
	Travel($MAP_ID_CTC)
	WaitMapLoading($MAP_ID_CTC)
EndFunc   ;==>MainLoop

#EndRegion Loops

#Region Bot init Functions
Func Setup()
	If GetMapID() <> $MAP_ID_CTC Then
		Out("Traveling to CTC.")
		Travel($MAP_ID_CTC)
	EndIf
	WaitMapLoading($MAP_ID_CTC)
	SwitchMode(0)
	LoadSkillTemplate('OgcTcXs9ZiHRn5AiAiVE354Q4AA')
	Zone()
	$BoolInitResign = True
EndFunc   ;==>Setup

Func Zone() ;Starts farm
	Local $brand = GetAgentByPlayerNumber(6227)
	Local $rockFist = GetAgentByPlayerNumber(6235)
	If isInventoryFull() Then
		GoToNPC($rockFist)
		IdentItemToMerchant()
		SellItemToMerchant()
		CloseAllPanels()
		GoToNPC($brand)
	EndIf
	GoToNPC($brand)
	Out("Entering Glints.")
	Dialog(0x86)
	WaitMapLoading($MAP_ID_GLINTS)
	Return True
EndFunc   ;==>Zone

#EndRegion Bot init Functions

#Region Combat Functions
Func AggroAndPrepare() ;Prepares players with enchants and aggro mobs
	Out('Switching to staff.')
	ChangeWeaponSet(2)
	Out('Moving to sweet spot.')
	MoveTo(-3327.01, 741.03)
	Out('Waiting for all destroyers to arive.')
	While Not GetIsDead(7)
		Sleep(100)
	WEnd
	While GetInstanceUpTime() < 225000
		If Not StayAlive() Then
			Return False
		EndIf
	WEnd

	While DllStructGetData(GetEffect(455), 'SkillID') == 455
		Sleep(100)
		StayAlive(1)
	WEnd

	Out('Balling destroyers.')
	MoveSafely(-2676.40, 1735.90)
	WaitAndStayAlive(2000)
	MoveSafely(-2232.54, 3384.54)
	WaitAndStayAlive(2000)
	MoveSafely(-2253.28, 810.86)
	WaitAndStayAlive(2000)
	UseSkillEx(7)
	Sleep(100)
EndFunc   ;==>AggroAndPrepare

Func WaitAndStayAlive($timeout)
	$timer = TimerInit()
	Do
		If Not StayAlive(1) Then
			Return False
		EndIf
	Until TimerDiff($timer) >= $timeout
EndFunc   ;==>WaitAndStayAlive

Func MoveSafely($lDestX, $lDestY)
	While ComputeDistance(DllStructGetData(GetAgentByID(), 'X'), DllStructGetData(GetAgentByID(), 'Y'), $lDestX, $lDestY) > 100
		If Not StayAlive(1) Then
			Return False
		EndIf
		If Not GetIsMoving(-2) Then
			Move($lDestX, $lDestY, 0)
		EndIf
	WEnd
	Return True
EndFunc   ;==>MoveSafely

Func StayAlive($walk = 0, $dp = 1)
	If IsRecharged(3) And GetEffectTimeRemaining(1031) < 3000 And GetEnergy(-2) >= 10 Then
		UseSkillEx(3)
	EndIf
	If IsRecharged(2) And GetEffectTimeRemaining(826) < 3000 And GetEnergy(-2) >= 20 Then
		If $dp == 1 Then
			UseSkillEx(1)
		EndIf
		UseSkillEx(2)
	EndIf
	If IsRecharged(4) And GetEffectTimeRemaining(1028) < 3000 And GetEnergy(-2) >= 10 Then
		UseSkillEx(4)
	EndIf
	If IsRecharged(5) And GetEffectTimeRemaining(2220) < 2000 And GetEnergy(-2) >= 10 Then
		UseSkillEx(5)
	EndIf
	;energy plox
	If (GetInstanceUpTime() < 210000 Or $walk == 0) And IsRecharged(7) Then
		UseSkillEx(7)
	EndIf
	Sleep(25)
	Return Not GetIsDead(-2)
EndFunc   ;==>StayAlive

Func Kill() ;Kills mobs
	Out('Preparing to woop ass.')
	ChangeWeaponSet(1)
	If GetMapLoading() == 2 Then Disconnected()
	If GetIsDead(-2) Then Return
	$target = GetBestTarget()
	$targetID = DllStructGetData($target, 'ID')
	Out('Wooping ass.')
	UseSkillEx(6, $targetID)
	UseSkillEx(8)

	$timer = TimerInit()
	While GetNumberOfFoesInRangeOfAgent(-2, 2000) > 7 And DllStructGetData(GetEffect(450), 'SkillID') == 450 And Not GetIsDead(-2) And TimerDiff($timer) <= 12000
		If GetMapLoading() == 2 Then Disconnected()
		If GetIsDead(-2) Then Return
		If GetIsDead($targetID) Then
			If Not isInventoryFull() Then PickUpLoot()
			$target = GetBestTarget()
			$targetID = DllStructGetData($target, 'ID')
			MoveTo(DllStructGetData($target, 'X'), DllStructGetData($target, 'Y'))
		EndIf
		Attack(-1)
		StayAlive(1, 0)
	WEnd
	Sleep(100)
	If Not isInventoryFull() Then PickUpLoot()
EndFunc   ;==>Kill

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
		StayAlive(1,0)
		If GetMapLoading() == 2 Then Disconnected()
		$lMe = GetAgentByID(-2)
		If DllStructGetData($lMe, 'HP') <= 0.0 Then Return
		$lAgent = GetAgentByID($i)
		If Not GetIsMovable($lAgent) Then ContinueLoop
		If Not GetCanPickup($lAgent) Then ContinueLoop
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
EndFunc   ;==>Travel
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
