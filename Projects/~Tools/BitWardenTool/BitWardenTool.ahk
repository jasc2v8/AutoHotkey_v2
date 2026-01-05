; TITLE  :  BitwardenTool v1.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Launch Chrome with Bitwarden Extension, then activate it.
; USAGE  :
; NOTES  :

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

ChromeTitle := "ahk_exe chrome.exe"

if WinExist(ChromeTitle) {
    WinActivate(ChromeTitle)
} else {
    Run 'chrome.exe'
    WinWaitActive(ChromeTitle)
}

; Open Bitwarden Extension
Send "^+y"




