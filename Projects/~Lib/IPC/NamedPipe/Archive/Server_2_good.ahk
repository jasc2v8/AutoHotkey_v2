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
#SingleInstance Off
Persistent

ipc := GlobalPipeIPC("AHK_IPC_Pipe")

Loop
{
    try
    {
        ; Create a fresh pipe instance and wait for client
        ipc.CreateServer()

        ; Read client request (UTF-16)
        request := ipc.Receive()

        ; Handle request (your logic here)
        response := "ACK: " request

        ; Send reply
        ipc.Send(response)
    }
    catch as err
    {
        ; Optional: log err.Message to file/event log
    }
    finally
    {
        ; REQUIRED: tear down instance so clients can reconnect
        ipc.Close()
    }
}
