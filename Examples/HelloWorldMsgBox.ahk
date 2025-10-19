#Requires AutoHotkey v2.0

/*
 *
 * SciTE4AutoHotkey Syntax Highlighting Demo
 * - by fincs
 *
*/

; Normal comment
/*
Block comment
*/

; Directives, keywords
#SingleInstance Force
#NoTrayIcon

MsgBox("Hello, World!")

ExitApp

; Label, hotkey, hotstring
Label:
^!m::MsgBox("You pressed Ctl+Alt+m")

::btw::by the way
