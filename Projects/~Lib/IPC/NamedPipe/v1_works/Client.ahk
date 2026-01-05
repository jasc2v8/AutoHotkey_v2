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

#Include NamedPipe.ahk

pipe := NamedPipe()

Loop {

    try
    {
        request := InputBox("Enter Message:", "Clien",,"TERMINATE").Value

        if (request = "") or (request = "BYE")
            break

        ; Connect to the service pipe
        ;pipe.Wait()
        r := pipe.Wait(5000)

        if (!r) {
            MsgBox "Timeout waiting for pipe to be created..", "Client", "IconX"
            break
        }

        ; Send request
        pipe.Send(request)

        ; Receive reply
        reply := pipe.Receive()

        MsgBox reply

        if (request = "TERMINATE")
            break
    }
    catch as err
    {
        MsgBox "Error:`n`n" err.message "`n`nPlease start Server or Task first.", "Client", "IconX"
        break
    }
    finally
    {
        pipe.Close()
    }
}
pipe.Close()
ExitApp()
