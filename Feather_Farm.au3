#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <ScrollBarsConstants.au3>
#include <EditConstants.au3>
#include <GuiEdit.au3>
#include "includes/GW_API.au3"
#NoTrayIcon

#Region Constants
Global Const $weapon_slot_shield = 2
Global Const $Outpost_ID = 250
Global Const $Explorable_ID = 196
Global $LL = 250
#EndRegion Constants

Opt("GUIOnEventMode", True)
Opt("GUICloseOnESC", False)
$title = "Feather Farmer"
$Gui = GUICreate($title & " - Derv Edition", 362, 420, -1, -1)
Local $dropCounterDictionary = ObjCreate("Scripting.Dictionary")
$dropCounterDictionary.Add($ITEM_ID_feather, "Feather")
$dropCounterDictionary.Add($ITEM_ID_Feathered_Crest, "Crests")
$dropCounterDictionary.Add($ITEM_ID_BONES, "Bones")
$dropCounterDictionary.Add($ITEM_ID_Shing_Jea_Key, "Keys")

Local $dropKeys = $dropCounterDictionary.Keys
_ArrayConcatenate($wontSell, $dropKeys)

initGui($dropCounterDictionary)

#Region Disable GUI
DeactivateAllGUI()
#EndRegion Disable GUI


GUISetOnEvent($GUI_EVENT_CLOSE, "_exit")
GUISetState(@SW_SHOW)


#Region Loops
Out("Ready.")
While Not $BotRunning
	Sleep(500)
WEnd

AdlibRegister("TimeUpdater", 1000)
Setup()
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
			Sleep(500)
		WEnd
		AdlibRegister("TimeUpdater", 1000)
	EndIf
	MainLoop()
WEnd
#EndRegion Loops

#Region Functions

Func Setup()
	GUICtrlSetData($storageGold, GetGoldStorage())
	GUICtrlSetData($inventoryGold, GetGoldCharacter())
	If GetMapID() <> $Outpost_ID Then
		Out("Travelling to Seitung.")
		TravelTo($Outpost_ID)
	EndIf
	Out("Loading skillbar.")
	LoadSkillTemplate('OgejkqrMLSmXfbaXNXTQ3lEYsXA')
	LeaveGroup()
	SwitchMode(0)
	ChangeWeaponSet($weapon_slot_shield)
	Sleep(750)
	SetUpFastWay()
EndFunc   ;==>Setup

Func SetUpFastWay()
	Out("Setting up resign")
	Zone()
	Move(10970, -13360)
	WaitMapLoading($Outpost_ID)
	Return True
EndFunc   ;==>SetUpFastWay

Func MainLoop()
	If GetMapID() == $Outpost_ID Then
		ChangeWeaponSet($weapon_slot_shield)
		Zone_Fast_Way()
	Else
		Setup()
		Zone_Fast_Way()
	EndIf
	Out("Running to Sensali.")
	MoveRun(7588, -10609)
	MoveRun(2900, -9700)
	MoveRun(1540, -6995)
	MoveKill(-472, -4342, False)
	Out("Farming Sensali.")
	MoveKill(-1536, -1686)
	MoveKill(586, -76)
	MoveKill(-1556, 2786)
	MoveKill(-2229, -815)
	MoveKill(-5247, -3290)
	MoveKill(-5247, -3290)
	MoveKill(-6994, -2273)
	MoveKill(-5042, -6638)
	MoveKill(-11040, -8577)
	MoveKill(-10860, -2840)
	MoveKill(-14900, -3000)
	MoveKill(-12200, 150)
	MoveKill(-12500, 4000)
	MoveKill(-12111, 1690)
	MoveKill(-10303, 4110)
	MoveKill(-10500, 5500)
	MoveKill(-9700, 2400)

	If GetIsDead(-2) Then
		$Fails += 1
		Out("I'm dead.")
		GUICtrlSetData($FailsCount, $Fails)
	Else
		$Runs += 1
		Out("Completed in " & GetTime() & ".")
		GUICtrlSetData($RunsCount, $Runs)
		GUICtrlSetData($AvgTimeCount, AvgTime())
	EndIf
	Out("Returning to Seitung.")
	Resign()
	RndSleep(5000)
	ReturnToOutpost()
	WaitMapLoading($Outpost_ID)
EndFunc   ;==>MainLoop

Func PingSleep($msExtra = 0)
	$ping = GetPing()
	Sleep($ping + $msExtra)
EndFunc   ;==>PingSleep


Func Zone_Fast_Way()
	Do
		MoveTo(17171, 17331)
		PingSleep()
		Move(16800, 17500)
		Sleep(5000)
		WaitMapLoading($Explorable_ID)
	Until GetMapID() <> $LL
EndFunc   ;==>Zone_Fast_Way

Func Zone()
	If GetMapLoading() == 2 Then Disconnected()
	Local $Me = GetAgentByID(-2)
	Local $X = DllStructGetData($Me, 'X')
	Local $Y = DllStructGetData($Me, 'Y')
	If ComputeDistance($X, $Y, 18383, 11202) < 750 Then
		MoveTo(18127, 11740)
		MoveTo(19196, 13149)
		MoveTo(17288, 17243)
		Move(16800, 17550)
		WaitMapLoading($Explorable_ID)
		Return
	EndIf
	If ComputeDistance($X, $Y, 18786, 9415) < 750 Then
		MoveTo(20556, 11582)
		MoveTo(19196, 13149)
		MoveTo(17288, 17243)
		Move(16800, 17550)
		WaitMapLoading($Explorable_ID)
		Return
	EndIf
	If ComputeDistance($X, $Y, 16669, 11862) < 750 Then
		MoveTo(17912, 13531)
		MoveTo(19196, 13149)
		MoveTo(17288, 17243)
		Move(16800, 17550)
		WaitMapLoading($Explorable_ID)
		Return
	EndIf
	MoveTo(19196, 13149)
	MoveTo(17288, 17243)
	Move(16800, 17550)
	WaitMapLoading($Explorable_ID)
EndFunc   ;==>Zone

Func MoveRun($DestX, $DestY)
	If GetMapLoading() == 2 Then Disconnected()
	If GetIsDead(-2) Then Return
	Local $Me
	Move($DestX, $DestY)
	Do
		If GetMapLoading() == 2 Then Disconnected()
		If IsRecharged(6) Then UseSkillEx(6)
		If IsRecharged(5) Then UseSkillEx(5)
		$Me = GetAgentByID(-2)
		If DllStructGetData($Me, "HP") < 0.95 Then
			If GetEffectTimeRemaining(1516) <= 0 Then UseSkillEx(8)
		EndIf
		If GetIsDead(-2) Then Return
		If DllStructGetData($Me, 'MoveX') == 0 Or DllStructGetData($Me, 'MoveY') == 0 Then Move($DestX, $DestY)
		RndSleep(250)
	Until ComputeDistance(DllStructGetData($Me, 'X'), DllStructGetData($Me, 'Y'), $DestX, $DestY) < 250
EndFunc   ;==>MoveRun

Func MoveKill($DestX, $DestY, $aWaitForSettle = True)
	If GetMapLoading() == 2 Then Disconnected()
	If GetIsDead(-2) Then Return
	Local $Me = GetAgentByID(-2)
	Local $Angle
	Local $lStuckCount = 0
	Local $Blocked = 0
	Move($DestX, $DestY)
	Do
		If GetMapLoading() == 2 Then Disconnected()
		If GetIsDead(-2) Then Return
		If IsRecharged(6) Then UseSkillEx(6)
		If IsRecharged(5) Then UseSkillEx(5)
		If DllStructGetData($Me, "HP") < 0.9 Then
			If GetEffectTimeRemaining(1516) <= 0 Then UseSkillEx(8)
			If GetEffectTimeRemaining(1540) <= 0 Then UseSkillEx(7)
		EndIf
		TargetNearestEnemy()
		$Me = GetAgentByID(-2)
		If GetNumberOfFoesInRangeOfAgent(-2, 1200) > 1 Then
			Sleep(2000)
			Kill($aWaitForSettle)
		EndIf
		If DllStructGetData($Me, 'MoveX') == 0 Or DllStructGetData($Me, 'MoveY') == 0 Then
			$Blocked += 1
			If $Blocked <= 5 Then
				Move($DestX, $DestY)
			Else
				$Me = GetAgentByID(-2)
				$Angle += 40
				Move(DllStructGetData($Me, 'X') + 300 * Sin($Angle), DllStructGetData($Me, 'Y') + 300 * Cos($Angle))
				Sleep(2000)
				Move($DestX, $DestY)
			EndIf
		EndIf
		$lStuckCount += 1
		If $lStuckCount > 25 Then
			$lStuckCount = 0
			SendChat("stuck", "/")
			RndSleep(50)
		EndIf
		RndSleep(250)
	Until ComputeDistance(DllStructGetData($Me, 'X'), DllStructGetData($Me, 'Y'), $DestX, $DestY) < 250
EndFunc   ;==>MoveKill

Func Kill($aWaitForSettle = True)
	If GetMapLoading() == 2 Then Disconnected()
	If GetIsDead(-2) Then Return
	Local $lStuckCount = 0
	SendChat("stuck", "/")
	RndSleep(50)
	If GetEffectTimeRemaining(1510) <= 0 Then UseSkillEx(1, -2)
	If $aWaitForSettle Then
		If Not WaitForSettle(1000, 210) Then Return False
	EndIf
	SendChat("stuck", "/")
	RndSleep(50)
	TargetNearestEnemy()
	ChangeWeaponSet($weapon_slot_scythe)
	Sleep(750)
	If IsRecharged(2) Then UseSkillEx(2, -2)
	If GetEnergy(-2) >= 10 Then
		UseSkillEx(3, -2)
		UseSkillEx(4, -1)
	EndIf
	While GetNumberOfFoesInRangeOfAgent(-2, 900) > 0
		If GetMapLoading() == 2 Then Disconnected()
		If GetIsDead(-2) Then Return
		TargetNearestEnemy()
		If GetEffectTimeRemaining(1516) <= 0 Then UseSkillEx(8, -2)
		If GetEffectTimeRemaining(1540) <= 0 Then UseSkillEx(7, -2)
		If GetEffectTimeRemaining(1510) <= 0 And GetNumberOfFoesInRangeOfAgent(-2, 300) > 1 Then UseSkillEx(1, -2)
		If GetEffectTimeRemaining(1759) <= 0 Then UseSkillEx(2, -2)
		$lStuckCount += 1
		If $lStuckCount > 100 Then
			$lStuckCount = 0
			SendChat("stuck", "/")
			RndSleep(50)
		EndIf
		Sleep(100)
		Attack(-1)
	WEnd
	RndSleep(500)
	PickUpLoot()
	ChangeWeaponSet($weapon_slot_shield)
	Sleep(750)
EndFunc   ;==>Kill

Func WaitForSettle($FarRange, $CloseRange, $Timeout = 10000)
	If GetMapLoading() == 2 Then Disconnected()
	Local $Target
	Local $Deadlock = TimerInit()
	Do
		If GetMapLoading() == 2 Then Disconnected()
		If GetIsDead(-2) Then Return False
		If DllStructGetData(GetAgentByID(-2), "HP") < 0.7 Then Return True
		If GetEffectTimeRemaining(1516) <= 0 Then UseSkillEx(8, -2)
		If GetEffectTimeRemaining(1540) <= 0 Then UseSkillEx(7, -2)
		If GetEffectTimeRemaining(1510) <= 0 Then UseSkillEx(1, -2)
		Sleep(100)
		$Target = GetFarthestEnemyToAgent(-2, $FarRange)
	Until GetNumberOfFoesInRangeOfAgent(-2, 900) > 0 Or (TimerDiff($Deadlock) > 5000)

	If GetNumberOfFoesInRangeOfAgent(-2, 900) == 0 Then Return False

	Local $Deadlock = TimerInit()
	Do
		If GetMapLoading() == 2 Then Disconnected()
		If GetIsDead(-2) Then Return False
		If DllStructGetData(GetAgentByID(-2), "HP") < 0.7 Then Return True
		If GetEffectTimeRemaining(1516) <= 0 Then UseSkillEx(8, -2)
		If GetEffectTimeRemaining(1540) <= 0 Then UseSkillEx(7, -2)
		If GetEffectTimeRemaining(1510) <= 0 Then UseSkillEx(1, -2)
		Sleep(100)
		$Target = GetFarthestEnemyToAgent(-2, $FarRange)
	Until (GetDistance(-2, $Target) < $CloseRange) Or (TimerDiff($Deadlock) > $Timeout)
	Return True
EndFunc   ;==>WaitForSettle

Func GetFarthestEnemyToAgent($aAgent = -2, $aDistance = 1250)
	If GetMapLoading() == 2 Then Disconnected()
	Local $lFarthestAgent, $lFarthestDistance = 0
	Local $lDistance, $lAgent, $lAgentArray = GetAgentArray(0xDB)
	If Not IsDllStruct($aAgent) Then $aAgent = GetAgentByID($aAgent)
	For $i = 1 To $lAgentArray[0]
		$lAgent = $lAgentArray[$i]
		If BitAND(DllStructGetData($lAgent, 'typemap'), 262144) Then ContinueLoop
		If DllStructGetData($lAgent, 'Allegiance') <> 3 Then ContinueLoop
		If DllStructGetData($lAgent, 'HP') <= 0 Then ContinueLoop
		If BitAND(DllStructGetData($lAgent, 'Effects'), 0x0010) > 0 Then ContinueLoop
		$lDistance = GetDistance($lAgent)
		If $lDistance > $lFarthestDistance And $lDistance < $aDistance Then
			$lFarthestAgent = $lAgent
			$lFarthestDistance = $lDistance
		EndIf
	Next
	Return $lFarthestAgent
EndFunc   ;==>GetFarthestEnemyToAgent

Func GetNumberOfFoesInRangeOfAgent($aAgent = -2, $aRange = 1250)
	If GetMapLoading() == 2 Then Disconnected()
	Local $lAgent, $lDistance
	Local $lCount = 0, $lAgentArray = GetAgentArray(0xDB)
	If Not IsDllStruct($aAgent) Then $aAgent = GetAgentByID($aAgent)
	For $i = 1 To $lAgentArray[0]
		$lAgent = $lAgentArray[$i]
		If Not IsSensali(DllStructGetData($lAgent, 'PlayerNumber')) Then ContinueLoop
		If BitAND(DllStructGetData($lAgent, 'typemap'), 262144) Then ContinueLoop
		If DllStructGetData($lAgent, 'Allegiance') <> 3 Then ContinueLoop
		If DllStructGetData($lAgent, 'HP') <= 0 Then ContinueLoop
		If BitAND(DllStructGetData($lAgent, 'Effects'), 0x0010) > 0 Then ContinueLoop
		$lDistance = GetDistance($lAgent, $aAgent)
		If $lDistance > $aRange Then ContinueLoop
		$lCount += 1
	Next
	Return $lCount
EndFunc   ;==>GetNumberOfFoesInRangeOfAgent

Func IsSensali($aPlayerNumber)
	If $aPlayerNumber == $ITEM_ID_sensali_claw Or $aPlayerNumber == $ITEM_ID_sensali_darkfeather Or $aPlayerNumber == $ITEM_ID_sensali_cutter Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>IsSensali

Func PickUpLoot()
	If GetMapLoading() == 2 Then Disconnected()
	Local $lMe, $lAgent, $lItem
	Local $lBlockedTimer
	Local $lBlockedCount = 0
	Local $lItemExists = True
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
				If $lBlockedCount > 2 Then UseSkillEx(6, -2)
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
					Sleep(100)
					$lItemExists = IsDllStruct(GetAgentByID($i))
				Until Not $lItemExists Or TimerDiff($lBlockedTimer) > Random(5000, 7500, 1)
				If $lItemExists Then $lBlockedCount += 1
			Until Not $lItemExists Or $lBlockedCount > 5
		EndIf
		GUICtrlSetData($inventoryGold, GetGoldCharacter())
	Next
EndFunc   ;==>PickUpLoot

Func _exit()
	Exit
EndFunc   ;==>_exit
