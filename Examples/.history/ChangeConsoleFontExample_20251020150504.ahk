#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

; Create a console window if one does not exist
DllCall("AllocConsole")

; Change console window Title
ChangeConsoleTitle("Console Window")

fontNameArray := ["Cascadia Code", "Cascadia Mono", "Consolas", "Courier New", "Consolas", "Lucida Console"]

fontSizeArray := [8,10,12,14,18,20,22,24,28]

for name in fontNameArray {
    for size in fontSizeArray {
        ChangeConsoleFont(name, size/2, size)
    }
}

MsgBox("Done!", "Done!", "Ok Icon!")

ConsoleWriteLine(Text){
 FileAppend Text . "`n", "*"
}

ChangeConsoleTitle(NewTitle) {
    ; The return value is non-zero if successful. We can ignore it for a simple call.
    DllCall("SetConsoleTitle", "str", NewTitle)
}

ClearConsole() {
    RunWait( A_ComSpec ' /c cls', , 'Hide')
}

ChangeConsoleFont(FontName, FontWidth, FontHeight)
{

    ; --- Create a CONSOLE_FONT_INFOEX structure ---
    ; Structure members and their sizes (in bytes)
    ; cbSize        ULONG, 4 bytes, offset 0
    ; nFont         DWORD, 4 bytes, offset 4
    ; dwFontSize    COORD, 4 bytes, offset 8 -> X, offset 10 -> Y
    ; FontFamily    UINT,  4 bytes, offset 12
    ; FontWeight    UINT,  4 bytes, offset 16
    ; FaceName      WCHAR, 64 bytes, offset 20 -> wide character array, so 32 * 2 bytes
    ; total: 4 * 5 = 20 + 64 = 84 bytes

    ; --- Constants for Windows API Calls ---
    STD_OUTPUT_HANDLE := -11
    ; Size of CONSOLE_FONT_INFOEX structure (108 bytes on 64-bit systems)
    SIZE_OF_CFIEX := 84
    ; Offset of the Font Face Name (32 WCHARs = 64 bytes)
    OFFSET_OF_FACENAME := 20

    ; Allocate a new console window
    DllCall("AllocConsole")

    ; Get a handle to the console output
    hConsole := DllCall("GetStdHandle", "Int", STD_OUTPUT_HANDLE, "Ptr")

    ; --- 1. Prepare the CONSOLE_FONT_INFOEX structure buffer ---
    ; Allocate buffer and set cbSize member (first 4 bytes)
    cfi := Buffer(SIZE_OF_CFIEX, 0)
    NumPut("UInt", SIZE_OF_CFIEX, cfi, 0) ; Offset 0: cbSize

    success := GetCurrentConsoleFont(cfi, hConsole)

    ; modify the font family (FF_DONTCARE=Default)
    NumPut('UInt', 0, cfi, 12) ;FontFamily: 0 for FF_DONTCARE, 5 for TMPF_TRUETYPE

    ; modify the font name (Only Monospace fonts work. Courier New=Default)
    StrPut(FontName, cfi.Ptr + 20, "UTF-16")
 
    ; modify the font size (8x16=default)
    NumPut('UShort', FontWidth,  cfi, 8)   ; X value width
    NumPut('UShort', FontHeight, cfi, 10) ; Y value size

    ; modify the font weight (400=Normal, 700=Bold)
    NumPut('UInt', 400, cfi, 16)

    ; set the new font info
    result := DllCall("SetCurrentConsoleFontEx", "ptr", hConsole, "int", false, "ptr", cfi)

    if (result = 0) {
        ConsoleWriteLine "Failed to change console font. Error: " DllCall("GetLastError")
    }

    success := GetCurrentConsoleFont(cfi, hConsole)

    ; Keep the console open until the user presses Enter
    r := MsgBox('Press Enter to Continue or Cancel to Exit', 
        "Font: " FontName ", Size: " Floor(FontWidth) "x" FontHeight, "OkCancel")
    if (r = "Cancel") {
        DllCall("FreeConsole")
        ExitApp
    }

    ; prepare for the next font change
    ClearConsole()

}

GetCurrentConsoleFont(cfi, hConsole)
{
    success := DllCall("GetCurrentConsoleFontEx", 
    "Ptr", hConsole,       ; hConsoleOutput
    "Int", false,          ; bMaximumWindow (false = current size)
    "Ptr", cfi,            ; lpConsoleCurrentFontEx (output buffer)
    "Int")                 ; Return Type (BOOL)

    if (success)
    {
        ; Retrieve data from the buffer using NumGet
        FontIndex  := NumGet(cfi,  4, "Int")    ; Offset 4: nFont
        FontWidth  := NumGet(cfi,  8, "Short")  ; Offset 8: dwFontSize.X (Width)
        FontHeight := NumGet(cfi, 10, "Short")  ; Offset 10: dwFontSize.Y (Height)
        FontFamily := NumGet(cfi, 12, "Int")    ; Offset 12: FontFamily
        FontWeight := NumGet(cfi, 16, "Int")    ; Offset 16: FontWeight
        FaceName   := StrGet(cfi.Ptr + 20)      ; Offset 20: FaceName
        
        ; Output the results to the console
        ConsoleWriteLine("--- Current Console Font Info ---")
        FileAppend("--- Current Console Font Info ---`n", "*")
        FileAppend("Face Name     : " FaceName "`n", "*")
        FileAppend("Size (W x H)  : " FontWidth " x " FontHeight " pixels`n", "*")
        FileAppend("Weight        : " FontWeight " (400=Normal, 700=Bold)`n", "*")
        FileAppend("Internal Index: " FontIndex "`n", "*")
        FileAppend("---`n", "*")
    }
    else
    {
        FileAppend("Error retrieving console font info! Error: " A_LastError "`n", "*")
    }

    return success
}