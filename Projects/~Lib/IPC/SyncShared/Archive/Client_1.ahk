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

pipe := NamedPipe("MyServicePipe", false)

pipe.Write("PING")
MsgBox pipe.Read()

pipe.Write("STATUS")
MsgBox pipe.Read()

;pipe.Close()