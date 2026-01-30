#Requires AutoHotkey v2+
#SingleInstance force

g := Gui('+Resize +Owner')
g.Add('Edit', 'x10 y10 w400 h200 vedit')
g.Add('Button', 'x420 y10 w100 h25 vbtn1', 'Button 1')
g.Add('Button', 'w100 h25 vbtn2', 'Button 2')
g.Add('Button', 'w100 h25 vbtn3', 'Button 3')
g.Add('Edit', 'x10 y220 w200 h100 vedit2')
g.Add('Edit', 'x220 y220 w200 h100 vedit3')

;g.OnEvent('Size', resizer.Set)
g.Show()
