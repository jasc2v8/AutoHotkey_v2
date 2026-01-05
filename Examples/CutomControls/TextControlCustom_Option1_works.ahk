; ABOUT:    FontCompare v0.1
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  None

/*
    TODO:

*/

#Requires AutoHotkey v2.0+

class MyTextControl {
    __New(guiControl, color) {
        this.Control := guiControl
        this.Color := color
    }

    SetColor(newColor) {
        this.Color := newColor
        this.Control.Opt("+c" newColor)
    }

    GetColor() {
        return this.Color
    }
}

MyGui := Gui()
MyGui.Add("Text", "vMyText", "Hello World")

; Create an instance of MyTextControl and associate it with the GUI control
myTextObj := MyTextControl(MyGui["MyText"], "Black")

MyGui.Show()

; Example of changing and getting the color
MsgBox("Current text color: " myTextObj.GetColor())
myTextObj.SetColor("Red")
MsgBox("Current text color: " myTextObj.GetColor())