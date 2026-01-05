#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance,Force

#Include talk.ahk
client2:= new talk("Background2") ; "Case Sensitive string of sender script's WinTitle"

Gui, Master2: New, AlwaysOnTop, Master2 
Gui, add, text, vText, Initial text label
Gui, add, Button, vButton gTalk, Talk
Gui, Show, x100 y450 w250 h70
myIndex:=0
return

ChangeText:
myIndex++
GuiControl, , Text, % "New value: " (1 * myIndex)
return

Talk:
client2.runlabel("ChangeText", wait:=true)
;MsgBox sent
return

GuiEscape:
Escape::
ExitApp
return