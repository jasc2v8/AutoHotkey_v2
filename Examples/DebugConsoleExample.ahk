#Requires AutoHotkey v2.0

/**
 * TODO:
 *  main.ahk
 *  CON := ClassDebugConsole.ahk
 *  CON.Write(String)
 * 
 *  or find window and control then settext?
 * 
 *  CON.Destroy
 * 
 */
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

; verify and resize
ConsoleHandle := DllCall("GetConsoleWindow", "Ptr")

OutputDebug("ConsoleHandle: " ConsoleHandle)

; Check if a console window was successfully created
if (ConsoleHandle)
{
    ; 2. Define the new size (Width, Height) in pixels
    NewWidth := 600
    NewHeight := 400
    
    ; 3. Use WinMove to set the new size (and position if needed)
    ; WinMove(X, Y, Width, Height, WinTitle)
    ;WinMove(, , NewWidth, NewHeight, "ahk_id " ConsoleHandle)
    WinMove(10, 10, NewWidth, NewHeight, "ahk_id " ConsoleHandle)
    
    ; Optional: Set the console window title to make it easier to find
    DllCall("SetConsoleTitle", "Str", "My Resized AHK Console")
    
    ; Write some text to the console (requires output stream to be set up)
    ; This part shows the console is active, but WinMove works on the window itself.
    FileAppend("Console window resized to " NewWidth "x" NewHeight " pixels.`n", "CONOUT$")
    
    ; Keep the script running to see the console
    MsgBox "Console window created and resized. Press OK to close the script and free the console."
    
    ; Clean up: Free the console when done
    DllCall("FreeConsole")
}
else
{
    MsgBox "Failed to allocate console."
}
Exit

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

