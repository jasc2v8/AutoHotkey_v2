#Requires AutoHotkey v2.0
#SingleInstance Force
#Include <Class_ConsoleWindow>

;=============================================================================================================
; Change the icon on an existing window. Source: https://tinyurl.com/2py768e4
; Params:
;   IconicoFile    Icon icoFilename (.dll, .exe, .ico)
;   IconNumber  Icon number in icoFile e.g. Icon1 or Icon-101
;   WinTitle    Window to change icon in.
; Throws:       Icon icoFile missing or invalid
; Returns:      Succes - Nothing '', Soft Error  - Error Description String
;-------------------------------------------------------------------------------------------------------------
ChangeWindowIcon(IconicoFile, IconNumber:="Icon1", WinTitle := "A") {

    hWnd  := WinExist(WinTitle)
    if (!hWnd)
        return "Window Not Found"

    SplitPath(IconicoFile,,,&OutExt)

    if (OutExt = "ico")
        hIcon := LoadPicture(IconicoFile,IconNumber, &IconType)
    else if (OutExt = 'dll')
        hIcon := LoadPicture(IconicoFile, IconNumber, &IconType)
    else if (OutExt = 'exe')
        hIcon := LoadPicture(IconicoFile, IconNumber, &IconType)
    else
        return "Not a valid icon icoFile (dll, exe, ico)."

    if (!hIcon)
        Throw("Icon icoFile missing or invalid: " IconicoFile)

    SendMessage(WM_SETICON:=0x80, ICON_SMALL:=0, hIcon,, "ahk_id " hWnd)
    SendMessage(WM_SETICON:=0x80, ICON_BIG:=1  , hIcon,, "ahk_id " hWnd)

    if (hIcon)
        DllCall("DestroyIcon", "ptr", hIcon)

    return ""
}

If (A_LineFile == A_ScriptFullPath)  ; when run directly, not included
    ChangeWindowIcon_Test()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------
ChangeWindowIcon_Test() {

    #Warn Unreachable

    ; set true to run tests, else false
    Run_Tests := true

    if (!Run_Tests )
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

    Console := ConsoleWindow("My Console Window", , 400, 200, 10, 10)

    hWndConsole := WinExist('A')

    ; Redirect stdout to the new console window
    Console.WriteLine("ScriptHwnd: " ScriptHwnd)
    Console.WriteLine("MyGui.Hwnd: " hWnd)
    Console.WriteLine("hWndConsole: " hWndConsole)
    
    ;r := ChangeWindowIcon("D:\Software\DEV\Work\AHK2\Icons\under-construction.ico", , "ahk_id" MyGui.Hwnd)
    ;Console.WriteLine("Result Gui Under Construction: " r)

    icoFile := "C:\Windows\SystemApps\MicrosoftWindows.Client.Core_cw5n1h2txyewy\StartMenu\Assets\UnplatedFolder\UnplatedFolder.ico"

    r :=ChangeWindowIcon(icoFile, "ahk_id" hWnd)
    Console.WriteLine("Result Gui: " r)

    r := ChangeWindowIcon(icoFile, "Icon1" ,"ahk_id" hWnd) 
    ;r := ChangeWindowIcon("C:\Windows\System32\shell32.dll", "Icon16","ahk_id" hWndConsole) 
    Console.WriteLine("Result Console: " r)

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
