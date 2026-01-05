; TITLE:    IPCBridgeClient v1.0
; SOURCE:   Gemini, Copilot, chageGPT, and jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
;#NoTrayIcon

#Include IPCBridge.ahk

global SERVER_NAME := "MyHiddenAdminServer"

global SECRET_KEY := 998877 ; 64-bit numeric password Must match receiver

DetectHiddenWindows true 

; Initialize the Client
server:= IPCBridge("Client", SERVER_NAME, SECRET_KEY, OnMessageReceived)

; Both of these work
serverHwnd:= server.GetHwnd()
;serverHwnd:= WinExist(SERVER_NAME)

if !serverHwnd {
    MsgBox "Server failed to start."
    ExitApp()
}

OnMessageReceived(text, serverHwnd) {
    MsgBox(text, "Client")
}

r:= server.Send(serverHwnd, "Do some work!")

if (r>0)
    MsgBox "Result: " r , "Client send #1"

server.Send(serverHwnd, "IPC_EXIT")

if (r>0)
    MsgBox "Result: " r , "Client send #2"
