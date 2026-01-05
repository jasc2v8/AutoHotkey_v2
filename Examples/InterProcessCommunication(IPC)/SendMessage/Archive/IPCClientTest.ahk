; TITLE:    AhkRunSkipUAC v1.0
; SOURCE:   jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
;#NoTrayIcon

serverHwnd := WinExist("AHK_IPC_SERVER")

if !serverHwnd
    throw Error("IPC server window not found")


MsgBox("Reply: " reply)
