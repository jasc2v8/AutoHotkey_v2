; TITLE  :  MyScript v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
;#NoTrayIcon

#Include NamedPipeBridge.ahk

;#Include <RunAsAdmin>

TrayTip "Admin Server is listening...", "Server Status"

pipe := NamedPipeBridge()

Loop {
    try
    {
        ; Read client request (UTF-16)
        request := pipe.Receive()

        MsgBox request, "SERVER"

        ; simulate some work
        ;Sleep 1000
        SoundBeep

        ; Handle request (your logic here)
        reply := "ACK: " request

        ; Send reply
        pipe.Send(reply)

        if (request = "TERMINATE")
            ExitApp
    }
    catch as err
    {
        ; Optional: log err.Message to file/event log
    }
}


