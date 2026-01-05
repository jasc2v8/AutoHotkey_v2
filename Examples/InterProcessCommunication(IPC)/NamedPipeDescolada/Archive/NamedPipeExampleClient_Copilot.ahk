; ABOUT:    MyScript v0.0
; SOURCE:   Copilot
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

pipeName := "\\.\pipe\MyPipe"

Loop {
    hPipe := DllCall("CreateFile", "Str", pipeName
        , "UInt", 0xC0000000 ; GENERIC_READ | GENERIC_WRITE
        , "UInt", 0
        , "Ptr", 0
        , "UInt", 3          ; OPEN_EXISTING
        , "UInt", 0
        , "Ptr", 0, "Ptr")
    if hPipe
        break
    Sleep 500
}

; Wrap pipe handle in File object
pipeFile := FileOpen(hPipe, "rw", "UTF-16")

; --- Write to server ---
pipeFile.Write("Hello Server!`n")
pipeFile.Read(0) ; flush

; --- Read response ---
serverMsg := pipeFile.Read()
MsgBox "Client received: " serverMsg

pipeFile.Close()
DllCall("CloseHandle", "Ptr", hPipe)