#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon
#Warn Unreachable, Off
Esc::ExitApp

g := Gui()

myButton1 := g.Add("Button", "w100", "Button1")
myButton2  := g.AddButton("w100", "Button2").OnEvent("Click", Button_Click)
myEdit          := g.AddEdit("w100 Center", "Edit Control")
myText          := g.AddText("w100 Center", "Text Control")

g.Show("w400 h 200")

MsgBox Type(myButton1) ", " Type(myButton2) ", " StrLen(myButton2) ", " Type(myText)



Button_Click(Ctrl, Info) {

    ;MsgBox Type(ButtonOK)

    ;ButtonOK.Move(100, 100)
    ;Ctrl.Move(100, 100)

    y := 0
    Ctrl.Move(100, y)
    ;g["OK"].Move(100, 100)
    ; no g[ButtonOK].Move(100, 100)
    
}