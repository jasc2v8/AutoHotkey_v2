; TITLE  :  MyScript v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include NamedPipe.ahk

#Requires AutoHotkey v2.0
#SingleInstance Force

pipe := NamedPipe()

Loop {

    request := InputBox("Enter data to send to server:", "Client").Value

    if (request = "") or (request = "BYE")
        break

    try
    {
        ; Connect to the service pipe
        pipe.ConnectClient(5000)

        ; Send request
        pipe.Send(request)

        ; Receive reply
        reply := pipe.Receive()

        MsgBox reply
    }
    catch as err
    {
        MsgBox "Error:`n`n" err.message
    }
    finally
    {
        pipe.Close()
    }
}
