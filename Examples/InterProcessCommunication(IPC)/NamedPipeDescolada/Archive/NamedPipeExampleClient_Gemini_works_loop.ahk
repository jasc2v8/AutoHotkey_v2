; ABOUT:    MyScript v0.0
; SOURCE:   Copilot
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

PipeName := "\\.\pipe\AHK_UTF16_Loop"
ResponseTimeout := 3000

Loop {
    ; 1. Get User Input
    userInput := InputBox("Enter message (Type 'BYE' to stop both):", "Pipe Client").Value
    
    ; Treat empty/cancel as exit but don't necessarily kill server unless 'BYE' is typed
    if (userInput = "")
        ExitApp

    ; 2. Connect
    if !DllCall("WaitNamedPipe", "Str", PipeName, "UInt", 2000) {
        MsgBox "Server not found."
        ExitApp
    }

    try {
        hPipe := DllCall("CreateFile", "Str", PipeName, "UInt", 0xC0000000, "UInt", 3, "Ptr", 0, "UInt", 3, "UInt", 0, "Ptr", 0, "Ptr")
        pipeFile := FileOpen(hPipe, "h", "UTF-16")
        
        ; 3. Send input to server
        pipeFile.WriteLine(userInput)
        pipeFile.Read(0)

        ; 4. Wait for response
        startTime := A_TickCount
        bytesAvail := 0
        while (A_TickCount - startTime < ResponseTimeout) {
            if DllCall("PeekNamedPipe", "Ptr", hPipe, "Ptr", 0, "UInt", 0, "Ptr", 0, "UIntP", &bytesAvail, "Ptr", 0) && bytesAvail > 0
                break
            Sleep 20
        }

        ; 5. Handle response and local exit
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