; TITLE:    AhkRunSkipUAC v1.0
; SOURCE:   jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
;#NoTrayIcon

;#Include <RunAsAdmin>

#Include IPCServerClass.ahk

MyHandler(msg) { ; , fromHwnd) {

    TrayTip "MyHandler recevied: " msg

    return "ACK|" msg
}

server := IPCServer(MyHandler)

;MsgBox("Server running`nHWND: " server.hwnd)
TrayTip "Server Status", "Admin Server is listening..."
