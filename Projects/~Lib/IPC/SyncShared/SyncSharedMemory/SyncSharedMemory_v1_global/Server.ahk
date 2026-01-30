; TITLE  :  SyncShared Server v1.0.0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2+
#SingleInstance Force
TraySetIcon("shell32.dll", 18) ; Blue Terminal with earth globe

#Include SharedMemory.ahk
#Include SyncShared.ahk

;SyncShared works if elevated or not
#Include <RunAsAdmin>

TrayTip "Server is listening...", "Server Status"
Sleep 1200
TrayTip

sync    := SyncShared(true) ; Create Server Instances
shared  := SharedMemory(true)

Loop
{
    Sleep -1

    try
    {

        TextReceived := sync.Receive(ReadShared)

        if (TextReceived = "TERMINATE") {
            break
        }

        ; simulate some work
        ;Sleep 1000
        SoundBeep

        ; Form reply
        reply := "ACK: " TextReceived

        ; Send reply
        sync.Send(reply, WriteShared)

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
        Throw Error "Server: Timeout ReadShared"

    TextReceived := shared.Read()

    return TextReceived
}

WriteShared(Text) {

    shared.Write(Text)

}

