#Requires AutoHotkey v2.0
MyGui := Gui(, "Simple Input Example")
MyGui.Add("Text","VFirst_name", "First name:")
MyGui.Add("Text",, "Last name:")
MyGui.Add("Edit", "vFirstName ym") .OnEvent('change', updateColor)
MyGui.Add("Edit", "vLastName") .OnEvent('change', updateColor)
MyGui.Add("Button", "default", "OK").OnEvent("Click", ProcessUserInput)
MyGui.OnEvent("Close", ProcessUserInput)
MyGui.Show()

updateColor(GuiCtrlObj, *)
{
	GuiCtrlObj.Opt("cRed")
}

ProcessUserInput(*)
{
    Saved := MyGui.Submit()  ; Save the contents of named controls into an object.
    MsgBox("You entered '" Saved.FirstName " " Saved.LastName "'.")
}