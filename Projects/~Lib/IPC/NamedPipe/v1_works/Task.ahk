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

#Include <RunAsAdmin>

TrayTip "Admin Task is listening...", "Task Status"

; One time on-demand Task

pipe := NamedPipe()

try
{
    ; Create a fresh pipe instance and wait for client
    pipe.Create()

    ; Read client request (UTF-16)
    request := pipe.Receive()

    ; simulate some work
        ; simulate some work
        ;Sleep 1000
        SoundBeep
        SoundBeep
        SoundBeep

    ; Handle request (your logic here)
    reply := "ACK: " request

    ; Send reply
    pipe.Send(reply)

    if (request = "TERMINATE") {
        pipe.Close()
        ExitApp()
    }
}
catch as err
{
    ; Optional: log err.Message to file/event log
}
finally
{
    pipe.Close()
}

