; ABOUT:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

; Register a new window message with the custom name "NewAHKScript"
MsgNum := DllCall("RegisterWindowMessage", "Str", "NewAHKScript")
OnMessage(MsgNum, NewScriptCreated)
Persistent()

NewScriptCreated(wParam, lParam, msg, hwnd) {
    MsgBox "New script with hWnd " hwnd " created!`n`nwParam: " wParam "`nlParam: " lParam
}
