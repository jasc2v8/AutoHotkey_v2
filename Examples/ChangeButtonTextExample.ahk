#Requires AutoHotkey v2.0

; --- 1. Create the GUI ---
MyGui := Gui()

; Method A: Store the returned object
Btn1 := MyGui.Add("Button", "w100", "Initial Text")
Btn1.OnEvent('Click', ChangeText1)

; Method B: Use a v-label
MyGui.Add("Button", "w100 vMyButton2", "Another Button")
MyGui["MyButton2"].OnEvent('Click', ChangeText2)

MyGui.Show()
return

; --- 2. Button Click Functions ---

; Function for the button referenced by its object variable
ChangeText1(GuiCtrl, *)
{
    ; GuiCtrl is the button object that was clicked
    GuiCtrl.Text := "Clicked! (Object)"
}

; Function for the button referenced by its v-label
ChangeText2(*)
{
    ; Access the control via the GUI object and its v-label
    MyGui["MyButton2"].Text := "Done! (v-Label)"
}