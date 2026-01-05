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

serverHwnd:= IPCBridge.Listen("Client", SERVER_NAME, SECRET_KEY, OnMessageReceived)

if !serverHwnd {
    MsgBox "Server failed to start."
    ExitApp()
}

OnMessageReceived(text, serverHwnd) {
    MsgBox(text, "Client")
}

r:= IPCBridge.Send(serverHwnd, "Do some work!")

if (r>0)
    MsgBox "Result: " r , "Client send #1"

IPCBridge.Send(serverHwnd, "IPC_EXIT")

if (r>0)
    MsgBox "Result: " r , "Client send #2"
