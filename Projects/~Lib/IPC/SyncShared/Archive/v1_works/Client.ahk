; TITLE  :  MyScript v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:

*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include SharedFile.ahk
#Include SyncShared.ahk

global TextReceived := ""

sync    := SyncShared() ; Create Client instance
shared  := SharedFile()

Loop {

    try
    {
        request := InputBox("Enter Message:", "Client",,"TERMINATE")

        if (request.Value = "")
            continue

        if (request.Value = "BYE") or (request.Result = "Cancel")
            break

        ; Send request
        sync.Send(request.Value, WriteShared)

        ; if terminate, don't wait for a reply
        if (request.Value = "TERMINATE") {
            ;Sleep 200 ; time for server to cleanup and exit
            break
        }

        ; Receive reply
        TextReceived := sync.Receive(ReadShared)

        MsgBox "Received:" TextReceived, "Client"

    }
    catch as err
    {
        ; Optional: log err.Message to file/event log
    }
    finally
    {
        ; Optional: if you need to clean up resources, do it here
    }
}
ExitApp()

ReadShared(Timeout) {

    if (Timeout)
        Throw Error "Client: Timeout ReadShared"

    TextReceived := shared.Read()

    ;MsgBox "ReadShared:" TextReceived, "Client"
    
    return TextReceived
}

WriteShared(Text) {

    ;MsgBox "WriteShared: " Text, "Client"

    shared.Write(Text)   

}