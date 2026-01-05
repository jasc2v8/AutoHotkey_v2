;#ABOUT: Debug.ahk add string, Debug.ListVar(string)

#Requires AutoHotkey v2.0+

; DEBUG
#SingleInstance Force
#Warn Unreachable, off
esc::ExitApp

#Include .\Debug.ahk
#Include .\GetVarName.ahk

test:="TEST"

MsgBox Debug.VarName(test) ": " test, "Debug"

junk:="THIS IS JUNK1"
MsgBox Debug.VarName(junk) ": " junk, "Debug"

junk:="THIS IS JUNK2"
MsgBox Debug.VarName(junk) ": " junk, "Debug"

ExitApp

test:="TEST"
MsgBox VarName(test) ": " test, "Debug"

junk:="THIS IS JUNK1"
MsgBox VarName(junk) ": " junk, "Debug"

junk:="THIS IS JUNK2"
MsgBox VarName(junk) ": " junk, "Debug"
