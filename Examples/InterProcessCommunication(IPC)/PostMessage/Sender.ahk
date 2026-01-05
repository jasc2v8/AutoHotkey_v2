; ABOUT:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

; The receiver script should have created a message with name "NewAHKScript", so get its number
MsgNum := DllCall("RegisterWindowMessage", "Str", "NewAHKScript")
PostMessage(MsgNum, 123, -456,, 0xFFFF) ; HWND_BROADCAST := 0xFFFF