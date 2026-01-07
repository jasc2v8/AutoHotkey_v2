; TITLE  :  AutoRun v1.0
; SOURCE :  kunkel321, see https://www.autohotkey.com/boards/viewtopic.php?f=82&t=137298
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Adds 'Start with Windows' checkbox to the SysTray icon.
; USAGE  :  When checked, create a shortcut to this script in shell::startup folder.
;           When UNchecked, remove the shortcut.
; NOTES  :

#Requires AutoHotkey v2+
#SingleInstance
; #Include <AutoRun> or AutoRun.ahk in your script.
appName := StrReplace(A_ScriptName, ".ahk")
A_TrayMenu.Delete
A_TrayMenu.Add(appName, (*) => False) ; Shows name of app at top of menu.
A_TrayMenu.Add() ; Separator.
A_TrayMenu.Add("Start with Windows", (*) => AddToStartUp()) ; Add menu item at the bottom.
A_TrayMenu.Add("Exit", (*) => ExitApp())
A_TrayMenu.Default := appName ; Select appName making it Bold

if FileExist(A_Startup "\" appName ".lnk") {
    A_TrayMenu.ToggleCheck("Start with Windows")
}

AddToStartUp(*) {	
    if FileExist(A_Startup "\" appName ".lnk") {
        FileDelete(A_Startup "\" appName ".lnk")
        A_TrayMenu.ToggleCheck("Start with Windows")
        TrayTip(appName, "AutoRun OFF")
        SetTimer(_HideTrayTip, -3000) 
    } Else {
        if (A_IsCompiled)
            ext := ".exe"
        else
            ext := ".ahk"
        FileCreateShortcut(A_WorkingDir "\" appName . ext, A_Startup "\" appName ".lnk", A_WorkingDir,,,,,)
        A_TrayMenu.ToggleCheck("Start with Windows")
        TrayTip(appName, "AutoRun ON")
        SetTimer(_HideTrayTip, -3000) 
    }
    _HideTrayTip() {
        TrayTip() ; Calling with no arguments clears the current notification
    }
}

