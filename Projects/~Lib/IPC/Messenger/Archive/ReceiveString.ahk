; TITLE  :  Listen v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

/*
    TODO:

    WM_USER range:
    Range       Start   End     Purpose
    WM_USER	    0x0400	0x7FFF	Private messages for window classes
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
;#NoTrayIcon

TrayTip "Listening...", "ReceiveString.ahk"

SetTimer(HideTrayTip, -1000) 

HideTrayTip() {
    TrayTip() ; Calling with no arguments clears the current notification
}

; Ensure the script stays running to receive messages
Persistent

; Register for WM_COPYDATA (0x4A) instead of CUSTOM (0x5555)
MsgID := 0x4A

#Requires AutoHotkey v2.0

OnMessage(0x4A, ReceiveString)

ReceiveString(wParam, lParam, msg, hwnd) {
    ; lParam points to the COPYDATASTRUCT
    ; The string address is at the 3rd position (offset: 2 * A_PtrSize)
    StringAddress := NumGet(lParam, A_PtrSize * 2, "Ptr")
    
    if (StringAddress != 0) {
        ReceivedData := StrGet(StringAddress)
        MsgBox "Received message: " ReceivedData

        if (ReceivedData = "IPC_EXIT") {
            Persistent false
            ; MsgBox "Exiting..."
            ; ExitApp()
        }
        return true ; Tell Windows we handled the message
    }

}