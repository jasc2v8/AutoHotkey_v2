
#Requires Autohotkey v2
;AutoGUI 2.5.8 creator: Alguimist autohotkey.com/boards/viewtopic.php?f=64&t=89901
;AHKv2converter creator: github.com/mmikeww/AHK-v2-script-converter
;Easy_AutoGUI_for_AHKv2 github.com/samfisherirl/Easy-Auto-GUI-for-AHK-v2

myGui := Gui()
Edit1 := myGui.Add("Edit", "x24 y24 w409 h21")
Dummy1 := myGui.AddText("xm w0 h0 +Hidden") ; dummy control to start new row
;ButtonOK := myGui.Add("Button", "x476 y23 w80 h23", "&OK")

Button1 := myGui.Add("Button", "yp w80", "&Button1")
Button2 := myGui.Add("Button", "yp w80", "&Button2")
Button3 := myGui.Add("Button", "yp w80", "&Button3")
Edit1.OnEvent("Change", OnEventHandler)
Button1.OnEvent("Click", OnEventHandler)
myGui.OnEvent('Close', (*) => ExitApp())
myGui.Title := "Window"
myGui.Show("w620 h420")

;MsgBox("test")

OnEventHandler(*)
{
	ToolTip("Click! This is a sample action.`n"
	. "Active GUI element values include:`n"  
	. "Edit1 => " Edit1.Value "`n" 
	. "Button1 => " Button1.Text "`n", 77, 277)
	SetTimer () => ToolTip(), -3000 ; tooltip timer
}
