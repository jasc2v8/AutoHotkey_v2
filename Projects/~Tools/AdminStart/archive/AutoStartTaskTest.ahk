; TITLE  :  AutoStartTest v1.0
; SOURCE :  kunkel321, see https://www.autohotkey.com/boards/viewtopic.php?f=82&t=137298
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Adds 'Start with Windows' checkbox to SysTray icon.
; USAGE  :  When checked, create a shortcut to this script in shell::startup folder.
;           When UNchecked, remove the shortcut.

#Requires AutoHotkey v2+
#SingleInstance

; Choose only one, Class or Function:
#Include AutoStart_Class.ahk
;#Include AutoStart_Function.ahk

AutoStart(, TrayIcons:=True)

MsgBox("Right-Click on the Tray Icon to enable/disable`n'Start with Windows'.`n`nSee the shortcut in shell::startup folder.", "AutoStart Test", "Iconi")

; The Gui keeps this script Persistent, so we need an exit
ExitApp()
