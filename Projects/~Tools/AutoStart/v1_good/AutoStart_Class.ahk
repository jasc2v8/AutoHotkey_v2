; TITLE  :  AutoStart_Class v1.0
; SOURCE :  kunkel321, see https://www.autohotkey.com/boards/viewtopic.php?f=82&t=137298
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Adds 'Start with Windows' checkbox to the SysTray icon.
; USAGE  :  #Include <AutoStart_Class> or #Include AutoStart_Class.ahk in your script.
;           Run your Script and right-click the tray icon to enable/disable 'Start with Windows.'
;           When checked, creates a shortcut to this script in shell::startup folder.
;           When UNchecked, removes the shortcut.
; NOTES  :  Works with YourScript.ahk or YourScript.exe.
;           Inherits User privleges so cannot bypass UAC prompt. Use AutoStartTask for that.

#Requires AutoHotkey v2+

class AutoStart {

    __New(TrayTipTimeout:=1500, TrayIcons:=False) {
        this.AutoStart(TrayTipTimeout)

        if (TrayIcons)
            this.TrayIcons()
    }

    AutoStart(TrayTipTimeout:=1500) {
        appName := (A_IsCompiled) ? StrReplace(A_ScriptName, ".exe") : StrReplace(A_ScriptName, ".ahk")
        appLink := A_Startup "\" appName ".lnk"

        A_TrayMenu.Delete
        A_TrayMenu.Add(appName, (*) => False) ; Shows name of app at menu top.
        A_TrayMenu.Add() ; Separator.
        A_TrayMenu.Add("Start with Windows", (*) => AddToStartUp()) ; Add item at menu bottom.
        A_TrayMenu.Add("Exit", (*) => ExitApp())
        A_TrayMenu.Default := appName ; Select appName making it Bold

        if FileExist(appLink) {
            A_TrayMenu.ToggleCheck("Start with Windows")
        }

        AddToStartUp(*) {	

            if FileExist(appLink) {
                FileDelete(appLink)
                A_TrayMenu.ToggleCheck("Start with Windows")
                TrayTip(appName, "AutoRun OFF")
                SetTimer(_HideTrayTip, -trayTipTimeOut) 
            } Else {
                FileCreateShortcut(A_WorkingDir "\" A_ScriptName, appLink, A_WorkingDir,,,,,)
                A_TrayMenu.ToggleCheck("Start with Windows")
                TrayTip(appName, "AutoRun ON")
                SetTimer(_HideTrayTip, -trayTipTimeOut) 
            }
            _HideTrayTip() {
                TrayTip()
            }
        }
    }

    TrayIcons() {
        ; OPTION: If no Gui in your script, then create an invisible gui just to show the task bar icon.
        TraySetIcon("imageres.dll", 283) ; Set task bar and tray icons to light blue Win11 start button with play arrow
        g:= Gui() 
        WinSetTransparent(0, g.Hwnd)
        g.Show()
    }

}
