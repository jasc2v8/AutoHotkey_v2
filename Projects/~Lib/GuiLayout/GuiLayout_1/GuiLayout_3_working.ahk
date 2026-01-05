/************************************************************************
 * @description GuiLayoutExample
 * @source 
 * @author jasc2v8
 * @date 2025/11/14
 * @version 0.0.1
 ***********************************************************************/

/*
    add edit and button
    add buttons

    Row AlignRight button to the right side
    Fill the edit to the button.

    Row AlignRight buttons

*/

; #region TEST

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon
;endregion

#Include GuiLayout.ahk
;DEBUG
Escape:: ExitApp()

; #region Globals


; #region Gui Create

g := Gui("", "Compare Fonts")
g.OnEvent("close", gui_exit)
g.SetFont("s10", "Segoe UI")
g.BackColor := "4682B4" ;"0x808080" ; Gray    "4682B4" ; Steel Blue

g.AddText("w500 h200 Border BackgroundDefault")
; when ready to test Fill: g.AddText("w5 h5 Border BackgroundDefault")
g.AddText("xm w2 h2 0x10 vLine", "Horizontal Line")  ;SS_ETCHEDHORZ
g.AddButton("xm w75 Default", "Left").OnEvent("click", Button_Click)
g.AddButton("yp w75", "Center").OnEvent("click", Button_Click)
g.AddButton("yp w75", "Right").OnEvent("click", Button_Click)
g.AddButton("yp w75", "Fill").OnEvent("click", Button_Click)
;g.AddButton("yp w75", "Cancel").OnEvent("Click", (*) => ExitApp())
g.AddText("xm w1 h2 Hidden", "Hidden Spacer")  ;SS_ETCHEDHORZ

g.Show()

; good
GuiLayout.Fill(g, g["Line"])

;GuiLayout._GetDimensions(g)

; Sleep 2000
; SoundBeep
; GuiLayout.Row(g, [g["Mono"], g["Save"], g["Load"], g["Cancel"]], "AlignLeftt")
; Sleep 2000
; SoundBeep
; GuiLayout.Row(g, [g["Left"], g["Right"], g["Center"], g["Fill"]], "AlignFill")
; Sleep 2000
; SoundBeep
; GuiLayout.Row(g, [g["Mono"], g["Save"], g["Load"], g["Cancel"]], "AlignCenter")
; Sleep 2000
; SoundBeep
;GuiLayout.Row(g, [g["Mono"], g["Save"], g["Load"], g["Cancel"]], "AlignRight")

; #region Event Handlers


Button_Click(Ctrl, Info) {

    ;ListControls(g)

    ;Buttons := [g["Left"], g["Right"], g["Center"], g["Fill"]]

    Controls := GuiLayout.GetControls(g, "Button") ; Button, Edit, Text, etc.

    Layout := Ctrl.Text

    GuiLayout.RowTest(g, Controls, Layout)

    ; NO equals  : AlignLeft, AlignCenter, AlignRight, AlignFill
    ; starts  : L         C            R           F
    ; starts  : LeftToRight          C            RightToLeft           F
   ; contains: Left       Center       Right       Fill


    ;L
    ;Left
}

ButtonSave_Click(ctl, info) {
}


gui_exit(g) {
    ExitApp
}

ButtonMonoSpace_Click(ctl, info) {
}

