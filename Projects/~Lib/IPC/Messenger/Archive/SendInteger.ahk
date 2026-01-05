; TITLE  :  SendInteger v0.0
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
#NoTrayIcon

; 1. Essential: Tell the script to look for hidden windows
DetectHiddenWindows True 

; 2. Define the title of your listener script
; "2" means a match can occur anywhere in the title
SetTitleMatchMode 2 

; This looks for the script filename specifically 
TargetTitle := "ReceiveInteger.ahk ahk_class AutoHotkey"

; 3. Get the Unique ID (HWND)
TargetHWND := WinExist(TargetTitle)

if !TargetHWND
    MsgBox "Listener not found. Is it running?"

IntegerToSend := 6969

Send(IntegerToSend, TargetHWND)

Send(IntegerToSend, TargetHWND) {
    MsgID := 0x5555
    try {
        MsgBox "Integer sent: " IntegerToSend
        SendMessage(MsgID, 0, IntegerToSend,, TargetHWND)
    } catch Error as e {
        MsgBox "Failed to send message.`n`nError: " e.Message
    }
}

MsgBox
ExitApp

SendStringViaHWND("Hello using HWND!", TargetHWND)

; --- The Function ---
SendStringViaHWND(StringToSend, WindowHandle) {
    ; 0x5555 is your custom message ID
    MsgID := 0x5555
    
    ; StrPtr gets the memory address of the string
    ; We pass the WindowHandle directly as the 5th parameter (WinTitle)
    try {
        SendMessage(MsgID, 0, 6970,, WindowHandle)
        MsgBox "Message sent to HWND: " WindowHandle
    } catch Error as e {
        MsgBox "Failed to send message.`n`nError: " e.Message
    }
}