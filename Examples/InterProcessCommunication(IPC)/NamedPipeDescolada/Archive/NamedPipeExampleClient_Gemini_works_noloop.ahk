; ABOUT:    MyScript v0.0
; SOURCE:   Copilot
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

PipeName := "\\.\pipe\AHK_UTF16_Pipe"
ResponseTimeout := 2000 ; 2 seconds

if !DllCall("WaitNamedPipe", "Str", PipeName, "UInt", 2000) {
    MsgBox "Server not responding."
    ExitApp
}

; Use "w" (write-only) first to avoid the BOM-check hang, 
; then we will use PeekNamedPipe for reading.
try {
    ; 1. Open pipe handle manually to bypass FileOpen's initial hang
    hPipe := DllCall("CreateFile", "Str", PipeName, "UInt", 0xC0000000, "UInt", 3, "Ptr", 0, "UInt", 3, "UInt", 0, "Ptr", 0, "Ptr")
    
    if (hPipe = -1)
        throw Error("Failed to open pipe handle.")

    ; Wrap in File Object for easy UTF-16 writing
    pipeFile := FileOpen(hPipe, "h", "UTF-16")
    pipeFile.WriteLine("Hello Server")
    pipeFile.Read(0) ; Flush buffer

    ; 2. Non-blocking Wait for Response
    startTime := A_TickCount
    bytesAvail := 0
    
    while (A_TickCount - startTime < ResponseTimeout) {
        ; Check if there is data waiting in the pipe
        if DllCall("PeekNamedPipe", "Ptr", hPipe, "Ptr", 0, "UInt", 0, "Ptr", 0, "UIntP", &bytesAvail, "Ptr", 0) {
            if (bytesAvail > 0)
                break
        }
        Sleep 50 ; Don't max out CPU
    }

    ; 3. Read if data exists, otherwise Timeout
    if (bytesAvail > 0) {
        MsgBox "Server Replied: " . pipeFile.ReadLine()
    } else {
        MsgBox "Timed out waiting for server response."
    }

    pipeFile.Close()
} catch Any as e {
    MsgBox "Error: " e.Message
}