
#Requires Autohotkey v2
;AutoGUI 2.5.8 creator: Alguimist autohotkey.com/boards/viewtopic.php?f=64&t=89901
;AHKv2converter creator: github.com/mmikeww/AHK-v2-script-converter
;Easy_AutoGUI_for_AHKv2 github.com/samfisherirl/Easy-Auto-GUI-for-AHK-v2
#Include AutoResizer.ahk
myGui := Gui()
AutoResizer(myGui) ; only function call needed

ButtonOK := myGui.Add("Button", "x16 y304 w75 h23", "&OK")
CheckBox1 := myGui.Add("CheckBox", "x16 y27 w120 h23", "CheckBox")
ComboBox1 := myGui.Add("ComboBox", "x16 yp+50 w120", ["ComboBox"])
Edit1 := myGui.Add("Edit", "x16 yp+50 w120 h21")
myGui.Add("GroupBox", "x488 y24 w120 h80", "GroupBox")
myGui.Add("Link", "x232 y24 w120 h23", "<a href=`"https://autohotkey.com`">autohotkey.com</a>")
myGui.Add("ListBox", "x230 y77 w120 h154", ["ListBox"])
ButtonOK.OnEvent("Click", OnEventHandler)
myGui.OnEvent('Close', (*) => ExitApp())
myGui.Title := "Window"
myGui.Show("w620 h420")

OnEventHandler(*)
{
	ToolTip("Click! This is a sample action.`n"
	. "Active GUI element values include:`n"  
	. "ButtonOK => " ButtonOK.Text "`n", 77, 277)
	SetTimer () => ToolTip(), -3000 ; tooltip timer
}
