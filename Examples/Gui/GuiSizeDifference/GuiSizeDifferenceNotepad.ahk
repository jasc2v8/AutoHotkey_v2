;SOURCE V1: https://www.autohotkey.com/boards/viewtopic.php?t=59059

#Requires AutoHotkey v2.0+
#SingleInstance Force

Escape::OnExit()

; This script demonstrates the difference between a window's total size and its client area size.

hWnd := WinExist("ahk_class Notepad")

if !hWnd {
    Run ("notepad.exe")
    hWnd := WinWait("ahk_class Notepad",, 5)
    if !hWnd
        ExitApp("Failed to find or start Notepad.")
}

Loop 2
{
    WinGetPos(&vWinX, &vWinY, &vWinW, &vWinH, "ahk_id " hWnd)
	vWinPos := Format("x{} y{} w{} h{}", vWinX, vWinY, vWinW, vWinH)

	WinGetClientPos(&vCWinX, &vCWinY, &vCWinW, &vCWinH, "ahk_id " hWnd)
	vCWinPos := Format("x{} y{} w{} h{}", vCWinX, vCWinY, vCWinW, vCWinH)
	MsgBox "Window/Client Size Comparison`n`n"
        . "Window Position: " vWinPos "`n"
        . "Client Position: " vCWinPos "`n`n"
        . "X difference (border width): " (vCWinX - vWinX) "`n"
        . "Y difference (title bar + menu + border): " (vCWinY - vWinY)

    ; First, get the menu handle before we modify the window
    hMenu := DllCall("user32\GetMenu", "Ptr", hWnd, "Ptr")
    
	if (A_Index = 1)
	{
        ; Now, remove the styles
        WinSetStyle(-0x40000, "ahk_id " hWnd) ; WS_THICKFRAME
		DllCall("user32\SetMenu", "Ptr", hWnd, "Ptr", 0) ;hide menu bar
        WinSetStyle(-0xC00000, "ahk_id " hWnd) ; WS_CAPTION
	} else {
        WinClose("ahk_id " hWnd)
    }
    ; Force the window to redraw its frame and content after style changes
    DllCall("user32\SetWindowPos", "Ptr", hWnd, "Ptr", 0, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x27) ; SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_FRAMECHANGED
}

; --- The following section calculates required window size from a desired client size ---

; Get system metrics for window borders and title bar. Using names is more readable than magic numbers.
SM_CXSIZEFRAME := SysGet(32)  ; Width of sizing border
SM_CYSIZEFRAME := SysGet(33)  ; Height of sizing border
SM_CYMENU      := SysGet(15)  ; Height of menu bar
SM_CYCAPTION   := SysGet(4)   ; Height of title bar

TotalBorderHeight := (SM_CYSIZEFRAME * 2) + SM_CYCAPTION + SM_CYMENU
TotalBorderWidth  := (SM_CXSIZEFRAME * 2)

MsgBox "System Metrics Calculation:`n`nTotal Border Width: " TotalBorderWidth "`nTotal Border Height: " TotalBorderHeight

;MsgBox "System Metrics Calculation:`n`nTotal Border Width: " TotalBorderWidth "`nTotal Border Height: " TotalBorderHeight

vHasMenu := 1
vWinStyle := 0x14CF0000 ;same as Notepad (Windows 7)
vWinExStyle := 0x00000110 ;same as Notepad (Windows 7)
RECT := Buffer(16, 0)
vPosW1 := 300
vPosH1 := 300
NumPut("Int", vPosW1, RECT, 8)
NumPut("Int", vPosH1, RECT, 12)
DllCall("user32\AdjustWindowRectEx", "Ptr", RECT, "UInt", vWinStyle, "Int", vHasMenu, "UInt", vWinExStyle)
vPosX := NumGet(RECT, 0, "Int")
vPosY := NumGet(RECT, 4, "Int")
MsgBox "AdjustWindowRectEx Result (for a 300x300 client area):`n`n"
    . "To get a 300x300 client area, the total window size needs to be larger.`n"
    . "Calculated X border size: " vPosX "`n"
    . "Calculated Y border size: " vPosY
OnExit()

OnExit() {
    if WinExist("ahk_class Notepad")
        WinClose("ahk_id " hWnd)
    ExitApp
}