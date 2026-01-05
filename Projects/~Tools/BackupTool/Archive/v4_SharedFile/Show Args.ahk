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

    filePath:= A_Args[A_Index]

    exist := FileExist(filePath)

    MsgBox(A_Index ": " filePath "`n`n" "Exist: " result:=(exist!="")?"true":"false", "Show Args")
}

ExitApp

ExitFunc(*) {
    mem:=""
    ExitApp()
}