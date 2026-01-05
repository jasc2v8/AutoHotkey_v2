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

Persistent

PipeName := "\\.\pipe\AHK_UTF16_Pipe"
; Create Pipe: Duplex (3), UTF-16
hPipe := DllCall("CreateNamedPipe", "Str", PipeName, "UInt", 3, "UInt", 0, "UInt", 255, "UInt", 0, "UInt", 0, "UInt", 0, "Ptr", 0, "Ptr")

MsgBox "Server Listening (UTF-16)..."

Loop {
    if DllCall("ConnectNamedPipe", "Ptr", hPipe, "Ptr", 0) {
        pipeFile := FileOpen(hPipe, "h", "UTF-16")
        
        ; Read and trim newline
        query := Trim(pipeFile.ReadLine(), "`r`n")

        MsgBox "Server Received: " . query
        
        ; Respond (MUST include `n at the end)
        pipeFile.WriteLine("ACK: " . query . " at " . A_TickCount)
        pipeFile.Read(0) ; Flush
        
        pipeFile := "" 
        DllCall("DisconnectNamedPipe", "Ptr", hPipe)
    }
    Sleep 10
}