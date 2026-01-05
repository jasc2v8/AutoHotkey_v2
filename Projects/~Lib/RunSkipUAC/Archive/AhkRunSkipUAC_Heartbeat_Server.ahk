; TITLE:    AhkRunSkipUAC v1.0
; SOURCE:   jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include <RunAsAdmin>

;#SingleInstance Off 

; --- Configuration ---
;Global SERVER_TITLE := "AHK_Admin_Bridge_" . A_ScriptName
Global SERVER_TITLE := "AHK_Admin_Bridge_Server"
Global WM_COPYDATA   := 0x004A
Global MSGFLT_ALLOW  := 1

; 1. Determine Identity
if A_IsAdmin {
    SetupAdminServer()
} else {
    LaunchOrContactServer()
}

; -----------------------------------------------------------------------------
; ADMIN SERVER LOGIC (Persistent)
; -----------------------------------------------------------------------------
SetupAdminServer() {
    Persistent(true)
    ; Rename the hidden window so the Client can find it
    A_AllowMainWindow := true
    WinSetTitle(SERVER_TITLE, A_ScriptHwnd)
    
    ; Poke hole in UAC for bidirectional communication
    DllCall("user32\ChangeWindowMessageFilterEx", "Ptr", A_ScriptHwnd, "UInt", WM_COPYDATA, "UInt", MSGFLT_ALLOW, "Ptr", 0)
    
    ; Listen for messages
    OnMessage(WM_COPYDATA, AdminOnMessage)
    
    TrayTip("Admin Bridge Active", "Waiting for client commands...")
    MsgBox("Admin Bridge Active.`n`nWaiting for client commands...", "Admin Bridge Active")
}

AdminOnMessage(wParam, lParam, msg, hwnd) {
    
    MsgBox("Message received.", "AdminOnMessage")

    ; Extract data
    lpData := NumGet(lParam, A_PtrSize * 2, "Ptr")
    receivedText := StrGet(lpData)
    
    ; Logic: If client asks "HEARTBEAT", reply "ALIVE"
    if (receivedText = "HEARTBEAT") {
        SendToClient(wParam, "ALIVE")
    } else {
        ; Handle actual commands here
        MsgBox("Admin received command: " . receivedText)
        SendToClient(wParam, "SUCCESS")
    }
    return true
}

; -----------------------------------------------------------------------------
; USER CLIENT LOGIC (Initiator)
; -----------------------------------------------------------------------------
LaunchOrContactServer() {
    targetHwnd := WinExist(SERVER_TITLE)
    
    if !targetHwnd {
        MsgBox("Admin Server not found. Attempting to launch...")
        ; Use your schtasks name here
        try {
            Run('schtasks /run /tn "AdminTask_' . StrReplace(A_ScriptName, " ", "_") . '"')
        } catch {
            Run('*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"')
        }
        ExitApp()
    }

    ; Setup a temporary listener to catch the Admin's reply
    OnMessage(WM_COPYDATA, (wp, lp, *) => (
        MsgBox("Server Reply: " . StrGet(NumGet(lp, A_PtrSize*2, "Ptr"))),
        ExitApp() ; Close client after reply
    ))

    ; Send Heartbeat
    SendToClient(targetHwnd, "HEARTBEAT")
    
    ; Set a timeout so the client doesn't hang if Admin is frozen
    SetTimer(() => (MsgBox("Server timed out."), ExitApp()), -3000)
}

; -----------------------------------------------------------------------------
; SHARED UTILITY
; -----------------------------------------------------------------------------
SendToClient(targetHwnd, text) {
    size := (StrLen(text) + 1) * 2
    cds := Buffer(A_PtrSize * 3, 0)
    NumPut("Ptr", 0, "Ptr", size, "Ptr", StrPtr(text), cds)
    ; wParam passes OUR hwnd so the receiver knows who to reply to
    return SendMessage(WM_COPYDATA, A_ScriptHwnd, cds, , "ahk_id " targetHwnd)
}
