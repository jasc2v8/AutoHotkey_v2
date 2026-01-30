#Requires AutoHotkey v2+
#SingleInstance
ESC::ExitApp()

/*
    if exe compiled with icon
        By default, the icon is shown on the taskbar and system tray, and created in the shortcut link.
        TraySetIcon will change the icon in the system tray only.
        SendMessage WM_SETICON ICON_SMALL and ICON_BIG will change the icon on the title bar and taskbar.
        Specify IconFile and IconNumber for FileCreateShortcut to change from the default.

    if ahk
        TraySetIcon sets the icon in the system tray only.
        Need to SendMessage to set taskbar icon.
        Need to specify IconFile and IconNumber for FileCreateShortcut
    
*/
;#NoTrayIcon
;
; Set Taskbar and System Tray icons from DLL file
;

g:= Gui() 
;WinSetTransparent(0, g.Hwnd)
g.Show("w400 h200")

; all OK:
;TraySetIcon("shell32.dll", 24) ; MsgBox Question
;TraySetIcon("C:\Windows\System32\OneDrive.ico")
;SetIconsFromDLL(g)

;TraySetIcon("c:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe", 2) ;1=small icon, 2=big icon
;TraySetIcon(A_ScriptFullPath)

appName := (A_IsCompiled) ? StrReplace(A_ScriptName, ".exe") : StrReplace(A_ScriptName, ".ahk")
appLink := A_Startup 

;Run(EnvGet("APPDATA") "\Microsoft\Windows\Start Menu\Programs\Startup")
;MsgBox("Opened shell::startup folder in File Explorer", "Startup", "Iconi")
FileCreateShortcut(A_WorkingDir "\" A_ScriptName, appLink, A_WorkingDir,,,,,)
MsgBox("Note in shell::startup folder: Shortcut with default AHK icon", "AHK", "Iconi")
FileCreateShortcut(A_WorkingDir "\" A_ScriptName, appLink, A_WorkingDir,,,"shell32.dll",,44) ; Gold Star
MsgBox("Note in shell::startup folder: Shortcut with Gold Star icon", "DLL", "Iconi")
FileCreateShortcut(A_WorkingDir "\" A_ScriptName, appLink, A_WorkingDir,,,"C:\Windows\System32\OneDrive.ico",,)
MsgBox("Note in shell::startup folder: Shortcut with OneDrive icon", "ICO", "Iconi")
FileCreateShortcut(A_WorkingDir "\" A_ScriptName, appLink, A_WorkingDir,,,"C:\Windows\System32\TaskMgr.exe",,)
MsgBox("Note in shell::startup folder: Shortcut with TaskMgr icon", "EXE", "Iconi")

;SetIconsFromDLL(g, "shell32.dll", 44) ; Gold Star
;SetIconsFromEXE(g, "c:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe")

;MsgBox("This is a test of AutoRun.`n`nSee the shortcut in shell::startup folder.", "Test", "Iconi")

SetIconsFromDLL(GuiCtrl, IconFile:="", IconNumber:=0) {

    IconFile:= (IconFile = "") ? "C:\Windows\System32\shell32.dll" : IconFile
    IconNumber:= (IconNumber = 0) ? 44 : IconNumber ; 44=Gold Star

    WM_SETICON := 0x80
    ICON_SMALL := 0     ; Small Icon (Title bar)
    ICON_BIG   := 1     ; Big Icon (Alt-Tab / Taskbar)

    ;TraySetIcon(IconFile, IconNumber)

    hIcon := LoadPicture(IconFile, "Icon"  IconNumber, &OutImageType)

    ; Apply big and small icons
    SendMessage(WM_SETICON, ICON_BIG,   hIcon, GuiCtrl)
    SendMessage(WM_SETICON, ICON_SMALL, hIcon, GuiCtrl)
}

SetIconsFromEXE(GuiCtrl, IconFile:="") {

    if !FileExist(IconFile)
        return


    WM_SETICON := 0x80
    ICON_SMALL := 0     ; Small Icon (Title bar)
    ICON_BIG   := 1     ; Big Icon (Alt-Tab / Taskbar)

    TraySetIcon(IconFile)

    hIcon := LoadPicture(IconFile, "Icon"  1, &OutImageType)

    ; Apply big and small icons
    SendMessage(WM_SETICON, ICON_BIG,   hIcon, GuiCtrl)
    SendMessage(WM_SETICON, ICON_SMALL, hIcon, GuiCtrl)
}
