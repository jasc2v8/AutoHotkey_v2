; ABOUT:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

newGuid:= CreateGUID()
A_Clipboard:= newGuid
MsgBox "Copied to Clipboard: " A_Clipboard

; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=4732
CreateGUID() {
    if !DllCall("ole32.dll\CoCreateGuid", "ptr", pguid := Buffer(16, 0)) {
        if (DllCall("ole32.dll\StringFromGUID2", "ptr", pguid, "ptr", sguid := Buffer(78, 0), "int", 78))
            return StrGet(sguid)
    }
    return ""
}