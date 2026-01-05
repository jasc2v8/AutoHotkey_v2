; TITLE:    IPCBridgeServer v1.0
; SOURCE:   Gemini, Copilot, chageGPT, and jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
;#NoTrayIcon

#Include <RunAsAdmin>

#Include IPCBridge.ahk

global SECRET_KEY := 998877 ; 64-bit numeric password Must match receiver

DetectHiddenWindows true

;A_AllowMainWindow := true

Persistent

TrayTip "Admin Server is starting...", "Server Status"

SetTimer(HideTrayTip, -1000) 

HideTrayTip() {
    TrayTip() ; Calling with no arguments clears the current notification
}
	
; Initialize the server
IPCBridge.Listen("Server", "MySecretAdminServer", SECRET_KEY, OnMessageReceived)

OnMessageReceived(text, clientHwnd) {

    ;MsgBox("OnMessage:`n`n" text, "Server")

    reply:= DoSomeWork(text)

    ; Reply to the client using their HWND (passed via wParam)
    IPCBridge.Send(clientHwnd, "Acknowledged at " . FormatTime(A_Now, "HH:mm:ss") "`n`n" reply)
}

DoSomeWork(text) {
    ;Sleep 5000
    ;MsgBox "Work Completed:`n`n" text, "Server"
    return "Work Completed: " text
}

; RunAsAdmin.RunAsAdmin("MySecretAdminServer
