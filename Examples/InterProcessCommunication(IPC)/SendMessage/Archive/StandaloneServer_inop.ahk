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

DetectHiddenWindows(true)

Persistent(true)

; --- SETTINGS ---
Global SERVER_NAME := "AHK_IPC_SERVER_NODE"
Global WM_COPYDATA := 0x004A
Global MSGFLT_ALLOW := 1

; 1. Set the Title so Client can find us
WinSetTitle(SERVER_NAME, A_ScriptHwnd)

; 2. (Optional) Verify for yourself that the window exists
;MsgBox("Server is running. HWND: " . A_ScriptHwnd)

; 2. THE FIX: Explicitly allow WM_COPYDATA through the UAC Shield
; If this DllCall fails or is skipped, SendMessage from Client will return 0
DllCall("user32\ChangeWindowMessageFilterEx", 
        "Ptr", A_ScriptHwnd, 
        "UInt", WM_COPYDATA, 
        "UInt", MSGFLT_ALLOW, 
        "Ptr", 0)

; 3. Setup Listener
OnMessage(WM_COPYDATA, OnMessageReceived)

OnMessageReceived(wParam, lParam, msg, hwnd) {
    ; Extract string
    pData := NumGet(lParam, A_PtrSize * 2, "Ptr")
    receivedText := StrGet(pData)
    
    ; Identify the sender's HWND (passed via wParam)
    clientHwnd := wParam
    
    ; Respond immediately (Use TrayTip instead of MsgBox to avoid blocking)
    TrayTip "Admin Received", receivedText
    
    ; Send a reply back to the Client
    Reply(clientHwnd, "Admin says: Order Processed at " . A_Hour . ":" . A_Min)
    
    return true ; Signals success to the Client's SendMessage
}

Reply(hwnd, text) {
    size := (StrLen(text) + 1) * 2
    cds := Buffer(A_PtrSize * 3, 0)
    NumPut("Ptr", 0, "Ptr", size, "Ptr", StrPtr(text), cds)
    ; Send reply back to user-level process
    try SendMessage(WM_COPYDATA, A_ScriptHwnd, cds, , "ahk_id " hwnd, 500)
}

TrayTip "Server Status", "Admin Server is listening..."