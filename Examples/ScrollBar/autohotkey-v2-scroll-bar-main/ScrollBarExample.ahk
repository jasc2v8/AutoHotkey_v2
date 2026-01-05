; ABOUT: MySCript v1.0
; From:
; License:
/*
    TODO: 
*/
#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include <ScrollBar>

Fonts := ["Cascadia Code","Cascadia Mono","Consolas","Courier","Courier New","Lucida Console","Lucida Sans"]
; Fonts := ["Cascadia Code","Cascadia Mono","Consolas","Courier","Courier New","Lucida Console","Lucida Sans",
;           "Cascadia Code","Cascadia Mono","Consolas","Courier","Courier New","Lucida Console","Lucida Sans",
;           "Cascadia Code","Cascadia Mono","Consolas","Courier","Courier New","Lucida Console","Lucida Sans"]

M := Gui('+Resize')

; M.SetFont("S11", "Consolas")
; Loop 15 {
;     M.Add("Text", "x5 y" 10 + ((A_Index - 1) * 100) " w600 h80", A_Index ": The quick brown fox jumps over the lazy dog.")
;     M.Add("Text", "yp w80 h80", A_Index ": TEST")
; }


Loop Fonts.Length {
    fSize := 18 ; A_Index + 5
    M.SetFont("S" fSize, Fonts[A_Index])
    M.Add("Text", "x5 y" 5 + ((A_Index - 1) * 60) " w1200 h60 BackgroundWhite", "s" fSize ": Font Name: " Fonts[A_Index])
}

SB := ScrollBar(M, 120, 200)
;M.Show('w500 h200')
M.Show()
M.OnEvent "Close", (*) => ExitApp()
M.OnEvent "Escape", (*) => ExitApp()

#HotIf WinActive(M.Hwnd)
    WheelUp::
    WheelDown::
    +WheelUp::
    +WheelDown:: {
        SB.ScrollMsg(InStr(A_ThisHotkey,"Down") ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, M.Hwnd)
        return
    }
#HotIf