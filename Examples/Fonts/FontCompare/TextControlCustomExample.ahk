; ABOUT:    FontCompare v0.1
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  None

/*
    TODO:

*/
#Requires AutoHotkey v2.0

class TextEx {

    FontColor := "Default"

    __New(gui, text := "", options := "", x := "", y := "") {

        this.ctrl := gui.Add("Text", options " x" x " y" y, text)
    }

    Append(newText) {
        ;this.ctrl.Text := this.ctrl.Text . newText . "`n"
        this.SetText(this.ctrl.Text . newText . "`n")
    }

    Clear() {
        this.ctrl.Text := ""
    }

    GetColor() {
        return this.FontColor
    }
    
    GetText() {
        return this.ctrl.Text
    }

    SetColor(color) {
        this.FontColor := color
        this.ctrl.SetFont("c" color)
    }

    SetText(newText) {
        this.ctrl.Text := newText
    }
 
    Show() {
        this.ctrl.Visible := true
    }

    Hide() {
        this.ctrl.Visible := false
    }
}

Esc::ExitApp

g := Gui()
g.SetFont("s12", "Consolas")
MyText := TextEx(g, "Empty", "w380 h180 BackgroundWhite -Border", 10, 10)
g.SetFont()
g.AddButton("xm w75 Default", "OK").OnEvent("Click", ButtonOK_Click)
g.AddButton("yp w75", "Clear").OnEvent("Click", ButtonClear_Click)
g.AddButton("yp w75", "Cancel").OnEvent("Click", (*)=>ExitApp())

MyText.SetText("Hello World!`n")
;MyText.Append("Current Text Color: " MyText.FontColor . "`n")

global count := 0

g.Show("w400 h240")

ButtonOK_Click(ctrl, Info) {
    global count
    static newColor

    count++
    ;global MyText

    ;newColor := (MyText.GetColor() != "Default") ? "Red" : "Default"

    if mod(count, 2) = 0 {
        ;MyText.Hide()
        newColor := "Red"
    } else {
        newColor := "Blue"
        ;MyText.Show()
    }

    MyText.SetColor(newColor)

    ;MyText.Text:="Current Text Color: " MyText.FontColor
    ;MyText.SetText("Current Text Color: " MyText.FontColor)
    MyText.Append(count ": Current Text Color: " MyText.FontColor ", ")

}

ButtonClear_Click(ctrl, Info) {
    global count

    count := 0
    MyText.SetText("")

    MyText.Move(10+count, 10+count)
}
