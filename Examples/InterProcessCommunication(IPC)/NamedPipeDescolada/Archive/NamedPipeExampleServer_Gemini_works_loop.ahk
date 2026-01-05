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

PipeName := "\\.\pipe\AHK_UTF16_Loop"

Loop {
    hPipe := DllCall("CreateNamedPipe", "Str", PipeName, "UInt", 3, "UInt", 0, "UInt", 255, "UInt", 0, "UInt", 0, "UInt", 0, "Ptr", 0, "Ptr")
    
    if (hPipe = -1)
        Continue

    if DllCall("ConnectNamedPipe", "Ptr", hPipe, "Ptr", 0) {
        pipeFile := FileOpen(hPipe, "h", "UTF-16")
        
        query := Trim(pipeFile.ReadLine(), "`r`n")
        
        ; --- Test for 'BYE' ---
        if (StrLower(query) = "bye") {
            pipeFile.WriteLine("Goodbye! Server shutting down.")
            pipeFile.Read(0)
            pipeFile := ""
            DllCall("DisconnectNamedPipe", "Ptr", hPipe)
            DllCall("CloseHandle", "Ptr", hPipe)
            MsgBox "Server received BYE. Closing."
            ExitApp ; Shutdown the server
        }
        
        ; Standard response for other queries
        pipeFile.WriteLine("ACK: " . query)
        pipeFile.Read(0) 
        pipeFile := "" 
    }
    
    DllCall("DisconnectNamedPipe", "Ptr", hPipe)
    DllCall("CloseHandle", "Ptr", hPipe)
}