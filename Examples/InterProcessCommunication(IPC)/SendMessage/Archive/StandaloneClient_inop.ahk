; TITLE:    AhkRunSkipUAC v1.0
; SOURCE:   jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
;#NoTrayIcon


DetectHiddenWindows(true)

; Search for the specific title we set in the Server
targetHwnd := WinExist("AHK_IPC_SERVER_NODE")

; if !targetHwnd {
;     MsgBox("Error: Target window not found!`n`nPossible causes:`n1. Server.ahk is not running.`n2. Server didn't set its title yet.`n3. DetectHiddenWindows is missing.")
;     ExitApp()
; } else {
;     MsgBox("Success: Target window found!")
; }

;MsgBox("All AHK Windows found:`n" . WinGetList("ahk_class AutoHotkey").Length)

; --- SETTINGS ---
Global SERVER_NAME := "AHK_IPC_SERVER_NODE"
Global WM_COPYDATA := 0x004A

; 1. Find the Server
targetHwnd := WinExist(SERVER_NAME)

if !targetHwnd {
    MsgBox "Server not found! Ensure Server.ahk is running as Admin."
    ExitApp()
}

; 2. Setup a listener for the Admin's reply
OnMessage(WM_COPYDATA, (wp, lp, *) => (
    reply := StrGet(NumGet(lp, A_PtrSize * 2, "Ptr")),
    MsgBox("Client received: " . reply),
    ExitApp()
))

; 3. Send data to Admin
; We pass OUR A_ScriptHwnd in the wParam so Admin knows where to reply
try {
    result := SendToAdmin(targetHwnd, "REQUEST_DATA_ALPHA")
    if !result
        MsgBox "Server exists but refused the message (Check UAC Filter)."
} catch Error as e {
    MsgBox "Communication Error: " . e.Message
}

; Fail-safe
SetTimer(() => (MsgBox("No response from Admin."), ExitApp()), -3000)

SendToAdmin(hwnd, text) {
    size := (StrLen(text) + 1) * 2
    cds := Buffer(A_PtrSize * 3, 0)
    NumPut("Ptr", 0, "Ptr", size, "Ptr", StrPtr(text), cds)
    
    ; SendMessage returns the 'true' from the Server's function
    return SendMessage(WM_COPYDATA, A_ScriptHwnd, cds, , "ahk_id " hwnd, 1000)
}