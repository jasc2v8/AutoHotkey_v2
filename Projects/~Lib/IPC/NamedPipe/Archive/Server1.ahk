; TITLE  :  MyScript v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include NamedPipe.ahk

pipe := NamedPipe("MyServicePipe", true)

Loop
{
    msg := pipe.Read()
    if msg = ""
        continue

    ; --- Handle command from user ---
    if (msg = "PING") {


        ;simulate work
        Sleep 3000

        pipe.Write("PONG from service")

    }
    else if (msg = "STATUS")
        pipe.Write("Service is running")

    else
        pipe.Write("UNKNOWN COMMAND")
}