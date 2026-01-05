; TITLE  : ShowArgs.ahk v1.0
; PURPOSE:  Command line app to write parameters to StdOut
; USAGE  :  StdOutArgs one, two, 3.14
;               Arg 1: one,
;               Arg 2: two,
;               Arg 3: 3.14
; USAGE:    StdOutArgs one, two, 3.14 > StdOutArgs.txt
;======================================================
/*
    TODO:

*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
#NoTrayIcon

;@Ahk2Exe-ConsoleApp

StdOut := "*"
StdErr := "**"

Loop A_Args.Length {
    text:= "Arg " A_Index ": " A_Args[A_Index] "`n"
    FileAppend text, StdOut
    ; no, this would write a second line FileAppend text, StdErr
}
