#Requires AutoHotkey v2.0
#SingleInstance Force

#Include <ChangeWindowIcon>

class ConsoleWindowIcon
{
    hIcon := 0
    w:=0
    h:=0
    x:=0
    y:=0
    Title:="Console Window"
    static hWnd:=0

    ; Constructor method

    __New(Title:="Console Window", Text:="", w:=400, h:=200, x:=10, y:=10)
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
        else
            this.hWnd := ConsoleHwnd

        this.ChangeIcon()

        this.SetTitle(Title)

        if (Text != "")
            this.WriteLine(Text )

        ;if (0,0,0,0) then default is w960 h480 x0 y0
        this.Move(w, h, x, y)

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

    ChangeIcon(IconFile:="shell32.dll", IconNumber:="Icon16") ; blue screen terminal
    {
        hIcon := LoadPicture(IconFile, IconNumber, &IconType)
        SendMessage(WM_SETICON:=0x80, ICON_SMALL:=0, hIcon,, "ahk_id " this.Hwnd)
        SendMessage(WM_SETICON:=0x80, ICON_BIG:=1, hIcon,, "ahk_id " this.Hwnd)
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
