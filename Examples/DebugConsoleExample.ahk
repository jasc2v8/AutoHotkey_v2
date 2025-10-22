#Requires AutoHotkey v2.0

; Directives, keywords
#SingleInstance Force
#NoTrayIcon

; Create a new Gui object
MyGui := Gui(, "Debug Console Example")
MyGui.BackColor := "4682B4" ; Steel Blue
MyGui.SetFont("S11 CBlack w480", "Segouie UI")

; Add a Button control to the GUI
buttonStart := MyGui.Add("Button", "w64", "START")  ; "x+5 y+5"
buttonStop := MyGui.Add("Button", "x+m yp W64 Default", "STOP")
buttonCancel := MyGui.Add("Button", "x+m yp W64 Default", "Cancel")

; Assign a function to be called when the button is clicked
buttonStart.OnEvent("Click", ButtonStartClicked)
buttonStop.OnEvent("Click", ButtonStopClicked)
buttonCancel.OnEvent("Click", ButtonCancelClicked)

; Show the GUI
MyGui.Show("w300")

; Create a console window if one does not exist
DllCall("AllocConsole")

; Redirect stdout to the new console window
ConsoleWriteLine("This will appear in the new console window.")

ConsoleWriteLine(Text){
 FileAppend Text . "`n", "*"
}

ButtonStartClicked(Ctrl, Info) {
 ConsoleWriteLine("Start button pressed.")
}

ButtonStopClicked(Ctrl, Info) {
 ConsoleWriteLine("Start button pressed.")
}

ButtonCancelClicked(Ctrl, Info) {
 ExitApp()
}

; This function is called when the window is closed
MyGui.OnEvent("Close", (*) => ExitApp())

