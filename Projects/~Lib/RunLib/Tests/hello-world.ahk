
#Requires AutoHotkey 2+
#SingleInstance Force
#Warn Unreachable, Off

/*
    NOTE:
    Must be run as an .exe NOT as an .ahk
    AHK can't write to StdOut unless compiled
    This is because there is no console or StdOut when run as a script.
*/

;@Ahk2Exe-ConsoleApp

StdOut := "*"
StdErr := "**"

text:= "Hello World" A_Space ".exe"

FileAppend text, StdOut
