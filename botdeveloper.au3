#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseX64=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <ListviewConstants.au3>
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <Array.au3>
#include <GuiEdit.au3>
#include <Constants.au3>
#include <Misc.au3>
#include <GUIConstantsEx.au3>
#include <GuiListView.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include "includes\GW_API.au3"

;~ Initialization()

$aCharName = GetParam("Character Name")

If $aCharName= "" Then
	If Not Initialize(WinGetProcess("Guild Wars"), True, True, False) Then
		MsgBox(0, "Error", "Guild Wars it not running.")
		Exit
	EndIf
Else
	If Not Initialize($aCharName, True, True, False) Then
		MsgBox(0, "Error", "Can't find a Guild Wars client with that character name.")
		Exit
	EndIf
EndIf

Const $gWindowTitle = "GW Bot Developer Helper v1.1"
Opt("GUICoordMode", 0)

$gGUI = GUICreate($gWindowTitle, 570, 650)
$gCredits = GuiCtrlCreateLabel("By Tormiasz for GameRevision based on kaps1500's Info Tool.", 100, 8, 400, 20, $SS_CENTER) ;Please don't delete it
GUICtrlSetColor(-1, 0x0000CD)
GUICtrlSetFont(-1, 10, 300, 0, "Arial")

$gMainMenu = GUICtrlCreateMenu("&Main")
	$gExitMenu = GUICtrlCreateMenuItem("Exit", $gMainMenu)

$gOthersMenu = GUICtrlCreateMenu("Other Functions")
	$gGetSkillBar = GUICtrlCreateMenuItem("Get Skillbar", $gOthersMenu)
	$gGetEffects = GUICtrlCreateMenuItem("Get Effects", $gOthersMenu)

$gCharInfoGroup = GUICtrlCreateGroup("Character Info", -92, 20, 161, 113)
	$gID = GUICtrlCreateLabel("ID: X", 8, 15, 140, 17)
	$gCurrentTarGet = GUICtrlCreateLabel("Current Target: X", 0, 15, 133, 17)
	$gName = GUICtrlCreateLabel("Name: X", 0, 15, 141, 17)
	$gChanGetarGet = GUICtrlCreateButton("Change Target", 8, 20, 81, 17, 0)
	$gAttack = GUICtrlCreateButton("Attack", 80, 0, 41, 17, $WS_GROUP)


$gMapInfoGroup = GUICtrlCreateGroup("Map Info", 80, -65, 201, 113)
	$gMapID = GUICtrlCreateLabel("MapID: X", 8, 15, 81, 17)
	$gRegion = GUICtrlCreateLabel("Region: X", 0, 15, 99, 17)
	$gLang = GUICtrlCreateLabel("Language: X", 0, 15, 113, 17)
	$gMapLoading = GUICtrlCreateLabel("Map Loading: X", 0, 30, 103, 17)
	$gMapIsLoaded = GUICtrlCreateLabel("MapIsLoaded: X", 0, 15, 82, 17)
	$gInitMapLoading = GUICtrlCreateButton("Init MapLoading", 88, 0, 89, 17, 0)
	$gTravelTo = GUICtrlCreateButton("TravelTo", 28, -75, 62, 17, $WS_GROUP)
	$gZoneMap = GUICtrlCreateButton("ZoneMap", 0, 20, 62, 17, $WS_GROUP)
	$gMoveMap = GUICtrlCreateButton("MoveMap", 0, 20, 62, 17, $WS_GROUP)


$gPositionGroup = GUICtrlCreateGroup("Position", 100, -55, 153, 113)
	$gX = GUICtrlCreateLabel("X: X", 8, 20, 112, 17)
	$gY = GUICtrlCreateLabel("Y: X", 0, 20, 128, 17)
	$gRotation = GUICtrlCreateLabel("Rotation: X", 0, 25, 121, 17)
	$gMove = GUICtrlCreateButton("Move", 0, 25, 49, 17, $WS_GROUP)
	$gGetCoords = GUICtrlCreateButton("Get Coords", 50, 0, 81, 17, $WS_GROUP)


$gParameterlessGroup = GUICtrlCreateGroup('"Parameterless" Actions', -458, 30, 265, 135)
	$gTravelGH = GUICtrlCreateButton("Travel GH", 8, 22, 121, 17, 0)
	$gLeaveGH = GUICtrlCreateButton("Leave GH", 0, 22, 121, 17, 0)
	$gEnterChallenge = GUICtrlCreateButton("EnterChallange", 0, 22, 121, 17, 0)
	$gEnterChallengeForeign = GUICtrlCreateButton("EnterChallangeForeign", 0, 22, 121, 17, 0)
	$gReturnToOutpost = GUICtrlCreateButton("ReturnToOutpost", 0, 22, 121, 17, $WS_GROUP)
	$gCancelAction = GUICtrlCreateButton("CancelAction", 128, -88, 121, 17, $WS_GROUP)
	$gLeaveGroup = GUICtrlCreateButton("LeaveGroup", 0, 22, 121, 17, $WS_GROUP)
	$gSkipSinematic = GUICtrlCreateButton("SkipCinematic", 0, 22, 121, 17, $WS_GROUP)


$gOtherInfoGroup = GUICtrlCreateGroup("Other Information", 140, -66, 193, 135)
	$gGoldChar = GUICtrlCreateLabel("Gold: X", 8, 20, 151, 17)
	$gGoldStorage = GUICtrlCreateLabel("Gold Storage: X", 0, 20, 167, 17)
	$gPing = GUICtrlCreateLabel("Ping: X", 0, 20, 158, 17)
	$gDepositGold = GUICtrlCreateButton("DepositGold", -3, 23, 81, 17, $WS_GROUP)
	$gWithdrawGold = GUICtrlCreateButton("WithdrawGold", 1, 23, 81, 17, $WS_GROUP)
	$gDropGold = GUICtrlCreateButton("DropGold", 88, -12, 89, 17, $WS_GROUP)


$gParameterGroup = GUICtrlCreateGroup("Parameter Actions", -370, 50, 449, 145)
	$gUseSkill = GUICtrlCreateButton("UseSkill", 8, 20, 137, 17, 0)
	$gChangeSecProf = GUICtrlCreateButton("ChangeSecondProfession", 144, 0, 137, 17, $WS_GROUP)
	$gSetSkill = GUICtrlCreateButton("SetSkillbarSkill", 144, 0, 137, 17, $WS_GROUP)

	$gGoNPC = GUICtrlCreateButton("GoNPC", -288, 20, 137, 17, $WS_GROUP)
	$gGoPlayer = GUICtrlCreateButton("GoPlayer", 144, 0, 137, 17, $WS_GROUP)
	$gGoSignpost = GUICtrlCreateButton("GoSignpost", 144, 0, 137, 17, $WS_GROUP)

	$gAcceptQuest = GUICtrlCreateButton("AcceptQuest", -288, 20, 137, 17, $WS_GROUP)
	$gAbandonQuest = GUICtrlCreateButton("AbandonQuest", 144, 0, 137, 17, $WS_GROUP)
	$gQuestReward = GUICtrlCreateButton("QuestReward", 144, 0, 137, 17, $WS_GROUP)

	$gAddHero = GUICtrlCreateButton("AddHero", -288, 20, 137, 17, $WS_GROUP)
	$gCommandHero = GUICtrlCreateButton("CommandHero", 144, 0, 137, 17, $WS_GROUP)
	$gKickHero = GUICtrlCreateButton("KickHero", 144, 0, 137, 17, $WS_GROUP)

	$gDialog = GUICtrlCreateButton("Dialog", -288, 20, 137, 17, $WS_GROUP)
	$gAddNPC = GUICtrlCreateButton("AddNpc", 144, 0, 137, 17, $WS_GROUP)
	$gKickNPC = GUICtrlCreateButton("KickNpc", 144, 0, 137, 17, $WS_GROUP)

	$gSwitchMode = GUICtrlCreateButton("SwitchMode", -288, 20, 137, 17, $WS_GROUP)
	$gCommandAll = GUICtrlCreateButton("CommandAll", 144, 0, 137, 17, $WS_GROUP)
	$gChangeWeaponSet = GUICtrlCreateButton("ChangeWeaponset", 144, 0, 137, 17, 0)

$gOptionsGroup = GUICtrlCreateGroup("Options", 165, -120, 73, 81)
	$gOnTopCheckbox = GUICtrlCreateCheckbox("onTop", 8, 20, 57, 17)
	$gHideGW = GUICtrlCreateCheckbox("HideGW", 0, 25, 57, 17)


$gItemGroup = GUICtrlCreateGroup("Item Actions", -469, 120, 449, 65)
	$gPickUpItem = GUICtrlCreateButton("PickUpItem", 8, 20, 105, 17, $WS_GROUP)
	$gMoveItem = GUICtrlCreateButton("MoveItem", 110, 0, 105, 17, $WS_GROUP)
	$gSellItem = GUICtrlCreateButton("SellItem", 110, 0, 105, 17, $WS_GROUP)
	$gIdentifyItem = GUICtrlCreateButton("IdentifyItem", 110, 0, 105, 17, $WS_GROUP)
	$gSalvageItem = GUICtrlCreateButton("SalvageItem", -330, 20, 105, 17, $WS_GROUP)
	$gUseItem = GUICtrlCreateButton("UseItem", 110, 0, 105, 17, $WS_GROUP)
	$gEquipItem = GUICtrlCreateButton("EquipItem", 110, 0, 105, 17, $WS_GROUP)
	$gDropItem = GUICtrlCreateButton("DropItem", 110, 0, 105, 17, $WS_GROUP)


$gStructsGroup = GUICtrlCreateGroup("Structs", -338, 40, 449, 65)
	$gCurrentTarGetButton = GUICtrlCreateButton("Current Target Info", 8, 20, 105, 17, $WS_GROUP)
	$gAllAgentsInfo = GUICtrlCreateButton("All Agents Info", 110, 0, 105, 17, $WS_GROUP)
	$gAllBagsInfo = GUICtrlCreateButton("All Items Info", 110, 0, 105, 17, $WS_GROUP)
	$gSkillByIDInfo = GUICtrlCreateButton("Skill By ID", 110, 0, 105, 17, $WS_GROUP)

AdLibRegister("Refresh", 1000)
GUISetState(@SW_SHOW)
OnAutoItExitRegister("DeveloperShutdown")

While 1
	$gMSG = GUIGetMsg()
	Switch $gMSG
		Case $GUI_EVENT_CLOSE
			Exit
		Case $gExitMenu
			Exit
		Case $gGetSkillBar
			$gSkillBar = ""
			For $i = 1 To 8
				$SkillID = DllStructGetData(GetSkillbar(), "Id" & $i)
				$gSkillBar = $gSkillBar & StringFormat("Skill %d ID: %s", $i, $SkillID) & @CRLF
			Next
			MsgBox(0, $gWindowTitle, $gSkillBar)
		Case $gGetEffects
			$gEfffects = ""
			$EffectArray = GetEffect()
			For $i = 1 To $EffectArray[0]
				$EffectID = DllStructGetData($EffectArray[$i], 'SkillID')
				$gEfffects = $gEfffects & StringFormat("Effect %d ID: %s", $i, $EffectID) & @CRLF
			Next
			MsgBox(0, $gWindowTitle, $gEfffects)
		Case $gInitMapLoading
			InitMapLoad()
		Case $gGetCoords
			$cbcontent = StringFormat("%s, %s", StringReplace(GUICtrlRead($gX), "X: ", ""), StringReplace(GUICtrlRead($gY), "Y: ", ""))
			_TooltipMouseExit(StringFormat("Send '%s' to Clipboard.", $cbcontent), 2000)
			ClipPut($cbcontent)
		Case $gTravelGH
			TravelGH()
		Case $gLeaveGH
			LeaveGH()
		Case $gEnterChallenge
			EnterChallenge()
		Case $gEnterChallengeForeign
			EnterChallengeForeign()
		Case $gMove
			Move(GetParam("X Coord"), GetParam("Y Coord"))
		Case $gChanGetarGet
			ChanGetarGet(GetParam("New Target ID"))
		Case $gChangeWeaponSet
			Changeweaponset(GetParam("Set ID [1-4]"))
		Case $gUseSkill
			UseSkill(GetParam("Skillslot [1-8]"), GetParam("Target ID [-2 => self]"))
		Case $gMoveItem
			MoveItem(GetParam("Item ID"), GetParam("BagID"), GetParam("New Slot"))
		Case $gGoPlayer
			GoPlayer(GetParam("ID"))
		Case $gGoNPC
			GoNPC(GetParam("ID"))
		Case $gAbandonQuest
			AbandonQuest(GetParam("Quest ID"))
		Case $gMoveMap
			MoveMap(GetParam("Map ID"), GetParam("Region"), GetParam("District"), GetParam("Language"))
		Case $gAttack
			Attack(GetParam("ID"))
		Case $gZoneMap
			ZoneMap(GetParam("Map ID"), GetParam("District"))
		Case $gCancelAction
			CancelAction()
		Case $gDialog
			Dialog(GetParam("Dialog ID"))
		Case $gSalvageItem
			StartSalvage(GetParam("Item ID"))
		Case $gIdentifyItem
			IdentifyItem(GetParam("Item ID"))
		Case $gSellItem
			SellItem(GetParam("Item ID"))
		Case $gAcceptQuest
			AcceptQuest(GetParam("Quest ID"))
		Case $gTravelTo
			TravelTo(GetParam("Map ID"), GetParam("District"))
		Case $gEquipItem
			EquipItem(GetParam("Item ID"))
		Case $gUseItem
			UseItem(GetParam("Item ID"))
		Case $gPickUpItem
			PickupItem(GetParam("Item ID"))
		Case $gDropItem
			DropItem(GetParam("Item ID"), GetParam("Item ID [0]"))
		Case $gAddHero
			AddHero(GetParam("Hero ID"))
		Case $gKickHero
			KickHero(GetParam("Hero ID"))
		Case $gAddNPC
			AddNPC(GetParam("NPC ID"))
		Case $gKickNPC
			KickNPC(GetParam("NPC ID"))
		Case $gCommandHero
			CommandHero(GetParam("Agent ID"), GetParam("X Coord"), GetParam("Y Coord"))
		Case $gCommandAll
			CommandAll(GetParam("X Coord"), GetParam("Y Coord"))
		Case $gGoSignpost
			GoSignpost(GetParam("Agent ID"))
		Case $gSetSkill
			SetSkillbarSkill(GetParam("Skill Slot [1-8]"), GetParam("Skill ID"))
		Case $gReturnToOutpost
			ReturnToOutpost()
		Case $gSkipSinematic
			SkipCinematic()
		Case $gLeaveGroup
			LeaveGroup()
		Case $gChangeSecProf
			ChangeSecondProfession(GetParam("Profession ID"))
		Case $gSwitchMode
			SwitchMode(GetParam("Normalmode/Hardmode <=> 0/1"))
		Case $gDropGold
			DropGold(GetParam("Amount"))
		Case $gDepositGold
			DepositGold(GetParam("Amount"))
		Case $gWithdrawGold
			WithdrawGold(GetParam("Amount"))
		Case $gQuestReward
			QuestReward(GetParam("Quest ID"))
		Case $gOnTopCheckbox
				If GUICtrlRead($gOnTopCheckbox) = 1 Then
					WinSetOnTop($gWindowTitle, "", 1)
				Else
					WinSetOnTop($gWindowTitle, "", 0)
				EndIf
		Case $gHideGW
			If GUICtrlRead($gHideGW) = 1 Then WinSetState(GetWindowHandle(), "", @SW_HIDE)
			If GUICtrlRead($gHideGW) = 4 Then
				WinSetState(GetWindowHandle(), "", @SW_SHOW)
				WinSetOnTop($gWindowTitle, "", 1)
				If GUICtrlRead($gOnTopCheckbox) <> 1 Then WinSetOnTop($gWindowTitle, "", 0)
			EndIf
		Case $gCurrentTarGetButton
			Local $gAgentInfo_row[1], $agentcount = 0
			GUISetState(@SW_DISABLE, $gGUI)
			Opt("GuiOnEventMode", 1)
			$gAgentInfoGUI = GUICreate("Agent Info", 850, 70)
			$gAgentInfo = GUICtrlCreateListView("Agent|AgentID|ModelID|Coordinates|Dist|Type|Type2|Team|Alleg|Effects|Hexes|Prof|Lvl|HP|Weap|Rot|Target", 0, 0, 850, 70, -1)
			GUICtrlSetOnEvent(-1, "BoxEventHandler")
			_GUICtrlListView_RegisterSortCallBack($gAgentInfo)
			_GUICtrlListView_DeleteAllItems($gAgentInfo)
			$aAgent = GetAgentByID(-1)
			AgentTable($aAgent)
			GUISetState()
			GUISetOnEvent($GUI_EVENT_CLOSE, "BoxEventHandler", $gAgentInfoGUI)
		Case $gAllAgentsInfo
			Local $gAgentInfo_row[1], $agentcount = 0
			GUISetState(@SW_DISABLE, $gGUI)
			Opt("GuiOnEventMode", 1)
			$gAgentInfoGUI = GUICreate("Agent Info", 850, 250)
			$gAgentInfo = GUICtrlCreateListView("Agent|AgentID|ModelID|Coordinates|Dist|Type|Type2|Team|Alleg|Effects|Hexes|Prof|Lvl|HP|Weap|Rot|Target", 0, 0, 850, 250, -1)
			GUICtrlSetOnEvent(-1, "BoxEventHandler")
			_GUICtrlListView_RegisterSortCallBack($gAgentInfo)
			_GUICtrlListView_DeleteAllItems($gAgentInfo)
			GUISetState()
			GUISetOnEvent($GUI_EVENT_CLOSE, "BoxEventHandler", $gAgentInfoGUI)
			$lAgentArray = GetAgentArray() ;Creating agent's struct
			If $lAgentArray[0] < 1 Then ContinueLoop
			For $i = 1 To $lAgentArray[0] ;Loop around all agent's
				$aAgent = $lAgentArray[$i]
				AgentTable($aAgent)
			Next
		Case $gAllBagsInfo
			ItemsTable()
		Case $gSkillByIDInfo
			SkillTable(GetParam("Skill ID"))
	EndSwitch
Wend

Func SkillTable($SkillID)
$aSkill = GetSkillByID($SkillID)
$aSkillID = $SkillID
$aCampaign = DllStructGetData($aSkill, 'Campaign')
$aType = DllStructGetData($aSkill, 'Type')
$aSpecial = DllStructGetData($aSkill, 'Special')
$aComboReq = DllStructGetData($aSkill, 'ComboReq')
$aEffect1 = DllStructGetData($aSkill, 'Effect1')
$aCondition = DllStructGetData($aSkill, 'Condition')
$aEffect2 = DllStructGetData($aSkill, 'Effect2')
$aWeaponReq = DllStructGetData($aSkill, 'WeaponReq')
$aProfession = DllStructGetData($aSkill, 'Profession')
$aAttribute = DllStructGetData($aSkill, 'Attribute')
$aPvPID  = DllStructGetData($aSkill, 'PvPID')
$aCombo = DllStructGetData($aSkill, 'Combo')
$aTarget = DllStructGetData($aSkill, 'Target')
$aEquipType = DllStructGetData($aSkill, '')
$aAdrenaline = DllStructGetData($aSkill, 'EquipType')
$aActivation = DllStructGetData($aSkill, 'Activation')
$aAftercast = DllStructGetData($aSkill, 'Aftercast')
$aDuration0 = DllStructGetData($aSkill, 'Duration0')
$aDuration15 = DllStructGetData($aSkill, 'Duration15')
$aRecharge = DllStructGetData($aSkill, 'Recharge')
$aScale0 = DllStructGetData($aSkill, 'Scale0')
$aScale15 = DllStructGetData($aSkill, 'Scale15')
$aBonusScale0 = DllStructGetData($aSkill, 'BonusScale0')
$aBonusScale15 = DllStructGetData($aSkill, 'BonusScale15')
$aAoERange = DllStructGetData($aSkill, 'AoERange')
$aConstEffect = DllStructGetData($aSkill, 'ConstEffect')

Switch $aCampaign
	Case 0
		$aCampaign = "Core"
	Case 1
		$aCampaign = "Prophecies"
	Case 2
		$aCampaign = "Factions"
	Case 3
		$aCampaign = "Nightfall"
	Case 4
		$aCampaign = "EoTN"
EndSwitch

Switch $aType
	Case 1
		$aType = "Bounty"
	Case 2
		$aType = "Scroll"
	Case 3
		$aType = "Stance"
	Case 4
		$aType = "Hex"
	Case 5
		$aType = "Spell"
	Case 6
		$aType = "Enchantment"
	Case 7
		$aType = "Signet"
	Case 8
		$aType = "Condition"
	Case 9
		$aType = "Well"
	Case 10
		$aType = "Skill"
	Case 11
		$aType = "Ward"
	Case 12
		$aType = "Glyph"
	Case 13
		$aType = "Title"
	Case 14
		$aType = "Attack"
	Case 15
		$aType = "Shout"
	Case 16
		$aType = "Skill2"
	Case 17
		$aType = "Passive"
	Case 18
		$aType = "Environmental"
	Case 19
		$aType = "Preparation"
	Case 20
		$aType = "Pet Attack"
	Case 21
		$aType = "Trap"
	Case 22
		$aType = "Ritual"
	Case 23
		$aType = "Environmental Trap"
	Case 24
		$aType = "Item Spell"
	Case 25
		$aType = "Weapon Spell"
	Case 26
		$aType = "Form"
	Case 27
		$aType = "Chant"
	Case 28
		$aType = "Echo Refrain"
	Case 29
		$aType = "Disguise"
EndSwitch

If $aPvPID == 3396 Then $aPvPID = ""
$aProfession = GetProfession($aProfession)
$aAttribute = GetAttribute($aAttribute)

Switch $aTarget
	Case 0
		$aTarget = "Self/No Target"
	Case 1
		$aTarget = "Conditions, Charm Animal, Putrid Explosion, Spirit Targetting"
	Case 3
		$aTarget = "Ally"
	Case 4
		$aTarget = "Other Ally"
	Case 5
		$aTarget = "Enemy"
	Case 6
		$aTarget = "Dead Ally"
	Case 14
		$aTarget = "Minion"
	Case 16
		$aTarget = "Ground (AoE spells)"
EndSwitch

Switch $aCombo
	Case 1
		$aCombo = "1 - Lead Attack"
	Case 2
		$aCombo = "2 - Offhand Attack"
	Case 3
		$aCombo = "3 - Dual Attack"
EndSwitch

Switch $aAoERange
	Case 156
		$aAoERange = "156 - Adjacent"
	Case 240
		$aAoERange = "240 - Nearby"
	Case 312
		$aAoERange = "312 - Area"
	Case 1000
		$aAoERange = "1000 - Earshot"
	Case 2500
		$aAoERange = "2500 - Spirit"
	Case 5000
		$aAoERange = "5000 - Compass"
EndSwitch

GUISetState(@SW_DISABLE, $gGUI)
Opt("GuiOnEventMode", 1)
$gSkillInfoGUI = GUICreate("Skill Info", 800, 80)
$gSkillInfo = GUICtrlCreateListView("ID|Campaign|Type|Special|Combo Req|Effect1|Condition|Effect2|Weapon Req|Profession|Attribute|PvP ID|Combo|Target|Equip Type|Adrenaline|Activation|AfterCast|Duration0|Duration15|Recharge|Scale0|Scale15|Bonus Scale0|Bonus Scale15|AoERange|Const Effect", 0, 0, 800, 80, -1)
GUICtrlSetOnEvent(-1, "BoxEventHandler")
_GUICtrlListView_RegisterSortCallBack($gSkillInfo)
_GUICtrlListView_DeleteAllItems($gSkillInfo)
GUISetState()
GUISetOnEvent($GUI_EVENT_CLOSE, "BoxEventHandler", $gSkillInfoGUI)

GUICtrlCreateListViewItem(""&$aSkillID&"|"&$aCampaign&"|"&$aType&"|"&$aSpecial&"|"&$aComboReq&"|"&$aEffect1&"|"&$aCondition&"|"&$aEffect2&"|"&$aWeaponReq&"|"&$aProfession&"|"&$aAttribute&"|"&$aPvPID&"|"&$aCombo&"|"&$aTarget&"|"&$aEquipType&"|"&$aAdrenaline&"|"&$aActivation&"|"&$aAftercast&"|"&$aDuration0&"|"&$aDuration15&"|"&$aRecharge&"|"&$aScale0&"|"&$aScale15&"|"&$aBonusScale0&"|"&$aBonusScale15&"|"&$aAoERange&"|"&$aConstEffect&"", $gSkillInfo)

EndFunc

Func ItemsTable()
	Local $itemcount = 0
	Local $bags_names[16] = ["Backpack", "Belt Pouch", "Bag 1", "Bag 2", "Equip Pack", "Storage I", "Storage II", "Storage III", "Storage IV", "Storage V", _
	"Storage VI", "Storage VII", "Storage VIII", "Anv Storage"]
	GUISetState(@SW_DISABLE, $gGUI)
	Opt("GuiOnEventMode", 1)
	$gItemInfoGUI = GUICreate("Items Info", 600, 250)
	$gItemInfo = GUICtrlCreateListView("Location|Bag|Slot|ItemID|ModelID|Rty|Qty|Color|Req|Attribute|Type|Mod Struct|Item Insc|Mod1|Mod2", 0, 0, 600, 250, -1)
	GUICtrlSetOnEvent(-1, "BoxEventHandler")
	_GUICtrlListView_RegisterSortCallBack($gItemInfo)
	_GUICtrlListView_DeleteAllItems($gItemInfo)
	GUISetState()
	GUISetOnEvent($GUI_EVENT_CLOSE, "BoxEventHandler", $gItemInfoGUI)

	For $bag = 1 To 16
		$bag_slots = DllStructGetData(GetBag($bag), 'Slots')
		For $slot = 1 to $bag_slots
			$bag_name = $bags_names[$bag]
			$item_id = ""
			$item_model_id = ""
			$item_rarity = ""
			$item_quantity = ""
			$item_color = ""
			$item_requirement = ""
			$item_attribute = ""
			$item_type = ""

			$item = GetItemBySlot($bag, $slot)
			If DllStructGetData($item, 'ID') = 0 Then ContinueLoop
			$item_id = DllStructGetData($item, 'ID')
			$item_model_id = DllStructGetData($item, 'ModelID')
			$item_rarity = GetRarity($item)
			$item_quantity = DllStructGetData($item, 'Quantity')
			If DllStructGetData($item, 'ModelID') = 146 or DllStructGetData($item, 'ModelID') = 24888 Then
				$item_color = GetColor(DllStructGetData($item, 'ExtraID'))
			Endif
			$item_requirement = GetItemReq($item)
			If DllStructGetData($item, 'ModelID') <> 146 and $item_requirement <=13 and $item_requirement <> 0 or GetItemAttribute($item) > 44 Then
				$item_attribute = GetAttribute(GetItemAttribute($item))
			else
				$item_attribute = GetItemAttribute($item)
			endif
			$item_type = DllStructGetData($item, 'Type')
			$item_ModStruct = GetModStruct($item)
			$item_insc = GetItemInscr($item)
			$item_insc = _ArrayToString($item_insc, "-")
			$item_mod1 = GetItemMod1($item)
			$item_mod1 = _ArrayToString($item_mod1, "-")
			$item_mod2 = GetItemMod2($item)
			$item_mod2 = _ArrayToString($item_mod2, "-")
			$itemcount += 1
			GUICtrlCreateListViewItem(""&$bag_name&"|"&$bag&"|"&$slot&"|"&$item_id&"|"&$item_model_id&"|"&$item_rarity&"|"&$item_quantity&"|"&$item_color&"|"&$item_requirement&"|"&$item_attribute&"|"&$item_type&"|"&$item_ModStruct&"|"&$item_insc&"|"&$item_mod1&"|"&$item_mod2&"", $gItemInfo)
		Next
	Next
EndFunc

Func AgentTable($aAgent)
	$agent_name = "Unnamed"
	$agent_id = ""
	$agent_model_id = ""
	$agent_coords = ""
	$agent_distance = ""
	$agent_type = ""
	$agent_type2 = ""
	$agent_allegiance = ""
	$agent_effects = ""
	$agent_hexes = ""
	$agent_professions = ""
	$agent_level = ""
	$agent_health = ""
	$agent_weapon = ""
	$agent_rotation = ""
	$agent_target = ""

	; Get player name
	$this_name = GetPlayerName($aAgent)
	if $this_name <> "" Then
		$agent_name = $this_name
	Else
		$agent_name = GetAgentName($aAgent)
	Endif
	$agent_id = DllStructGetData($aAgent, 'ID')
	$agent_model_id = DllStructGetData($aAgent, 'PlayerNumber')
	$agent_coords = "X: " & Round(DllStructGetData($aAgent, 'X')) & ", Y: " & Round(DllStructGetData($aAgent, 'Y')) & ", Z: " & Round(DllStructGetData($aAgent, 'Z'))
	$agent_distance = Round(GetDistance($aAgent))
	$agent_type = DllStructGetData($aAgent, 'Type')
	$agent_type2 = DllStructGetData($aAgent, 'TypeMap')
	$agent_team = DllStructGetData($aAgent, 'Team')
	$agent_allegiance = DllStructGetData($aAgent, 'Allegiance')
	$agent_effects = DllStructGetData($aAgent, 'Effects')
	$agent_hexes = DllStructGetData($aAgent, 'Hex')
	If DllStructGetData($aAgent, 'Primary') <> 0 Then $agent_professions = GetProfession(DllStructGetData($aAgent, 'Primary'))&"/"& GetProfession(DllStructGetData($aAgent, 'Secondary'))
	$agent_level = DllStructGetData($aAgent, 'Level')
	$agent_health = round(DllStructGetData($aAgent, 'HP')*100)&"%"
	$agent_weapon = GetWeapon(DllStructGetData($aAgent, 'WeaponType'))
	$agent_rotation = round(DllStructGetData($aAgent, 'Rotation') * 100) & "�"
	$agent_target = GetTarget($agent_id)
	$agentcount += 1
	ReDim $gAgentInfo_row[$agentcount + 1]
	$gAgentInfo_row[$agentcount] = GUICtrlCreateListViewItem(""&$agent_name&"|"&$agent_id&"|"&$agent_model_id&"|"&$agent_coords&"|"&$agent_distance&"|"&$agent_type&"|"&$agent_type2&"|"&$agent_team&"|"&$agent_allegiance&"|"&$agent_effects&"|"&$agent_hexes&"|"&$agent_professions&"|"&$agent_level&"|"&$agent_health&"|"&$agent_weapon&"|"&$agent_rotation&"|"&$agent_target&"", $gAgentInfo)
EndFunc

Func BoxEventHandler()
	Switch @GUI_CtrlId
		Case $GUI_EVENT_CLOSE
			GUIDelete()
			GUISetState(@SW_ENABLE, $gGUI)
			Opt("GuiOnEventMode", 0)
			WinSetOnTop($gWindowTitle, "", 1)
			If GUICtrlRead($gOnTopCheckbox) <> 1 Then WinSetOnTop($gWindowTitle, "", 0)
	EndSwitch
EndFunc

; @Func		GetProfession
; @action	Get profession abbreviation from index
; @param	$prof (int)		= profession index
; @return	string
; ------------------------------------------------------------------- ;
Func GetProfession($prof)
	$Ret = $prof
	Switch $prof
		Case 0
			$Ret = ""
		Case 1
			$Ret = "W"
		Case 2
			$Ret = "R"
		Case 3
			$Ret = "Mo"
		Case 4
			$Ret = "N"
		Case 5
			$Ret = "Me"
		Case 6
			$Ret = "E"
		Case 7
			$Ret = "A"
		Case 8
			$Ret = "Rt"
		Case 9
			$Ret = "P"
		Case 10
			$Ret = "D"
	EndSwitch
	return $Ret
EndFunc

; @Func		GetWeapon
; @action	Get Weapon abbreviation from index
; @param	$weap (int)		= weapon index
; @return	string
; ------------------------------------------------------------------- ;
Func GetWeapon($weap)
	$Ret = $weap
	Switch $weap
		Case 0
			$Ret = ""
		Case 1
			$Ret = "Bow"
		Case 2
			$Ret = "Axe"
		Case 3
			$Ret = "Hammer"
		Case 4
			$Ret = "Daggers"
		Case 5
			$Ret = "Scythe"
		Case 6
			$Ret = "Spear"
		Case 7
			$Ret = "Sword"
		Case 8
			$Ret = "?"
		Case 9
			$Ret = "?"
		Case 10
			$Ret = "Wand"
		Case 12
			$Ret = "Staff"
		Case 14
			$Ret = "Staff"
	EndSwitch
	return $Ret
EndFunc

; @Func		GetColor
; @action	Get color abbreviation from index
; @param	$color (int)		= color index
; @return	string
; ------------------------------------------------------------------- ;
Func GetColor($color)
	$Ret = $color
	Switch $color
		Case 0
			$Ret = ""
		Case 1
			$Ret = ""
		Case 2
			$Ret = "Blue"
		Case 3
			$Ret = "Green"
		Case 4
			$Ret = "Purple"
		Case 5
			$Ret = "Red"
		Case 6
			$Ret = "Yellow"
		Case 7
			$Ret = "Brown"
		Case 8
			$Ret = "Orange"
		Case 9
			$Ret = "Silver"
		Case 10
			$Ret = "Black"
		Case 12
			$Ret = "White"
		Case 13
			$Ret = "Pink"
	EndSwitch
	return $Ret
EndFunc


Func GetAttribute($attr)
	$Ret = $attr
	Switch $attr
		Case 0
			$Ret = "Fast Casting"
		Case 1
			$Ret = "Illusion Magic"
		Case 2
			$Ret = "Domination Magic"
		Case 3
			$Ret = "Inspiration Magic"
		Case 4
			$Ret = "Blood Magic"
		Case 5
			$Ret = "Death Magic"
		Case 6
			$Ret = "Soul Reaping"
		Case 7
			$Ret = "Curses"
		Case 8
			$Ret = "Air Magic"
		Case 9
			$Ret = "Earth Magic"
		Case 10
			$Ret = "Fire Magic"
		Case 11
			$Ret = "Water Magic"
		Case 12
			$Ret = "Energy Storage"
		Case 13
			$Ret = "Healing Prayers"
		Case 14
			$Ret = "Smiting Prayers"
		Case 15
			$Ret = "Protection Prayers"
		Case 16
			$Ret = "Divine Favor"
		Case 17
			$Ret = "Strength"
		Case 18
			$Ret = "Axe Mastery"
		Case 19
			$Ret = "Hammer Mastery"
		Case 20
			$Ret = "Swordsmanship"
		Case 21
			$Ret = "Tactics"
		Case 22
			$Ret = "Beast Mastery"
		Case 23
			$Ret = "Expertise"
		Case 24
			$Ret = "Wilderness Survival"
		Case 25
			$Ret = "Marksmanship"
		Case 29
			$Ret = "Dagger Mastery"
		Case 30
			$Ret = "Deadly Arts"
		Case 31
			$Ret = "Shadow Arts"
		Case 32
			$Ret = "Communing"
		Case 33
			$Ret = "Restoration Magic"
		Case 34
			$Ret = "Channeling Magic"
		Case 35
			$Ret = "Critical Strikes"
		Case 36
			$Ret = "Spawning Power"
		Case 37
			$Ret = "Spear Mastery"
		Case 38
			$Ret = "Command"
		Case 39
			$Ret = "Motivation"
		Case 40
			$Ret = "Leadership"
		Case 41
			$Ret = "Scythe Mastery"
		Case 42
			$Ret = "Wind Prayers"
		Case 43
			$Ret = "Earth Prayers"
		Case 44
			$Ret = "Mysticism"
		EndSwitch
	return $Ret
EndFunc

Func GetParam($desc)
	Return InputBox("Parameter", "Please enter the Value. Description for Parameter: " & $desc)
EndFunc

Func Refresh()
	UpdateCharInfo()
	UpdateMapInfo()
	UpdatePos()
	UpdateOtherInfos()
EndFunc

Func UpdateOtherInfos()
	$gold = GetGoldCharacter()
	$goldstorage = GetGoldStorage()
	$ping = GetPing()
	GUICtrlSetData($gGoldChar, StringFormat("Gold: %d", $gold))
	GUICtrlSetData($gGoldStorage, StringFormat("Gold Storage: %d", $goldstorage))
	GUICtrlSetData($gPing, StringFormat("Ping: %dms", $ping))
EndFunc

Func UpdatePos()
	GUICtrlSetData($gX, StringFormat("X: %d", DllStructGetData(GetAgentByID(-2), "X")))
	GUICtrlSetData($gY, StringFormat("Y: %d", DllStructGetData(GetAgentByID(-2), "Y")))
	GUICtrlSetData($gRotation, StringFormat("Rotation: %f", DllStructGetData(GetAgentByID(-2), "Rotation")))
EndFunc

Func UpdateCharInfo()
	$me = GetMyID()
	$tarGet = GetCurrentTarGetID()
	$player_number = DllStructGetData(GetAgentByID(-2), "PlayerNumber")
	$agent = GetAgentByID(-2)
	$pname = GetPlayerName($agent)
	GUICtrlSetData($gID, StringFormat("ID: %d", $me))
	GUICtrlSetData($gCurrentTarGet, StringFormat("Current TarGet: %d", $tarGet))
	GUICtrlSetData($gName, StringFormat("Name: %s", $pname))
EndFunc

Func UpdateMapInfo()
	$MapID = GetmapID()
	$Region = GetRegion()
	$sRegion = ""
	$Lang = Getlanguage()
	$MapLoading = GetMapLoading()
	$mapisloaded = Getmapisloaded()
	Switch $Region
		Case 0
			$sRegion = "America"
		Case 1
			$sRegion = "Asia"
		Case 2
			$sRegion = "Europe"
		Case Else
			$sRegion = "International"
	EndSwitch
	If $Region = 1 Then
		Switch $Lang
			Case 0
				$sLang = "Korean"
			Case 1
				$sLang = "Traditional Chinese"
		EndSwitch
	Else
		Switch $Lang
			Case 0
				$sLang = "English"
			Case 2
				$sLang = "French"
			Case 3
				$sLang = "German"
			Case 4
				$sLang = "Italian"
			Case 5
				$sLang = "Spanish"
			Case 9
				$sLang = "Polish"
			Case 10
				$sLang = "Russian"
			Case Else
				$sLang = "Unknown"
		EndSwitch
	EndIf
	GUICtrlSetData($gMapID, StringFormat("MapID: %d", $MapID))
	GUICtrlSetData($gRegion, StringFormat("Region: %d (%s)", $Region, $sRegion))
	GUICtrlSetData($gLang, StringFormat("Language: %d (%s)", $Lang, $sLang))
	GUICtrlSetData($gMapLoading, StringFormat("Map Loading: %d", $MapLoading))
	GUICtrlSetData($gMapIsLoaded, StringFormat("MapIsLoaded: %d", $mapisloaded))
EndFunc

; Returns first Mod and all of its modvalues
;	return: array(modvalcount, mod, modval1, [modval2, modval3 ...])
;	no mod: return 0
Func GetItemMod1($aItem)
	If Not IsDllStruct($aItem) Then $aItem = GetItemByItemID($aItem)
	Local $lModString = GetModStruct($aItem)
	Local $lMods = ""
	Local $lPos = StringInStr($lModString, "3025", 0, 1)
	If $lPos = 0 Then Return 0
	$lMods = StringMid($lModString, $lPos - 4, 8) & "|" & StringMid($lModString, $lPos + 4, 8)
	Do
		$lPos = StringInStr($lModString, StringMid($lModString, $lPos - 4, 8), 0, 1, $lPos + 1)
		If $lPos = 0 Then ExitLoop
		$lMods = $lMods & "|" & StringMid($lModString, $lPos + 8, 8)
	Until false
	If $lMods = "" Then Return 0
	Local $lModArr = StringSplit($lMods, "|")
	$lModArr[0] -= 1
	Return $lModArr
EndFunc   ;==>GetItemMod1

; Returns second Mod and all of its modvalues
;	return: array(modvalcount, mod, modval1, [modval2, modval3 ...])
;	no 2nd mod: return 0
Func GetItemMod2($aItem)
	If Not IsDllStruct($aItem) Then $aItem = GetItemByItemID($aItem)
	Local $lModString = GetModStruct($aItem)
	Local $lMods = ""
	Local $lMod1 = ""
	Local $lPos = StringInStr($lModString, "3025", 0, 1)
	If $lPos = 0 Then Return 0
	$lMod1 = StringMid($lModString, $lPos - 4, 8)
	Do
		$lPos = StringInStr($lModString, "3025", 0, 1, $lPos + 1)
		If $lPos = 0 Then ExitLoop
		If StringMid($lModString, $lPos - 4, 8) = $lMod1 Then ContinueLoop
		If $lMods = "" Then
			$lMods = StringMid($lModString, $lPos - 4, 8)
		EndIf
		$lMods = $lMods & "|" & StringMid($lModString, $lPos + 4, 8)
	Until false
	If $lMods = "" Then Return 0
	Local $lModArr = StringSplit($lMods, "|")
	$lModArr[0] -= 1
	Return $lModArr
EndFunc   ;==>GetItemMod2

; Returns Inscription and all modvalues of the Inscription
;	return: array(modvalcount, inscr, modval1, [modval2, modval3 ...])
;	no inscription: return 0
Func GetItemInscr($aItem)
	If Not IsDllStruct($aItem) Then $aItem = GetItemByItemID($aItem)
	Local $lModString = GetModStruct($aItem)
	Local $lMods = ""
	Local $lSearch = "3225"
	Local $lPos = StringInStr($lModString, $lSearch)
	If $lPos = 0 Then
		$lSearch = "32A5"
		$lPos = StringInStr($lModString, $lSearch)
	EndIf
	If $lPos = 0 Then Return 0
	$lMods = StringMid($lModString, $lPos - 4, 8) & "|" & StringMid($lModString, $lPos + 4, 8)
	Do
		$lPos = StringInStr($lModString, $lSearch, 0, 1, $lPos + 1)
		If $lPos = 0 Then ExitLoop
		$lMods = $lMods & "|" & StringMid($lModString, $lPos + 4, 8)
	Until false
	If $lMods = "" Then Return 0
	Local $lModArr = StringSplit($lMods, "|")
	$lModArr[0] -= 1
	Return $lModArr
EndFunc   ;==>GetItemInscr

Func _TooltipMouseExit($text, $time = -1, $x = -1, $y = -1, $title = "", $icon = 0, $opt = "")
	If $time = -1 Then $time = 3000
	Local $start = TimerInit(), $pos0 = MouseGetPos()
	If ($x = -1) OR ($y = -1) Then
		ToolTip($text, $pos0[0], $pos0[1], $title, $icon, $opt)
	Else
		ToolTip($text, $x, $y, $title, $icon, $opt)
	EndIf
	Do
		Sleep(50)
		$pos = MouseGetPos()
	Until (TimerDiff($start) > $time) OR (Abs($pos[0] - $pos0[0]) > 10 OR Abs($pos[1] - $pos0[1]) > 10)
	ToolTip("")
EndFunc

Func DeveloperShutdown()
	WinSetTitle(GetWindowHandle(), "", "Guild Wars")
EndFunc