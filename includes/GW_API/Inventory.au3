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

Func CanPickUp($aitem)
	$m = DllStructGetData($aitem, 'ModelID')
	$lRarity = GetRarity($aitem)

	_ArrayConcatenate($wontSell, $farmSpecific)
	For $i = 0 To UBound($wontSell) - 1
		If ($m = $wontSell[$i]) Then
			Return True
		EndIf
	Next

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
			Out("Selling item: " & DllStructGetData($aitem, 'ModelID'))
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
			BuySuperiorIDKit()
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

	; Cele
	For $i = 0 To UBound($CelestialWeapons) - 1
		If $m = $CelestialWeapons[$i] Then
			Return False
		EndIf
	Next

	; Special stuff
	If ($q > 1 And $m <> 146) Then Return False
	If $m > 21785 And $m < 21806 Then Return False
	If $m = 146 And DllStructGetData($aitem, "ExtraId") > 9 Then ;Dyes
		Return False
	EndIf

	; Normal stuff
	_ArrayConcatenate($wontSell, $farmSpecific)

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