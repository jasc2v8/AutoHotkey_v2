#Requires AutoHotkey v2+
#SingleInstance force

g := Gui('+Resize +Owner')

myEdit1 :=g.Add('Edit', 'x10 y10 w400 h200')
edit1Params := {ctrl: myEdit1, w: 1, h: .5}

myBtn1 := g.Add('Button', 'x420 y10 w100 h25', 'Button 1')
btn1Params := {ctrl: myBtn1, x: 1}

myBtn2 := g.Add('Button', 'w100 h25', 'Button 2')
btn2Params := {ctrl: myBtn2, x: 1}

myBtn3 := g.Add('Button', 'w100 h25', 'Button 3')
btn3Params := {ctrl: myBtn3, x: 1}

myEdit2 := g.Add('Edit', 'x10 y220 w200 h100')
edit2Params := {ctrl: myEdit2, w: .5, h: .5, y: .5}

myEdit3 := g.Add('Edit', 'x220 y220 w200 h100')
edit3Params := {ctrl: myEdit3, x: .5, y: .5, w: .5, h: .5}

;params := [edit1Params, edit2Params, edit3Params, btn1Params, btn2Params, btn3Params]
;resizer := GuiResizer(g, params)
;g.OnEvent('Size', resizer.Set)
g.Show()