#include "includes/GW_Api.au3"

Global $NQ = 216 ; Nahpui Quarter
Global $WB = 239 ; Wajing Basar

Opt("GUIOnEventMode", 1)

;Rare Materials
Opt("GUIOnEventMode", True)
Opt("GUICloseOnESC", False)
$title = "Celestial Farmer"
$Gui = GUICreate($title & " - Sin Edition", 362, 420, -1, -1)
Local $dropCounterDictionary = ObjCreate("Scripting.Dictionary")
$dropCounterDictionary.Add($ITEM_ID_monstrous_eye, "Monstrous Eye")
$dropCounterDictionary.Add($ITEM_ID_amber, "Amber")
$dropCounterDictionary.Add($ITEM_ID_ruby, "Ruby")
$dropCounterDictionary.Add("Celestial", "Celestial")

Global $farmSpecific[4] = [$dropCounterDictionary.Keys]

initGui($dropCounterDictionary)

DeactivateAllGUI()

GUISetOnEvent($GUI_EVENT_CLOSE, "_exit")
GUISetState(@SW_SHOW)

Out("Ready to start.")
While Not $BotRunning
	Sleep(100)
WEnd

AdlibRegister("TimeUpdater", 1000)
While 1
	GUICtrlSetData($storageGold, GetGoldStorage())
	GUICtrlSetData($inventoryGold, GetGoldCharacter())
	If Not $BotRunning Then
		SwitchMode(1)
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
	Travel($NQ)
	KickAllHeroes()
	LoadSkillTemplate("OwJTYZ/8ZiHRn5AKu8uU4A3B6AA")
	SwitchMode(1)
	AddHero(11)
	SetHeroAggression(1, 2)
	LoadSkillTemplate("OQijEymM6MDbT8NGAAAAAAAAAA", 1)
	Sleep(100)
	EnableHeroSkillSlot(1, 1)
	DisableHeroSkillSlot(1, 2)
	DisableHeroSkillSlot(1, 3)
	SetupResignPosition()
	While $BotRunning
		If isInventoryFull() Then
			SellAndBack()
		EndIf
		MainLoop()
	WEnd
WEnd

Func SellAndBack()
	RndSleep(1000)
	IDAndSell()
	If GetGoldCharacter() > 80000 Then
		Out("Depositing gold")
		DepositGold(70000)
		$intCash = GetGoldCharacter()
	EndIf
EndFunc   ;==>SellAndBack

Func HardLeave()
	If GetIsdead(-2) Then
		$Fails += 1
		GUICtrlSetData($FailsCount, $Fails)
	EndIf
	Sleep(Random(3000, 5000))
	Resign()
	Sleep(Random(4000, 6000))
	ReturnToOutpost()
	WaitMapLoading($NQ)
EndFunc   ;==>HardLeave

Func Travel($map)
	If GetMapID() <> $map Then
		TravelTo($map)
		WaitMapLoading($map)
	EndIf
EndFunc   ;==>Travel

Func MainLoop()
	While GetMapID() = $NQ
		MoveTo(-21648, 13750)
	WEnd
	While Not GetMapIsLoaded()
		Sleep(100)
	WEnd
	Out("Fixing Hero")
	UseHeroSkill(1, 1)
	While DllStructGetData(GetEffect(1731, 1), 'SkillID') <> 1731
		Sleep(100)
	WEnd
	CommandHero(1, 8946.49, -19282.36)
	UseHeroSkill(1, 2, GetAgentByID())
	While DllStructGetData(GetEffect(1574), 'SkillID') <> 1574
		Sleep(100)
	WEnd
	UseHeroSkill(1, 3, GetAgentByID())
	Out("Running to Starting point.")
	MoveTo(7860, -17800)
	MoveTo(4000, -17000)
	MoveTo(2700, -16500)
	Out("Casting Run Skills.")
	UseSkillEx(1)
	UseSkillEx(2)
	UseSkillEx(3)
	While GetEnergy(-2) <= 10
		Sleep(100)
	WEnd
	UseSkillEx(4)

	Out("Running to Waypoint 1.")
	MoveAndUseSF(-700, -16000)
	MoveAndUseSF(-900, -15400)
	MoveAndUseSF(-700, -14400)
	If GetIsdead(-2) Then
		HardLeave()
		Return False
	EndIf

	Out("Running to Waypoint 2.")
	MoveAndUseSF(800, -14500)
	If GetIsdead(-2) Then
		HardLeave()
		Return False
	EndIf

	Out("Preballing")
	Local $preballingTimer = 1500
	While $preballingTimer > 0
		StayAlive()
		$preballingTimer = $preballingTimer - 100
	WEnd

	Out("Running to Waypoint 3.")
	MoveAndUseSF(1038, -14991)
	If GetIsdead(-2) Then
		HardLeave()
		Return False
	EndIf

	Out("Balling Monks.")
	UseSkillEx(5)

	Local $ballingtime = 2000
	Sleep($ballingtime)

	Out("Balling Necros.")
	MoveTo(400, -14200)
	MoveTo(-400, -14200)

	MoveTo(-958, -14500)
	If GetIsdead(-2) Then
		HardLeave()
		Return False
	EndIf

	Out("Waiting for SF.")
	$enemy = DllStructGetData(GetBestTarget(), 'ID')

	Out('Wooping ass.')
	UseSkillEx(7, $enemy)
	UseSkillEx(6)
	UseSkillEx(8)

	$Timeout = 0
	While Not GetIsDead($enemy)
		If IsRecharged(2) And DllStructGetData(GetEffect(826), 'SkillID') <> 826 Then
			UseSkillEx(2)
		EndIf
		Sleep(100)
		$Timeout = $Timeout + 100
		If $Timeout > 10000 Then ExitLoop
	WEnd
	Sleep(100)

	Out("Loot :D")
	PickUpLoot()
	Out("Repeat")
	$Runs += 1
	GUICtrlSetData($RunsCount, $Runs)
	GUICtrlSetData($AvgTimeCount, AvgTime())
	HardLeave()

EndFunc   ;==>MainLoop

Func MoveAndUseSF($lDestX, $lDestY)
	While ComputeDistance(DllStructGetData(GetAgentByID(), 'X'), DllStructGetData(GetAgentByID(), 'Y'), $lDestX, $lDestY) > 100
		If Not StayAlive() Then
			Return False
		EndIf
		If Not GetIsMoving(-2) Then
			Move($lDestX, $lDestY)
		EndIf
	WEnd
	Return True
EndFunc   ;==>MoveAndUseSF

Func StayAlive($timer = 100)
	If IsRecharged(2) And DllStructGetData(GetEffect(826), 'SkillID') <> 826 And GetEnergy(-2) >= 20 Then
		UseSkillEx(1)
		UseSkillEx(2)
	EndIf
	Sleep($timer)
	Return Not GetIsDead(-2)
EndFunc   ;==>StayAlive

Func SetupResignPosition()
	While GetMapID() = $NQ
		MoveTo(-21648, 13750)
	WEnd
	While Not GetMapIsLoaded()
		Sleep(100)
	WEnd
	While GetMapID() = $WB
		MoveTo(9050, -20000)
	WEnd
	While Not GetMapIsLoaded()
		Sleep(100)
	WEnd
EndFunc   ;==>SetupResignPosition

Func Dist($x1, $y1, $x2, $y2)
	$x1 = ($x1 - $x2) * ($x1 - $x2)
	$y1 = ($y1 - $y2) * ($y1 - $y2)
	Return Sqrt($x1 + $y2)
EndFunc   ;==>Dist

Func IDAndSell()
	RndSleep(1000)

	;GoToMerch
	MoveTo(-18693, 10132, 100)
	GoNearestNPCToCoords(-18693, 10132)

	;Buy ID KIT if not available
	SecureIDKit()
	For $i = 0 To 3
		If (GUICtrlRead($bags[$i]) == $GUI_CHECKED) Then
			Ident($i + 1)
		EndIf
	Next

	For $i = 0 To 3
		If (GUICtrlRead($bags[$i]) == $GUI_CHECKED) Then
			Sell($i + 1)
		EndIf
	Next

	GUICtrlSetData($inventoryGold, GetGoldCharacter())
EndFunc   ;==>IDAndSell

Func PickUpLoot()
	Local $lAgent
	Local $aitem
	Local $lDeadlock
	For $i = 1 To GetMaxAgents()
		If GetIsDead(-2) Then Return
		If IsRecharged(2) And DllStructGetData(GetEffect(826), 'SkillID') <> 826 Then
			UseSkillEx(2)
		EndIf
		$lAgent = GetAgentByID($i)
		If Not GetIsMovable($lAgent) Then ContinueLoop
		If Not GetCanPickUp($lAgent) Then ContinueLoop
		$aitem = GetItemByAgentID($i)
		If CanPickUp($aitem) Then
			PickUpItem($aitem)
			$m = DllStructGetData($aitem, 'ModelID')
			For $vKey In $dropCounterLabels
				If ($m == $vkey) Then
					$dropCounter.Item($vkey) = $dropCounter.Item($vkey) + DllStructGetData($aitem, 'Quantity')
					GUICtrlSetData($dropCounterLabels.Item($vkey), $dropCounter.Item($vkey))
				EndIf
			Next
			If (_ArraySearch($CelestialWeapons, $m) <> -1) Then
				$dropCounter.Item("Celestial") = $dropCounter.Item("Celestial") + DllStructGetData($aitem, 'Quantity')
				GUICtrlSetData($dropCounterLabels.Item("Celestial"), $dropCounter.Item("Celestial"))
			EndIf
			$lDeadlock = TimerInit()
			While GetAgentExists($i)
				Sleep(100)
				If GetIsDead(-2) Then Return
				If TimerDiff($lDeadlock) > 10000 Then ExitLoop
			WEnd
		EndIf
		GUICtrlSetData($inventoryGold, GetGoldCharacter())
	Next

EndFunc   ;==>PickUpLoot

Func GoNearestNPCToCoords($x, $y)
	Do
		RndSleep(250)
		$guy = GetNearestNPCToCoords($x, $y)
	Until DllStructGetData($guy, 'Id') <> 0
	ChangeTarget($guy)
	RndSleep(250)
	GoNPC($guy)
	RndSleep(250)
	Do
		RndSleep(100)
		MoveTo(DllStructGetData($guy, 'X'), DllStructGetData($guy, 'Y'), 40)
		RndSleep(100)
		GoNPC($guy)
		RndSleep(250)
		$Me = GetAgentByID(-2)
	Until ComputeDistance(DllStructGetData($Me, 'X'), DllStructGetData($Me, 'Y'), DllStructGetData($guy, 'X'), DllStructGetData($guy, 'Y')) < 250
	RndSleep(1000)
EndFunc   ;==>GoNearestNPCToCoords

Func _exit()
	Exit
EndFunc   ;==>_exit
