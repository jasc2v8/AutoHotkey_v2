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
#NoTrayIcon

; 1. Essential: Tell the script to look for hidden windows
DetectHiddenWindows True 

; 2. Define the title of your listener script
; "2" means a match can occur anywhere in the title
SetTitleMatchMode 2 

; This looks for the script filename specifically 
TargetTitle := "ReceiveString.ahk ahk_class AutoHotkey"

; 3. Get the Unique ID (HWND)
TargetHWND := WinExist(TargetTitle)

if !TargetHWND
    MsgBox "Listener not found. Is it running?"

StringToSend := "Hello from Sender!"

SendString(StringToSend, TargetHWND)

SendString("IPC_EXIT", TargetHWND)

SendString(StringToSend, hwnd) {
    ; Create a Buffer for the COPYDATASTRUCT
    ; It needs 3 pointers: dwData (0), cbData (size), lpData (pointer)
    cds := Buffer(A_PtrSize * 3, 0)
    
    ; Calculate size in bytes (UTF-16)
    size := (StrLen(StringToSend) + 1) * 2
    
    ; Fill the structure
    NumPut("UPtr", 0, cds, 0)               ; dwData: arbitrary value
    NumPut("UInt", size, cds, A_PtrSize)    ; cbData: size of string
    NumPut("UPtr", StrPtr(StringToSend), cds, A_PtrSize * 2) ; lpData: address
    
    ; 0x4A is WM_COPYDATA
    SendMessage(WM_COPYDATA:=0x4A, 0, cds.Ptr,, "ahk_id " hwnd)
}