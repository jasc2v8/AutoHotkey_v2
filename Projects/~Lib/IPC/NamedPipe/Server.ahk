; TITLE  :  MyScript v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Off
;#NoTrayIcon

#Include NamedPipe.ahk

;#Include <RunAsAdmin>

TrayTip "Admin Server is listening...", "Server Status"

Persistent

pipe := NamedPipe()

Loop
{
    try
    {
        ; Create a fresh pipe instance and wait for client
        pipe.Create()

        ; Read client request (UTF-16)
        request := pipe.Receive()

        ; simulate some work
        ;Sleep 1000
        SoundBeep

        ; Handle request (your logic here)
        reply := "ACK: " request

        ; Send reply
        pipe.Send(reply)

        if (request = "TERMINATE")
            break
    }
    catch as err
    {
        ; Optional: log err.Message to file/event log
    }
    finally
    {
        ; REQUIRED: tear down instance so clients can reconnect
        pipe.Close()
    }
}
Persistent false
pipe.Close()
ExitApp()


