; TITLE  :  SyncShared Client v1.0.0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:

*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
TraySetIcon("shell32.dll", 16) ; Blue Terminal

#Include NamedPipe.ahk
#Include SyncShared.ahk

global TextReceived := ""

sync    := SyncShared() ; Create Client Instances
shared  := NamedPipe(false, "\\.\pipe\Global\AHK_Pipe")
;shared  := NamedPipe(false, "\\.\pipe\Global\AHK_Pipe")

Loop {

    try
    {
        ; Form request
        request := InputBox("Enter Message:", "Client",,"TERMINATE")

        if (request.Value = "")
            continue

        if (request.Value = "BYE") or (request.Result = "Cancel")
            break

        ; Send request
        sync.Send(request.Value, WriteShared)

        ; if terminate, don't wait for a reply
        if (request.Value = "TERMINATE")
            break
 
        ; Receive reply
        TextReceived := sync.Receive(ReadShared, 1000)

        ; Handle timeout
        if (TextReceived = "TIMEOUT") {
            MsgBox "Server timed out!`n`nIs Server running?", "Client", "Icon!"
            continue
        }

        MsgBox "Received:" TextReceived, "Client"

    }
    catch Any as e
    {
        ; Optional: log e.Message to file/event log
    }
    finally
    {
        ; Optional: if you need to clean up resources, do it here
    }
}
ExitApp()

; Call the Read method specific to your shared resource: File, Memory, Messenger, Object, Pipe, etc.
ReadShared(Timeout) {

    TextReceived := (Timeout) ? "TIMEOUT" : shared.Read()
    
    return TextReceived
}

; Call the Write method specific to your shared resource: File, Memory, Messenger, Object, Pipe, etc.
WriteShared(Text) {

    shared.Write(Text)   

}