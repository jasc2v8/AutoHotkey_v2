;AHK v2
;slightly-improved dialogs by jeeswg: functions
;written for AutoHotkey v2 alpha (v2.0-a096)
;[first released: 2018-06-08]
;[updated: 2018-06-09]

;==================================================

;;FUNCTIONS - INIT
;MsgBoxNew_Init()
;InputBoxNew_Init()
;ToolTipNew_Init()
;;FUNCTIONS - MSGBOX
;MsgBoxNew(oParams*) ;vText, vWinTitle, vOpt
;MsgBoxNew_Close(oGui, vBtn)
;;FUNCTIONS - INPUTBOX
;InputBoxNew(oParams*) ;vText, vWinTitle, vOpt, vDefault
;InputBoxNew_Close(oGui, vBtn)
;InputBoxNew_Size(oGui)
;;FUNCTIONS - INPUTBOX MULTI
;InputBoxMulti(oParams*) ;oText, vWinTitle, vOpt, oDefault
;;FUNCTIONS - PROGRESS/SPLASHIMAGE (AHK V1 DIAGNOSTIC)
;Progress(ProgressParam1, SubText:="", MainText:="", WinTitle:="", FontName:="")
;SplashImage(ImageFile:="", Options:="", SubText:="", MainText:="", WinTitle:="", FontName:="")
;ProgressAhk1(oParams*)
;SplashImageAhk1(oParams*)
;SplashAhk1(vFunc, oParams*)
;;FUNCTIONS - PROGRESS/SPLASHIMAGE (AHK V2)
;ProgressNew(vParam1, vSubText:="", vMainText:="", vWinTitle:=" ", vFontName:="")
;SplashImageNew(vImageFile:="", vOpt:="", vSubText:="", vMainText:="", vWinTitle:=" ", vFontName:="")
;;FUNCTIONS - TOOLTIP
;ToolTipNew(vText:="", vPosX:="", vPosY:="", vWhichToolTip:=1, vColTxRGB:="", vColBkRGB:="")
;;FUNCTIONS - BORDERS
;Borders(vPosX, vPosY, vPosW:=0, vPosH:=0, vTime:=1000, vColRGB:=0xFFFF00, vBdrW:=5, vBdrH:=5)
;Borders_WndProc(hWnd, uMsg, wParam, lParam)

;;FUNCTIONS - AUXILIARY
;JEE_HIconGetDims(hIcon, &vImgW, &vImgH)
;JEE_HBitmapGetDims(hBitmap, &vImgW, &vImgH)
;JEE_FontCreate(vName, vSize, vFontStyle:="", vWeight:="")
;JEE_StrGetDim(vText, hFont, &vTextW, &vTextH, vDTFormat:=0x400, vLimW:="", vLimH:="")

;==================================================

global AX_DlgTitle
global AX_ScriptNameNoExt
global AX_MsgBoxResult
global AX_MsgBoxOpt ;object
MsgBoxNew_Init()
{
	static vDummy := MsgBoxNew_Init()
	SplitPath(A_ScriptFullPath,,,, AX_ScriptNameNoExt)
	AX_DlgTitle := AX_ScriptNameNoExt

	AX_MsgBoxOpt := {}
	AX_MsgBoxOpt.Prompt0 := "Press OK to continue."
	AX_MsgBoxOpt.Prompt1 := ""
	AX_MsgBoxOpt.TextAbort := "&Abort"
	AX_MsgBoxOpt.TextCancel := "Cancel"
	AX_MsgBoxOpt.TextContinue := "&Continue"
	AX_MsgBoxOpt.TextIgnore := "&Ignore"
	AX_MsgBoxOpt.TextNo := "&No"
	AX_MsgBoxOpt.TextOK := "OK"
	AX_MsgBoxOpt.TextRetry := "&Retry"
	AX_MsgBoxOpt.TextTryAgain := "&Try Again"
	AX_MsgBoxOpt.TextYes := "&Yes"
	AX_MsgBoxOpt.TextButton1 := "Btn1"
	AX_MsgBoxOpt.TextButton2 := "Btn2"
	AX_MsgBoxOpt.TextButton3 := "Btn3"
	AX_MsgBoxOpt.CustomButtonCount := ""
	AX_MsgBoxOpt.FontName := "Segoe UI"
	AX_MsgBoxOpt.FontSize := 10
	AX_MsgBoxOpt.FontWeight := 400
	;AX_MsgBoxOpt.HFont := hFont
	AX_MsgBoxOpt.StylesWin := "+0x94C803C5 +E0x00010101"
	AX_MsgBoxOpt.StylesButton1 := "+0x50030001 +E0x00000004"
	AX_MsgBoxOpt.StylesButton2 := "+0x50010000 +E0x00000004"
	AX_MsgBoxOpt.StylesButton3 := "+0x50010000 +E0x00000004"
	AX_MsgBoxOpt.StylesStatic := "+0x50022080 +E0x00000004"
	AX_MsgBoxOpt.StylesIcon := "+0x50020003 +E0x00000004"
	AX_MsgBoxOpt.WinMaxWidth := 800
	AX_MsgBoxOpt.HIconDefault := ""
	AX_MsgBoxOpt.HIconAsterisk := ""
	AX_MsgBoxOpt.HIconExclamation := ""
	AX_MsgBoxOpt.HIconHand := ""
	AX_MsgBoxOpt.HIconQuestion := ""
	AX_MsgBoxOpt.SoundDefault := "-"
	AX_MsgBoxOpt.SoundAsterisk := ""
	AX_MsgBoxOpt.SoundExclamation := ""
	AX_MsgBoxOpt.SoundHand := ""
	AX_MsgBoxOpt.SoundQuestion := ""
}

global AX_DlgTitle
global AX_ScriptNameNoExt
global AX_InputBoxResult
global AX_InputBoxOpt ;object
InputBoxNew_Init()
{
	static vDummy := InputBoxNew_Init()
	SplitPath(A_ScriptFullPath,,,, AX_ScriptNameNoExt)
	AX_DlgTitle := AX_ScriptNameNoExt

	AX_InputBoxOpt := {}
	AX_InputBoxOpt.Prompt0 := ""
	AX_InputBoxOpt.Prompt1 := ""
	AX_InputBoxOpt.TextButton1 := "OK"
	AX_InputBoxOpt.TextButton2 := "Cancel"
	AX_InputBoxOpt.FontName := "Segoe UI"
	AX_InputBoxOpt.FontSize := 10
	AX_InputBoxOpt.FontWeight := 400
	;AX_InputBoxOpt.HFont := hFont
	AX_InputBoxOpt.StylesWin := "+0x94CC0A4C +E0x00010100"
	AX_InputBoxOpt.StylesEdit := "+0x50010080 +E0x00000204"
	AX_InputBoxOpt.StylesEditPW := "+0x500100A0 +E0x00000204"
	AX_InputBoxOpt.StylesButton1 := "+0x50010001 +E0x00000004"
	AX_InputBoxOpt.StylesButton2 := "+0x50010000 +E0x00000004"
	AX_InputBoxOpt.StylesStatic := "+0x50020000 +E0x00000004"
}

global AX_DlgTitle
global AX_ScriptNameNoExt
global AX_ToolTipOpt ;object
ToolTipNew_Init()
{
	static vDummy := ToolTipNew_Init()
	SplitPath(A_ScriptFullPath,,,, AX_ScriptNameNoExt)
	AX_DlgTitle := AX_ScriptNameNoExt

	AX_ToolTipOpt := {}
	AX_ToolTipOpt.FontName := "Segoe UI"
	AX_ToolTipOpt.FontSize := 9
	AX_ToolTipOpt.FontWeight := 400
	;AX_ToolTipOpt.ColTxRGB := 0x404040
	;AX_ToolTipOpt.ColBkRGB := 0xF0F0F0
	AX_ToolTipOpt.ColTxRGB := 0x000000
	AX_ToolTipOpt.ColBkRGB := 0xFFFFFF
	AX_ToolTipOpt.SetWindowTheme := "" ;like AutoHotkey ToolTip command (faded colours and rounded corners)
	AX_ToolTipOpt.SetWindowTheme := 0
}

;==================================================

;FUNCTIONS - MSGBOX

MsgBoxNew(oParams*) ;vText, vWinTitle, vOpt
{
	static oType := {"OK",0, "O",0, "OKCancel",1, "O/C",1, "OC",1, "AbortRetryIgnore",2, "A/R/I",2, "ARI",2
	, "YesNoCancel",3, "Y/N/C",3, "YNC",3, "YesNo",4, "Y/N",4, "YN",4, "RetryCancel",5, "R/C",5, "RC",5
	, "CancelTryAgainContinue",6, "C/T/C",6, "CTC",6, "Iconx",16, "Icon?",32, "Icon!",48, "Iconi",64
	, "Default2",256, "Default3",512, "Default4",768}
	static hIconHand := DllCall("user32\LoadIcon", Ptr,0, Ptr,32513, Ptr) ;IDI_HAND := 32513
	static hIconQuestion := DllCall("user32\LoadIcon", Ptr,0, Ptr,32514, Ptr) ;IDI_QUESTION := 32514
	static hIconExclamation := DllCall("user32\LoadIcon", Ptr,0, Ptr,32515, Ptr) ;IDI_EXCLAMATION := 32515
	static hIconAsterisk := DllCall("user32\LoadIcon", Ptr,0, Ptr,32516, Ptr) ;IDI_ASTERISK := 32516
	global oMsgBoxRet

	vText := !oParams.Length() ? AX_MsgBoxOpt.Prompt0 : oParams.HasKey(1) ? oParams.1 : AX_MsgBoxOpt.Prompt1
	vWinTitle := oParams.HasKey(2) ? oParams.2 : AX_DlgTitle
	vOpt := oParams.3

	if !IsObject(oMsgBoxRet)
		oMsgBoxRet := []
	hWnd := WinExist("A")

	vDHW := A_DetectHiddenWindows
	DetectHiddenWindows(1)
	vPosWin := "", vTimeout := "", vType := 0, vHasIcon := 0, vHasIconCustom := 0
	vMgnX := 5, vMgnY := 5
	vWinW := 368, vWinH := 166

	Loop Parse, vOpt, " `t"
	{
		if (SubStr(A_LoopField, 1, 1) = "W")
			vWinW := SubStr(A_LoopField, 2)
		else if (SubStr(A_LoopField, 1, 1) = "H")
			vWinH := SubStr(A_LoopField, 2)

		if (A_LoopField ~= "i)^[XYWH]\d")
			vPosWin .= A_LoopField " "
		else if (SubStr(A_LoopField, 1, 1) = "T")
			vTimeout := SubStr(A_LoopField, 2)
		else if ((A_LoopField is "number") && (vTemp := Abs(A_LoopField))
		|| (vTemp := oType[A_LoopField]))
			vType |= vTemp
	}

	vStyleReset := "-0xFFFFFFFF -E0xFFFFFFFF "

	vBtnClose := 0
	if (AX_MsgBoxOpt.CustomButtonCount = 1)
		vBtnList := "Button1"
	else if (AX_MsgBoxOpt.CustomButtonCount = 2)
		vBtnList := "Button1,Button2"
	else if (AX_MsgBoxOpt.CustomButtonCount = 3)
		vBtnList := "Button1,Button2,Button3"
	else if (vType & 0xF = 0) ;O
		vBtnList := "OK", vBtnClose := 1
	else if (vType & 0xF = 1) ;OC
		vBtnList := "OK,Cancel", vBtnClose := 2
	else if (vType & 0xF = 2) ;ARI
		vBtnList := "Abort,Retry,Ignore", vDisableClose := 1
	else if (vType & 0xF = 3) ;YNC
		vBtnList := "Yes,No,Cancel", vBtnClose := 3
	else if (vType & 0xF = 4) ;YN
		vBtnList := "Yes,No", vDisableClose := 1
	else if (vType & 0xF = 5) ;RC
		vBtnList := "Retry,Cancel", vBtnClose := 2
	else if (vType & 0xF = 6) ;CTC
		vBtnList := "Cancel,TryAgain,Continue", vBtnClose := 1
	StrReplace(vBtnList, ",",, vBtnCount), vBtnCount += 1
	oTemp := StrSplit(vBtnList, ",")
	vTextBtn0 := "Cancel"
	Loop vBtnCount
		vTextBtn%A_Index% := AX_MsgBoxOpt["Text" oTemp[A_Index]]

	if (vType & 0xF0 = 0x10) ;Iconx
		vTypeIcon := "Hand", vHasIcon := 1
	else if (vType & 0xF0 = 0x20) ;Icon?
		vTypeIcon := "Question", vHasIcon := 1
	else if (vType & 0xF0 = 0x30) ;Icon!
		vTypeIcon := "Exclamation", vHasIcon := 1
	if (vType & 0xF0 = 0x40) ;Iconi
		vTypeIcon := "Asterisk", vHasIcon := 1

	if vHasIcon
	&& !(hIcon := AX_MsgBoxOpt["HIcon" vTypeIcon])
		hIcon := hIcon%vTypeIcon%
	if !vHasIcon
	&& (hIcon := AX_MsgBoxOpt.HIconDefault)
		vHasIconCustom := 1

	vFontName := AX_MsgBoxOpt.FontName
	vFontSize := AX_MsgBoxOpt.FontSize
	vFontWeight := AX_MsgBoxOpt.FontWeight
	vStylesWin := vStyleReset AX_MsgBoxOpt.StylesWin
	vStylesButton1 := AX_MsgBoxOpt.StylesButton1
	vStylesButton2 := AX_MsgBoxOpt.StylesButton2
	vStylesButton3 := AX_MsgBoxOpt.StylesButton3
	vStylesStatic := AX_MsgBoxOpt.StylesStatic
	vStylesIcon := AX_MsgBoxOpt.StylesIcon

	vFontOpt := "s" vFontSize
	if AX_MsgBoxOpt.HFont
		hFont := AX_MsgBoxOpt.HFont
	else
		hFont := JEE_FontCreate(vFontName, vFontSize, "", vFontWeight)
	JEE_StrGetDim("Try Again", hFont, vBtn0W, vBtn0H, vDTFormat:=0x400, vLimW:="", vLimH:="") ;minimum width
	JEE_StrGetDim(vTextBtn1, hFont, vBtn1W, vBtn1H, vDTFormat:=0x400, vLimW:="", vLimH:="")
	JEE_StrGetDim(vTextBtn2, hFont, vBtn2W, vBtn2H, vDTFormat:=0x400, vLimW:="", vLimH:="")
	JEE_StrGetDim(vTextBtn3, hFont, vBtn3W, vBtn3H, vDTFormat:=0x400, vLimW:="", vLimH:="")
	vBtnW := Max(vBtn0W, vBtn1W, vBtn2W, vBtn3W) + 16
	vBtnH := Max(vBtn0H, vBtn1H, vBtn2H, vBtn3H) + 7

	if !InStr(vPosWin, "W") || !InStr(vPosWin, "H")
	{
		if AX_MsgBoxOpt.WinMaxWidth
			vLimW := AX_MsgBoxOpt.WinMaxWidth - 2*vMgnX
		else
			vLimW := A_ScreenWidth - 2*vMgnX
		JEE_StrGetDim(vText, hFont, vTextW, vTextH, vDTFormat:=0x2410, vLimW, vLimH:="")
		vWinW := vTextW + 2*vMgnX
		vWinH := vTextH + vBtnH + 3*vMgnY
		vWinW := Max(vWinW, 368)
		vWinH := Max(vWinH, 166)
	}

	if vHasIcon || vHasIconCustom
	{
		vWinW += vMgnX + 32
		vOffsetX := vMgnX + 32
	}
	else
		vOffsetX := 0
	if !InStr(vPosWin, "W")
		vPosWin .= " W" vWinW
	if !InStr(vPosWin, "H")
		vPosWin .= " H" vWinH

	vEditW := vWinW - 2*vMgnX - vOffsetX
	vGap := Round((vWinW - vBtnCount*vBtnW - 2*vMgnX)/(vBtnCount*2))
	;[][BTN1][]
	;[][BTN1][][][BTN2][]
	;[][BTN1][][][BTN2][][][BTN3][]
	;centred buttons:
	;vBtn1X := vMgnX + vGap
	;vBtn2X := vMgnX + 3*vGap + vBtnW
	;vBtn3X := vMgnX + 5*vGap + 2*vBtnW
	;offset from right
	vBtn1X := vWinW - vBtnCount*vMgnX - vBtnCount*vBtnW
	vBtn2X := vWinW - (vBtnCount-1)*vMgnX - (vBtnCount-1)*vBtnW
	vBtn3X := vWinW - (vBtnCount-2)*vMgnX - (vBtnCount-2)*vBtnW
	vBtnY := vWinH - vMgnY - vBtnH
	;vEditY := vBtnY - vMgnY - vBtnH
	;vStcH := vEditY - vMgnY
	vStcH := vBtnY - vMgnY
	;vPosEdit := Format("X{} Y{} W{} H{}", vMgnX, vEditY, vEditW, vBtnH)
	vPosBtn1 := Format("X{} Y{} W{} H{}", vBtn1X, vBtnY, vBtnW, vBtnH)
	vPosBtn2 := Format("X{} Y{} W{} H{}", vBtn2X, vBtnY, vBtnW, vBtnH)
	vPosBtn3 := Format("X{} Y{} W{} H{}", vBtn3X, vBtnY, vBtnW, vBtnH)
	vPosStc := Format("X{} Y{} W{} H{}", vMgnX+vOffsetX, vMgnY, vEditW, vStcH)
	vPosStcIcon := Format("X{} Y{} W{} H{}", vMgnX, vMgnY, 32, 32)

	hWnd := WinExist("A")
	if (vWinTitle = "")
		vWinTitle := AX_DlgTitle

	;WS_POPUPWINDOW := 0x80880000 ;composite style (WS_POPUP | WS_BORDER | WS_SYSMENU)
	;WS_VISIBLE := 0x10000000
	;WS_CLIPSIBLINGS := 0x4000000
	;WS_CAPTION := 0xC00000 ;composite style (WS_BORDER | WS_DLGFRAME)
	;WS_THICKFRAME := 0x40000
	;WS_EX_CONTROLPARENT := 0x10000
	;WS_EX_WINDOWEDGE := 0x100
	oGui := GuiCreate(vStylesWin, vWinTitle)
	oGui.SetFont(vFontOpt, vFontName)
	;types: O,OC,ARI,YNC,YN,RC,CTC
	;press Esc or alt+space, c: OK/Cancel/-/Cancel/-/Cancel/Cancel
	oGui.OnEvent("Close", Func("MsgBoxNew_Close").Bind(oGui, vTextBtn%vBtnClose%))
	if !vDisableClose
		oGui.OnEvent("Escape", Func("MsgBoxNew_Close").Bind(oGui, vTextBtn%vBtnClose%))
	hGui := oGui.hWnd

	;SC_RESTORE := 0xF120 ;SC_MOVE := 0xF010
	;SC_SIZE := 0xF000 ;SC_MINIMIZE := 0xF020
	;SC_MAXIMIZE := 0xF030 ;SC_CLOSE := 0xF060
	hSysMenu := DllCall("user32\GetSystemMenu", Ptr,hGui, Int,0, Ptr)
	vList := "0xF120,0xF000,0xF020,0xF030,0,"
	Loop Parse, vList, ","
		DllCall("user32\DeleteMenu", Ptr,hSysMenu, UInt,A_LoopField, UInt,0x0) ;MF_BYCOMMAND := 0x0
	if vDisableClose
		DllCall("user32\DeleteMenu", Ptr,hSysMenu, UInt,0xF060, UInt,0x0) ;MF_BYCOMMAND := 0x0
	;DllCall("user32\EnableMenuItem", Ptr,hSysMenu, UInt,0xF060, UInt,0x3) ;MF_DISABLED := 0x2, MF_GRAYED := 0x1

	oGui.MarginX := vMgnX
	oGui.MarginY := vMgnY

	;oGui.Add("Edit", vStylesEdit " " vPosEdit, vDefault)

	Loop vBtnCount
	{
		oBtn%A_Index% := oGui.Add("Button", vStylesButton%A_Index% " " vPosBtn%A_Index%, vTextBtn%A_Index%)
		oBtn%A_Index%.OnEvent("Click", Func("MsgBoxNew_Close").Bind(oGui, "*" vTextBtn%A_Index%))
	}
	if vHasIcon | vHasIconCustom
	{
		oGui.Add("Picture", vStylesIcon " " vPosStcIcon)
		SendMessage(0x172, 1, hIcon, "Static1", "ahk_id " hGui) ;STM_SETIMAGE := 0x172 ;IMAGE_ICON := 1 ;IMAGE_BITMAP := 0
	}
	oGui.Add("Text", vStylesStatic " " vPosStc, vText)

	if (vType & 0x200)
		ControlFocus("Button3", "ahk_id " hGui)
	else if (vType & 0x100)
		ControlFocus("Button2", "ahk_id " hGui)
	else
		ControlFocus("Button1", "ahk_id " hGui)

	;oGui.OnEvent("Size", "MsgBoxNew_Size")

	if !(vTimeout = "")
	{
		BoundFuncTemp := Func("MsgBoxNew_Close").Bind(oGui, "Timeout")
		SetTimer(BoundFuncTemp, -vTimeout)
	}

	oGui.Show(vPosWin)

	DetectHiddenWindows(vDHW)

	if vHasIcon
	{
		vPathSound := AX_MsgBoxOpt["Sound" vTypeIcon]
		if (vPathSound = "")
			;vPathSound := RegRead("HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\System" vTypeIcon "\.Current")
			vPathSound := "*" ({Hand:16, Question:32, Exclamation:48, Asterisk:64}[vTypeIcon])
	}
	else
	{
		vPathSound := AX_MsgBoxOpt.SoundDefault
		if (vPathSound = "")
			;vPathSound := RegRead("HKEY_CURRENT_USER\AppEvents\Schemes\Apps\.Default\.Default\.Current")
			vPathSound := "*-1"
	}
	if (SubStr(vPathSound, 1, 1) = "*")
	|| (InStr(vPathSound, "\") && FileExist(vPathSound))
		SoundPlay(vPathSound)

	WinWaitClose("ahk_id " hGui)

	;if WinExist("ahk_id " hWnd)
	;	WinActivate("ahk_id " hWnd)

	if oMsgBoxRet.Length()
		return oMsgBoxRet[hGui]
	else
		return
}
MsgBoxNew_Close(oGui, vBtn)
{
	global oMsgBoxRet
	try hWnd := oGui.hWnd
	catch
		vBtn := ""
	vBtn := StrReplace(vBtn, "&")
	vBtn := StrReplace(vBtn, " ") ;e.g. 'Try Again' to 'TryAgain'
	;MsgBox(A_ThisFunc " " hWnd " " vBtn)
	;Abort,Cancel,Continue,Ignore,No,OK,Retry,TryAgain,Yes
	if (SubStr(vBtn, 1, 1) = "*")
	{
		oMsgBoxRet[hWnd] := SubStr(vBtn, 2)
		ErrorLevel := 0
		AX_MsgBoxResult := SubStr(vBtn, 2)
	}
	;Timeout
	else
	{
		oMsgBoxRet[hWnd] := vBtn
		ErrorLevel := 1
		AX_MsgBoxResult := vBtn
	}
	try oGui.Destroy
}

;==================================================

;FUNCTIONS - INPUTBOX

InputBoxNew(oParams*) ;vText, vWinTitle, vOpt, vDefault
{
	global oInputBoxRet

	vText := !oParams.Length() ? AX_InputBoxOpt.Prompt0 : oParams.HasKey(1) ? oParams.1 : AX_InputBoxOpt.Prompt1
	vWinTitle := oParams.HasKey(2) ? oParams.2 : AX_DlgTitle
	vOpt := oParams.3
	vDefault := oParams.4

	if !IsObject(oInputBoxRet)
		oInputBoxRet := []
	hWnd := WinExist("A")

	DetectHiddenWindows(1)
	vPosWin := "", vTimeout := "", vPassChar := ""
	vMgnX := 5, vMgnY := 5
	vWinW := 368, vWinH := 166

	Loop Parse, vOpt, " `t"
	{
		if (SubStr(A_LoopField, 1, 1) = "W")
			vWinW := SubStr(A_LoopField, 2)
		else if (SubStr(A_LoopField, 1, 1) = "H")
			vWinH := SubStr(A_LoopField, 2)

		if (A_LoopField ~= "i)^[XYWH]")
			vPosWin .= A_LoopField " "
		else if (SubStr(A_LoopField, 1, 1) = "T")
			vTimeout := SubStr(A_LoopField, 2)
		else if (A_LoopField = "Password")
			vHasPassChar := 1
		else if (SubStr(A_LoopField, 1, 8) = "Password")
		&& (StrLen(A_LoopField) > 8)
			vPassChar := SubStr(A_LoopField, 9, 1), vHasPassChar := 1
	}
	if !InStr(vPosWin, "W")
		vPosWin .= " W" vWinW
	if !InStr(vPosWin, "H")
		vPosWin .= " H" vWinH

	vStyleReset := "-0xFFFFFFFF -E0xFFFFFFFF "

	vTextBtn1 := AX_InputBoxOpt.TextButton1
	vTextBtn2 := AX_InputBoxOpt.TextButton2
	vFontName := AX_InputBoxOpt.FontName
	vFontSize := AX_InputBoxOpt.FontSize
	vFontWeight := AX_InputBoxOpt.FontWeight
	vStylesWin := vStyleReset AX_InputBoxOpt.StylesWin
	vStylesEdit := AX_InputBoxOpt.StylesEdit
	vStylesEditPW := AX_InputBoxOpt.StylesEditPW
	vStylesButton1 := AX_InputBoxOpt.StylesButton1
	vStylesButton2 := AX_InputBoxOpt.StylesButton2
	vStylesStatic := AX_InputBoxOpt.StylesStatic

	vFontOpt := "s" vFontSize
	if AX_InputBoxOpt.HFont
		hFont := AX_InputBoxOpt.HFont
	else
		hFont := JEE_FontCreate(vFontName, vFontSize, "", vFontWeight)
	JEE_StrGetDim(vTextBtn1, hFont, vBtn1W, vBtn1H, vDTFormat:=0x400, vLimW:="", vLimH:="")
	JEE_StrGetDim(vTextBtn2, hFont, vBtn2W, vBtn2H, vDTFormat:=0x400, vLimW:="", vLimH:="")
	vBtnW := Max(vBtn1W, vBtn2W) + 16
	vBtnH := Max(vBtn1H, vBtn2H) + 7

	vEditW := vWinW - 2*vMgnX
	vGap := Round((vWinW - 2*vBtnW - 2*vMgnX)/4)
	vBtn1X := vMgnX + vGap
	vBtn2X := vMgnX + vGap*3 + vBtnW
	vBtnY := vWinH - vMgnY - vBtnH
	vEditY := vBtnY - vMgnY - vBtnH
	vStcH := vEditY - vMgnY
	vPosEdit := Format("X{} Y{} W{} H{}", vMgnX, vEditY, vEditW, vBtnH)
	vPosBtn1 := Format("X{} Y{} W{} H{}", vBtn1X, vBtnY, vBtnW, vBtnH)
	vPosBtn2 := Format("X{} Y{} W{} H{}", vBtn2X, vBtnY, vBtnW, vBtnH)
	vPosStc := Format("X{} Y{} W{} H{}", vMgnX, vMgnY, vEditW, vStcH)

	hWnd := WinExist("A")
	if (vWinTitle = "")
		vWinTitle := AX_DlgTitle

	;WS_POPUPWINDOW := 0x80880000 ;composite style (WS_POPUP | WS_BORDER | WS_SYSMENU)
	;WS_VISIBLE := 0x10000000
	;WS_CLIPSIBLINGS := 0x4000000
	;WS_CAPTION := 0xC00000 ;composite style (WS_BORDER | WS_DLGFRAME)
	;WS_THICKFRAME := 0x40000
	;WS_EX_CONTROLPARENT := 0x10000
	;WS_EX_WINDOWEDGE := 0x100
	oGui := GuiCreate(vStylesWin, vWinTitle)
	oGui.SetFont(vFontOpt, vFontName)
	oGui.OnEvent("Close", Func("InputBoxNew_Close").Bind(oGui, "Close"))
	oGui.OnEvent("Escape", Func("InputBoxNew_Close").Bind(oGui, "Escape"))
	hGui := oGui.hWnd

	oGui.MarginX := vMgnX
	oGui.MarginY := vMgnY

	if !vHasPassChar
		oGui.Add("Edit", vStylesEdit " " vPosEdit, vDefault)
	else
	{
		oGui.Add("Edit", vStylesEditPW " " vPosEdit, vDefault)
		if !(vPassChar = "")
			PostMessage(0xCC, Ord(vPassChar),, "Edit1", "ahk_id " hGui) ;EM_SETPASSWORDCHAR := 0xCC
	}
	ControlFocus("Edit1", "ahk_id " hGui)
	PostMessage(0xB1, 0, -1, "Edit1", "ahk_id " hGui) ;EM_SETSEL := 0xB1 ;select all

	oBtn1 := oGui.Add("Button", vStylesButton1 " " vPosBtn1, vTextBtn1)
	oBtn2 := oGui.Add("Button", vStylesButton2 " " vPosBtn2, vTextBtn2)
	oBtn1.OnEvent("Click", Func("InputBoxNew_Close").Bind(oGui, "OK"))
	oBtn2.OnEvent("Click", Func("InputBoxNew_Close").Bind(oGui, "Cancel"))
	oGui.Add("Text", vStylesStatic " " vPosStc, vText)

	oGui.Show(vPosWin)

	oGui.OnEvent("Size", "InputBoxNew_Size")

	if !(vTimeout = "")
	{
		BoundFuncTemp := Func("InputBoxNew_Close").Bind(oGui, "Timeout")
		SetTimer(BoundFuncTemp, -vTimeout)
	}

	WinWaitClose("ahk_id " hGui)

	;if WinExist("ahk_id " hWnd)
	;	WinActivate("ahk_id " hWnd)

	if oInputBoxRet.Length()
		return oInputBoxRet[hGui].1
	else
		return
}
InputBoxNew_Close(oGui, vBtn)
{
	global oInputBoxRet
	try hWnd := oGui.hWnd
	catch
		vBtn := ""
	;MsgBox(A_ThisFunc " " hWnd " " vBtn)
	if (vBtn = "OK")
	{
		oArray := []
		Loop
		{
			hCtl := ControlGetHwnd("Edit" A_Index, "ahk_id " hWnd)
			if !hCtl
				break
			oArray.Push(ControlGetText("", "ahk_id " hCtl))
		}
		oInputBoxRet[hWnd] := oArray
		ErrorLevel := 0
		AX_InputBoxResult := 0
	}
	else
	{
		ErrorLevel := 1
		AX_InputBoxResult := 1
	}
	try oGui.Destroy
}
InputBoxNew_Size(oGui)
{
	try hWnd := oGui.hWnd
	catch
		return
	WinGetClientPos(vWinX, vWinY, vWinW, vWinH, "ahk_id " hWnd)
	vMgnX := oGui.MarginX
	vMgnY := oGui.MarginY
	ControlGetPos(,, vBtnW, vBtnH, "Button1", "ahk_id " hWnd)

	vEditW := vWinW - 2*vMgnX
	vGap := Round((vWinW - 2*vBtnW - 2*vMgnX)/4)
	vBtn1X := vMgnX + vGap
	vBtn2X := vMgnX + vGap*3 + vBtnW
	vBtnY := vWinH - vMgnY - vBtnH
	vEditY := vBtnY - vMgnY - vBtnH
	vStcH := vEditY - 5
	ControlMove(vMgnX, vEditY, vEditW, vBtnH, "Edit1", "ahk_id " hWnd)
	ControlMove(vBtn1X, vBtnY, vBtnW, vBtnH, "Button1", "ahk_id " hWnd)
	ControlMove(vBtn2X, vBtnY, vBtnW, vBtnH, "Button2", "ahk_id " hWnd)
	ControlMove(vMgnX, vMgnY, vEditW, vStcH, "Static1", "ahk_id " hWnd)
}

;==================================================

;FUNCTIONS - INPUTBOX MULTI

;note: no handling for passwords
;note: no handling for resize
InputBoxMulti(oParams*) ;oText, vWinTitle, vOpt, oDefault
{
	global oInputBoxRet

	oText := oParams.1
	vWinTitle := oParams.HasKey(2) ? oParams.2 : AX_DlgTitle
	vOpt := oParams.3
	oDefault := oParams.4

	if !IsObject(oInputBoxRet)
		oInputBoxRet := []
	hWnd := WinExist("A")

	if !IsObject(oText)
		oText := [oText]
	if !IsObject(oDefault)
		oDefault := [oDefault]

	DetectHiddenWindows(1)
	vPosWin := "", vTimeout := "", vPassChar := ""
	vMgnX := 5, vMgnY := 5
	vWinW := 368, vWinH := 166

	Loop Parse, vOpt, " `t"
	{
		if (SubStr(A_LoopField, 1, 1) = "W")
			vWinW := SubStr(A_LoopField, 2)
		else if (SubStr(A_LoopField, 1, 1) = "H")
			vWinH := SubStr(A_LoopField, 2)

		if (A_LoopField ~= "i)^[XYWH]")
			vPosWin .= A_LoopField " "
		else if (SubStr(A_LoopField, 1, 1) = "T")
			vTimeout := SubStr(A_LoopField, 2)
	}

	vStyleReset := "-0xFFFFFFFF -E0xFFFFFFFF "

	vTextBtn1 := AX_InputBoxOpt.TextButton1
	vTextBtn2 := AX_InputBoxOpt.TextButton2
	vFontName := AX_InputBoxOpt.FontName
	vFontSize := AX_InputBoxOpt.FontSize
	vFontWeight := AX_InputBoxOpt.FontWeight
	vStylesWin := vStyleReset AX_InputBoxOpt.StylesWin
	vStylesEdit := AX_InputBoxOpt.StylesEdit
	vStylesEditPW := AX_InputBoxOpt.StylesEditPW
	vStylesButton1 := AX_InputBoxOpt.StylesButton1
	vStylesButton2 := AX_InputBoxOpt.StylesButton2
	vStylesStatic := AX_InputBoxOpt.StylesStatic

	vFontOpt := "s" vFontSize
	hFont := JEE_FontCreate(vFontName, vFontSize, "", vFontWeight)
	JEE_StrGetDim(vTextBtn1, hFont, vBtn1W, vBtn1H, vDTFormat:=0x400, vLimW:="", vLimH:="")
	JEE_StrGetDim(vTextBtn2, hFont, vBtn2W, vBtn2H, vDTFormat:=0x400, vLimW:="", vLimH:="")
	vBtnW := Max(vBtn1W, vBtn2W) + 16
	vBtnH := Max(vBtn1H, vBtn2H) + 7

	vGap := Round((vWinW - 2*vBtnW - 2*vMgnX)/4)
	vBtn1X := vMgnX + vGap
	vBtn2X := vMgnX + vGap*3 + vBtnW

	vEditW := vWinW - 2*vMgnX
	vEditH := vBtnH
	vStcW := vEditW

	hWnd := WinExist("A")
	if (vWinTitle = "")
		vWinTitle := AX_DlgTitle

	;WS_POPUPWINDOW := 0x80880000 ;composite style (WS_POPUP | WS_BORDER | WS_SYSMENU)
	;WS_VISIBLE := 0x10000000
	;WS_CLIPSIBLINGS := 0x4000000
	;WS_CAPTION := 0xC00000 ;composite style (WS_BORDER | WS_DLGFRAME)
	;WS_THICKFRAME := 0x40000
	;WS_EX_CONTROLPARENT := 0x10000
	;WS_EX_WINDOWEDGE := 0x100
	oGui := GuiCreate(vStylesWin, vWinTitle)
	oGui.SetFont(vFontOpt, vFontName)
	oGui.OnEvent("Close", Func("InputBoxNew_Close").Bind(oGui, "Close"))
	oGui.OnEvent("Escape", Func("InputBoxNew_Close").Bind(oGui, "Escape"))
	hGui := oGui.hWnd

	vPosX := vMgnX, vPosY := vMgnY
	Loop Max(oText.Length(), oDefault.Length())
	{
		if (A_Index <= oDefault.Length())
		{
			JEE_StrGetDim(oText[A_Index], hFont, vStcW2, vStcH, vDTFormat:=0x400, vLimW:=vWinW, vLimH:="")
			vPosStc := Format("X{} Y{} W{} H{}", vPosX, vPosY, vStcW, vStcH)
			oGui.Add("Text", vStylesStatic " " vPosStc, oText[A_Index])
			vPosY += vStcH + vMgnY
		}
		if (A_Index <= oDefault.Length())
		{
			vPosEdit := Format("X{} Y{} W{} H{}", vPosX, vPosY, vEditW, vEditH)
			oGui.Add("Edit", vStylesEdit " " vPosEdit, oDefault[A_Index])
			vPosY += vEditH + vMgnY
		}
	}

	vBtnY := vPosY
	vPosBtn1 := Format("X{} Y{} W{} H{}", vBtn1X, vBtnY, vBtnW, vBtnH)
	vPosBtn2 := Format("X{} Y{} W{} H{}", vBtn2X, vBtnY, vBtnW, vBtnH)
	vPosY += vBtnH + vMgnY

	hWnd := WinExist("A")
	if (vWinTitle = "")
		vWinTitle := AX_DlgTitle

	oGui.MarginX := vMgnX
	oGui.MarginY := vMgnY

	ControlFocus("Edit1", "ahk_id " hGui)
	PostMessage(0xB1, 0, -1, "Edit1", "ahk_id " hGui) ;EM_SETSEL := 0xB1 ;select all

	oBtn1 := oGui.Add("Button", vStylesButton1 " " vPosBtn1, vTextBtn1)
	oBtn2 := oGui.Add("Button", vStylesButton2 " " vPosBtn2, vTextBtn2)
	oBtn1.OnEvent("Click", Func("InputBoxNew_Close").Bind(oGui, "OK"))
	oBtn2.OnEvent("Click", Func("InputBoxNew_Close").Bind(oGui, "Cancel"))

	if !InStr(vPosWin, "W")
		vPosWin .= " W" vWinW
	if !InStr(vPosWin, "H")
		vPosWin .= " H" vPosY
	oGui.Show(vPosWin)

	;oGui.OnEvent("Size", "InputBoxNew_Size")

	if !(vTimeout = "")
	{
		BoundFuncTemp := Func("InputBoxNew_Close").Bind(oGui, "Timeout")
		SetTimer(BoundFuncTemp, -vTimeout)
	}

	WinWaitClose("ahk_id " hGui)

	;if WinExist("ahk_id " hWnd)
	;	WinActivate("ahk_id " hWnd)

	if oInputBoxRet.Length()
		return oInputBoxRet[hGui]
	else
		return
}

;==================================================

;FUNCTIONS - PROGRESS/SPLASHIMAGE (AHK V1 DIAGNOSTIC)

;function wrappers for AHK v1
;to compare with these clone functions
/*
Progress(ProgressParam1, SubText:="", MainText:="", WinTitle:="", FontName:="")
{
	Progress, % ProgressParam1, % SubText, % MainText, % WinTitle, % FontName
}
SplashImage(ImageFile:="", Options:="", SubText:="", MainText:="", WinTitle:="", FontName:="")
{
	SplashImage, % ImageFile, % Options, % SubText, % MainText, % WinTitle, % FontName
}
*/

;diagnostic functions to test Progress/SplashImage commands using an AHK v1 exe
ProgressAhk1(oParams*)
{
	SplashAhk1("Progress", oParams*)
}
SplashImageAhk1(oParams*)
{
	SplashAhk1("SplashImage", oParams*)
}
SplashAhk1(vFunc, oParams*)
{
	global vGblPathAhk1
	global vGblDelayAhk1
	vPathAhk1 := vGblPathAhk1
	vDelay := vGblDelayAhk1
	vScript := vFunc
	if !FileExist(vPathAhk1)
		return
	Loop oParams.Length()
	{
		vValue := oParams[A_Index]
		if (vValue = "")
			vScript .= ", % " Chr(34) Chr(34)
		else
		{
			vValue := StrReplace(vValue, "`r", "``r")
			vValue := StrReplace(vValue, "`n", "``n")
			vScript .= ", % " Chr(34) vValue Chr(34)
		}
	}
	vScript .= "`r`nSleep, " vDelay
	;MsgBox(vScript)

	vDoWait := 1
	;based on ExecScript
	oShell := ComObjCreate("WScript.Shell")
	oExec := oShell.Exec(vPathAhk1 " /ErrorStdOut *")
	oExec.StdIn.Write(vScript)
	oExec.StdIn.Close()
	if vDoWait
		return oExec.StdOut.ReadAll()
}

;==================================================

;FUNCTIONS - PROGRESS/SPLASHIMAGE (AHK V2)

ProgressNew(vParam1, vSubText:="", vMainText:="", vWinTitle:=" ", vFontName:="")
{
	SplashImageNew("*PROGRESS*", vParam1, vSubText, vMainText, vWinTitle, vFontName)
}
SplashImageNew(vImageFile:="", vOpt:="", vSubText:="", vMainText:="", vWinTitle:=" ", vFontName:="")
{
	static vIsInit, oColRGB, vFontNameDefault, oGuiStore
	local vX, vY
	local vZX, vZY, vFM, vFS, vWM, vWS
	local vZW, vZH
	local vCB, vCT, vCW
	if !vIsInit
	{
		vListColRGB := " ;continuation section
		(LTrim
		Black=000000
		Silver=C0C0C0
		Gray=808080
		White=FFFFFF
		Maroon=800000
		Red=FF0000
		Purple=800080
		Fuchsia=FF00FF
		Green=008000
		Lime=00FF00
		Olive=808000
		Yellow=FFFF00
		Navy=000080
		Blue=0000FF
		Teal=008080
		Aqua=00FFFF
		)"
		oColRGB := Object(StrSplit(vListColRGB, ["=", "`n"])*)

		;DEFAULT_GUI_FONT := 17
		hFontDefault := DllCall("gdi32\GetStockObject", Int,17, Ptr)
		vSize := DllCall("gdi32\GetObject", Ptr,hFontDefault, Int,vSize, Ptr,0)
		VarSetCapacity(LOGFONT, vSize, 0)
		DllCall("gdi32\GetObject", Ptr,hFontDefault, Int,vSize, Ptr,&LOGFONT)
		vFontNameDefault := StrGet(&LOGFONT + 28, 32)
		DllCall("gdi32\DeleteObject", Ptr,hFontDefault)

		oGuiStore := {}
		vIsInit := 1
	}

	vDHW := A_DetectHiddenWindows
	DetectHiddenWindows("On")

	vNum := 1
	if (vImageFile = "*PROGRESS*") ;Progress
	{
		vIsProgress := 1
		vP := 0 ;progress bar (filled) position [Progress windows only]
		vZH := 20 ;progress bar thickness
		if RegExMatch(vOpt, "^(\d+):(.*)$", oMatch) ;window number (which window to change)
			vNum := oMatch.1, vOpt := oMatch.2
		if (vOpt = "Off")
		|| (vOpt = "Show")
			vImageFile := vOpt, vOpt := ""
		;else if !(vOpt+0 = "")
		else if vOpt is "number"
			vP := vOpt
	}

	if (vWinTitle = " ")
		vWinTitle := AX_DlgTitle

	if (SubStr(vFontName, 1, 6) = "HFONT:")
		hFont := SubStr(vFontName, 7)+0
	if !hFont && (vFontName = "")
		vFontName := vFontNameDefault

	if RegExMatch(vImageFile, "^(\d+):(.*)$", oMatch) ;window number (which window to change)
		vNum := oMatch.1, vImageFile := oMatch.2

	vID := (vIsProgress ? "P" : "S") vNum
	if (vImageFile = "Off")
	{
		if !oGuiStore.HasKey(vID)
			return
		oGui := GuiFromHwnd(oGuiStore[vID])
		oGuiStore.Delete(vID)
		oGui.Destroy()
		DetectHiddenWindows(vDHW)
		return
	}
	else if (vImageFile = "Show")
	{
		WinShow("ahk_id " oGuiStore[vID])
		DetectHiddenWindows(vDHW)
		return
	}
	else if (vImageFile = "Hide")
	{
		WinHide("ahk_id " oGuiStore[vID])
		DetectHiddenWindows(vDHW)
		return
	}
	else if !vIsProgress
	&& !(vImageFile = "")
	&& !InStr(vImageFile, "\")
	&& !(SubStr(vImageFile, 1, 8) = "HBITMAP:")
	&& !(SubStr(vImageFile, 1, 6) = "HICON:")
		vImageFile := A_WorkingDir "\" vImageFile

	;get image dimensions
	if !vIsProgress
		if (SubStr(vImageFile, 1, 8) = "HBITMAP:")
		{
			hImg := SubStr(vImageFile, 9)+0
			if !(hImg ~= "^\d+$")
				return
			JEE_HBitmapGetDims(hImg, vImgW, vImgH)
		}
		else if (SubStr(vImageFile, 1, 6) = "HICON:")
		{
			hImg := SubStr(vImageFile, 7)+0
			if !(hImg ~= "^\d+$")
				return
			JEE_HIconGetDims(hImg, vImgW, vImgH)
		}
		else if InStr(vImageFile, "\")
		{
			hImg := LoadPicture(vImageFile,, vImgType) ;IMAGE_ICON := 1 ;IMAGE_BITMAP := 0
			if (vImgType = 0)
				JEE_HBitmapGetDims(hImg, vImgW, vImgH)
			else if (vImgType = 1)
				JEE_HIconGetDims(hImg, vImgW, vImgH)
		}

	;WS_POPUP := 0x80000000	;WS_DISABLED := 0x8000000
	;WS_CLIPSIBLINGS := 0x4000000
	;WS_CAPTION := 0xC00000 := WS_BORDER|WS_DLGFRAME := 0x800000|0x400000
	vWinStyle := 0x8CC00000
	;WS_EX_WINDOWEDGE := 0x100 ;WS_EX_TOPMOST := 0x8
	vWinExStyle := 0x108
	vWinX := vWinY := vWinW := vWinX := ""
	vCM := 1, vCS := 1 ;main/sub text centred by default
	vFM := 0, vFS := 0 ;main/sub font size
	;FW_BOLD := 700 ;FW_SEMIBOLD := 600
	;FW_NORMAL := 400 ;FW_DONTCARE := 0
	vWM := 600, vWS := 400 ;main/sub font weight
	if vIsProgress || !(vMainText = "") || !(vSubText = "")
		vZX := 10, vZY := 5 ;margins
	else
		vZX := 0, vZY := 0 ;margins
	vR1 := "" ;progress bar range ;[Progress windows only]
	vR2 := "" ;progress bar range ;[Progress windows only]

	Loop Parse, vOpt, " `t"
	{
		vTemp := A_LoopField
		if (vTemp = "A") ;always-on-top *off*
		|| (vTemp = "A0") ;always-on-top *off*
			vWinExStyle &= 0x8 ^ -1 ;WS_EX_TOPMOST := 0x8
		else if (vTemp = "B") ;*no* border, no title bar
		|| (vTemp = "B0") ;*no* border, no title bar
			vWinStyle &= 0xC00000 ^ -1 ;WS_CAPTION := 0xC00000
		else if (vTemp = "B1") ;thin border, no title bar
		{
			vWinStyle &= 0xC00000 ^ -1 ;WS_CAPTION := 0xC00000
			vWinStyle |= 0x800000 ;WS_BORDER := 0x800000
		}
		else if (vTemp = "B2") ;dialog-style border, no title bar
		{
			vWinStyle &= 0xC00000 ^ -1 ;WS_CAPTION := 0xC00000
			vWinStyle |= 0x400000 ;WS_DLGFRAME := 0x400000
		}
		else if (vTemp = "M") ;movable
			vWinStyle &= 0x8000000 ^ -1 ;WS_DISABLED := 0x8000000
		else if (vTemp = "M1") ;resizeable
		{
			vWinStyle |= 0x40000 ;WS_THICKFRAME := 0x40000
			vWinStyle &= 0x8000000 ^ -1 ;WS_DISABLED := 0x8000000
		}
		else if (vTemp = "M2") ;resizeable + sysmenu + title bar buttons
		;WS_MINIMIZEBOX := 0x20000 ;WS_MAXIMIZEBOX := 0x10000
		;WS_SYSMENU := 0x80000 ;WS_THICKFRAME := 0x40000
		{
			vWinStyle |= 0xF0000
			vWinStyle &= 0x8000000 ^ -1 ;WS_DISABLED := 0x8000000
		}
		;else if (vTemp = "T") ;taskbar button
		;	vIsOwned := 0
		else if (vTemp = "Hide")
		{
			WinHide("ahk_id " oGuiStore[vID])
			DetectHiddenWindows(vDHW)
			return
		}
		else if (vTemp ~= "i)^[XY]-?\d") ;X/Y coordinates
		|| (vTemp ~= "i)^[WH]\d")
		{
			vTemp1 := SubStr(vTemp, 1, 1)
			vWin%vTemp1% := SubStr(vTemp, 2)+0
		}
		else if (vTemp ~= "i)^C\d\d$") ;centred
		{
			vCM := SubStr(vTemp, 2, 1)
			vCS := SubStr(vTemp, 3, 1)
		}
		else if (vTemp ~= "i)^(ZX|ZY|FM|FS|WM|WS)\d+$") ;X/Y margins, main/sub font size, main/sub font weight
		|| (vTemp ~= "i)^(ZW|ZH)-?\d+$") ;image width/height, progress bar thickness
		{
			vTemp1 := SubStr(vTemp, 1, 2)
			v%vTemp1% := SubStr(vTemp, 3)
		}
		;CB## [Progress windows only]
		else if (vTemp ~= "i)^(CB|CT|CW)[a-z0-9]+") ;progress bar/text/window colours
		{
			vTemp1 := SubStr(vTemp, 1, 2)
			vTemp2 := SubStr(vTemp, 3)
			if oColRGB.HasKey(vTemp2)
				v%vTemp1% := oColRGB[vTemp2] ;hex number without 0x
				;v%vTemp1% := "0x" oColRGB[vTemp2] ;hex number with 0x
			else
				v%vTemp1% := Format("{:06X}", vTemp2) ;hex number without 0x
				;v%vTemp1% := vTemp ;dec number/hex number with 0x
		}
		;P## [Progress windows only] progress bar (filled) position
		else if RegExMatch(vTemp, "i)^P-?\d+")
			vP := SubStr(vTemp, 2)
		;R##-## [Progress windows only] progress bar range
		else if RegExMatch(vTemp, "i)^R(-?\d+)-(-?\d+)$", oMatch)
			vR1 := oMatch.1+0, vR2 := oMatch.2+0
		else if (SubStr(vTemp, 1, 2) = "IE") ;use Internet Explorer_Server control
			vIsIE := 1, vZoomIE := SubStr(vTemp, 3)
		else if (SubStr(vTemp, 1, 6) = "HICON:")
			hIcon := SubStr(vTemp, 7), hIcon += 0
	}
	vStylesWin := "-0xFFFFFFFF " vWinStyle " E" vWinExStyle
	if !vZH ;if no progress bar, place MainText slightly higher
		vZY := 0

	if oGuiStore.HasKey(vID)
	{
		if vIsProgress && !(vP = "")
			SendMessage(0x402, vP,, "msctls_progress321", "ahk_id " oGuiStore[vID]) ;PBM_SETPOS := 0x402
		vText1 := ControlGetText("Static1", "ahk_id " oGuiStore[vID])
		vText2 := ControlGetText("Static2", "ahk_id " oGuiStore[vID])
		if !(vText1 = vSubText)
			ControlSetText(vText1, "Static1", "ahk_id " oGuiStore[vID])
		if !(vText1 = vMainText)
			ControlSetText(vText2, "Static2", "ahk_id " oGuiStore[vID])
		if !(vCB = "")
		{
			vCB := "0x" vCB
			vCBBGR := ((0xFF & vCB) << 16) + (0xFF00 & vCB) + ((0xFF0000 & vCB) >> 16)
			SendMessage(0x409, 0, vCBBGR, "msctls_progress321", "ahk_id " oGuiStore[vID]) ;PBM_SETBARCOLOR := 0x409 ;doesn't work if set theme to blank
			;SendMessage(0x2001, 0, vCBBGR, "msctls_progress321", "ahk_id " oGuiStore[vID]) ;PBM_SETBKCOLOR := 0x2001 ;doesn't work if set theme to blank
		}
		if !(vCT = "")
		{
			hCtl1 := ControlGetHwnd("Static1", "ahk_id " oGuiStore[vID])
			hCtl2 := ControlGetHwnd("Static2", "ahk_id " oGuiStore[vID])
			GuiCtrlFromHwnd(hCtl1).Opt("C" vCW)
			GuiCtrlFromHwnd(hCtl2).Opt("C" vCW)
		}
		if !(vCW = "")
		{
			oGui := GuiFromHwnd(oGuiStore[vID])
			oGui.BackColor := vCW
		}
		DetectHiddenWindows(vDHW)
		return
	}

	oGui := GuiCreate(vStylesWin, vWinTitle)
	;oGui.SetFont(vFontOpt, vFontName)
	;oGui.OnEvent("Close", Func("MsgBoxNew_Close").Bind(oGui, vTextBtn%vBtnClose%))
	;oGui.OnEvent("Escape", Func("MsgBoxNew_Close").Bind(oGui, vTextBtn%vBtnClose%))
	hGui := oGui.hWnd
	oGuiStore[vID] := hGui

	if (vWinStyle & 0x80000) ;WS_SYSMENU := 0x80000
		SendMessage(0x80, 0, hIcon,, "ahk_id " hGui) ;WM_SETICON := 0x80 ;ICON_SMALL := 0 ;sets title bar icon + taskbar icon
	if !vIsOwned
		SendMessage(0x80, 1, hIcon,, "ahk_id " hGui) ;WM_SETICON := 0x80 ;ICON_BIG := 1 ;sets alt+tab icon

	if !(vCW = "")
		oGui.BackColor := vCW

	if hFont
		hFontM := hFontS := hFont
	else
	{
		if !(vMainText = "")
			hFontM := JEE_FontCreate(vFontName, vFM, "", vWM)
		if !(vSubText = "")
			hFontS := JEE_FontCreate(vFontName, vFS, "", vWS)
	}

	;WS_CHILD := 0x40000000 ;WS_VISIBLE := 0x10000000
	;PBS_SMOOTH := 0x1
	;WS_EX_CLIENTEDGE := 0x200
	;vStylesPgs := 0x50000001
	vStylesPgs := 0x50000000

	vTextMW := vTextMH := 0
	vTextSW := vTextSH := 0
	if !(vMainText = "")
		JEE_StrGetDim(vMainText, hFontM, vTextMW, vTextMH, vDTFormat:=0x400, vLimW:="", vLimH:="")
	if !(vSubText = "")
		JEE_StrGetDim(vSubText, hFontS, vTextSW, vTextSH, vDTFormat:=0x400, vLimW:="", vLimH:="")

	if (vZW = -1) && (vZH = -1)
		vZW := vZH := ""
	if (vZW = -1)
		vZW := Round(vImgW * (vZH/vImgH))
	if (vZH = -1)
		vZH := Round(vImgH * (vZW/vImgW))
	if !(vZW = "")
		vImgW := vZW
	if !(vZH = "")
		vImgH := vZH
	if !vImgW
		vImgW := 0
	if !vImgH && !vIsProgress
		vImgH := 20
	if !vWinW
		if vIsProgress
			vWinW := Max(280, vTextMW, vTextSW) + 2*vZX
		else
			vWinW := vImgW + 2*vZX

	vStcMY := vZY
	vImgY := vStcMY + (vTextMH = 0 ? 0 : 21)
	vStcSY := vImgY + vImgH + vZY
	if !vWinH
		vWinH := vStcSY + vTextSH

	;WS_THICKFRAME require a minimum window width
	if (vWinStyle & 0x40000) ;WS_THICKFRAME := 0x40000
	{
		vMinW := SysGet(34) ;SM_CXMINTRACK := 34
		vMinH := SysGet(35) ;SM_CYMINTRACK := 35
		;specify negative values to convert window to client
		;What is the inverse of AdjustWindowRect and AdjustWindowRectEx? – The Old New Thing
		;https://blogs.msdn.microsoft.com/oldnewthing/20131017-00/?p=2903
		VarSetCapacity(RECT, 16, 0)
		NumPut(-vMinW, RECT, 8, "Int")
		NumPut(-vMinH, RECT, 12, "Int")
		DllCall("user32\AdjustWindowRectEx", Ptr,&RECT, UInt,vWinStyle, Int,0, UInt,vWinExStyle)
		vWinW2 := Abs(NumGet(&RECT, 8, "Int"))
		vWinH2 := Abs(NumGet(&RECT, 12, "Int"))
		vWinW := Max(vWinW, vWinW2)
		;vWinH := Max(vWinH, vWinH2)
	}

	MonitorGetWorkArea(1, vLimX, vLimY, vLimR, vLimB)
	vLimW := vLimR-vLimX, vLimH := vLimB-vLimY
	if (vWinW > vLimW)
		vWinW := vLimW
	if (vWinH > vLimH)
		vWinH := vLimH

	if vIsProgress && !vImgW
		vImgW := vWinW - 2*vZX
	vTextMW := vWinW - 2*vZX
	vTextSW := vWinW - 2*vZX

	vMainTextPos := Format("X{} Y{} W{} H{}", vZX, vStcMY, vTextMW, vTextMH)
	vSubTextPos := Format("X{} Y{} W{} H{}", vZX, vStcSY, vTextSW, vTextSH)
	vImgPos := Format("X{} Y{} {} {}", vZX, vImgY, (vImgW = "") ? "" : "W" vImgW, (vImgH = "") ? "" : "H" vImgH)

	;WS_CHILD := 0x40000000 ;WS_VISIBLE := 0x10000000
	;SS_NOPREFIX := 0x80
	;SS_CENTER := 0x1 ;SS_LEFT := 0x0
	vStylesMainText := (0x50000080|vCM) " E0x00000000"
	vStylesSubText := (0x50000080|vCS) " E0x00000000"
	if !(vCT = "")
		vCT := "C" vCT
	oCtl1 := oGui.Add("Text", vStylesMainText " " vMainTextPos " " vCT, vMainText)
	if vIsProgress && vImgH
	{
		vTemp := vStylesPgs " " vImgPos
		if !(vCB = "")
			vTemp .= " C" vCB
		if !(vR1 = "") && !(vR2 = "")
			vTemp .= " Range" vR1 "-" vR2
		oCtl3 := oGui.Add("Progress", vTemp, vP)
		if (vCB = "")
			DllCall("uxtheme\SetWindowTheme", Ptr,oCtl3.hWnd, Str,"", Ptr,0)
		;SendMessage(0x401, 0, (vR2 << 16) | (vR1 & 0xFFFF),, "ahk_id " oCtl3.hWnd) ;PBM_SETRANGE := 0x401
		;SendMessage(0x406, vR1, vR2,, "ahk_id " oCtl3.hWnd) ;PBM_SETRANGE32 := 0x406
	}
	if !(vCT = "")
		vCT := "C" vCT
	oCtl2 := oGui.Add("Text", vStylesSubText " " vSubTextPos " " vCT, vSubText)
	if !vIsProgress && !vIsIE
		oCtl3 := oGui.Add("Picture", vStylesImg " " vImgPos, vImageFile)
	if !vIsProgress && vIsIE
	{
		oWB := oGui.Add("ActiveX", vImgPos, "Shell.Explorer").Value
		oWB.Navigate(vImageFile)
		;OLECMDID_OPTICAL_ZOOM := 63 ;OLECMDEXECOPT_DONTPROMPTUSER := 2
		while oWB.Busy || !(oWB.ReadyState = 4)
			Sleep(100)
		;oWB.ExecWB(63, 2, 30, 0) ;zoom 30%
		if !(vZoomIE = "")
			oWB.ExecWB(63, 2, vZoomIE+0, 0)
		;oWB.document.parentWindow.scrollBy(120, 35)
		oWB.document.body.scroll := "no"
	}

	SendMessage(0x30, hFontM, 0,, "ahk_id " oCtl1.hWnd) ;WM_SETFONT := 0x30
	SendMessage(0x30, hFontS, 0,, "ahk_id " oCtl2.hWnd) ;WM_SETFONT := 0x30

	;vWinPos := Format("X{} Y{} W{} H{}", vWinX, vWinY, vWinW, vWinH)
	if !(vWinX = "")
		vWinPos .= "X" vWinX " "
	if !(vWinY = "")
		vWinPos .= "Y" vWinY " "
	if !(vWinW = "")
		vWinPos .= "W" vWinW " "
	if !(vWinH = "")
		vWinPos .= "H" vWinH " "

	oGui.Show(vWinPos " NoActivate")
	DetectHiddenWindows(vDHW)
	;WinWaitClose("ahk_id " hGui)
	return hGui
}

;==================================================

;FUNCTIONS - TOOLTIP

;note: specify c for vPosX or vPosY, to place the ToolTip in the centre of the screen
ToolTipNew(vText:="", vPosX:="", vPosY:="", vWhichToolTip:=1, vColTxRGB:="", vColBkRGB:="")
{
	static oArray := []
	if (vText = "")
	{
		if oArray[vWhichToolTip]
			DllCall("user32\DestroyWindow", Ptr,oArray[vWhichToolTip])
		oArray[vWhichToolTip] := 0
		return
	}
	else if oArray[vWhichToolTip]
		DllCall("user32\DestroyWindow", Ptr,oArray[vWhichToolTip])

	vFontName := AX_ToolTipOpt.FontName
	vFontSize := AX_ToolTipOpt.FontSize
	vFontWeight := AX_ToolTipOpt.FontWeight
	if (vColTxRGB = "")
		vColTxRGB := AX_ToolTipOpt.ColTxRGB
	if (vColBkRGB = "")
		vColBkRGB := AX_ToolTipOpt.ColBkRGB
	if (vFontName = "")
		vFontName := "Segoe UI"
	if (vFontSize = "")
		vFontSize := 9
	if (vFontWeight = "")
		vFontWeight := 400
	if (vColTxRGB = "")
		vColTxRGB := 0x000000
	if (vColBkRGB = "")
		vColBkRGB := 0xFFFFFF

	;if either X or Y is unspecified,
	;get cursor position
	if (vPosX = "") || (vPosY = "")
	{
		vCMM := A_CoordModeMouse
		CoordMode("Mouse", "Screen")
		MouseGetPos(vCurX, vCurY)
		CoordMode("Mouse", vCMM)
	}

	;if either X or Y is numeric,
	;get required offset
	if !((vPosX = "c") || (vPosX = ""))
	|| !((vPosY = "c") || (vPosY = ""))
	{
		if (A_CoordModeToolTip = "Window")
			WinGetPos(vOffsetX, vOffsetY,,, "A")
		else if (A_CoordModeToolTip = "Client")
			WinGetClientPos(vOffsetX, vOffsetY,,, "A")
		else
			vOffsetX := vOffsetY := 0
	}

	if (vPosX = "")
		vPosX := vCurX+16
	else if !(vPosX = "c")
		vPosX += vOffsetX
	if (vPosY = "")
		vPosY := vCurY+16
	else if !(vPosY = "c")
		vPosY += vOffsetY

	vColTxBGR := ((0xFF & vColTxRGB) << 16) + (0xFF00 & vColTxRGB) + ((0xFF0000 & vColTxRGB) >> 16)
	vColBkBGR := ((0xFF & vColBkRGB) << 16) + (0xFF00 & vColBkRGB) + ((0xFF0000 & vColBkRGB) >> 16)

	vDHW := A_DetectHiddenWindows
	DetectHiddenWindows("On")
	vSizeTI := A_PtrSize=8?72:48
	VarSetCapacity(TOOLINFO, vSizeTI, 0)
	NumPut(vSizeTI, &TOOLINFO, 0, "UInt") ;cbSize
	NumPut(0x20, &TOOLINFO, 4, "UInt") ;uFlags ;TTF_TRACK := 0x20
	NumPut(&vText, &TOOLINFO, A_PtrSize=8?48:36, "Ptr") ;lpszText

	;create window
	;WS_VISIBLE := 0x10000000
	;vWinStyle := 0x8
	;vWinExStyle := 0x3
	vWinStyle := 0x94000003
	;vWinStyle := 0x84000003
	vWinExStyle := 0x00080088

	;TTS_USEVISUALSTYLE := 0x100
	;TTS_CLOSE := 0x80 ;TTS_BALLOON := 0x40
	;TTS_NOFADE := 0x20 ;TTS_NOANIMATE := 0x10
	;TTS_NOPREFIX := 0x2 ;TTS_ALWAYSTIP := 0x1
	;WS_EX_TOPMOST := 0x8
	hTT := DllCall("user32\CreateWindowEx", UInt,vWinExStyle, Str,"tooltips_class32", Ptr,0, UInt,vWinStyle, Int,0, Int,0, Int,0, Int,0, Ptr,A_ScriptHwnd, Ptr,0, Ptr,0, Ptr,0, Ptr)
	;WinSet, Style, 0x94000003, % "ahk_id " hTT
	;WinSet, ExStyle, 0x00080088, % "ahk_id " hTT

	;set background colours/margins
	;the text/font/margins will determine the window size
	if (AX_ToolTipOpt.SetWindowTheme = 0)
		DllCall("uxtheme\SetWindowTheme", Ptr,hTT, Ptr,0, Str,"")
	VarSetCapacity(RECT, 16, 0)
	;vMgnL := vMgnR := 8
	;vMgnT := vMgnB := 4
	vMgnL := vMgnR := 4
	vMgnT := vMgnB := 1
	vRect := vMgnL "," vMgnT "," vMgnR "," vMgnB
	Loop Parse, vRect, ","
		NumPut(A_LoopField, &RECT, A_Index*4-4, "Int")
	SendMessage(0x41A, 0, &RECT,, "ahk_id " hTT) ;TTM_SETMARGIN := 0x41A
	SendMessage(0x413, vColBkBGR, 0,, "ahk_id " hTT) ;TTM_SETTIPBKCOLOR := 0x413
	SendMessage(0x414, vColTxBGR, 0,, "ahk_id " hTT) ;TTM_SETTIPTEXTCOLOR := 0x414

	;to allow multiline ToolTips
	SendMessage(0x418, 0, 200,, "ahk_id " hTT) ;TTM_SETMAXTIPWIDTH := 0x418

	;set font
	vFontHeight := -Round(vFontSize*A_ScreenDPI/72)
	hFont := DllCall("gdi32\CreateFont", Int,vFontHeight, Int,0, Int,0, Int,0, Int,vFontWeight, UInt,0, UInt,0, UInt,0, UInt,0, UInt,0, UInt,0, UInt,0, UInt,0, Str,vFontName, Ptr)
	SendMessage(0x30, hFont, 0,, "ahk_id " hTT) ;WM_SETFONT := 0x30

	if (vPosX = "c") || (vPosY = "c")
		JEE_StrGetDim(vText, hFont, vTextW, vTextH, vDTFormat:=0x400, vLimW:="", vLimH:="")
	if (vPosX = "c")
	{
		vWinW := vTextW + vMgnL + vMgnR + 5 ;5 is of unknown origin
		vPosX := Round((A_ScreenWidth - vWinW) / 2)
	}
	if (vPosY = "c")
	{
		vWinH := vTextH + vMgnT + vMgnB + 3 ;3 is of unknown origin
		vPosY := Round((A_ScreenHeight - vWinH) / 2)
	}

	;TTM_TRACKPOSITION will determine the window position
	SendMessage(A_IsUnicode?0x432:0x404, 0, &TOOLINFO,, "ahk_id " hTT) ;TTM_ADDTOOLW := 0x432
	SendMessage(0x412, 0, (vPosX&0xFFFF)|(vPosY<<16),, "ahk_id " hTT) ;TTM_TRACKPOSITION := 0x412
	SendMessage(0x411, 1, &TOOLINFO,, "ahk_id " hTT) ;TTM_TRACKACTIVATE := 0x411

	;vWinPos1 := Format("x{} y{} w{} h{}", vPosX, vPosY, vWinW, vWinH)
	;WinGetPos, vWinX, vWinY, vWinW, vWinH, % "ahk_id " hTT
	;vWinPos2 := Format("x{} y{} w{} h{}", vWinX, vWinY, vWinW, vWinH)
	;MsgBox, % vWinPos1 "`r`n" vWinPos2

	oArray[vWhichToolTip] := hTT

	DetectHiddenWindows(vDHW)
}

;==================================================

;FUNCTIONS - BORDERS

Borders(vPosX, vPosY, vPosW:=0, vPosH:=0, vTime:=1000, vColRGB:=0xFFFF00, vBdrW:=5, vBdrH:=5)
{
	;based on example at the very bottom of:
	;WinSet
	;https://autohotkey.com/docs/commands/WinSet.htm
	static vWinClass := "AHKBordersClass"
	static vFunc := "Borders_WndProc"
	static pWndProc := CallbackCreate(vFunc, "F")
	static vPIs64 := (A_PtrSize=8)
	static vSize := vPIs64?80:48
	VarSetCapacity(WNDCLASSEX, vSize, 0)
	NumPut(vSize, &WNDCLASSEX, 0, "UInt") ;cbSize
	NumPut(pWndProc, &WNDCLASSEX, 8, "Ptr") ;lpfnWndProc
	vColBGR := ((0xFF & vColRGB) << 16) + (0xFF00 & vColRGB) + ((0xFF0000 & vColRGB) >> 16)
	hBrush := DllCall("gdi32\CreateSolidBrush", UInt,vColBGR, Ptr)
	NumPut(hBrush, &WNDCLASSEX, vPIs64?48:32, "Ptr") ;hbrBackground
	NumPut(&vWinClass, &WNDCLASSEX, vPIs64?64:40, "Ptr") ;lpszClassName
	DllCall("user32\RegisterClassEx", Ptr,&WNDCLASSEX, UShort)

	vPosX -= vBdrW, vPosY -= vBdrH
	vPosW += vBdrW*2, vPosH += vBdrH*2

	DetectHiddenWindows("On")
	;WS_POPUP := 0x80000000
	;WS_EX_TOOLWINDOW := 0x80 ;WS_EX_TOPMOST := 0x8
	vWinText := "", vWinStyle := 0x80000000, vWinExStyle := 0x88
	hWnd := DllCall("user32\CreateWindowEx", UInt,vWinExStyle, Str,vWinClass, Str,vWinText, UInt,vWinStyle, Int,vPosX, Int,vPosY, Int,vPosW, Int,vPosH, Ptr,0, Ptr,0, Ptr,0, Ptr,0, Ptr)
	vBdrL := vBdrR := vBdrW
	vBdrT := vBdrB := vBdrH
	oArray := [vPosW, vPosH, vBdrL, vPosW-vBdrR, vBdrT, vPosH-vBdrB]
	vRegion := Format("0-0 {1:}-0 {1:}-{2:} 0-{2:} 0-0" " {3:}-{5:} {4:}-{5:} {4:}-{6:} {3:}-{6:} {3:}-{5:}", oArray*)
	WinSetRegion(vRegion, "ahk_id " hWnd)
	WinShow("ahk_id " hWnd)

	Sleep(vTime)
	DllCall("user32\DestroyWindow", Ptr,hWnd)
}
Borders_WndProc(hWnd, uMsg, wParam, lParam)
{
	return DllCall("user32\DefWindowProc", Ptr,hWnd, UInt,uMsg, UPtr,wParam, Ptr,lParam, Ptr)
}

;==================================================

;;FUNCTIONS - AUXILIARY

;==================================================

JEE_HIconGetDims(hIcon, &vImgW, &vImgH)
{
	vIsMask := 0
	VarSetCapacity(ICONINFO, A_PtrSize=8?32:20, 0)
	DllCall("user32\GetIconInfo", Ptr,hIcon, Ptr,&ICONINFO)
	hBitmapCol := NumGet(&ICONINFO, A_PtrSize=8?24:16, "Ptr") ;hbmColor
	hBitmapMask := NumGet(&ICONINFO, A_PtrSize=8?16:12, "Ptr") ;hbmMask
	if hBitmap := hBitmapCol
	{
		if hBitmapMask
			DllCall("gdi32\DeleteObject", Ptr,hBitmapMask)
	}
	else if hBitmap := hBitmapMask
		vIsMask := 1
	else
		return
	VarSetCapacity(BITMAP, A_PtrSize=8?32:24, 0)
	DllCall("gdi32\GetObject", Ptr,hBitmap, Int,A_PtrSize=8?32:24, Ptr,&BITMAP)
	vImgW := NumGet(&BITMAP, 4, "Int") ;bmWidth
	vImgH := NumGet(&BITMAP, 8, "Int") ;bmHeight
	if vIsMask
		vImgH //= 2
	DllCall("gdi32\DeleteObject", Ptr,hBitmap)
}

;==================================================

JEE_HBitmapGetDims(hBitmap, &vImgW, &vImgH)
{
	VarSetCapacity(BITMAP, A_PtrSize=8?32:24, 0)
	DllCall("gdi32\GetObject", Ptr,hBitmap, Int,A_PtrSize=8?32:24, Ptr,&BITMAP)
	vImgW := NumGet(&BITMAP, 4, "Int") ;bmWidth
	vImgH := NumGet(&BITMAP, 8, "Int") ;bmHeight
}

;==================================================

;e.g. hFont := JEE_FontCreate("Arial", 12, "bius")

;JEE_CreateFont
JEE_FontCreate(vName, vSize, vFontStyle:="", vWeight:="")
{
	vHeight := -DllCall("kernel32\MulDiv", Int,vSize, Int,A_ScreenDPI, Int,72)
	vWidth := 0
	vEscapement := 0
	vOrientation := 0
	vWeight := (vWeight != "") ? vWeight : InStr(vFontStyle, "b") ? 700 : 400
	vItalic := InStr(vFontStyle, "i") ? 1 : 0
	vUnderline := InStr(vFontStyle, "u") ? 1 : 0
	vStrikeOut := InStr(vFontStyle, "s") ? 1 : 0
	vCharSet := 0
	vOutPrecision := 0
	vClipPrecision := 0
	vQuality := 0
	vPitchAndFamily := 0
	vFaceName := vName
	vOutPrecision := 3
	vClipPrecision := 2
	vQuality := 1
	vPitchAndFamily := 34
	return DllCall("gdi32\CreateFont", Int,vHeight, Int,vWidth, Int,vEscapement, Int,vOrientation, Int,vWeight, UInt,vItalic, UInt,vUnderline, UInt,vStrikeOut, UInt,vCharSet, UInt,vOutPrecision, UInt,vClipPrecision, UInt,vQuality, UInt,vPitchAndFamily, Str,vFaceName, Ptr)
}

;==================================================

;vLimW and vLimH if present are used as limits
;JEE_DrawText
JEE_StrGetDim(vText, hFont, &vTextW, &vTextH, vDTFormat:=0x400, vLimW:="", vLimH:="")
{
	;DT_EDITCONTROL := 0x2000 ;DT_NOPREFIX := 0x800
	;DT_CALCRECT := 0x400 ;DT_NOCLIP := 0x100
	;DT_EXPANDTABS := 0x40 ;DT_SINGLELINE := 0x20
	;DT_WORDBREAK := 0x10

	;HWND_DESKTOP := 0
	hDC := DllCall("user32\GetDC", Ptr,0, Ptr)
	hFontOld := DllCall("gdi32\SelectObject", Ptr,hDC, Ptr,hFont, Ptr)
	VarSetCapacity(SIZE, 8, 0)
	vTabLengthText := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
	DllCall("gdi32\GetTextExtentPoint32", Ptr,hDC, Str,vTabLengthText, Int,52, Ptr,&SIZE)
	vTabLength := NumGet(&SIZE, 0, "Int") ;cx ;logical units
	vTabLength := Floor((vTabLength/52)+0.5)
	vTabLength := Round(vTabLength*(72/A_ScreenDPI))
	vLen := StrLen(vText)

	VarSetCapacity(DRAWTEXTPARAMS, 20, 0)
	NumPut(20, &DRAWTEXTPARAMS, 0, "UInt") ;cbSize
	NumPut(vTabLength, &DRAWTEXTPARAMS, 4, "Int") ;iTabLength
	;NumPut(0, &DRAWTEXTPARAMS, 8, "Int") ;iLeftMargin
	;NumPut(0, &DRAWTEXTPARAMS, 12, "Int") ;iRightMargin
	NumPut(vLen, &DRAWTEXTPARAMS, 16, "UInt") ;uiLengthDrawn

	VarSetCapacity(RECT, 16, 0)
	if !(vLimW = "")
		NumPut(vLimW, &RECT, 8, "Int")
	if !(vLimH = "")
		NumPut(vLimH, &RECT, 12, "Int")
	DllCall("user32\DrawTextEx", Ptr,hDC, Str,vText, Int,vLen, Ptr,&RECT, UInt,vDTFormat, Ptr,&DRAWTEXTPARAMS)
	DllCall("gdi32\SelectObject", Ptr,hDC, Ptr,hFontOld, Ptr)
	DllCall("user32\ReleaseDC", Ptr,0, Ptr,hDC)

	vTextW := NumGet(&RECT, 8, "Int")
	vTextH := NumGet(&RECT, 12, "Int")
}

;==================================================
