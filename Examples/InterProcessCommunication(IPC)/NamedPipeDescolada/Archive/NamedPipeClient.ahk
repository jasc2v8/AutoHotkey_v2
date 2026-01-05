; TITLE  :  NamedPipeClient v0.0
; SOURCE :  Gemini and Copilot
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

global PipeName := "\\.\pipe\global\AHK_UTF16_Loop"

ServerTimeout   := 2000
ResponseTimeout := 3000

READWRITE       := 0xC0000000
SHARED          := 3
OPEN_EXISTING   := 3


Loop {
    
    userInput := InputBox("Enter message (Type 'BYE' to stop both):", "Pipe Client").Value
    
    ; Treat empty/cancel as exit but don't necessarily kill server unless 'BYE' is typed
    if (userInput = "")
        ExitApp

    ; Wait until Server call ConnectNamedPipe or timeout
    if !DllCall("WaitNamedPipe", "Str", PipeName, "UInt", ServerTimeout) {
        MsgBox "Server not found."
        ExitApp
    }

    try {
        ; Open Pipe and return its handle
        hPipe := DllCall("CreateFile", "Str", PipeName, "UInt", READWRITE, "UInt", SHARED, "Ptr", 0, "UInt", OPEN_EXISTING, "UInt", 0, "Ptr", 0, "Ptr")
        pipeFile := FileOpen(hPipe, "h", "UTF-16")
        
        ; Send user input to server
        pipeFile.WriteLine(userInput)
        pipeFile.Read(0)

        ; Wait for response
        startTime := A_TickCount
        bytesAvail := 0
        while (A_TickCount - startTime < ResponseTimeout) {
            if DllCall("PeekNamedPipe", "Ptr", hPipe, "Ptr", 0, "UInt", 0, "Ptr", 0, "UIntP", &bytesAvail, "Ptr", 0) && bytesAvail > 0
                break
            Sleep 20
        }

        ; Handle response and local exit
        if (bytesAvail > 0) {
            reply := pipeFile.ReadLine()
            MsgBox "Server: " . reply, "Client", "T2"
            
            ; If we sent BYE, exit the client after receiving the server's acknowledgment
            if (StrLower(userInput) = "bye")
                ExitApp
        } else {
            MsgBox "Timeout."
        }
        
        pipeFile.Close()

    } catch Any as e {
        MsgBox "Error: " e.Message
    }
}