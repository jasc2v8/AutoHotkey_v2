#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance,Force

#Include talk.ahk
client1:= new talk("Master2") ; "Case Sensitive string of receiver script's WinTitle"


Gui, Background2: New, AlwaysOnTop, Background2
Gui, add, text, vText, Initial text label
Gui, add, Button, vButton gTalk, Talk
Gui, Show, x500 y450 w250 h70
myIndex:=0
return

ChangeText:
myIndex++
GuiControl, , Text, % "New value: " (1 * myIndex)
return

Talk:
client1.runlabel("ChangeText", wait:=true)
;MsgBox sent
return

GuiEscape:
Escape::
ExitApp
return