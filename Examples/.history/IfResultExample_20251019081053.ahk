#Requires AutoHotkey v2.0

; Directives, keywords
#SingleInstance Force
#NoTrayIcon

; Create a new Gui object
MyGui := Gui(, "If Result Example")
MyGui.BackColor := "4682B4" ; Steel Blue
MyGui.SetFont("S11 CBlack w480", "Segouie UI")

; Add Buttons
;buttonStart := MyGui.Add("Button", "w64", "START")  ; "x+5 y+5"
;buttonStop := MyGui.Add("Button", "x+m yp W64 Default", "STOP")
buttonClear := MyGui.AddButton("x+m yp W64", "Clear")
buttonCancel := MyGui.AddButton("x+m yp W64 Default", "Cancel")

; Assign a function to be called when the button is clicked
; buttonStart.OnEvent("Click", ButtonStartClicked)
; buttonStop.OnEvent("Click", ButtonStopClicked)
buttonClear.OnEvent("Click", ButtonClearClicked)
buttonCancel.OnEvent("Click", ButtonCancelClicked)

MyGui.OnEvent("Close", (*) => ExitApp())

; Show the GUI
MyGui.Show("w300 x10 y10")

; Create a console window if one does not exist
DllCall("AllocConsole")

Sleep(1000) ; wait for console to be created
MoveConsole()

; Redirect stdout to the new console window
ConsoleWriteLine("This will appear in the new console window.")
ConsoleWriteLine("cls")

ConsoleWriteLine(Text){
 FileAppend Text . "`n", "*"
}

ButtonStartClicked(Ctrl, Info) {
 ConsoleWriteLine("Start button pressed.")
}

ButtonStopClicked(Ctrl, Info) {
 ConsoleWriteLine("Start button pressed.")
}

ButtonClearClicked(Ctrl, Info) {
    ClearConsole()
}
ButtonCancelClicked(Ctrl, Info) {
 ExitApp()
}

ClearConsole() {
    RunWait( A_ComSpec ' /c cls', , 'Hide')
}

MoveConsole(w:=0, h:=0, x:=0, y:=0) {
    hConsoleWnd := DllCall("GetConsoleWindow", "ptr")
    if (!hConsoleWnd)
        return

    if(w+h+x+y = 0) {
        ;center window
        Rect := Buffer(16)
        DllCall("GetWindowRect", "ptr", hConsoleWnd, "ptr", Rect)
        
        ; Extract the window's width and height
        WinWidth  := NumGet(Rect, 8, "Int") - NumGet(Rect, 0, "Int") ; Right - Left
        WinHeight := NumGet(Rect, 12, "Int") - NumGet(Rect, 4, "Int") ; Bottom - Top

        ; Get the screen work area coordinates (MONITORINFO structure: 40 bytes)
        ; This is the usable screen space, excluding the taskbar.
        hMonitor := DllCall("MonitorFromWindow", "ptr", hConsoleWnd, "uint", 2) ; MONITOR_DEFAULTTONEAREST
        MonitorInfo := Buffer(40)
        NumPut(40, MonitorInfo, 0, "Int") ; Set cbSize
        DllCall("GetMonitorInfo", "ptr", hMonitor, "ptr", MonitorInfo)
        
        ; Extract the work area dimensions (rcWork is at offset 4)
        WorkLeft   := NumGet(MonitorInfo, 4,  "Int") ; rcWork.Left
        WorkTop    := NumGet(MonitorInfo, 8,  "Int") ; rcWork.Top
        WorkRight  := NumGet(MonitorInfo, 12, "Int") ; rcWork.Right
        WorkBottom := NumGet(MonitorInfo, 16, "Int") ; rcWork.Bottom
        
        WorkWidth  := WorkRight - WorkLeft
        WorkHeight := WorkBottom - WorkTop

        ; 3. Calculate the new centered coordinates
        NewX := WorkLeft + ((WorkWidth - WinWidth) // 2)
        NewY := WorkTop + ((WorkHeight - WinHeight) // 2)

        ; Ensure coordinates are not negative (shouldn't happen with work area, but good practice)
        NewX := (NewX < 0) ? 0 : NewX
        NewY := (NewY < 0) ? 0 : NewY

    } else {
        NewX := x
        NewY := y
        WinWidth  := w
        WinHeight := h
    }
    ;move and resize window
    DllCall("MoveWindow", 
        "ptr", hConsoleWnd, "int", NewX, "int", NewY, 
        "int", WinWidth, "int", WinHeight, "int",
        1) ; 1 means repaint the window
}




