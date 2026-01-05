; ABOUT:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

; --- Mailslot Client (AHK v2) ---
clientSlot := DllCall("CreateFile"
    , "Str", "\\\\.\\mailslot\\demo"
    , "UInt", 0x40000000 ; GENERIC_WRITE
    , "UInt", 0
    , "Ptr", 0
    , "UInt", 3          ; OPEN_EXISTING
    , "UInt", 0
    , "Ptr", 0
    , "Ptr")

if !clientSlot {
    MsgBox "Failed to open mailslot"
    ExitApp
}

msg := "Hello from client!"
bytes := StrPut(msg, "UTF-8") - 1 ; exclude null terminator
bytesWritten := 0
buf   := Buffer(bytes)
StrPut(msg, buf, "UTF-8")

DllCall("WriteFile"
    , "Ptr", clientSlot
    , "Ptr", buf
    , "UInt", bytes
    , "UInt*", bytesWritten
    , "Ptr", 0)

MsgBox "Client sent message: " msg

DllCall("CloseHandle", "Ptr", clientSlot)
ExitApp