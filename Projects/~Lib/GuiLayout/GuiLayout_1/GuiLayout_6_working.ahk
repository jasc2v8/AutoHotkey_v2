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

;g.AddText("w500 h200 Border BackgroundDefault")
g.AddText("w50 h5 Border BackgroundDefault vText")

g.AddText("xm w50 h5 0x10 Border vLine", "Horizontal Line")  ;SS_ETCHEDHORZ

g.AddButton("xm w75 Default", "Left").OnEvent("click", Button_Click)
g.AddButton("yp w75", "Center").OnEvent("click", Button_Click)
g.AddButton("yp w75", "Right").OnEvent("click", Button_Click)
g.AddButton("yp w75", "Fill").OnEvent("click", Button_Click)
;g.AddButton("yp w75", "Cancel").OnEvent("Click", (*) => ExitApp())
g.AddText("xm w1 h2 Hidden", "Hidden Spacer")  ;SS_ETCHEDHORZ

g.Show("w400 h200")

; #region Event Handlers

; WinGetPos(&guiX, &guiY, &guiW, &guiH, g)
; WinGetClientPos(&clientX, &clientY, &clientW, &clientH, g)
; inop:=true


Button_Click(Ctrl, Info) {

    ; Width :   ; -1=same W/H, 0=max W/H, >0=new W/H (default=0)
    ; Height:   ; -1=same W/H, 0=max W/H, >0=new W/H (default=0)
    ;GuiLayout.Fill(g, Control, Width, Height) ; fill width

    GuiLayout.Fill(g, g["Line"], , -1)  ; fill width only
    ; ok GuiLayout.Fill(g, g["Line"], 0, -1) ; fill width only

    Controls := GuiLayout.GetControls(g, "Button") ; Button, Edit, Text, etc.
    Layout := Ctrl.Text
    GuiLayout.Row(g, Controls, Layout, 0)

    ;GuiLayout.Fill(g, g["Text"], 0, 0)
    ;GuiLayout.Fill(g, g["Text"], 0, g["Line"]) ; fill down to top of line width to default client right edge


;? WinRedraw(g)
    ;ListControls(g)

    ;Buttons := [g["Left"], g["Right"], g["Center"], g["Fill"]]

    ; Controls := GuiLayout.GetControls(g, "Button") ; Button, Edit, Text, etc.
    ; Layout := Ctrl.Text
    ; GuiLayout.Row(g, Controls, Layout)

    nop:=true
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

