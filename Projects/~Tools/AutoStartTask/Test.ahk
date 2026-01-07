; TITLE  :  AutoRun Test v1.0
; SOURCE :  kunkel321, see https://www.autohotkey.com/boards/viewtopic.php?f=82&t=137298
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Adds 'Start with Windows' checkbox to SysTray icon.
; USAGE  :  When checked, create a shortcut to this script in shell::startup folder.
;           When UNchecked, remove the shortcut.
; NOTES  :

#Requires AutoHotkey v2+
#SingleInstance

#Include AutoStart.ahk

TraySetIcon("imageres.dll", 283) ; Set task bar and tray icons to light blue Win11 start with play arrow
g:= Gui() ; create invisible gui just to show the task bar icon
WinSetTransparent(0, g.Hwnd)
g.Show()

MsgBox("Right-Click on the Tray Icon to enable/disable`n'Start with Windows'.`n`nSee the shortcut in shell::startup folder.", "AutoRun Test", "Iconi")

; The Gui keeps this script Persistent, so we need an exit
ExitApp()
