; TITLE  :  MyScript v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Off
#NoTrayIcon

#Include NamedPipe.ahk

#Include <RunAsAdmin>

Persistent

pipe := NamedPipe()

Loop
{
    try
    {
        ; Create a fresh pipe instance and wait for client
        pipe.CreateServer()

        ; Read client request (UTF-16)
        request := pipe.Receive()

        ; simulate some work
        Sleep 2000

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

 pipe.Close()
 ExitApp()

