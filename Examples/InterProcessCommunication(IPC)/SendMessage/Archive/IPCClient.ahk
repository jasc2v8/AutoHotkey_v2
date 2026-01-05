; TITLE:    AhkRunSkipUAC v1.0
; SOURCE:   jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
;#NoTrayIcon

#Include IPCClientClass.ahk

;serverHwnd := 0x123456  ; replace with real hwnd

client := IPCClient()

reply := ""

client.Send("PING|Hello", &reply)

MsgBox("Reply: " reply)
