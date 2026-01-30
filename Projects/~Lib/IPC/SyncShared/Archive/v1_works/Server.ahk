; TITLE  :  MyScript v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2+
#SingleInstance Force
;#NoTrayIcon

#Include SharedFile.ahk
#Include SyncShared.ahk

;#Include <RunAsAdmin>

global TextReceived := ""

TrayTip "Server is listening...", "Server Status"
SetTimer((*) => TrayTip(), -1500)

Persistent

sync    := SyncShared(true)
shared  := SharedFile(true)

Loop
{
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

Persistent false
ExitApp()

ReadShared(Timeout) {

    if (Timeout)
        Throw Error "Server: Timeout ReadShared"

    TextReceived := shared.Read()

    ;MsgBox "ReadShared:" TextReceived, "Server"

    return TextReceived
}

WriteShared(Text) {

    ;MsgBox "WriteShared: " Text, "Server"

    shared.Write(Text)

}

