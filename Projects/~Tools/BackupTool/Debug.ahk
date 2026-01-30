; Version 1.0.4

MyGui := Gui()
MyGui.Add("Button", "vBtn1", "Button 1")
MyGui.Add("Button", "vBtn2", "Button 2")
MyGui.Add("Edit", "vEdit1", "This will stay enabled")
MyGui.Add("Button", "vBtn3", "Button 3")
MyGui.Show()

Sleep(1000) ; Wait 1 second before disabling

; Loop through all controls in the Gui object
for GuiCtrlObj in MyGui
{
    ; Check if the control is a Button
    if (GuiCtrlObj.Type = "Button")
    {
        MsgBox GuiCtrlObj.Text

        GuiCtrlObj.Enabled := false
    }
}