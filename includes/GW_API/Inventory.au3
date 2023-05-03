Func isInventoryFull()
	If CountSlots() < 4 Then
		Return True
	EndIf
	Return False
EndFunc   ;==>isInventoryFull

Func CountSlots()
	Local $FreeSlots = 0, $lBag, $aBag
	For $i = 0 To 3
		If (GUICtrlRead($bags[$i]) == $GUI_CHECKED) Then
			$lBag = GetBag($i + 1)
			$FreeSlots += DllStructGetData($lBag, 'slots') - DllStructGetData($lBag, 'ItemsCount')
		EndIf
	Next
	Return $FreeSlots
EndFunc   ;==>CountSlots

Func _PointerToStringW($ptr)
	Return DllStructGetData(DllStructCreate("wchar[" & _WinAPI_StringLenW($ptr) & "]", $ptr), 1)
EndFunc   ;==>_PointerToStringW

Func CanPickUp($aitem)
	$m = DllStructGetData($aitem, 'ModelID')
	$lRarity = GetRarity($aitem)
	For $i = 0 To UBound($wontSell) - 1
		If ($m = $wontSell[$i]) Then
			Return True
		EndIf
	Next

	If GetIsRareWeapon($aitem) Then Return True
	If (($lRarity == $RARITY_Gold) And (GUICtrlRead($itemTypes[0]) == $GUI_CHECKED)) Then Return True
	If (($lRarity == $RARITY_Purple) And (GUICtrlRead($itemTypes[1]) == $GUI_CHECKED)) Then Return True
	If (($lRarity == $RARITY_Blue) And (GUICtrlRead($itemTypes[2]) == $GUI_CHECKED)) Then Return True
	If (($lRarity == $RARITY_White) And (GUICtrlRead($itemTypes[3]) == $GUI_CHECKED)) Then Return True
	If ($m == 2511) Then Return True
	Return False
EndFunc   ;==>CanPickUp

Func Sell($bagIndex)
	$bag = GetBag($bagIndex)
	$numOfSlots = DllStructGetData($bag, 'slots')
	For $i = 1 To $numOfSlots
		$aitem = GetItemBySlot($bagIndex, $i)
		If DllStructGetData($aitem, 'ID') = 0 Then ContinueLoop
		If CanSell($aitem) Then
			SellItem($aitem)
		EndIf
		RndSleep(250)
	Next
EndFunc   ;==>Sell

Func SecureIDKit()
	If FindIDKit() = 0 Then
		If GetGoldCharacter() < 500 Then
			WithdrawGold(500)
			Sleep(Random(200, 300))
		EndIf
		Do
			If GetMapID() = $MAP_ID_NOLANI Then
				BuyItem(4, 1, 100)
			Else
				BuySuperiorIDKit()
			EndIf
			RndSleep(500)
		Until FindIDKit() <> 0
		RndSleep(500)
	EndIf
EndFunc   ;==>SecureIDKit

Func Ident($bagIndex)
	$bag = GetBag($bagIndex)
	Local $r = 0
	For $i = 1 To DllStructGetData($bag, 'slots')
		SecureIDKit()
		$aitem = GetItemBySlot($bagIndex, $i)
		If DllStructGetData($aitem, 'ID') = 0 Then ContinueLoop
		$lRarity = GetRarity($aitem)
		;If $lType == 24 Then Return True ;Shields
		If (($lRarity == $RARITY_Gold) And (GUICtrlRead($itemTypes[0]) <> $GUI_CHECKED)) Then ContinueLoop
		If (($lRarity == $RARITY_Purple) And (GUICtrlRead($itemTypes[1]) <> $GUI_CHECKED)) Then ContinueLoop
		If (($lRarity == $RARITY_Blue) And (GUICtrlRead($itemTypes[2]) <> $GUI_CHECKED)) Then ContinueLoop
		If ($lRarity == $RARITY_White) Then ContinueLoop
		If Not GetIsIDed($aitem) Then IdentifyItem($aitem)
		Sleep(Random(400, 750))
	Next
EndFunc   ;==>Ident


Func CanSell($aitem)
	$q = DllStructGetData($aitem, 'quantity')
	$m = DllStructGetData($aitem, 'ModelID')
	$lRarity = GetRarity($aitem)

	If GetItemReq($aitem) > 10 Then
		Return True
	EndIf

	; Cele
	For $i = 0 To UBound($CelestialWeapons) - 1
		If $m = $CelestialWeapons[$i] Then
			Return False
		EndIf
	Next
	
	If GetIsRareWeapon($aitem) Then Return False
	; Special stuff
	If ($q > 1 And $m <> 146) Then Return False
	If $m > 21785 And $m < 21806 Then Return False
	If $m = 146 And DllStructGetData($aitem, "ExtraId") > 9 Then ;Dyes
		Return False
	EndIf
	
	For $i = 0 To UBound($wontSell) - 1
		If ($m = $wontSell[$i]) And $wontSell[$i] <> 330 Then
			Return False
		EndIf
	Next

	; Rarity based
	If (($lRarity == $RARITY_Gold) And (GUICtrlRead($itemTypes[0]) <> $GUI_CHECKED)) Then Return False
	If (($lRarity == $RARITY_Purple) And (GUICtrlRead($itemTypes[1]) <> $GUI_CHECKED)) Then Return False
	If (($lRarity == $RARITY_Blue) And (GUICtrlRead($itemTypes[2]) <> $GUI_CHECKED)) Then Return False
	If (($lRarity == $RARITY_White) And (GUICtrlRead($itemTypes[3]) <> $GUI_CHECKED)) Then Return False
	Return True
EndFunc   ;==>CanSell

;~ Description: Returns max dmg of item.
Func GetItemMaxDmg($aitem)
	Local $lModString = GetModStruct(GetItemPtr($aitem))
	Local $lPos = StringInStr($lModString, "A8A7") ; Weapon Damage
	If $lPos = 0 Then $lPos = StringInStr($lModString, "C867") ; Energy (focus)
	If $lPos = 0 Then $lPos = StringInStr($lModString, "B8A7") ; Armor (shield)
	If $lPos = 0 Then Return 0
	Return Int("0x" & StringMid($lModString, $lPos - 2, 2))
EndFunc   ;==>GetItemMaxDmg

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
EndFunc

Func HasTwoUsefulMods($ModStruct)
	Local $UsefulMods = 0
	Local $aModStrings[121] = ["003C7823", "05320823", "0500F822", "0F00D822", "000A0822", "000AA823", "00140828", "00130828", "0A0018A1", "0A0318A1", "0A0B18A1", "0A0518A1", "0A0418A1", "0A0118A1", "0A0218A1", "02008820", "0200A820", "05147820", "05009821", "000AA823", "00142828", "00132828", "0100E820", "000AA823", "00142828", "00132828", "002D6823", "002C6823", "002B6823", "002D8823", "002C8823", "002B8823", "001E4823", "001D4823", "001C4823", "14011824", "13011824", "14021824", "13021824", "14031824", "13031824", "14041824", "13041824", "14051824", "13051824", "14061824", "13061824", "14071824", "13071824", "14081824", "13081824", "14091824", "13091824", "140A1824", "130A1824", "140B1824", "130B1824", "140D1824", "130D1824", "140E1824", "130E1824", "140F1824", "130F1824", "14101824", "13101824", "14201824", "13201824", "14211824", "13211824", "14221824", "13221824", "14241824", "13241824", "0A004821", "0A014821", "0A024821", "0A034821", "0A044821", "0A054821", "0A064821", "0A074821", "0A084821", "0A094821", "0A0A4821", "01131822", "02131822", "03131822", "04131822", "05131822", "06131822", "07131822", "08131822", "09131822", "0A131822", "0B131822", "0D131822", "0E131822", "0F131822", "10131822", "20131822", "21131822", "22131822", "24131822", "01139823", "02139823", "03139823", "04139823", "05139823", "06139823", "07139823", "08139823", "09139823", "0A139823", "0B139823", "0D139823", "0E139823", "0F139823", "10139823", "20139823", "21139823", "22139823", "24139823"]
	Local $NumMods = 120
	For $i = 0 to $NumMods
	   Local $ModStr = StringInStr($ModStruct, $aModStrings[$i], 0, 1)
	   If ($ModStr > 1) Then
		  $UsefulMods += 1
	   EndIf
	Next
	If $UsefulMods >= 2 Then Return True
	Return False
 EndFunc

;~ Description: Returns if rare weapon.
Func GetIsRareWeapon($aitem)
	Local $Attribute = GetItemAttribute($aitem)
	Local $Requirement = GetItemReq($aitem)
	Local $Damage = GetItemMaxDmg($aitem)
	Local $modStr = GetModStruct($aitem)
	If $Attribute = 20 And $Requirement <= 8 And $Damage = 22 Then Return True
	If $Attribute = 17 And $Requirement <= 8 And $Damage = 16 Then Return True
	If $Attribute = 21 And $Requirement <= 8 And $Damage = 16 Then Return True
	If $Attribute = 39 And $Requirement <= 8 And $Damage = 16 Then Return True
	If $Attribute = 38 And $Requirement <= 8 And $Damage = 16 Then Return True
	; gimme oldskool dualmod shields
	If $Requirement > 8 And $Requirement < 12 And Not GetItemInscr($aitem) And HasTwoUsefulMods($modStr) Then Return True
	If $Requirement > 8 And $Requirement < 12 And Not GetItemInscr($aitem) And HasTwoUsefulMods($modStr) Then Return True
	Return False
EndFunc   ;==>GetIsRareWeapon
