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

#Include NamedPipeBridge.ahk

pipe := NamedPipeBridge()

Loop {

    try
    {
        request := InputBox("Enter Message:", "Client",,"TERMINATE").Value

        if (request = "") or (request = "BYE")
            ExitApp

        ; Send request
        pipe.Send(request)

        ; Receive reply
        reply := pipe.Receive()

        MsgBox reply

        if (request = "TERMINATE")
            ExitApp
    }
    catch as err
    {
        MsgBox "Error:`n`n" err.message "`n`nPlease start Server or Task first.", "Client", "IconX"
        ExitApp
    }
}

