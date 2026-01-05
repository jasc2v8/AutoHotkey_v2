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

g := Gui("", "Gui Layout Example")
g.OnEvent("close", gui_exit)
;g.SetFont("s10", "Segoe UI")
g.BackColor := "4682B4" ;"0x808080" ; Gray    "4682B4" ; Steel Blue

;g.AddText("w500 h200 Border BackgroundDefault")
g.AddText("w50 h5 Border BackgroundDefault vText")

g.AddText("xm w50 h1 0x10 vLine", "Horizontal Line")  ;SS_ETCHEDHORZ

g.AddButton("w75 Default", "Left").OnEvent("click", Button_Click)
g.AddButton("w75", "Center").OnEvent("click", Button_Click)
g.AddButton("w75", "Right").OnEvent("click", Button_Click)
g.AddButton("w75", "Fill").OnEvent("click", Button_Click)
;g.AddButton("yp w75", "Cancel").OnEvent("Click", (*) => ExitApp())
;g.AddText("xm w1 h2 Hidden", "Hidden Spacer")  ;SS_ETCHEDHORZ

;g.Show("w400 h200")
g.Show("w500 h300")
;g.Show("w600 h300")

; #region Event Handlers

; WinGetPos(&guiX, &guiY, &guiW, &guiH, g)
; WinGetClientPos(&clientX, &clientY, &clientW, &clientH, g)
; inop:=true

;ControlGetPos &OutX, &OutY, &OutWidth, &OutHeight, g["Left"]
;ControlMove OutX, OutY, 100, OutHeight, g["Left"]

;GetControlPos()

ControlGetPos &OutX, &OutY, &OutWidth, &OutHeight, g["Line"]
;ControlMove OutX, OutY, 100, OutHeight, g["Fill"]

Button_Click(Ctrl, Info) {

    ; Width :   ; -1=same W/H, 0=max W/H, >0=new W/H (default=0)
    ; Height:   ; -1=same W/H, 0=max W/H, >0=new W/H (default=0)
    ;GuiLayout.Fill(g, Control, Width, Height) ; fill width

    ; ok GuiLayout.Fill(g, g["Line"], , -1)  ; fill width only
;GuiLayout.Move(x,y,w,h)
    ;GuiLayout.Move(g, g["Line"],,0,,) ; to top of Button
    ;GuiLayout.Fill(g, g["Line"], 0, -1) ;

    ; get the buttons and move to a new Y postion (or the bottom)
    ; Controls := GuiLayout.GetControls(g, "Button") ; Button, Edit, Text, etc.
    ; for control in Controls
    ;     GuiLayout.ControlMove(Control,,50)

    ; move the buttons to the bottom and Align them
    Controls := GuiLayout.GetControls(g, "Button") ; Button, Edit, Text, etc.
    Layout := Ctrl.Text
    GuiLayout.Row(g, Controls, Layout, 0)

    ;Fill(MyGui, Control, Width:=0, Height:=0 )
    ;GuiLayout.Fill(g, g["Text"], MaxWidth:=0, SameHeight:=-1)
    ;GuiLayout.Fill(g, g["Text"], MaxWidth:=0, SameHeight:=150)
    ;GuiLayout.Fill(g, g["Text"], MaxWidth:=0, Height:=200)


ControlGetPos &OutX, &OutY, &OutWidth, &OutHeight, g["Left"]

;GetRelativeY(g["Left"])

GuiLayout.ControlMove(g["Line"],,OutY-6-6,0)      ; -6 to the top of the Button, -6 margin above the button

;MY := GetControlMarginY()
GuiLayout.ControlMove(g["Text"],,,0, OutY-6-6-6-6)  ; -6 to the top of the Line, -6 margin above the line

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

GetControlPos() {

    MyGui := Gui()

; Create a button at Y100 with a requested height of 30 pixels
MyButton := MyGui.AddButton("w100 h30 y100", "My Button")

MyGui.Show()

; Retrieve the final, actual dimensions and position
MyButton.GetPos(&X, &Y, &Width, &Height)

MsgBox("Actual Button Position & Size:`n`n" . 
    "Top Y:     " Y "`n`n" .
    "Height:    " Height "`n`n" .
    "Bottom Y:  " (Y + Height))
}
GetRelativeY(Ctrl)
{
    ; 1. Get the control's position relative to the GUI window's client area (Y_Client)
    Ctrl.GetPos(, &Y_Client)
    
    ; 2. Get the GUI window's position relative to the screen (WinY)
    Ctrl.Gui.GetPos(, &WinY)
    
    ; 3. Get the current absolute mouse position on the screen (MouseY_Screen)
    ;MouseGetPos(, &MouseY_Screen)
    MouseY_Screen := 0

    ; Calculate the absolute screen Y coordinate of the control's top edge
    Y_Control_Screen := WinY + Y_Client

    MsgBox("Delta Y from Control Y to the top of the control: " Y_Control_Screen)

    ; The Y position relative to the control's top is the difference:
    Y_Relative_To_Control_Top := MouseY_Screen - Y_Control_Screen

    MsgBox("Mouse Y relative to control top: " Y_Relative_To_Control_Top)
}

ButtonSave_Click(ctl, info) {
}


gui_exit(g) {
    ExitApp
}

ButtonMonoSpace_Click(ctl, info) {
}

