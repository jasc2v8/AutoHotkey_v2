; ABOUT:    MyScript v0.0
; SOURCE:   Copilot
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

;#Include .\NamedPipe.ahk

global LogFile := "D:\Software\DEV\Work\AHK2\Examples\InterProcessCommunication(IPC)\NamedPipeDescolada\LogServer.txt"

PipeName := "\\.\pipe\testpipe"

Loop {

    msg := InputBox("Start the Server, then Create a pipe message", "Enter a message to write in " PipeName,, "This is a message").Value

    If !msg
        continue
    else if (msg = 'BYE')
        break

    ; 1. Check if the pipe exists before trying to open
    if !DllCall("WaitNamedPipe", "Str", PipeName, "UInt", 2000) {
        MsgBox "Pipe not found or timed out."
        ExitApp
    }

    ; 2. Open the pipe and write
    try {
        pipeFile := FileOpen(PipeName, "w", "UTF-8")

        ;pipeFile.WriteLine("Hello from the Client!")
        pipeFile.WriteLine(msg)

        pipeFile.Close()

        ;MsgBox "Message sent!"

    } catch Any as e {
        MsgBox "Error: " e.Message
    }
    
    MsgBox "", "CLIENT"
    
    ; wait for server to connect
    if !DllCall("WaitNamedPipe", "Str", PipeName, "UInt", 2000) {
        MsgBox "Pipe not found or timed out."
        ExitApp
    }

    ; 2. Open the pipe and read response
    try {

        pipeFile := FileOpen(PipeName, "r", "UTF-8")
        
        ; Read the message
        message := pipeFile.ReadLine()

        pipeFile.Close()

        MsgBox "Response: " message

    } catch Any as e {
        MsgBox "Error: " e.Message
    }

    ;MsgBox "Response: " msg


}

 ;if f.Close() wouldn't close the handle
;DllCall("CloseHandle", "ptr", hPipe)
ExitApp()

CreateNamedPipe(Name, OpenMode:=3, PipeMode:=0, MaxInstances:=255) => DllCall("CreateNamedPipe", "str", Name, "uint", OpenMode, "uint", PipeMode, "uint", MaxInstances, "uint", 0, "uint", 0, "uint", 0, "ptr", 0, "ptr")


