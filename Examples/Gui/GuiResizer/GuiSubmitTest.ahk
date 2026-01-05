#Requires AutoHotkey v2.0
MyGui := Gui(, "Simple Input Example")
MyGui.Add("Text","vFirst_name", "First name:")
MyGui.Add("Text","vLast_name", "Last name:")
MyGui.Add("Edit", "vFirstName ym").OnEvent('change', updateColor.Bind(MyGui['First_name']))
MyGui.Add("Edit", "vLastName").OnEvent('change', updateColor.Bind(MyGui['Last_name']))
MyGui.Add("Button", "default", "OK").OnEvent("Click", ProcessUserInput)
MyGui.OnEvent("Close", ProcessUserInput)
MyGui.Show()

updateColor(changeObj, *)
{
	changeObj.Opt("cRed")
}

ProcessUserInput(*)
{
    Saved := MyGui.Submit()  ; Save the contents of named controls into an object.
    MsgBox("You entered '" Saved.FirstName " " Saved.LastName "'.")
}