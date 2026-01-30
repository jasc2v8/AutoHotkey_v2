#Requires AutoHotkey v2+
#SingleInstance force

#Include Anchor.ahk
;#Include <Anchor>

g := Gui('+Resize +Owner')
e1:= g.Add('Edit', 'x10 y10 w400 h200 vedit')
b1 := g.Add('Button', 'x420 y10 w100 h25 vbtn1', 'Button 1')
b2:= g.Add('Button', 'w100 h25 vbtn2', 'Button 2')
b3:= g.Add('Button', 'w100 h25 vbtn3', 'Button 3')
e2:= g.Add('Edit', 'x10 y220 w200 h100 vedit2')
e3:= g.Add('Edit', 'x220 y220 w200 h100 vedit3')

b3.OnEvent('Click', b3_Click)
g.OnEvent('Size', Gui_Size)
g.Show()

Gui_Size(*) {

    redraw := true

    Anchor(e1, "wh", redraw)
    Anchor(b1, "x", redraw)
    Anchor(b2, "x", redraw)
    Anchor(b3, "x", redraw)
    Anchor(e2, "y", redraw)
    Anchor(e3, "yw", redraw)
}

b3_Click(*) {
    SoundBeep
    Anchor_Reset(CtrlObj := "All")
}