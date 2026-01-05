; TITLE  :  Listen v0.0
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

#Include Messenger.ahk

TrayTip "Listening...", "Listen.ahk"

SetTimer(HideTrayTip, -1000) 

HideTrayTip() {
    TrayTip() ; Calling with no arguments clears the current notification
}

; Ensure the script stays running to receive messages
Persistent
DetectHiddenWindows True
SetTitleMatchMode 3 ; exact match

class MyReceiver {
    __New() {
        this.MsgID := 0x4A ; WM_COPYDATA
        
        ; Using a nested function instead of a fat arrow
        OnIncomingMessage(wParam, lParam, msg, hwnd) {
            return this._HandleIncoming(wParam, lParam)
        }
        
        OnMessage(this.MsgID, OnIncomingMessage)
    }

    _HandleIncoming(wParam, lParam) {
        ; 1. lParam is a pointer to the COPYDATASTRUCT
        ; 2. The string pointer (lpData) is at the 3rd offset (2 * A_PtrSize)
        lpData := NumGet(lParam, A_PtrSize * 2, "Ptr")
        
        ; 3. Retrieve the string from that memory address
        ReceivedStr := StrGet(lpData)
        
        ; Now you can use the string!
        MsgBox("Received:`n`n" ReceivedStr)
        return true ; Tell the system we handled it
    }
}


listener:= MyReceiver()

