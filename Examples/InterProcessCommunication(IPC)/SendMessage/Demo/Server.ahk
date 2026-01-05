; TITLE:    AhkRunSkipUAC v1.0
; SOURCE:   jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
;#NoTrayIcon

#Include <RunAsAdmin>

#Include Helper.ahk

;MsgBox A_ScriptHwnd, "Server"

DetectHiddenWindows(true) ; Crucial: The main script window is hidden by default
Persistent(true)

; g:=Gui()
; ;g.Show("Hide")
; g.Show("w400 h200")

; 1. Setup Identity
Global SERVER_IDENTIFIER := "MY_UNIQUE_IPC_SERVER"
A_AllowMainWindow := true
WinSetTitle(SERVER_IDENTIFIER, A_ScriptHwnd)

; 2. Enable UIPI Bypass (Allows Non-Admin to talk to Admin)
; 0x004A = WM_COPYDATA, 1 = MSGFLT_ALLOW
;DllCall("user32\ChangeWindowMessageFilterEx", "Ptr", A_ScriptHwnd, "UInt", 0x004A, "UInt", 1, "Ptr", 0)
; 3. Listen for Messages
;OnMessage(0x004A, ReceiveFromClient)

help:= Helper(SERVER_IDENTIFIER)
help.Listen()

;IPCHelper.Listen(SERVER_IDENTIFIER, ReceiveFromClient)

ReceiveFromClient(wParam, lParam, msg, hwnd) {
    ; Extract the string
    text := StrGet(NumGet(lParam, A_PtrSize * 2, "Ptr"))
    senderHwnd := wParam

    if (text == "HEARTBEAT") {
        ReplyToClient(senderHwnd, "ALIVE")
        return true
    }

    if (text == "TERMINATE") {
        ReplyToClient(senderHwnd, "TERMINATED")
        ExitApp()
    }

    ; Handle actual logic
    MsgBox("From Client: " text, "Server")
    ReplyToClient(senderHwnd, "RECEIVED_OK")
    return true
}

ReplyToClient(clientHwnd, responseText) {
    size := (StrLen(responseText) + 1) * 2
    cds := Buffer(A_PtrSize * 3, 0)
    NumPut("Ptr", 0, "Ptr", size, "Ptr", StrPtr(responseText), cds)
    SendMessage(0x004A, A_ScriptHwnd, cds, , "ahk_id " clientHwnd)
}

TrayTip "Server Status", "Admin Server is listening..."