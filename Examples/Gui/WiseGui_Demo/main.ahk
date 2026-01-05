; main.ahk

#Requires AutoHotkey v2.0
#Warn
#SingleInstance

#Include "WiseGui.ahk"
#Include "SplashClock.ahk"

; Use Hotkey Win+F2 to show/hide the clock.

#F2:: WinExist("WiseGui\SplashClock ahk_class AutoHotkeyGUI")
    ? WinClose()
    : Splashclock()

; Use  Hotkey Win+F3 to exit application.

#F3:: ExitApp
