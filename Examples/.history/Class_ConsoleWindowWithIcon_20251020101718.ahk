#Requires AutoHotkey v2.0
#SingleInstance Force

;#Include <ChangeWindowIcon>

class ConsoleWindow
{
    hIcon := 0
    w:=0
    h:=0
    x:=0
    y:=0
    Title:="Console Window"
    static hWnd:=0

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

        this.hWnd := WinExist(Title)

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
    ConsoleWindowWithIcon_Test()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------

ConsoleWindowWithIcon_Test() {

    #Warn Unreachable

    ; set true to run tests, else false
    Run_Tests := true

    if (!Run_Tests )
        SoundBeep(), ExitApp()

    ; comment out tests to skip:
    ConsoleWindowWithIcon_Test()
    ;Test2()
    ;Test3()
}

ConsoleWindowWithIcon_Test1() {
    
    MyGui := Gui(, "Change Icon")

    buttonReload := MyGui.Add("Button", "w64", "Reload")
    buttonCancel := MyGui.AddButton("x+m yp W64 Default", "Cancel")

    buttonReload.OnEvent("Click", ButtonReloadClicked)
    buttonCancel.OnEvent("Click", ButtonCancelClicked)

    MyGui.OnEvent("Close", OnGui_Close)

    ; Show the GUI
    MyGui.Show("w300")

    Console := ConsoleWindow("My Console Window", , 400, 200, 10, 10)

    Console.hWnd := WinExist('A')

    ; Redirect stdout to the new console window
    Console.WriteLine("MyGui.Hwnd : " MyGui.Hwnd)
    Console.WriteLine("hWndConsole: " Console.hWnd)
    
    ;r := ChangeWindowIcon("D:\Software\DEV\Work\AHK2\Icons\under-construction.ico", , "ahk_id" MyGui.Hwnd)
    ;Console.WriteLine("Result Gui Under Construction: " r)

    icoFile := "C:\Windows\SystemApps\MicrosoftWindows.Client.Core_cw5n1h2txyewy\StartMenu\Assets\UnplatedFolder\UnplatedFolder.ico"

    r :=ChangeWindowIcon(icoFile, , "ahk_id" MyGui.hWnd)
    Console.WriteLine("Result Gui: " r)

    ;r := ChangeWindowIcon(icoFile, "Icon1" ,"ahk_id" Console.hWnd) 
    r := ChangeWindowIcon("C:\Windows\System32\shell32.dll", "Icon16","ahk_id" Console.hWnd) 
    Console.WriteLine("Result Console: " r)

    WinWaitClose(MyGui.hWnd)

    ; #region Functions

    ButtonReloadClicked(Ctrl, Info) {
        Reload()
    }

    ButtonCancelClicked(Ctrl, Info) {
        OnGui_Close()
    }

    OnGui_Close(*) {
        ;MsgBox('OnGui_Close')
        DllCall("FreeConsole")
        ExitApp()
    }
}
