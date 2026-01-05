#Requires AutoHotkey v2.0
#SingleInstance Force

MyGui := Gui(, "Password Reveal Demo")

; Create the Edit control with the +Password option, so text is hidden initially
; A variable name is crucial for accessing it later.
MyEdit := MyGui.Add("Edit", "w250 vPwdControl +Password", "SecretPassword123!") 

; Button to reveal/hide the text. We use OnEvent to call the function.
MyGui.Add("Button", "y+10 w100", "Reveal Text").OnEvent("Click", TogglePassword)

MyGui.Show()
return

TogglePassword(Ctrl, *)
{
    ; Check the current options of the Edit control to see its state
    CurrentOptions := MyEdit.GetText()
    
    if InStr(CurrentOptions, "Password") ; If 'Password' option is active (text is hidden)
    {
        ; --- REVEAL TEXT ---
        ; Use -Password to REMOVE the style and show the text.
        MyEdit.Modify("-Password")
        Ctrl.Text := "Hide Text"
    }
    else ; If 'Password' option is NOT active (text is visible)
    {
        ; --- HIDE TEXT ---
        ; Use +Password to ADD the style and hide the text again.
        MyEdit.Modify("+Password")
        Ctrl.Text := "Reveal Text"
    }
    
    ; Ensure the cursor remains in the Edit control, not on the button
    MyEdit.Focus()
}