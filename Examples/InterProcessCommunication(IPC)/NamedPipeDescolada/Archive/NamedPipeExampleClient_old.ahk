; ABOUT:    MyScript v0.0
; SOURCE:   Copilot
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include .\NamedPipe.ahk

;MsgBox "Press OK to start the Client and Wait for a Message..."

PipeName := "\\.\pipe\testpipe"

Loop {

    IB := InputBox("Enter a message to the SERVER:", "CLIENT",,
                        "This is a message from the CLIENT")

    If (IB.Value ="" OR IB.result = "Cancel")
        break   

    hPipe := DllCall("CreateFile"
    , "str", PipeName
    , "uint", 0xC0000000  ; GENERIC_READ | GENERIC_WRITE
    , "uint", 0           ; no sharing
    , "ptr", 0            ; default security
    , "uint", 3           ; OPEN_EXISTING
    , "uint", 0           ; flags
    , "ptr", 0
    , "ptr")

    ;DOES NOT WAIT BECAUSE SERVER HAS ALREADY CREATE THE PIPE!
    ; Wait until the pipe is ready for a connection
    ;r := DllCall("WaitNamedPipe", "Str", PipeName, "UInt", 0xffffffff)
    ;Pipe_Wait(PipeName)
    msgbox "test if wait: " hPipe

    ; if (r=0) {
    ;     Sleep 250
    ;     continue
    ; }
    ; ;msg := Pipe_Read(PipeName)

    ;MsgBox "Client received:`n`n" msg

    ;Pipe_Write(PipeName, ClientMsg)
    ;f := FileOpen(PipeName, "rw")

    f := FileOpen(PipeName, "rw")
    msg := f.ReadLine()
    MsgBox "Client received:`n`n" msg, "CLIENT"

    f.Write(IB.Value "`n")
    f.Close()

    if (msg = "Exit")
        break

    ;hPipe := Pipe_Create(PipeName
    ;Pipe_Write(hPipe, "Hello from client!")

    ;MsgBox "Server sent message."

    ;Pipe_Close(hPipe)

}
ExitApp
