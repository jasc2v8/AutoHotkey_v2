; ABOUT:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

MsgBox "I will wait until lock.txt is available"
Loop {
    try {
        ; FileOpen will throw an error if the file is already being accessed
        f := FileOpen("d:\lock.txt", "a-rwd") 
        f.Write("SCRIPT2")
        f.Close()
        break
    }
    Sleep 200 ; Retry every 200 milliseconds
}
MsgBox "Script2 now has access to lock.txt"