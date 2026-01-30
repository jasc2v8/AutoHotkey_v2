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

ipc := GlobalPipeIPC("AHK_IPC_Pipe")

try
{
    ; Connect to the service pipe
    ipc.ConnectClient(5000)

    ; Send request
    ipc.Send("Hello from user session")

    ; Receive reply
    reply := ipc.Receive()
    MsgBox reply
}
catch as err
{
    MsgBox "IPC error:`n" err.Message
}
finally
{
    ipc.Close()
}
