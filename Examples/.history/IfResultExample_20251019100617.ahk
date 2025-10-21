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

Sleep(100) ; wait for console to be created
MoveConsole()

;Sleep(100) ; wait for console to be created
;MoveConsole(600,300,10,10)

;ChangeConsoleFont("Lucida", 12, 12)
;r := ChangeConsoleFont("Times New Roman", 12, 12)
; r := ChangeConsoleFont_3()
; if (r=0)
;     ConsoleWriteLine("Error ChangeConsoleFont")

; sleep(100)
; Redirect stdout to the new console window
ConsoleWriteLine("This will appear in the new console window.")

ConsoleWriteLine(Text){
 FileAppend Text . "`n", "*"
}

ButtonWriteClicked(Ctrl, Info) {
    line := "The rain in Spain falls mainly on the plain.`r`nThe quick brown fox jumped over the lazy dogs back.`r`n"
    msg:= line . line . line . line
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

ChangeConsoleFont_2(FontName, FontSizeY, FontWeight := 400)
{
    ; 1. Get the console output handle
    STD_OUTPUT_HANDLE := -11
    hConsoleOutput := DllCall("GetStdHandle", "int", STD_OUTPUT_HANDLE, "ptr")
    
    if (hConsoleOutput = 0 || hConsoleOutput = -1)
    {
        return 0 ; Failed to get handle
    }

    ; 2. Define the CONSOLE_FONT_INFOEX structure (84 bytes)
    ; Fields: cbSize, nFont, dwFontSize (X, Y), FontFamily, FontWeight, FaceName
    
    FONT_INFO_SIZE := 84
    ConsoleFontInfo := Buffer(FONT_INFO_SIZE, 0) ; Initialize buffer with zeros
    
    ; Set the size of the structure (cbSize)
    NumPut("UInt", FONT_INFO_SIZE, ConsoleFontInfo, 0) 
    
    ; Set the font size (dwFontSize - 8 bytes)
    ; FontSizeX: 0 means Auto-select best width
    NumPut("Int", 0, ConsoleFontInfo, 4*2)         ; X at offset 8
    NumPut("Int", FontSizeY, ConsoleFontInfo, 4*2 + 4) ; Y (Height) at offset 12

    ; Set the font family (FF_DONTCARE=0, FF_MODERN=48, 48|4=52 is modern monospace)
    NumPut("UInt", 52, ConsoleFontInfo, 16)        ; FontFamily at offset 16

    ; Set the font weight (e.g., 400 for Regular, 700 for Bold)
    NumPut("UInt", FontWeight, ConsoleFontInfo, 20) ; FontWeight at offset 20

    ; Set the font name (FaceName - WChar string, 32 WChars = 64 bytes)
    ; StringPut copies the UTF-16 string into the buffer at the specified offset (24)
    StrPut(FontName, ConsoleFontInfo, 24, "UTF-16") 

    ; 3. Call SetCurrentConsoleFontEx to apply the changes
    ; DllCall("SetCurrentConsoleFontEx", hConsoleOutput, bMaximumWindow, lpConsoleCurrentFontEx)
    Result := DllCall("SetCurrentConsoleFontEx", "ptr", hConsoleOutput, "int", 0, "ptr", ConsoleFontInfo)
    
    return Result
}

ChangeConsoleFont_1(FontName, FontSizeX, FontSizeY)
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

ChangeConsoleFont_3() {
    ; Get a handle to the console output.
    ; -11 is the standard output handle (STD_OUTPUT_HANDLE).
    hConsole := DllCall("GetStdHandle", "Int", -11, "Ptr")
    if hConsole == 0
    {
        ConsoleWriteLine("Failed to get console handle.")
        ExitApp
    }

    ; Create the CONSOLE_FONT_INFOEX structure.
    ; sizeof(CONSOLE_FONT_INFOEX) is 84 bytes on 64-bit systems.
    ; 84 = 4 (cbSize) + 4 (nFont) + 8 (dwFontSize) + 4 (FontFamily) + 4 (FontWeight) + 64 (FaceName).
    FontInfo := Buffer(84, 0)
    cbSize := 84

    ; Populate the structure fields.
    NumPut("UInt", cbSize, FontInfo, 0) ; cbSize (size of the struct)
    ; NumPut(0, FontInfo, 4, "UInt") ; nFont (leave as 0)
    NumPut("Int64", 0x124 << 16, FontInfo, 8) ; dwFontSize (height << 16 | width). Use Int64 for COORD type.
    NumPut("UInt", 0x36, FontInfo, 16) ; FontFamily (0x36 is FF_DONTCARE | FF_MODERN)
    NumPut("UInt", 700, FontInfo, 20) ; FontWeight (700 = bold)

    ; FaceName is a wide string (UTF-16).
    FontName := "Consolas"
    StrPut(FontName, FontInfo, 24, "UTF-16")

    ; Call the SetCurrentConsoleFontEx function.
    Result := DllCall("SetCurrentConsoleFontEx", "Ptr", hConsole, "Int", False, "Ptr", FontInfo)

    if (Result = 0) {
        LastError := DllCall("GetLastError")
        MsgBox("Error calling SetCurrentConsoleFontEx: " LastError, "Error", 16)
    }

}
OnGui_Close(*) {
    DllCall("FreeConsole")
    ExitApp()
}

ChangeConsoleFont_4() {
    ; Change the font of the active console window.

    ; --- AHK v2 Code ---

    ; Define the console font structure (CONSOLE_FONT_INFOEX)
    ; Note: These offsets are for 64-bit systems.
    ; cbSize (DWORD, 4 bytes)
    ; nFont (DWORD, 4 bytes)
    ; dwFontSize (COORD, 8 bytes)
    ; FontFamily (UINT, 4 bytes)
    ; FontWeight (UINT, 4 bytes)
    ; FaceName (WCHAR[32], 64 bytes)
    ; Total size: 88 bytes

    ConsoleFontInfoEx := Buffer(88, 0)
    DllCall("RtlZeroMemory", "ptr", ConsoleFontInfoEx, "uptr", ConsoleFontInfoEx.Size)
    NumPut("UInt", ConsoleFontInfoEx.Size, ConsoleFontInfoEx, 0)

    ; Set font family to TrueType (we don't use this, but it's part of the structure)
    NumPut("UInt", 8, ConsoleFontInfoEx, 16) ; FontFamily value

    ; Set font weight to bold (700)
    NumPut("UInt", 700, ConsoleFontInfoEx, 20) ; FontWeight

    ; Set font size. The COORD struct takes two shorts (width, height)
    NumPut("UShort", 0, ConsoleFontInfoEx, 8) ; dwFontSize.X (0 for automatic width)
    NumPut("UShort", 16, ConsoleFontInfoEx, 12) ; dwFontSize.Y (height)

    ; Set the font name (FaceName)
    ;FontName := "Cascadia Mono"
    FontName := "Arial"
    StrPut(FontName, ConsoleFontInfoEx, 24, "UTF-16")

    ; Get a handle to the standard output console.
    StdOutputHandle := DllCall("GetStdHandle", "UInt", -11, "ptr")

    ; ok ConsoleWriteLine("StdOutputHandle:" StdOutputHandle)

    ; Call SetCurrentConsoleFontEx to apply the changes.
    ; 1: hConsoleOutput (Handle to console screen buffer)
    ; 2: bMaximumWindow (Boolean: set to false)
    ; 3: lpConsoleCurrentFontEx (Pointer to CONSOLE_FONT_INFOEX)
    Result := DllCall("SetCurrentConsoleFontEx", "ptr", StdOutputHandle, "int", false, "ptr", ConsoleFontInfoEx, "int")

    ; Check if the function call was successful.
    if (Result = 0) {
        LastError := DllCall("GetLastError")
        MsgBox("Error calling SetCurrentConsoleFontEx: " LastError, "Error", 16)
    }
}
ChangeConsoleFont_5() {
    ; This script sets the font of the current console window (cmd or powershell).

    ; --- Get a handle to the console output buffer ---
    hConsole := DllCall("GetStdHandle", "int", -11, "ptr") ; -11 is STD_OUTPUT_HANDLE

    if (hConsole = -1) {
        ConsoleWriteLine "Failed to get console handle."
        ExitApp
    }

    ; --- Create a CONSOLE_FONT_INFOEX structure ---
    ; Structure members and their sizes (in bytes)
    ; cbSize (4)
    ; nFont (4)
    ; dwFontSize (8)
    ; FontFamily (4)
    ; FontWeight (4)
    ; FaceName (64) -> wide character array, so 32 * 2 bytes
    ; total: 4 + 4 + 8 + 4 + 4 + 64 = 88 bytes

    cfi := Buffer(88) ; Allocate a memory buffer for the structure.

    ;NumPut("int", 88, cfi, 0) ; Set cbSize to the structure's size.
    NumPut("UInt64", 88, cfi, 0) ; Set cbSize to the structure's size.
    ;NumPut("int", 0, cfi, 4)  ; nFont is ignored on input, so set to 0.
    NumPut("Double", 0, cfi, 4)  ; nFont is ignored on input, so set to 0.

    ; dwFontSize.Y: Set font height in pixels.
    NumPut("int", 24, cfi, 8 + 4) ; Offset 8 is dwFontSize.X, +4 for .Y

    ; FontFamily: 0 for FF_DONTCARE, 5 for TMPF_TRUETYPE
    ;NumPut("int", 5, cfi, 20) ; Set FontFamily to TMPF_TRUETYPE.
    NumPut("UInt", 5, cfi, 20) ; Set FontFamily to TMPF_TRUETYPE.

    ; FontWeight: FW_NORMAL (400) or FW_BOLD (700).
    ;NumPut("int", 700, cfi, 24) ; Set FontWeight to FW_BOLD.
    NumPut("UInt", 700, cfi, 24) ; Set FontWeight to FW_BOLD.

    ; FaceName: Set the font name (e.g., "Consolas").
    fontName := "Consolas"
    StrPut(fontName, cfi, 28, "UTF-16") ; Offset 28 for FaceName, store as UTF-16.

    ; --- Call the SetCurrentConsoleFontEx function ---
    ; Parameters: (hConsoleOutput, bMaximumWindow, lpConsoleCurrentFontEx)
    ; bMaximumWindow (false) = Set for current window size.
    result := DllCall("SetCurrentConsoleFontEx", "ptr", hConsole, "int", false, "ptr", cfi)

    if (result = 0) {
        ConsoleWriteLine "Failed to change console font. Error: " DllCall("GetLastError")
    }

    ; This script will change the font and size of the console it is run in.
    ; If run from a standard AutoHotkey script (not in a console), you need to
    ; find the target console's window handle first and pass it to DllCall.

}