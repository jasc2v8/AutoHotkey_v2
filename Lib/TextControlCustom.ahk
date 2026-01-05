; ABOUT:    TextControlCustom v0.2
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:

*/

#Requires AutoHotkey v2.0

;-----------------------------------------------------------------------------------
; MyText := TextCustom(Options, Text)
; MyText.Append("Hello World!" . "`n")
; MyText.AppendLine("Hello World!)
; MyText.Clear()
; MyText.GetText()
; MyText.SetText("Hello World!`n")
; MyText.Hide()
; MyText.Show()
; MyText.GetColor()
; MyText.SetColor("White")
; MyText.FontColor
;-----------------------------------------------------------------------------------
class TextCustom {

    FontColor := "Default"

    __New(gui, options := "", text := "")  => this.ctrl := gui.Add("Text", options, text)

    Append(newText) => this.ctrl.Text .= newText

    AppendLine(newText) => this.ctrl.Text .= newText . "`n"

    Clear() => this.ctrl.Text := ""
                
    GetColor() => this.ctrl.FontColor

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

 TextControlCustom_Tests() {

    ;Esc::ExitApp

    ; comment out to run tests
    ;SoundBeep(), ExitApp()

    ; comment out tests to skip:
    ;Test1()
    ;Test2()
    ;Test3()

    g := Gui()
    g.SetFont("s14", "Consolas")
    MyText := TextCustom(g, "w380 h180 BackgroundWhite -Border", "Empty")
    g.SetFont()
    g.AddButton("xm w75 Default", "OK").OnEvent("Click", ButtonOK_Click)
    g.AddButton("yp w75", "Clear").OnEvent("Click", ButtonClear_Click)
    g.AddButton("yp w75", "Cancel").OnEvent("Click", (*)=>ExitApp())

    g.Show("w400 h240")

    MsgBox

    MyText.SetText("1: Hello World!`n")
    ;MyText.Clear()
    MyText.Append("2: Hello World!`n")
    MyText.AppendLine("3: Hello World!")
    MyText.Append("4: Current Text Color: " MyText.FontColor . "`n")

    global count := 0

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

        ;MyText.Text:="Current Text Color: " MyText.FontColor "`n"
        ;MyText.Text.="Current Text Color: " MyText.FontColor "`n"
        ;MyText.SetText("Current Text Color: " MyText.FontColor)
        ;MyText.Append(count ": Current Text Color: " MyText.FontColor "`n" )
        ;MyText.AppendLine(count ": Current Text Color: " MyText.FontColor)

    }

    ButtonClear_Click(ctrl, Info) {
        global count
        count := 0
        MyText.SetText("")
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
    ; mytext := g.AddText("w400 r20", "Hello World!")
    ; g.Show()
    ; mytext.text .= "`n"
    ; mytext.text .= "changed `n" 
    ; Loop 20 {
    ;     mytext.text .= "Line " A_Index "`n"
    ; }
    ; Msgbox(myText)
    ; g.Destroy()
    ; ExitApp



 }
