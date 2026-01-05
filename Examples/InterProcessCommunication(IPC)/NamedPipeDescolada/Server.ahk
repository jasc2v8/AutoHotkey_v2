; TITLE:    Named Pipe Server v0.0
; SOURCE:   Descolada https://www.autohotkey.com/boards/viewtopic.php?style=19&t=124720&start=20
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

global LogFile := "D:\Software\DEV\Work\AHK2\Examples\InterProcessCommunication(IPC)\NamedPipeDescolada\LogServer.txt"

PipeName := "\\.\pipe\testpipe"

hPipe := CreateNamedPipe(PipeName)
If (hPipe = -1)
    throw Error("Creating the named pipe failed")

PipeMsg := InputBox("Start the Client, then Create a pipe message", "Enter a message to write in " PipeName,, "This is a message").Value
If !PipeMsg
    ExitApp

; Wait for a client to connect. This can be made non-blocking as well (https://www.codeproject.com/Articles/5347611/Implementing-an-Asynchronous-Named-Pipe-Server-Par)
DllCall("ConnectNamedPipe", "ptr", hPipe, "ptr", 0)

; YES! MsgBox "DID IT WAIT?", 'SERVER'

; Wrap the handle in a file object
f := FileOpen(hPipe, "h")
; If the new-line is not included then the message can't be read from the pipe
f.Write(PipeMsg "`n")

; Wait for the response
while !(msg := f.ReadLine())
    Sleep 200
MsgBox "Response: " msg
;f.Close() wouldn't close the handle
DllCall("CloseHandle", "ptr", hPipe)
ExitApp

CreateNamedPipe(Name, OpenMode:=3, PipeMode:=0, MaxInstances:=255) => DllCall("CreateNamedPipe", "str", Name, "uint", OpenMode, "uint", PipeMode, "uint", MaxInstances, "uint", 0, "uint", 0, "uint", 0, "ptr", 0, "ptr")