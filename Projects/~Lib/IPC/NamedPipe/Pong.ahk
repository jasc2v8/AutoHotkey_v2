; TITLE  :  MyScript v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
;#NoTrayIcon

#Include <LogFile>
#Include NamedPipe.ahk

;#Include <RunAsAdmin>

TrayTip "Admin Server is listening...", "Server Status"

logger:= Logfile("D:\pong.log", "PONG")
;logger.Disable()

Persistent

logger.Write("START")

pipe := NamedPipe()

; Open existins, or Create a new pipe instance and wait for client
pipe.Create()

Loop
{
    try
    {
        ; Read client request
        request := pipe.Receive()

        ; simulate some work
        sleepTime:= Random(1000,3000)
        Sleep sleepTime

        logger.Write("Receive: " request)

        ; Handle request
        reply := "ACK: " request ", Sleep: " sleepTime

        logger.Write("Reply: " reply)

        ; Send reply
        pipe.Send(reply)

        if (request = "TERMINATE")
            break
    }
    catch any as e
    {
        logger.Write("Error: " e.Message)
    }
}
Persistent false
pipe.Close()
logger.Write("TERMINATE")

