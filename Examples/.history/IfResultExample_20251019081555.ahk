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
        
        WinLeft   := NumGet(Rect, 0, "Int")
        WinTop    := NumGet(Rect, 4, "Int")
        WinRight  := NumGet(Rect, 8, "Int")
        WinBottom := NumGet(Rect, 12, "Int")
        
        WinWidth  := WinRight - WinLeft
        WinHeight := WinBottom - WinTop

        MONITOR_DEFAULTTONEAREST := 0x00000002
        hMonitor := DllCall("MonitorFromWindow", "ptr", hConsoleWnd, "uint", MONITOR_DEFAULTTONEAREST, "ptr")
        
        MonitorInfo := Buffer(40)
        NumPut(40, MonitorInfo, 0, "Int") ; Set cbSize (first field)
        
        DllCall("GetMonitorInfo", "ptr", hMonitor, "ptr", MonitorInfo)
        
        WorkLeft   := NumGet(MonitorInfo, 4,  "Int")  ; rcWork.Left
        WorkTop    := NumGet(MonitorInfo, 8,  "Int")  ; rcWork.Top
        WorkRight  := NumGet(MonitorInfo, 12, "Int") ; rcWork.Right
        WorkBottom := NumGet(MonitorInfo, 16, "Int") ; rcWork.Bottom
        
        WorkWidth  := WorkRight - WorkLeft
        WorkHeight := WorkBottom - WorkTop

        ; 4. Calculate the new centered coordinates
        NewX := WorkLeft + ((WorkWidth - WinWidth) // 2)
        NewY := WorkTop + ((WorkHeight - WinHeight) // 2)

        ; 5. Move the console window
        ; MoveWindow(hWnd, X, Y, nWidth, nHeight, bRepaint)
        DllCall("MoveWindow", "ptr", hConsoleWnd, "int", NewX, "int", NewY, "int", WinWidth, "int", WinHeight, "int", 1) 


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




