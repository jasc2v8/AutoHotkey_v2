#Requires AutoHotkey v2.0

; Directives, keywords
#SingleInstance Force
#NoTrayIcon

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

;ChangeConsoleFont("Lucida", 12, 12)
r := ChangeConsoleFont("Times New Roman", 12, 12)
if (r=0)
    ConsoleWriteLine("Error ChangeConsoleFont")

ChangeConsoleTitle("Console Window")

Sleep(100) ; wait for console to be created
MoveConsole()

Sleep(1000) ; wait for console to be created
MoveConsole(600,200,10,10)

; Redirect stdout to the new console window
ConsoleWriteLine("This will appear in the new console window.")
ConsoleWriteLine("cls")

ConsoleWriteLine(Text){
 FileAppend Text . "`n", "*"
}

ButtonWriteClicked(Ctrl, Info) {
    line := "The rain in Spain falls mainly on the plain. The quick brown fox jumped over the lazy dogs back. "
    msg:= line . line . line . line
    msg := "1.    Is this a monospace font?`n2.    Is this a monospace font?`n3.    Is this a monospace font?"
    ConsoleWriteLine(msg)
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

ChangeConsoleFont(FontName, FontSizeX, FontSizeY)
{
    ; 1. Get the console output handle
    STD_OUTPUT_HANDLE := -11
    hConsoleOutput := DllCall("GetStdHandle", "int", STD_OUTPUT_HANDLE, "ptr")
    
    if (hConsoleOutput = 0 || hConsoleOutput = -1)
    {
        return ; Failed to get handle
    }

    ; 2. Define the CONSOLE_FONT_INFOEX structure (Size: 84 bytes)
    ; We need to fill this structure with the desired font information.
    ; Fields: cbSize, nFont, dwFontSize (X, Y), FontFamily, FontWeight, FaceName
    
    FONT_INFO_SIZE := 84
    ConsoleFontInfo := Buffer(FONT_INFO_SIZE)
    NumPut("UInt", FONT_INFO_SIZE, ConsoleFontInfo, 0) ; cbSize (4 bytes)
    
    ; dwFontSize (X and Y coordinates, 8 bytes total)
    NumPut("Int", FontSizeX, ConsoleFontInfo, 4*2) ; X at offset 8
    NumPut("Int", FontSizeY, ConsoleFontInfo, 4*2 + 4) ; Y at offset 12

    ; FontFamily (Raster or Truetype) - 52 (FF_DONTCARE | FF_MODERN) is typical for TrueType
    NumPut("UInt", 52, ConsoleFontInfo, 16) ; FontFamily at offset 16 (4 bytes)

    ; FontWeight (e.g., 400 for Normal, 700 for Bold)
    NumPut("UInt", 400, ConsoleFontInfo, 20) ; FontWeight at offset 20 (4 bytes)

    ; FaceName (WChar string, 32 WChars = 64 bytes)
    ; StringPut copies the UTF-16 string into the buffer at the specified offset (24)
    StrPut(FontName, ConsoleFontInfo, 24, "UTF-16") 

    ; 3. Call SetCurrentConsoleFontEx to apply the changes
    ; DllCall("SetCurrentConsoleFontEx", hConsoleOutput, bMaximumWindow, lpConsoleCurrentFontEx)
    Result := DllCall("SetCurrentConsoleFontEx", "ptr", hConsoleOutput, "int", 0, "ptr", ConsoleFontInfo)
    
    return Result
}

OnGui_Close(*) {
    DllCall("FreeConsole")
    ExitApp()
}

