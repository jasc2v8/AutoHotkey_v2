; ABOUT:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

TestGui2()

TestGui() 
	{
    g := Gui()
    g.Add("Text",,"Pick one:")
    ddl := g.AddDropDownList("w200", ["One", "Two", "Three"])
    btn := g.AddButton("w100 Default", "OK")
	btn.OnEvent("Click", (*) => (MsgBox("You picked: " ddl.Text), g.Destroy()))       ;() instead of {}
    g.Show()
	}

TestGui2() 
{
g := Gui()
g.Add("Text",,"Pick one:")
ddl := g.AddDropDownList("w200", ["One", "Two", "Three"])
btn := g.AddButton("w100 Default", "OK")
btn.OnEvent("Click", (*) => (
    MsgBox("You picked: " ddl.Text)
    g.Destroy()
    ))       ;() instead of {}
g.Show()
}
