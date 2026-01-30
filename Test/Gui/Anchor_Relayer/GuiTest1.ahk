#Requires AutoHotkey v2+
#SingleInstance force

#Include Anchor.ahk

g := Gui('+Resize +Owner')
e1:= g.Add('Edit', 'x10 y10 w400 h200 vedit')
b1 := g.Add('Button', 'x420 y10 w100 h25 vbtn1', 'Button 1')
b2:= g.Add('Button', 'w100 h25 vbtn2', 'Button 2')
b3:= g.Add('Button', 'w100 h25 vbtn3', 'Button 3')
e2:= g.Add('Edit', 'x10 y220 w200 h100 vedit2')
e3:= g.Add('Edit', 'x220 y220 w200 h100 vedit3')

g.OnEvent('Size', Gui_OnSize)
g.Show()

Gui_OnSize(GuiObj, MinMax, Width, Height) {

    redraw := false

    Anchor(GuiObj["edit"],	"wh", redraw)
    Anchor(b1, "x")
    Anchor(b2, "x")
    Anchor(b3, "x")
    Anchor(e2, "y")
    Anchor(e3, "yw")
}
