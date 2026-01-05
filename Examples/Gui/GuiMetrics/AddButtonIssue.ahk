#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon
#Warn Unreachable, Off
Esc::ExitApp

g := Gui()

myButton1 := g.Add("Button", "w100", "Button1")
myButton2 := g.AddButton("w100", "Button2")
myEdit    := g.AddEdit("w100 Center", "Edit Control")
myText    := g.AddText("w100 Center", "Text Control")

g.Show("w400 h 200")

; myButton2 is an Empty String, the others are GuiCtrl objects.
ListVars





Button_Click(Ctrl, Info) {

    ;MsgBox Type(ButtonOK)

    ;ButtonOK.Move(100, 100)
    ;Ctrl.Move(100, 100)

    y := 0
    Ctrl.Move(100, y)
    ;g["OK"].Move(100, 100)
    ; no g[ButtonOK].Move(100, 100)
    
}