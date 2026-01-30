#Requires AutoHotkey v2.0
#SingleInstance Force

#include Anchor.ahk

grui := Gui("+Resize +MinSize400x300", "Anchor Flicker Test")

; Left pane (resizes both directions)
editLeft := grui.AddEdit("x10 y10 w200 h200", "Resizable Edit`nTry dragging the window corner")

; Right pane (moves horizontally + resizes vertically)
editRight := grui.AddEdit("x220 y10 w160 h200", "Right Edit")

; Bottom status bar (width only)
status := grui.AddText("x10 y220 w370 h30 Border", "Status Bar")

; Buttons
btnOK     := grui.AddButton("x10  y260 w80 h30", "OK")
btnCancel := grui.AddButton("x300 y260 w80 h30", "Cancel")

; Anchors
anchor1 := Anchor(grui)
Anchor1.Add(editLeft,  "w h")
Anchor1.Add(editRight, "x h")
Anchor1.Add(status,    "w y")
Anchor1.Add(btnOK,     "y")
Anchor1.Add(btnCancel, "x y")

grui.Show("w400 h300")
