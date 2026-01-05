; ABOUT:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

; --- Mailslot Server (AHK v2) ---

sa:=0
serverSlot := DllCall("CreateMailslot"
    , "Str", "\\\\.\\mailslot\\demo"
    , "UInt", 0          ; max message size (0 = default)
    , "UInt", -1         ; no read timeout
    , "Ptr*", &sa ;0           ; security attributes
    , "Ptr")             ; returns handle

if !serverSlot {
    MsgBox "Failed to create mailslot"
    ExitApp
}

MsgBox "Server ready. Waiting for message..."

bufSize := 256
buff  := Buffer(bufSize, 0)
bytesRead := 0

DllCall("ReadFile"
    , "Ptr", serverSlot
    , "Ptr", buff
    , "UInt", bufSize
    , "UInt*", bytesRead
    , "Ptr", 0)

msg := StrGet(buff, bytesRead, "UTF-8")
MsgBox "Server received: " msg

DllCall("CloseHandle", "Ptr", serverSlot)
ExitApp