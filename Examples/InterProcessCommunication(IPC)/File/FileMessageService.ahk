; ABOUT:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

global Filename:= "D:\lock.txt"

Loop {

    try {
        f := FileOpen(Filename, "r") 
        message:= f.Read()
        f.Close()
    } catch Error as e {
        MsgBox "SERVICE: File read error: " e.Message
        continue       
    }

    if (message="STATUS") {

        f := FileOpen(Filename, "w")
         
        f.Write("Recived from User: " message)

        f.Close()
    }

     Sleep 1000

}
