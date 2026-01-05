;ABOUT: Initial version

#Requires AutoHotkey v2.0+
#SingleInstance Force
;#NoTrayIcon
Escape::ExitApp()

Persistent

; Hotkey definition with the tilde (~) prefix
~LButton::
{
    ; This code runs every time the LButton is pressed down, 
    ; but the click is still sent to the window underneath.
	MouseGetPos(&OutputVarX, &OutputVarY, &OutputVarWin, &OutputVarControl)  , StoreHwnd:=2
	IF (OutputVarWin = MyGui.Hwnd)
	 	Return

    CoordMode "Mouse", "Screen" ; Use screen coordinates
    MouseGetPos(&X, &Y)        ; Get the cursor position

    ToolTip("LButton Click Detected, Coords: X" X " Y" Y), Sleep(1000), ToolTip()
    ; You can add any custom action here, like logging, specific actions, etc.
}

;MyGui := Gui("+AlwaysOnTop")
MyGui := Gui()
MyGui.Show("w200 h200")

MyGui2 := Gui("-Caption +LastFound +ToolWindow")

;WinSetTransparent(1, MyGui.Hwnd)

MyGui2.Show("w" A_ScreenWidth/4 " h" A_ScreenHeight/4 " Center")

WinWaitNotActive(MyGui.Hwnd)

;OnMessage(0x0201, WM_LBUTTONDOWN)
;OnMessage(0x404, AHK_NOTIFYICON)

WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
	Global
    OutputDebug("AHK_NOTIFYICON")

	MouseGetPos(&OutputVarX, &OutputVarY, &OutputVarWin, &OutputVarControl)  , StoreHwnd:=2

	IF (OutputVarWin = MyGui2.Hwnd)
	 	Return
	; WinSetStyle("+0x20", "ahk_id " MyGui2.Hwnd)
	ToolTip("hwnd:" OutputVarWin), Sleep(1000), ToolTip()
	KeyWait "LButton"
		Click
	;WinSetStyle("-0x20", "ahk_id " MyGui2.Hwnd)
	ToolTip
	Return
}
