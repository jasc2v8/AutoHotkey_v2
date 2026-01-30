#Requires AutoHotkey v2.0

#Include SystemCursor.ahk

MyGui := Gui(, "AppStarting Demo")
MyGui.Add("Text",, "Click the button to simulate a 3-second task.")
Btn := MyGui.Add("Button", "w100", "Start Task")
Btn.OnEvent("Click", RunLongTask)
MyGui.Show()

RunLongTask(*) {
    wc := AppStartingCursor(MyGui)
    
    wc.Start()

    Sleep(3000) 
    
    wc.Stop()
    MsgBox("Task Finished!")
}