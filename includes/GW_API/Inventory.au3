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
		If ($m = $wontSell[$i]) Then
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


;~ Description: Returns if rare weapon.
Func GetIsRareWeapon($aitem)
	Local $Attribute = GetItemAttribute($aitem)
	Local $Requirement = GetItemReq($aitem)
	Local $Damage = GetItemMaxDmg($aitem)
	If $Attribute = 21 And $Requirement <= 8 And $Damage = 22 Then Return True
	If $Attribute = 18 And $Requirement <= 8 And $Damage = 16 Then Return True
	If $Attribute = 22 And $Requirement <= 8 And $Damage = 16 Then Return True
	If $Attribute = 36 And $Requirement <= 8 And $Damage = 16 Then Return True
	If $Attribute = 37 And $Requirement <= 8 And $Damage = 16 Then Return True
	Return False
EndFunc   ;==>GetIsRareWeapon
