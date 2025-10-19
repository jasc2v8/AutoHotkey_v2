
#Requires AutoHotkey v2.0

MyGui := Gui(,"My Gui",)
MyGui.Add("Text", , "Question 1?")

Q1 := MyGui.Add("Edit")
MyGui.Add("Text", , "Question 2?")

Q2 := MyGui.Add("Edit")

buttonOK := MyGui.Add("Button", "Default w80", "&OK")
buttonOK.OnEvent('Click', go)

Q1.Text := "First question"
Q2.Text := "Second question"

MyGui.Show("w200")

go(btn, info) {
 ;MyGui.Hide
 OutputDebug "You Selected " Q1.Value " and " Q2.Value " from the GUI."

 OutputDebug "You Selected [" buttonOK.Value "] and [" buttonOK.Text "] from the GUI."

}


; Class Two {

; MyGui := Gui()

; C1 := MyGui.Add("ComboBox", "vColorChoice", ["Red", "Green", "Blue", "Black", "White"])

; E1 := MyGui.Add("Edit", "vMyEdit")

; B1 := MyGui.Add("Button", "xp w64 h24 vMyButton", "OK")
;         .OnEvent("Click", OnButtonOK_Click)

; B2 :=MyGui.Add("Button", "xp w64 h24 vButtonCancel", "Cancel")
;         .OnEvent("Click", OnButtonOK_Click)

; ;E1.Text :== "Hello World!"

; MyGui.Show()

; OnButtonOK_Click(GuiCtrl, *) {
;     OutputDebug(GuiCtrl.Text)

;     OutputDebug(E1.Text)

; }
; }
