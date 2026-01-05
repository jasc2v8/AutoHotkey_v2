; ABOUT:    FontCompare v0.1
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  None
/*
    TODO:

*/

#Requires AutoHotkey v2.0

;-----------------------------------------------------------------------------------
; MyText := TextCustom(MyGui, "My TExt", "w380 h180 BackgroundWhite -Border", 10, 10)
; MyText.Append("Hello World!)
; MyText.Clear()
; MyText.GetText()
; MyText.SetText("Hello World!`n")
; MyText.Hide()
; MyText.Show()
; MyText.GetColor()
; MyText.SetColor(newColor)
; MyText.FontColor
;-----------------------------------------------------------------------------------
class TextCustom {

    FontColor := "Default"
    ctrl := ""

    __New(guictrl, options := "", text := "") {

        this.ctrl := guictrl.AddText(options, text)
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

