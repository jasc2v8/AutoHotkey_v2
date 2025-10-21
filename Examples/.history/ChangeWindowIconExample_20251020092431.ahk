#Requires AutoHotkey v2.0
#SingleInstance Force
#Include <Class_ConsoleWindow>

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
ChangeWindowIcon(IconFile, IconNumber, WinTitle := "A") {

    hWnd  := WinExist(WinTitle)
    if (!hWnd)
        return "Window Not Found"

    SplitPath(IconFile,,,&OutExt)

    if (OutExt = "ico")
        hIcon := LoadPicture(IconFile,IconNumber, &IconType)
    else if (OutExt = 'dll')
        hIcon := LoadPicture(IconFile, IconNumber, &IconType)
    else if (OutExt = 'exe')
        hIcon := LoadPicture(IconFile, IconNumber, &IconType)
    else
        return "Not a valid icon file (dll, exe, ico)."

    if (!hIcon)
        Throw "Icon file missing or invalid in `nChangeWindowIcon(" IconFile ", " WinTitle ")`n`n"

    SendMessage(WM_SETICON:=0x80, ICON_SMALL:=0, hIcon,, "ahk_id " hWnd)
    SendMessage(WM_SETICON:=0x80, ICON_BIG:=1  , hIcon,, "ahk_id " hWnd)

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
    ChangeWindowIcon_Test1()
    ;Test2()
    ;Test3()
}

ChangeWindowIcon_Test1() {
    Persistent

    MyGui := Gui(, "Change Icon")

    hWnd := MyGui.Hwnd
    ;hWnd := A_ScriptHwnd

    buttonReload := MyGui.Add("Button", "w64", "Reload")
    buttonCancel := MyGui.AddButton("x+m yp W64 Default", "Cancel")

    buttonReload.OnEvent("Click", ButtonReloadClicked)
    buttonCancel.OnEvent("Click", ButtonCancelClicked)

    MyGui.OnEvent("Close", OnGui_Close)

    ; Show the GUI
    MyGui.Show("w300")

    ScriptHwnd := A_ScriptHwnd
    if (!ScriptHwnd)
    return

    ; Create an instance of the ConsoleWindow class
    ;Console := ConsoleWindow()
    Console := ConsoleWindow("My Console Window", , 400, 200, 10, 10)

    ;sleep(100)
    ;Console.Move(400, 300, 10, 10)

    ; Redirect stdout to the new console window
    Console.WriteLine("MyGui.Hwnd: " hWnd)
    Console.WriteLine("ScriptHwnd: " ScriptHwnd)
    ;WinWaitActive(hWnd)
    ;Sleep(500)

    ;ChangeWindowIcon("D:\Software\DEV\Work\AHK2\Icons\under-construction.ico", "Change Icon")
    ;ChangeWindowIcon("C:\Windows\System32\OneDrive.ico", "ahk_id" hWnd) 
    ;ChangeWindowIcon("D:\Software\DEV\Work\AHK2\Icons\red-cog-24.ico", "Icon1" ,"ahk_id" hWnd) 
    r := ChangeWindowIconFromDLL("C:\Windows\System32\shell32.dll", "Icon16", "ahk_id" hWnd) 
    Console.WriteLine("r: " r)

    WinWaitClose(hWnd)
    ; Loop 10 {
    ;     Console.WriteLine("Waiting...")
    ;     Sleep(1000)
    ; }

;MsgBox()
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
