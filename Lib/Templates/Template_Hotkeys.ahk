; TITLE  :  MyScript v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
;#NoTrayIcon

; ==============================================================================
; Environment Settings
; ==============================================================================
SetWorkingDir(A_ScriptDir)  ; Ensures a consistent starting directory
SendMode("Input")           ; Recommended for superior speed and reliability
InstallMouseHook()          ; Better detection of user activity
InstallKeybdHook()

; ==============================================================================
; Script Auto-Execute Section (Startup)
; ==============================================================================
TraySetIcon("shell32.dll", 16) ; Optional: Changes the tray icon to a star/folder

; ==============================================================================
; Global Hotkeys
; ==============================================================================

; Press Ctrl+Alt+R to quickly reload the script while editing
^!r:: {
    Reload()
}

; Press Ctrl+Alt+E to edit this script in your default editor
^!e:: {
    Edit()
}

; Example Hotkey: Win+Z to run a website
#z:: {
    Run("https://www.autohotkey.com/docs/v2/")
}

; ==============================================================================
; Context-Sensitive Hotkeys (Example)
; ==============================================================================
#HotIf WinActive("ahk_class Notepad")
; These hotkeys only work while Notepad is active
^j:: {
    Send("This text was sent specifically to Notepad.")
}
#HotIf ; Reset context sensitivity

; ==============================================================================
; Functions
; ==============================================================================
MyFunction(param) {
    MsgBox("You passed: " . param)
}
