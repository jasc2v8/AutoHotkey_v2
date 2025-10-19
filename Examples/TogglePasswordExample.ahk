#Requires AutoHotkey v2.0
#SingleInstance Force
g := gui()
g.setfont("s13")
edt1 := g.add("edit", "+password w300")
g.add("button",, "OK").onevent("click",tpw)
g.show()
edt1.Text := "Pa$$word"

tpw(*)
{
    
    ; static pset := 1
    ; edt1.opt((pset := !pset) ? "+Password" : "-Password")

    edt1.opt(ControlGetStyle(edt1, "A") & 0x20 ? "-Password" : "+Password")
}
