; ABOUT:    MyScript v0.0
; SOURCE:   Copilot
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon
PipeName := "\\.\pipe\testpipe"

MsgBox "Press OK to start the Client and Wait for a Message..."

; Wait until the pipe is ready for a connection
DllCall("WaitNamedPipe", "Str", PipeName, "UInt", 0xffffffff)

f := FileOpen(PipeName, "rw")
MsgBox f.ReadLine()
f.Write("I message back!`n")
f.Close()

ExitApp