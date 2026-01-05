; ABOUT:    MyScript v0.0
; SOURCE:   https://www.autohotkey.com/boards/viewtopic.php?t=124720
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

PipeName := "\\.\pipe\testpipe"

hPipe := DllCall("WaitNamedPipe", "Str", PipeName, "UInt", NMPWAIT_WAIT_FOREVER:=0xffffffff)

f := FileOpen(PipeName, "rw")

MsgBox "From Server:`n`n" f.ReadLine()

f.Write("Message Received!")

f.Close()

DllCall("CloseHandle", "Ptr", hPipe)
 
ExitApp
