#Region Include
#include "includes/GW_Api.au3"
#EndRegion Include


Opt("GUIOnEventMode", True)
Opt("GUICloseOnESC", False)
$title = "Crude shield Farmer"
$Gui = GUICreate($title & " - Ele Edition", 362, 420, -1, -1)
Local $dropCounterDictionary = ObjCreate("Scripting.Dictionary")
$dropCounterDictionary.Add(330, "Crude Shields")

Global $farmSpecific[1] = [$dropCounterDictionary.Keys]
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
		$died = 1
		Sleep(2000)
	Else
		$Runs += 1
		Out("Run completed in " & GetTime() & ".")
		GUICtrlSetData($RunsCount, $Runs)
		GUICtrlSetData($AvgTimeCount, AvgTime())
	EndIf
	Out("Returning to Nolani.")
	ZoneMap($MAP_ID_NOLANI)
	Do
		Sleep(100)
	Until GetMapLoading() == 0
	WaitMapLoading($MAP_ID_NOLANI)
EndFunc   ;==>MainLoop
#EndRegion Loops

#Region Bot init Functions
Func Setup()
	Out('Setup')
	If GetMapID() <> $MAP_ID_NOLANI Then
		Out("Traveling to Nolani.")
		Travel($MAP_ID_NOLANI)
	EndIf
	WaitMapLoading($MAP_ID_NOLANI)
	SwitchMode(1)
	LoadSkillTemplate('OgNCkMzk8AtANZuYpwXFP0yA')
	Zone()
EndFunc   ;==>Setup

Func Zone() ;Starts farm
	Local $merchant = GetAgentByPlayerNumber(2101)
	If isInventoryFull() Then
		Out('Merchant')
		MoveTo(-1924.00, 14692.00)
		Sleep(500)
		GoToNPC($merchant)
		IdentItemToMerchant()
		SellItemToMerchant()
		CloseAllPanels()
	EndIf
	Sleep(500)
	EnterChallengeForeign()
	Sleep(4000)
	Out("Entering mission.")
	WaitMapLoading($MAP_ID_NOLANI)
	If GetMapLoading() == 0 Then
		EnterChallengeForeign()
		Sleep(4000)
		WaitMapLoading($MAP_ID_NOLANI)
	EndIf
	Return True
EndFunc   ;==>Zone

#EndRegion Bot init Functions

#Region Combat Functions
Func AggroAndPrepare() ;Prepares players with enchants and aggro mobs
	Out('Running to lever')
	UseSkillEx(1)
	MoveTo('-1300.12', '11786.02')
	$lever = GetNearestAgentToCoords('-674.80', '11801.90')
	MoveTo(DllStructGetData($lever, 'X'), DllStructGetData($lever, 'Y'))
	Sleep(500)
	TargetNearestItem()
	UseSkillEx(5)
	UseSkillEx(6)
	ActionInteract()
	Out('Moving to Sweetspot')
	MoveTo('-160', '11800')
EndFunc   ;==>AggroAndPrepare

Func MoveSafely($lDestX, $lDestY)
	$moveTimer = TimerInit()
	$blockedCount = 0
	$aRandom = 100
	While ComputeDistance(DllStructGetData(GetAgentByID(), 'X'), DllStructGetData(GetAgentByID(), 'Y'), $lDestX, $lDestY) > 100 And TimerDiff($moveTimer) < 30000
		Out('SafeLoop')
		If GetMapLoading() == 2 Then Disconnected()
		If GetIsDead(-2) Then Return
		If Mod(TimerDiff($moveTimer), 2500) < 5 Then
			Out('ping stuck')
			SendChat("stuck", "/")
		EndIf
		If IsRecharged(5) And GetEffectTimeRemaining(165) < 5000 And GetEnergy(-2) >= 10 Then UseSkillWhileCheckingForMs(5)
		If IsRecharged(6) And GetEffectTimeRemaining(1375) < 5000 And GetEnergy(-2) >= 10 Then UseSkillWhileCheckingForMs(6)
		If Not GetIsMoving(-2) Then
			Move($lDestX, $lDestY, 0)
			Sleep(100)
		EndIf
		; Move backward since we almost certainly are closed in
		If DllStructGetData(GetAgentByID(), 'MoveX') == 0 And DllStructGetData(GetAgentByID(), 'MoveY') == 0 Then
			Out('Blocked')
			$blockedCount += 1
			If Mod($blockedCount, 50) < 5 Then
				Move(DllStructGetData(GetAgentByID(), 'X') + Random(-$aRandom, $aRandom), DllStructGetData(GetAgentByID(), 'Y') + Random(0, $aRandom), 0)
			EndIf
			If $blockedCount > 100 And IsRecharged(8) And IsRecharged(7) And GetEnergy(-2) >= 15 Then
				UseSkillWhileCheckingForMs(8)
				UseSkillEx(7, -2, 500)
			EndIf
			Sleep(1000)
		EndIf
	WEnd
	Return True
EndFunc   ;==>MoveSafely

Func UseSkillWhileCheckingForMs($skillId, $target = -2, $timeOut = 3000)
	If IsRecharged(3) And GetEnergy(-2) >= 5 And GetNumberOfFoesInRangeOfAgentCastingMS(2000) > 0 Then UseSkillEx(3)
	UseSkillEx($skillId, $target, $timeOut)
	Return
EndFunc   ;==>UseSkillWhileCheckingForMs

Func Kill() ;Kills mobs
	Out('Preparing to woop ass.')
	If GetMapLoading() == 2 Then Disconnected()
	If GetIsDead(-2) Then Return

	$target = GetNearestEnemyToAgent()
	$targetID = DllStructGetData($target, 'ID')

	$scattered = False
	$scatteredPrinted = False
	$timer = TimerInit()
	While GetNumberOfAxeFoesInRangeOfAgent(-2, 2000) > 0 And TimerDiff($timer) <= 65000
		If GetMapLoading() == 2 Then Disconnected()
		If GetIsDead(-2) Then Return
		If $scattered And Not $scatteredPrinted Then
			Out('Resuming Fight')
			$scatteredPrinted = True
		EndIf
		If IsRecharged(5) And GetEffectTimeRemaining(165) < 5000 And GetEnergy(-2) >= 10 Then UseSkillWhileCheckingForMs(5)
		If IsRecharged(6) And GetEffectTimeRemaining(1375) < 5000 And GetEnergy(-2) >= 10 Then UseSkillWhileCheckingForMs(6)
		If IsRecharged(4) And GetEnergy(-2) >= 10 And $scattered Then UseSkillWhileCheckingForMs(4)
		If IsRecharged(2) And GetEnergy(-2) >= 5 Then UseSkillWhileCheckingForMs(2)
		If IsRecharged(8) And IsRecharged(7) And GetEnergy(-2) >= 15 Then
			UseSkillWhileCheckingForMs(8)
			UseSkillEx(7, -2, 500)
		EndIf
		If Not $scattered Then
			Sleep(500)
			MoveSafely('-425.58', '11272.90')
			$scattered = True
			Out('Moved to final spot')
		EndIf
	WEnd
	Sleep(1000)
	If Not isInventoryFull() Then PickUpLoot()
EndFunc   ;==>Kill

#Region Player & Mobs Interactions Functions
Func GetNumberOfAxeFoesInRangeOfAgent($aAgent = -2, $aRange = 1250)
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
		If DllStructGetData($lAgent, 'WeaponType') <> 7 Then ContinueLoop
		$lCount += 1
	Next
	Return $lCount
EndFunc   ;==>GetNumberOfAxeFoesInRangeOfAgent

Func GetNumberOfFoesInRangeOfAgentCastingMS($aAgent = -2, $aRange = 1250)
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
		If DllStructGetData($lAgent, 'Skill') <> 192 Then ContinueLoop
		$lCount += 1
	Next
	Return $lCount
EndFunc   ;==>GetNumberOfFoesInRangeOfAgentCastingMS

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
		If IsRecharged(5) And GetEffectTimeRemaining(165) < 5000 And GetEnergy(-2) >= 10 Then UseSkillWhileCheckingForMs(5)
		If IsRecharged(6) And GetEffectTimeRemaining(1375) < 5000 And GetEnergy(-2) >= 10 Then UseSkillWhileCheckingForMs(6)
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
