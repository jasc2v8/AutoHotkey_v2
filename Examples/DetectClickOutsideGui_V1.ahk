#Requires AutoHotkey v2.0+
#SingleInstance,Force

MyGui := Gui("+AlwaysOnTop")
MyGui.Show("w200 h200")
MyGui2 := Gui("-Caption +LastFound +ToolWindow")
WinSetTransparent 1
MyGui2.Show("w" A_ScreenWidth " h" A_ScreenHeight " Center"
;OnMessage(0x201, Func("WM_LBUTTONDOWN"))
OnMessage 0x201, WM_LBUTTONDOWN

WM_LBUTTONDOWN(*) {
	Global
	MouseGetPos(&OutputVarX, &OutputVarY, &OutputVarWin, &OutputVarControl, StoreHwnd:=2)
	IF (OutputVarControl = MyGui.Hwnd)
		Return
	WinSet("+0x20", "ahk_id " MyGui2.Hwnd)
	ToolTip("outside")
	KeyWait("{LButton}")
		Click
	WinSet("-0x20", "ahk_id " MyGui2.Hwnd)
	ToolTip
}