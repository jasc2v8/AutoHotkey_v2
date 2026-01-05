; ABOUT:    MyScript v0.0
; SOURCE:   Copilot
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:

    msg := "Hello from server!"

    client ony received "Hello fro"
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include .\NamedPipe.ahk

PipeName := "\\.\pipe\testpipe"

Persistent

; 1. Create the Named Pipe
; PIPE_ACCESS_INBOUND = 1 | FILE_FLAG_OVERLAPPED = 0x40000000 (usually used for async)
; Using PIPE_ACCESS_DUPLEX (3) for simplicity
hPipe := DllCall("CreateNamedPipe", "Str", PipeName, "UInt", 3, "UInt", 0, "UInt", 255, "UInt", 0, "UInt", 0, "UInt", 0, "Ptr", 0, "Ptr")

if (hPipe = -1) {
    MsgBox "Failed to create named pipe. Error: " A_LastError
    ExitApp
}

MsgBox "Server started. Waiting for connection on " PipeName

Loop {
    ; 2. Wait for a client to connect
    if DllCall("ConnectNamedPipe", "Ptr", hPipe, "Ptr", 0) {

        ; 3. Wrap the handle in a File object for easier reading
        pipeFile := FileOpen(hPipe, "h", "UTF-8")
        
        ; Read the message
        message := pipeFile.ReadLine()

        MsgBox "SERVER Received: " message
        
        ; send ACK
        pipeFile.WriteLine("ACK")

        pipeFile.Close()

        ;MsgBox "SERVER Response Sent: ACK"

        ; 4. Disconnect to allow next connection
        ;DllCall("DisconnectNamedPipe", "Ptr", hPipe)

        if (message = "BYE")
            break

    }
    Sleep 100
}

        ; 4. Disconnect
        DllCall("DisconnectNamedPipe", "Ptr", hPipe)


DllCall("CloseHandle", "ptr", hPipe)
ExitApp()

;CreateNamedPipe(Name, OpenMode:=3, PipeMode:=0, MaxInstances:=255) => DllCall("CreateNamedPipe", "str", Name, "uint", OpenMode, "uint", PipeMode, "uint", MaxInstances, "uint", 0, "uint", 0, "uint", 0, "ptr", 0, "ptr")


