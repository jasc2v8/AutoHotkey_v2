; TITLE  :  ReceiveInteger v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
;#NoTrayIcon

TrayTip "Listening...", "ReceiveInteger.ahk"

SetTimer(HideTrayTip, -1000) 

HideTrayTip() {
    TrayTip() ; Calling with no arguments clears the current notification
}

; Ensure the script stays running to receive messages
Persistent

MsgID := 0x5555

OnMessage(MsgID, ReceiveInteger)

ReceiveInteger(wParam, lParam, msg, hwnd) {

    ;msgbox "received!"

    ; StringAddress := NumGet(lParam, 2 * A_PtrSize, "Ptr")
    ; CopyOfData := StrGet(StringAddress)
    MsgBox "Received: " lParam ;; CopyOfData
    Persistent false
}