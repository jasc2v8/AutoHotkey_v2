; TITLE  :  CopyToAhkApps v1.0.0.1
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Copy Scripot open in VSCode to AhkApps
; USAGE  :
; NOTES  :

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include <String_Functions>

ahkAppsDir := "C:\Users\Jim\Documents\AutoHotkey\AhkLauncher\AhkApps\"

currentPath := GetVSCodePath()

if (currentPath = "")
    return

filename := StrSplitPath(currentPath).FileName

newPath := StrJoinPath(ahkAppsDir, filename)

;MsgBox currentPath "`n`nCopied To:`n`n" newPath, "CopyToAhkApps", "Iconi"

buttonPressed:= MsgBox("Copy:`n`n" currentPath "`n`nTo:`n`n" newPath, "CopyToAhkApps", "YesNo Icon?")

if buttonPressed = "Yes"
    FileCopy(currentPath, newPath, Overwrite:=true)


; Version 1.0.4
GetVSCodePath() {
    if !WinActive("ahk_exe Code.exe") {
        MsgBox("VS Code is not the active window.")
        return
    }

    ; Save current clipboard to restore it later
    OldClipboard := ClipboardAll()
    A_Clipboard := "" 

    ; VS Code Shortcut for "Copy Path of Active File"
    ; Default: Shift + Alt + C
    Send("+!c")

    if ClipWait(2) {
        FilePath := A_Clipboard
        A_Clipboard := OldClipboard ; Restore original clipboard
        return FilePath
    }

    A_Clipboard := OldClipboard
    return ""
}

