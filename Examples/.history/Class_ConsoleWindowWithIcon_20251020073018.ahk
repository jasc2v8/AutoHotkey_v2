#Requires AutoHotkey v2.0
#SingleInstance Force

class ConsoleWindow
{
    hIcon := 0
    w:=0
    h:=0
    x:=0
    y:=0
    Title:="Console Window"

    ; Constructor method

    __New(Title:="Console Window", Text:="", w:=0, h:=0, x:=0, y:=0)
    {
        this.w := w
        this.h := h
        this.x := x
        this.y := y
        this.Title := Title

        DllCall("AllocConsole")

        ConsoleHwnd := DllCall("GetConsoleWindow", "ptr")
        if (!ConsoleHwnd)
            return

        this.SetTitle(Title)

        if (Text != "")
            this.WriteLine(Text )

        ;default is w960 h480 x0 y0
        this.Move(w, h, x, y)
  
        this.hIcon := LoadPicture("C:\Windows\System32\shell32.dll", "Icon16", &IconType)

        WM_SETICON := 0x80
        ICON_SMALL := 0
        ICON_BIG := 1

        ; Set the Small Icon (Taskbar/Title Bar)
        SendMessage(WM_SETICON, ICON_SMALL, this.hIcon,, "ahk_id " ConsoleHwnd)

        ; Set the Big Icon (Alt+Tab Switcher)
        SendMessage(WM_SETICON, ICON_BIG, this.hIcon,, "ahk_id " ConsoleHwnd)

    }

    __Delete() {
        DllCall("FreeConsole")
        if (this.hIcon != 0)
            DllCall("DestroyIcon", "ptr", this.hIcon)
        this := unset
    }

    Center() {
        this.Move()
    }

    Clear(){
        RunWait( A_ComSpec ' /c cls', , 'Hide')
    }
    SetTitle(NewTitle) {
        DllCall("SetConsoleTitle", "str", NewTitle)
    }    
    Write(Text) {
         FileAppend Text, "*"
    }
    WriteLine(Text) {
         FileAppend Text . "`n", "*"
    }
    Move(w:=0, h:=0, x:=0, y:=0) {
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
            NumPut("Int", 40, MonitorInfo, 0) ; Set cbSize (first field)
            DllCall("GetMonitorInfo", "ptr", hMonitor, "ptr", MonitorInfo)
            
            WorkLeft   := NumGet(MonitorInfo, 4,  "Int")  ; rcWork.Left
            WorkTop    := NumGet(MonitorInfo, 8,  "Int")  ; rcWork.Top
            WorkRight  := NumGet(MonitorInfo, 12, "Int") ; rcWork.Right
            WorkBottom := NumGet(MonitorInfo, 16, "Int") ; rcWork.Bottom
            
            WorkWidth  := WorkRight - WorkLeft
            WorkHeight := WorkBottom - WorkTop

            NewX := WorkLeft + ((WorkWidth - WinWidth) // 2)
            NewY := WorkTop + ((WorkHeight - WinHeight) // 2)

            ;DllCall("MoveWindow", "ptr", hConsoleWnd, "int", NewX, "int", NewY, "int", WinWidth, "int", WinHeight, "int", 1) ; 1=repaint

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
}

If (A_LineFile == A_ScriptFullPath)  ; when run directly, not included
    DoTest_ConsoleWindow()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------
DoTest_ConsoleWindow() {

    #Warn Unreachable

    ; set true to run tests, else false
    Run_Tests := true

    if !Run_Tests
        SoundBeep(), ExitApp()

    ; comment out tests to skip:
    Test1()
    ;Test2()
    ;Test3()
}

Test1() {
    ; #region Create Gui

    ; Create a new Gui object
    MyGui := Gui(, "If Result Example")
    MyGui.BackColor := "4682B4" ; Steel Blue
    MyGui.SetFont("S11 CBlack w480", "Segouie UI")

    ; Add Buttons
    buttonWrite := MyGui.Add("Button", "w64", "WRITE")
    buttonClear := MyGui.AddButton("x+m yp W64", "Clear")
    buttonCancel := MyGui.AddButton("x+m yp W64 Default", "Cancel")

    ; Assign a function to be called when the button is clicked
    buttonWrite.OnEvent("Click", ButtonWriteClicked)
    buttonClear.OnEvent("Click", ButtonClearClicked)
    buttonCancel.OnEvent("Click", ButtonCancelClicked)

    MyGui.OnEvent("Close", OnGui_Close)

    ; Show the GUI
    MyGui.Show("w300")

    ScriptHwnd := A_ScriptHwnd
    if (!ScriptHwnd)
    return

    hIcon := LoadPicture("C:\Windows\System32\shell32.dll", "Icon16", &IconType)
    ;hIcon := LoadPicture("C:\Windows\System32\OneDrive.ico", "Icon1", &IconType)

    WM_SETICON := 0x80
    ICON_SMALL := 0
    ICON_BIG := 1

    ; Set the Small Icon (Taskbar/Title Bar)
    SendMessage(WM_SETICON, ICON_SMALL, hIcon,, "If Result Example")

    ; Set the Big Icon (Alt+Tab Switcher)
    SendMessage(WM_SETICON, ICON_BIG, hIcon,, "If Result Example")

    ; Create an instance of the ConsoleWindow class
    ;Console := ConsoleWindow(400, 300, 10, 10, "My Console Window")
    Console := ConsoleWindow("My Console Window", "Hello Console", 400, 200, 10, 10)

    sleep(100)
    ;Console.Move(400, 300, 10, 10)

    ; Redirect stdout to the new console window
    Console.WriteLine("This will appear in the new console window.")

    ButtonWriteClicked(Ctrl, Info) {
        line := "The rain in Spain falls mainly on the plain."
        msg:= line . line . line . line "`n"
        Console.WriteLine(msg)
    }

    ButtonClearClicked(Ctrl, Info) {
        Console.Clear()
    }

    ButtonCancelClicked(Ctrl, Info) {
        MyGui.Destroy()
    }

    OnGui_Close(*) {
        DllCall("FreeConsole")
        ExitApp()
    }
}
