; ABOUT:    FontCompare v0.1
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  None

/*
    TODO:

*/

#Requires AutoHotkey v2.0+

g := Gui()
g.SetFont("s18")
(TxtCtrl:=[])[1] := new MyTextControlWithColorGetterSetter("text1", 1, "w100 h30 vtext1 gtext1 center border", "color1")
TxtCtrl[2] := new MyTextControlWithColorGetterSetter("text2", 1, "x+10 yp w100 h30 gtext2 vtext2 center border", "color2")
TxtCtrl[3] := new MyTextControlWithColorGetterSetter("text3", 1, "x+10 yp w100 h30 gtext3 vtext3 center border", "color3")
Loop 3
{
	TxtCtrl[a_index].setColor(["FF0000", "FF00FF", "00FFFF"][a_index])
}
g.Show(w500 h300)
return


text1:
text2:
text3:
MsgBox TxtCtrl[SubStr(A_ThisLabel, 0, 1)].getColor()
return


esc::{
gui_close:
exitapp

}

class MyTextControlWithColorGetterSetter {


	__New(__associatedOutputVar, __gui:=1, __options:="", __text:="") {
	global
	Gui, %__gui%:Add, Text, % "v" . __associatedOutputVar . A_Space . __options, % __text
	this.controlName := __associatedOutputVar, this.GUIName := __gui
	}

		setColor(__color) {
		GuiControl, % this.GUIName . ":+c" . __color, % this.controlName
		this.color := __color
		}
		getColor() {
		return this.color
		}
		
}



; class MyTextControl {
;     __New(guiControl, color) {
;         this.Control := guiControl
;         this.Color := color
;     }

;     SetColor(newColor) {
;         this.Color := newColor
;         this.Control.Opt("+c" newColor)
;     }

;     GetColor() {
;         return this.Color
;     }
; }

; MyGui := Gui()
; MyGui.Add("Text", "vMyText", "Hello World")

; ; Create an instance of MyTextControl and associate it with the GUI control
; myTextObj := MyTextControl(MyGui.GetControl("MyText"), "Black")

; MyGui.Show()

; ; Example of changing and getting the color
; myTextObj.SetColor("Red")
; MsgBox("Current text color: " myTextObj.GetColor())