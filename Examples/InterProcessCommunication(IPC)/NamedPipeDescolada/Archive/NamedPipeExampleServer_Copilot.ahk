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


pipeName := "\\.\pipe\MyPipe"

hPipe := DllCall("CreateNamedPipe", "Str", pipeName
    , "UInt", 0x00000003 ; PIPE_ACCESS_DUPLEX
    , "UInt", 0x00000000 ; PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT
    , "UInt", 255
    , "UInt", 4096
    , "UInt", 4096
    , "UInt", 0
    , "Ptr", 0, "Ptr")
if !hPipe {
    MsgBox "Failed to create pipe"
    ExitApp
}

MsgBox "Server waiting for client..."
DllCall("ConnectNamedPipe", "Ptr", hPipe, "Ptr", 0)

; Wrap pipe handle in File object
pipeFile := FileOpen(hPipe, "rw", "UTF-16")

; --- Read from client ---
clientMsg := pipeFile.Read()
MsgBox "Server received: " clientMsg

; --- Write response ---
pipeFile.Write("Hello Client, I got your message!`n")
pipeFile.Read(0) ; flush

MsgBox "Server sent response."

pipeFile.Close()
DllCall("DisconnectNamedPipe", "Ptr", hPipe)
DllCall("CloseHandle", "Ptr", hPipe)