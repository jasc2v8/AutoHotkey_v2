; TITLE: ShowArgs.ahk v10
; 
/*
    TODO:

*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
#NoTrayIcon

OnExit(ExitFunc)

Loop A_Args.Length {
    MsgBox("Argument " A_Index " is: " A_Args[A_Index])
}

ExitApp

ExitFunc(*) {
    mem:=""
    ExitApp()
}