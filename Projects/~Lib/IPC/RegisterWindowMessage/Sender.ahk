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

;#Include TextConverter.ahk

Persistent

; Define a custom message number using RegisterWindowMessage
MsgNum := DllCall("RegisterWindowMessage", "Str", "AHK_MESSAGE")

; Ensure the receiver script is running
SetTitleMatchMode 2
DetectHiddenWindows true

; Give the receiver script window some time to initialize
Sleep 50

; Get the handle of the receiver script window
;WinGet, receiverHwnd, ID, Receiver.ahk ahk_class AutoHotkey

;receiverHwnd := WinExist("ahk_id Receiver.ahk ahk_class AutoHotkey")
receiverHwnd := WinExist("Receiver.ahk")
; Check if the handle is valid

if (!receiverHwnd) {
    MsgBox "Receiver.ahk is not running!"
    ExitApp
}

; Send the "Hello world" message to the receiver script

; NO - maximum 8 chars to convert into a 64 bit integer
; convert string to integer?
;int := TextConverter.TextToInteger("Hello world")

; Max signed integer:
PostMessage MsgNum, 9223372036854775807, 9223372036854775808,, "Receiver.ahk"

; Exit after sending the message
ExitApp
