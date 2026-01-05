;SOURCE: https://www.autohotkey.com/boards/viewtopic.php?t=59059

q:: ;test compare window/client sizes

WinGet, hWnd, ID, Untitled - Notepad ahk_class Notepad
if !hWnd
	return

Loop, 2
{
	WinGetPos, vWinX, vWinY, vWinW, vWinH, % "ahk_id " hWnd
	vWinPos := Format("x{} y{} w{} h{}", vWinX, vWinY, vWinW, vWinH)
	WinGetClientPos(vCWinX, vCWinY, vCWinW, vCWinH, "ahk_id " hWnd)
	vCWinPos := Format("x{} y{} w{} h{}", vCWinX, vCWinY, vCWinW, vCWinH)
	MsgBox, % (vCWinX-vWinX) " " (vCWinY-vWinY) ;e.g. 8 50

	if (A_Index = 1)
	{
		WinSet, Style, -0x40000, % "ahk_id " hWnd ;WS_THICKFRAME := 0x40000
		hMenu := DllCall("user32\GetMenu", Ptr,hWnd, Ptr)
		DllCall("user32\SetMenu", Ptr,hWnd, Ptr,0) ;hide menu bar
		WinSet, Style, -0xC00000, % "ahk_id " hWnd ;WS_CAPTION := 0xC00000 ;hide title bar
	}
	else
	{
		WinSet, Style, +0x40000, % "ahk_id " hWnd ;WS_THICKFRAME := 0x40000
		DllCall("user32\SetMenu", Ptr,hWnd, Ptr,hMenu) ;show menu bar
		WinSet, Style, +0xC00000, % "ahk_id " hWnd ;WS_CAPTION := 0xC00000 ;show title bar
	}
}

SysGet, SM_CXSIZEFRAME, 32
SysGet, SM_CYSIZEFRAME, 33
SysGet, SM_CYMENU, 15
SysGet, SM_CYCAPTION, 4

MsgBox, % Format("{} {}={}+{}+{}", SM_CYSIZEFRAME, SM_CYSIZEFRAME + SM_CYMENU + SM_CYCAPTION, SM_CXSIZEFRAME, SM_CYMENU, SM_CYCAPTION) ;e.g. 8 50=8+20+22

vHasMenu := 1
vWinStyle := 0x14CF0000 ;same as Notepad (Windows 7)
vWinExStyle := 0x00000110 ;same as Notepad (Windows 7)
VarSetCapacity(RECT, 16, 0)
vPosW1 := 300
vPosH1 := 300
NumPut(vPosW1, &RECT, 8, "Int")
NumPut(vPosH1, &RECT, 12, "Int")
DllCall("user32\AdjustWindowRectEx", Ptr,&RECT, UInt,vWinStyle, Int,vHasMenu, UInt,vWinExStyle)
vPosX := NumGet(&RECT, 0, "Int")
vPosY := NumGet(&RECT, 4, "Int")
MsgBox, % (-vPosX) " " (-vPosY) ;e.g. 8 50
return

;/*
;commands as functions (AHK v2 functions for AHK v1) - AutoHotkey Community
;https://autohotkey.com/boards/viewtopic.php?f=37&t=29689

WinGetClientPos(ByRef X:="", ByRef Y:="", ByRef Width:="", ByRef Height:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
	local hWnd, RECT
	hWnd := WinExist(WinTitle, WinText, ExcludeTitle, ExcludeText)
	VarSetCapacity(RECT, 16, 0)
	DllCall("user32\GetClientRect", Ptr,hWnd, Ptr,&RECT)
	DllCall("user32\ClientToScreen", Ptr,hWnd, Ptr,&RECT)
	X := NumGet(&RECT, 0, "Int"), Y := NumGet(&RECT, 4, "Int")
	Width := NumGet(&RECT, 8, "Int"), Height := NumGet(&RECT, 12, "Int")
}
;*/
