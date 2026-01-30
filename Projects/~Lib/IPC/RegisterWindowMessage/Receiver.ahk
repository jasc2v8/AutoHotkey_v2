;;TITLE  :  MyScript v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

;;TODO: Fix something

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

Persistent

; Define a custom message number using RegisterWindowMessage
MsgNum := DllCall("RegisterWindowMessage", "Str", "AHK_MESSAGE")

; Set up a handler for the custom message
OnMessage(MsgNum, HandleMessage)

HandleMessage(wParam, lParam, msg, hwnd)
{

    MsgBox "Received message:`n`nsParam: " wParam "`n`nlParam: " lParam
}

; Keep the script running
Return