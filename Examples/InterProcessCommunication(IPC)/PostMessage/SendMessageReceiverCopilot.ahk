; ABOUT:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Requires AutoHotkey v2.0

; g:=Gui()
; g.Title:="SendMessageDemo"
; g.Show("w600 h300")
; g.Hide()
Persistent

; Retrieve the PID directly from the built-in variable
currentPID := DllCall("GetCurrentProcessId", "UInt")

HexResult1 := Format('0x{1:X}', currentPID)

FileAppend "Sender PID: " HexResult1 "`n", "D:\SendMessage.txt"

; Display the result
MsgBox("The Process ID (PID) of the current script is: " . HexResult1, "Script Information")

WM_COPYDATA := 0x4A

OnMessage(WM_COPYDATA, HandleCopyData)

HandleCopyData(wParam, lParam, msg, hwnd) {
    ; COPYDATASTRUCT layout: dwData, cbData, lpData
    cbData := NumGet(lParam, A_PtrSize, "uptr")
    lpData := NumGet(lParam, A_PtrSize*2, "ptr")

    if cbData > 0 {
        text := StrGet(lpData, cbData//2, "UTF-16")
        MsgBox "Received: " text
    }
    return true
}
