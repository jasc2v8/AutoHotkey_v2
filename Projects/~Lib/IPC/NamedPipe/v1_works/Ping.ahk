; TITLE  :  MyScript v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:

    Server is continuous, Task is one-time.

    Start Server or Task
    Server will listen for client requests until it receives "TERMINATE"
    Task wiill listen for a client request, perform some work, send an ACK back to the client, then Exit.
    Start Client, enter input, press OK. Enter "TERMINATE" then "BYE" or press Cancel to exit.

*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include <LogFile>
#Include NamedPipe.ahk

logger:= Logfile("D:\ping.log", "PING")
;logger.Disable()

MsgBox "START"

logger.Write("START")

pipe := NamedPipe()

r := pipe.Wait(5000)

if (!r) {
    logger.Write("Timeout waiting for pipe to be created..")
    MsgBox "Timeout waiting for pipe to be created..", "Client", "IconX"
}

Loop 10 {

    try
    {
        request := "Request #" A_Index

        logger.Write("Send: " request)

        pipe.Send(request)

        reply := pipe.Receive()

        logger.Write("Reply #" A_Index ": " reply)
    }
    catch any as e
    {
        logger.Write("Error: " e.message)
        break
    }
}

logger.Write("Request TERMINATE")
pipe.Send("TERMINATE")
reply := pipe.Receive()
pipe.Close()
logger.Write("END")
MsgBox "END"
