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

;Persistent
DetectHiddenWindows True
SetTitleMatchMode 2 ; contains (default)

TargetScriptTitle := "Listen.ahk" ; Change this to your listener's script name

TargetHWND := WinExist(TargetScriptTitle)
;ok TargetHWND := WinExist("Listen.ahk ahk_class AutoHotkey")

;MessageToSend := "Hello from Sender!"
StringToSend := "Hello from Sender!"

SendString(TargetHWND, StringToSend)

ExitApp()

SendString(TargetHWND, StringToSend, Timeout:=0) {
    ; Define the WM_COPYDATA message ID
    static WM_COPYDATA := 0x4A
    
    ; 1. Create a Buffer for the COPYDATASTRUCT
    ; Size: 3 fields * 8 bytes (on 64-bit) = 24 bytes
    cds := Buffer(A_PtrSize * 3, 0)
    
    ; 2. Calculate string size in bytes (v2 uses UTF-16, so 2 bytes per char)
    cbData := (StrLen(StringToSend) + 1) * 2
    
    ; 3. Fill the structure
    NumPut("Ptr", 0,      cds, 0)               ; dwData: Custom value (optional)
    NumPut("UInt", cbData, cds, A_PtrSize)      ; cbData: Size of string in bytes
    NumPut("Ptr", StrPtr(StringToSend), cds, A_PtrSize * 2) ; lpData: Pointer to string
    
    ; 4. Send the message
    ; The lParam (last param) must be the pointer to our structure
    return SendMessage(WM_COPYDATA, A_ScriptHwnd, cds.Ptr,, "ahk_id " TargetHWND, , , , Timeout)
}

