#Include GuiResizer.ahk
g := Gui('+Resize +Owner')
g.Add('Edit', 'x10 y10 w400 h200 vedit')
g.Add('Button', 'x420 y10 w100 h25 vbtn1', 'Button 1')
g.Add('Button', 'w100 h25 vbtn2', 'Button 2')
g.Add('Button', 'w100 h25 vbtn3', 'Button 3')
g.Add('Edit', 'x10 y220 w200 h100 vedit2')
g.Add('Edit', 'x220 y220 w200 h100 vedit3')
params := [{ctrl:g['edit'],w:1,h:.5}, {ctrl:g['edit2'],w:.5,h:.5,y:.5}, {ctrl:g['edit3'],w:.5,h:.5,x:.5,y:.5}]
Loop 3
   params.push({ctrl:g['btn' A_Index],x:1})
resizer := GuiResizer(g, params)
g.OnEvent('Size', resizer.Set)
g.Show()
