
#Requires AutoHotkey 2+
#SingleInstance Force
#Warn Unreachable, Off

;@Ahk2Exe-ConsoleApp

StdOut := "*"
StdErr := "**"

ext := (A_IsCompiled) ? ".exe" : ".ahk"

text:= "Hello World" A_Space ext

FileAppend text, StdOut
