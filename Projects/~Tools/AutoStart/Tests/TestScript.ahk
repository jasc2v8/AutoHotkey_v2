#Requires AutoHotkey v2+
#SingleInstance

; Choose one:
#Include AutoStart_Class.ahk
;#Include AutoStart_Function.ahk

;
; IF COMPILED
;

; If compiled with icon then don't specify IconFile and IconNumber.
; The compiled icon will be used for the Taskbar and Tray (officially called the Notification Area)
;AutoStart()

; If compiled with no icon then the AHK default icon will be in the Taskbar and Tray.
;AutoStart()

; If compiled, you can change the icon for the Shortcut only with IconFile and IconNumber.
;AutoStart(,"shell32.dll",44)

;
; IF NOT COMPILED
;

; If not compiled and you don't specify IconFile and IconNumber, the default AHK icon will be used in the Taskbar and Tray.
;AutoStart()

; If not compiled and you specify IconFile and IconNumber, the IconFile and IconNumber will be shown in Tray.
; If your script includes a gui then the IconFile and IconNumber will be shown in the Taskbar and the Gui title bar.
; If your script doesn't include a gui then a hidden gui is created by AutoStart so the IconFile and IconNumber can be shown in the Taskbar.
AutoStart(,"shell32.dll",44)

;g:= Gui()
;g.Show("w400 h200")

MsgBox("Right-Click on the Tray Icon to enable/disable`n'Start with Windows'.`n`nSee the shortcut in shell::startup folder.", "AutoStart Test", "Iconi")

; The Gui keeps this script Persistent, so we need an exit
ExitApp()