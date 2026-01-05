;SOURCE V1: https://www.autohotkey.com/boards/viewtopic.php?t=59059

#Requires AutoHotkey v2.0+
#SingleInstance Force

Escape::OnExit()

; This script demonstrates the difference between a window's total size and its client area size.

MyGui := Gui()

; Margin results are the same with/winout border
; The Borders are drawn inside the control, reducing the viewing area by 2 pixels
Opt := "Border"

;MAX AFTER SYLES REMOVED MyGui.AddText("w300 h320 Border")
txt1 := MyGui.AddText("w280 h260 " Opt, "Txt1")

MyGui.AddButton("xm w75 Default", "OK").OnEvent("Click", _Button_Click)
;MyGui.AddButton("yp w75", "No")  ; .OnEvent("Click", _Button_Click)

txt2 := MyGui.AddText("x40 ys w80 h266 " Opt, "Txt2:`n`nFrom:Top of Text`n`nTo: Top of Buttons")
txt3 := MyGui.AddText("x110 ys w80 h289 " Opt, "Txt3:`n`nFrom:Top of Text`n`nTo: Bottom of Buttons")
txt4 := MyGui.AddText("x190 ys w80 h294 " Opt, "Txt4:`n`nFrom:Top of Text`n`nTo: Bottom of Gui")

txt5 := MyGui.AddText("x0 y130 w80 h80 " Opt, "Txt5:`n`nGui Left Margin")
txt6 := MyGui.AddText("x220 y130 w80 h80 " Opt, "Txt6:`n`nGui Right Margin")

txt7 := MyGui.AddText("x236 y0 w80 h80 " Opt, "Txt7:`n`nGui Right Margin")

MyGui.Show("w300 h300")
hWnd := MyGui.Hwnd

WinWaitClose(hWnd)
ExitApp

_Button_Click(Ctrl, Info) {

    WinGetPos(&vWinX, &vWinY, &vWinW, &vWinH, "ahk_id " MyGui.Hwnd)
	vWinPosGui := Format("x{} y{} w{} h{}", vWinX, vWinY, vWinW, vWinH)
    guiX:=vWinx, guiY:=vWinY, guiW:=vWinW, guiH:=vWinH

    WinGetClientPos(&vCWinX, &vCWinY, &vCWinW, &vCWinH, "ahk_id " hWnd)
	vCWinPos := Format("x{} y{} w{} h{}", vCWinX, vCWinY, vCWinW, vCWinH)

    ;MsgBox "Gui: " vWinPosGui

    ControlGetPos(&vWinX, &vWinY, &vWinW, &vWinH, txt1)
	vClientPosText1 := Format("x{} y{} w{} h{}", vWinX, vWinY, vWinW, vWinH)
    txt1X:=vWinx, txt1Y:=vWinY, txt1W:=vWinW, txt1H:=vWinH

    ControlGetPos(&vWinX, &vWinY, &vWinW, &vWinH, txt2)
	vClientPosText2 := Format("x{} y{} w{} h{}", vWinX, vWinY, vWinW, vWinH)
    txt2X:=vWinx, txt2Y:=vWinY, txt2W:=vWinW, txt2H:=vWinH

    ControlGetPos(&vWinX, &vWinY, &vWinW, &vWinH, txt3)
	vClientPosText3 := Format("x{} y{} w{} h{}", vWinX, vWinY, vWinW, vWinH)
    txt3X:=vWinx, txt3Y:=vWinY, txt3W:=vWinW, txt3H:=vWinH

    ControlGetPos(&vWinX, &vWinY, &vWinW, &vWinH, txt4)
	vClientPosText4 := Format("x{} y{} w{} h{}", vWinX, vWinY, vWinW, vWinH)
    txt4X:=vWinx, txt4Y:=vWinY, txt4W:=vWinW, txt4H:=vWinH

    ControlGetPos(&vWinX, &vWinY, &vWinW, &vWinH, txt5)
	vClientPosText5 := Format("x{} y{} w{} h{}", vWinX, vWinY, vWinW, vWinH)
    txt5X:=vWinx, txt5Y:=vWinY, txt5W:=vWinW, txt5H:=vWinH

    ControlGetPos(&vWinX, &vWinY, &vWinW, &vWinH, txt6)
	vClientPosText6 := Format("x{} y{} w{} h{}", vWinX, vWinY, vWinW, vWinH)
    txt6X:=vWinx, txt6Y:=vWinY, txt6W:=vWinW, txt6H:=vWinH

    MarginBottomTextToButtomGui := txt4H - txt1H
    MarginBottomTextToTopButtom := txt2H - txt1H
    MarginBottomButtonToButtomGui := txt4H - txt3H
    
    MarginGuiLeft := txt1X
    MarginGuiRight := guiW - txt1W
    
    btnH := txt3H - txt2H

    ;MarginGuiLeft := 
    MsgBox "Gui     : " vWinPosGui  "`n" .
           "Client : " vCWinPos  "`n`n" .
           "Text1: " vClientPosText1 "`nText2: " vClientPosText2 "`nText3: " vClientPosText3 "`nText4: " vClientPosText4 "`n`n" .

           "MarginBottomTextToButtomGui: " MarginBottomTextToButtomGui . "`n" .
           "MarginBottomTextToTopButton: " MarginBottomTextToTopButtom . "`n" .
           "MarginBottomButtonToButtomGui: "  MarginBottomButtonToButtomGui "`n`n" .

           "MarginGuiLeft: "  MarginGuiLeft  "`n" .
           "MarginGuiRight: "  MarginGuiRight  "`n`n" .
           "Button Height: " btnH

    ; Now, remove the styles
    WinSetStyle(-0x40000, "ahk_id " MyGui.hWnd) ; WS_THICKFRAME
    DllCall("user32\SetMenu", "Ptr", MyGui.hWnd, "Ptr", 0) ;hide menu bar
    WinSetStyle(-0xC00000, "ahk_id " MyGui.hWnd) ; WS_CAPTION
    ; Force the window to redraw its frame and content after style changes
    DllCall("user32\SetWindowPos", "Ptr", MyGui.hWnd, "Ptr", 0, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x27) ; SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_FRAMECHANGED

    MsgBox("compare")

}
; hWnd := WinExist("ahk_class Notepad")

; if !hWnd {
;     Run ("notepad.exe")
;     hWnd := WinWait("ahk_class Notepad",, 5)
;     if !hWnd
;         ExitApp("Failed to find or start Notepad.")
; }


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