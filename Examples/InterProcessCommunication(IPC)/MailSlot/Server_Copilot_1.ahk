; ABOUT:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Requires AutoHotkey v2.0

; --- Mailslot Constants ---
global MAILSLOT_NAME := "\\\\.\\mailslot\\AHKv2MailSlot"
global MAX_MESSAGE_SIZE := 1024  ; Max message size in bytes
global MAILSLOT_WAIT_FOREVER := -1 ; Timeout value for reading
global INVALID_HANDLE_VALUE := -1

; --- Global Variables ---
global hSlot := 0  ; Handle for the mailslot

; --- Mailslot Server ---
serverSlot := DllCall("CreateMailslot"
    , "Str", "\\\\.\\mailslot\\demo"
    , "UInt", 0          ; no max message size (use default)
    , "UInt", -1         ; no read timeout
    , "Ptr", 0           ; security attributes
    , "Ptr")             ; return handle

if (serverSlot = -1) {
    MsgBox "Failed to create mailslot"
    ExitApp
}

MsgBox "Mailslot server ready. Waiting for message..."

bufSize := 256
buf:= Buffer(bufSize, 0)
bytesRead := 0

DllCall("ReadFile"
    , "Ptr", serverSlot
    , "Ptr", &buf
    , "UInt", bufSize
    , "UInt*", bytesRead
    , "Ptr", 0)

MsgBox "Server received: " StrGet(&buff, bytesRead, "UTF-8")

DllCall("CloseHandle", "Ptr", serverSlot)
ExitApp