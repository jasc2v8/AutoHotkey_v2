; TITLE:    Messenger Server v1.0
; SOURCE:   Gemini, Copilot, chageGPT, and jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
;#NoTrayIcon

; Uncomment to run as admin
;#Include <RunAsAdmin>

#Include Messenger_works_1.ahk

global SERVER_NAME := "MyHiddenAdminServer"

global SECRET_KEY := 998877 ; 64-bit numeric password Must match receiver

DetectHiddenWindows true

Persistent

TrayTip "Admin Server is starting...", "Server Status"

SetTimer(HideTrayTip, -1500) 

HideTrayTip() {
    TrayTip() ; Calling with no arguments clears the current notification
}
	
; Initialize the server
server:= Messenger(SERVER_NAME, SECRET_KEY, OnMessageReceived)

OnMessageReceived(text, clientHwnd) {

    reply:= DoSomeWork(text)

    ; Reply to the client using their HWND (passed via wParam)
    server.Send(clientHwnd, "Server ACK at " . FormatTime(A_Now, "HH:mm:ss") "`n`n" reply)
}

DoSomeWork(text) {
    ;Sleep 5000
    ;MsgBox "Work Completed:`n`n" text, "Server"
    return "Work Completed: " text
}
