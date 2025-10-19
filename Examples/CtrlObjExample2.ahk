
#Requires AutoHotkey v2.0

MyGui := Gui()

C1 := MyGui.Add("ComboBox", "vColorChoice", ["Red", "Green", "Blue", "Black", "White"])

E1 := MyGui.Add("Edit", "vMyEdit")

B1 := MyGui.Add("Button", "xp w64 h24 vMyButton", "OK")
B1.OnEvent("Click", OnButtonOK_Click)

B2 :=MyGui.Add("Button", "xp w64 h24 vButtonCancel", "Cancel")
B2.OnEvent("Click", OnButtonOK_Click)

E1.Text := "Hello World!"

MyGui.Show()

OnButtonOK_Click(GuiCtrl, *) {

    if GuiCtrl.Text = 'Cancel'
        ExitApp

    OutputDebug('c1: ' C1.Text)
    OutputDebug('e1: ' E1.Text)
    OutputDebug('b1: ' B1.Text)
    OutputDebug('b2: ' B2.Text)

}

