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
#Include AhkRunSkipUAC_IPC.ahk

; 1. Try to elevate
;RunSkipUAC.RunAsAdmin()

; 2. Define logic
if A_IsAdmin {
    
    Persistent
    
    ; --- ADMIN SERVER SIDE ---
    A_IconTip := "Admin IPC Server"
    
    RunSkipUAC.InitializeServer(AdminReceive)

    AdminReceive(text, senderHwnd) {
        MsgBox("Admin received: " text "`n`nSending reply...")
        RunSkipUAC.Send(senderHwnd, "Hello from the Elevated side!")
    }
} else {
    ; --- USER CLIENT SIDE ---
    ; Wait for the Admin instance to exist
    if WinWait("ahk_class AutoHotkey", , 5) {
        adminHwnd := WinExist() 
        
        ; Listen for the Admin's reply
        OnMessage(0x4A, (wp, lp, *) => MsgBox("User received: " StrGet(NumGet(lp, A_PtrSize*2, "Ptr"))))
        
        ; Send initial message
        RunSkipUAC.Send(adminHwnd, "Hello from the standard User side!")
    }
}