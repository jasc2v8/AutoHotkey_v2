#Requires AutoHotkey v2.0

#Include WaitCursor_1.ahk

MyGui := Gui(, "Restricted WaitCursor")
MyGui.Add("Text", "w250", "While processing, the wait cursor only shows here.")
Btn := MyGui.Add("Button", "w100", "Start Task")
BtnCancel := MyGui.Add("Button", "xm w100", "Cancel")
SB := MyGui.AddStatusBar("")

Btn.OnEvent("Click", RunLongTask)

BtnCancel.OnEvent("Click", (*) => ExitApp())

MyGui.Show()

RunLongTask(*) {

    SB.Text:="   Running..."
    ; Pass the Gui object so the class knows which window to target
    WaitCursor.Start() ; MyGui
    
    ; Simulate a background task
    Sleep(5000) 
    
    WaitCursor.Stop()
    ;MsgBox("Task Finished!")

    SB.Text:="   Stopped..."
}

;wc := WaitCursor(MyGui)
;wc.Start()
;wc.Stop()