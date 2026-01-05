; ABOUT:    TextControlCustom v0.2
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:

*/

#Requires AutoHotkey v2.0

;-----------------------------------------------------------------------------------
; MyEdit := EditCustom(Options, Text)
; MyEdit.Append("Hello World!" . "`n")
; MyEdit.AppendLine("Hello World!)
; MyEdit.Clear()
; MyEdit.GetText()
; MyEdit.SetText("Hello World!`n")
; MyEdit.Hide()
; MyEdit.Show()
; MyEdit.GetColor()
; MyEdit.SetColor("White")
; MyEdit.FontColor
;-----------------------------------------------------------------------------------
class EditCustom {

    FontColor := "Default"

    __New(gui, options := "", text := "")  => this.ctrl := gui.Add("Edit", options, text)

    Append(newText) => this.ctrl.Text .= newText

    AppendLine(newText) => this.ctrl.Text .= newText . "`n"

    Clear() => this.ctrl.Text := ""
                
    GetColor() => this.ctrl.Font.Color

    GetText() => this.ctrl.Text

    SetColor(color) => (
        this.FontColor := color,
        this.ctrl.SetFont("c" color)
    )

    SetText(newText) => this.ctrl.Text := newText
 
    Show() => this.ctrl.Visible := true

    Hide() => this.ctrl.Visible := false

}

If (A_LineFile == A_ScriptFullPath)  ; if run directly, not included
    TextControlCustom_Tests()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------
#Warn Unreachable, off

Esc::ExitApp

g := Gui()
g.SetFont("s14", "Consolas")
MyEdit := EditCustom(g, "w380 h180 BackgroundWhite -Border", "Empty")
g.SetFont()
g.AddButton("xm w75 Default", "OK").OnEvent("Click", ButtonOK_Click)
g.AddButton("yp w75", "Clear").OnEvent("Click", ButtonClear_Click)
g.AddButton("yp w75", "Cancel").OnEvent("Click", (*)=>ExitApp())

g.Show("w400 h240")

MsgBox

MyEdit.SetText("1: Hello World!`n")
;MyEdit.Clear()
MyEdit.Append("2: Hello World!`n")
MyEdit.AppendLine("3: Hello World!")
MyEdit.Append("4: Current Text Color: " MyEdit.FontColor . "`n")

global count := 0

ButtonOK_Click(ctrl, Info) {
    global count
    static newColor

    count++
    ;global MyEdit

    ;newColor := (MyEdit.GetColor() != "Default") ? "Red" : "Default"

    if mod(count, 2) = 0 {
        ;MyEdit.Hide()
        newColor := "Red"
    } else {
        newColor := "Blue"
        ;MyEdit.Show()
    }

    MyEdit.SetColor(newColor)

    ;MyEdit.Text:="Current Text Color: " MyEdit.FontColor "`n"
    ;MyEdit.Text.="Current Text Color: " MyEdit.FontColor "`n"
    ;MyEdit.SetText("Current Text Color: " MyEdit.FontColor)
    ;MyEdit.Append(count ": Current Text Color: " MyEdit.FontColor "`n" )
    ;MyEdit.AppendLine(count ": Current Text Color: " MyEdit.FontColor)

}

ButtonClear_Click(ctrl, Info) {
    global count
    count := 0
    MyEdit.SetText("")
}




TextControlCustom_Tests() {

    ; comment out to run tests
    ;SoundBeep(), ExitApp()

    ; comment out tests to skip:
    Test1()
    Test2()
    Test3()

    ; Standard Textbox set or append?
    Test1() {
        
        g := Gui()


    }
    Test2() {
    }
    Test3() {
    }
}

; Validate a Standard Text Control will append text, not overwrite
; g := Gui()
; myEdit := g.AddText("w400 r20", "Hello World!")
; g.Show()
; myEdit.text .= "`n"
; myEdit.text .= "changed `n" 
; Loop 20 {
;     myEdit.text .= "Line " A_Index "`n"
; }
; Msgbox(myEdit)
; g.Destroy()
; ExitApp

