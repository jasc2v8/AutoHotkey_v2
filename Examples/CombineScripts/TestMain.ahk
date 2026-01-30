#Requires AutoHotkey v2.0
#SingleInstance Force

; Main Configuration
Global AppName := "My Toolbox"
Global Version := "1.0.0.4"

;MsgBox("Welcome to " AppName " v" Version, "Startup")

; This is a comment that will be stripped if the option is checked.
/*
    Multi-line block
    describing the main script.
*/

#Include "Lib_Math.ahk"
#Include "Lib_String.ahk"
#Include "Lib_UI.ahk"

;^j::MsgBox("Main Hotkey Pressed!")

text := "hellow world"

ShowStatus("Test Started.")

MsgBox  AddNumbers(10, 20) "`n`n" SubtractNumbers(10, 20) "`n`n"  .
        ToUpper(text)  "`n`n" ToLower(text), "Combine Scripts Test"

ShowStatus("Test Finished.")