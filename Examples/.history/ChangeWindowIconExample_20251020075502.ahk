#Requires AutoHotkey v2.0
#SingleInstance Force

;=============================================================================================================
; Func: ChangeWindowIcon
; Change the icon on an existing window.  Refactored from
; <http://www.autohotkey.com/board/topic/73578-changing-an-application-icon=AHK Forum>
;
; Params:
;   IconFile    - Filename for new icon.  Should be a .ICO file
;
;   WinTitle     - Standard Window Spec.  Returns "Window Not Found" if window missing, but doesn't throw error.
;
; Throws:
;   Icon file missing or invalid
;
; Returns:
;   Succes      - Nothing
;   Soft Error  - Error Description String
;-------------------------------------------------------------------------------------------------------------
ChangeWindowIcon(IconFile, WinTitle := "A") {

    hWnd  := WinExist(WinTitle)
    if (!hWnd)
        return "Window Not Found"

    hIcon := LoadPicture(IconFile, "Icon1", &IconType)

    if (!hIcon)
        Throw "Icon file missing or invalid in `nChangeWindowIcon(" IconFile ", " WinTitle ")`n`n"

    SendMessage(WM_SETICON:=0x80, ICON_SMALL2:=0, hIcon,, "ahk_id " hWnd)
    SendMessage(WM_SETICON:=0x80, ICON_BIG:=1   , hIcon,, "ahk_id " hWnd)

    if (hIcon)
        DllCall("DestroyIcon", "ptr", hIcon)
}

ChangeWindowIconFromDLL(DllOrExeFile, IconNumber, WinTitle := "A") {

    hWnd  := WinExist(WinTitle)
    if (!hWnd)
        return "Window Not Found"

    hIcon := LoadPicture(DllOrExeFile, IconNumber, &IconType)

    if (!hIcon)
        Throw "Icon file missing or invalid in `nChangeWindowIcon(" DllOrExeFile ", " WinTitle ")`n`n"

    SendMessage(WM_SETICON:=0x80, ICON_SMALL2:=0, hIcon,, "ahk_id " hWnd)
    SendMessage(WM_SETICON:=0x80, ICON_BIG:=1   , hIcon,, "ahk_id " hWnd)

    if (hIcon)
        DllCall("DestroyIcon", "ptr", hIcon)

}
If (A_LineFile == A_ScriptFullPath)  ; when run directly, not included
    DoTest_ChangeWindowIcon()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------
DoTest_ChangeWindowIcon() {

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
    MyGui := Gui(, "Change Icon")

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

    ;ChangeWindowIcon("C:\Windows\System32\OneDrive.ico", WinTitle := "A") 
    ChangeWindowIconFromDLL("C:\Windows\System32\shell32.dll", "Icon16", WinTitle := "A") 

    ; Create an instance of the ConsoleWindow class
    ;Console := ConsoleWindow(400, 300, 10, 10, "My Console Window")
    ;Console := ConsoleWindow("My Console Window", "Hello Console", 400, 200, 10, 10)

    sleep(100)
    ;Console.Move(400, 300, 10, 10)

    ; Redirect stdout to the new console window
    ;Console.WriteLine("This will appear in the new console window.")

    ButtonWriteClicked(Ctrl, Info) {
        line := "The rain in Spain falls mainly on the plain."
        msg:= line . line . line . line "`n"
        ;Console.WriteLine(msg)
    }

    ButtonClearClicked(Ctrl, Info) {
        ;Console.Clear()
    }

    ButtonCancelClicked(Ctrl, Info) {
        MyGui.Destroy()
    }

    OnGui_Close(*) {
        DllCall("FreeConsole")
        ExitApp()
    }
}
