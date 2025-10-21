#Requires AutoHotkey v2.0

; Directives, keywords
#SingleInstance Force
#NoTrayIcon

; #region Create Gui

; Create a new Gui object
MyGui := Gui(, "If Result Example")
MyGui.BackColor := "4682B4" ; Steel Blue
MyGui.SetFont("S11 CBlack w480", "Segouie UI")

; Add Buttons
buttonWrite := MyGui.Add("Button", "w64", "WRITE")
;buttonStop := MyGui.Add("Button", "x+m yp W64 Default", "STOP")
buttonClear := MyGui.AddButton("x+m yp W64", "Clear")
buttonCancel := MyGui.AddButton("x+m yp W64 Default", "Cancel")

; Assign a function to be called when the button is clicked
buttonWrite.OnEvent("Click", ButtonWriteClicked)
; buttonStop.OnEvent("Click", ButtonStopClicked)
buttonClear.OnEvent("Click", ButtonClearClicked)
buttonCancel.OnEvent("Click", ButtonCancelClicked)

MyGui.OnEvent("Close", OnGui_Close)

; Show the GUI
MyGui.Show("w300")

; Create a console window if one does not exist
DllCall("AllocConsole")

ChangeConsoleTitle("Console Window")

;Sleep(100) ; wait for console to be created
;MoveConsole() ; center

Sleep(100) ; wait for console to be created
MoveConsole(600,300,10,10)

;ChangeConsoleFont("Lucida", 12, 12)
;r := ChangeConsoleFont("Times New Roman", 12, 12)
; r := ChangeConsoleFont_3()
; if (r=0)
;     ConsoleWriteLine("Error ChangeConsoleFont")

; sleep(100)
; Redirect stdout to the new console window
;ConsoleWriteLine("This will appear in the new console window.")

ConsoleWriteLine(Text){
 FileAppend Text . "`n", "*"
}

ButtonWriteClicked(Ctrl, Info) {
    ; line := "The rain in Spain falls mainly on the plain.`r`nThe quick brown fox jumped over the lazy dogs back.`r`n"
    ; msg:= line . line . line . line
    ; ConsoleWriteLine(msg)

    Result := -1
    WriteResult(Result)
    Result++
    WriteResult(Result)
    Result := "string"
    WriteResult(Result)
    Result := ""
    WriteResult(Result)

}

WriteResult(Result) {
    if (Result)
        ConsoleWriteLine("Result is true: " Result)
    else
        ConsoleWriteLine("Result is false: " Result)
}

ButtonClearClicked(Ctrl, Info) {
    ClearConsole()
}
ButtonCancelClicked(Ctrl, Info) {
 ExitApp()
}

ChangeConsoleTitle(NewTitle) {
    ; The return value is non-zero if successful. We can ignore it for a simple call.
    DllCall("SetConsoleTitle", "str", NewTitle)
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
        ;NumPut(40, MonitorInfo, 0, "Int") ; Set cbSize (first field)
        NumPut("Int", 40, MonitorInfo, 0) ; Set cbSize (first field)
        
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
