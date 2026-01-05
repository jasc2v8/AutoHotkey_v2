; ABOUT:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

; Clear registry value
RegWrite "", "REG_SZ", "HKEY_CURRENT_USER\SOFTWARE\AHKScripts", "IpcRegistryService"

SetTimer(ReadMap, 1000)

ReadMap() {

    message := RegRead("HKEY_CURRENT_USER\SOFTWARE\AHKScripts", "IpcRegistryService", "")

    if (message = "TERMINATE")
        SetTimer , 0

    if (message != "") {
        ;MsgBox(message)
        FileAppend("[" message "]" "`n", "D:\IpcRegistryService.txt")
    }


}