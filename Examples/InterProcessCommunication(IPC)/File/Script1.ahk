; ABOUT:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Requires AutoHotkey v2.0

global Filename:= "D:\lock.txt"

loop {

    r := MsgBox("Press OK to write a message to the Service", "Write Message", "OKCancel")
    if (r="Cancel")
        break

    try
        f := FileOpen(FileName, "w")
    catch as Err
    {
        MsgBox "Can't open '" FileName "' for writing." . "`n`n" Type(Err) ": " Err.Message
        continue
    }

    try {
        f.Write("STATUS")
    } catch Error as e {
        MsgBox "File write error: " e.Message        
    }
    f.Close

    r:= MsgBox("Press OK to read the response from the Service", "Read Message", "OKCancel")
    if (r="Cancel")
        break

    try {
        f := FileOpen(FileName, "r")
    } catch as Err {
        MsgBox "Can't open '" FileName "' for reading." . "`n`n" Type(Err) ": " Err.Message
        continue
    }

    try {
        message:= f.Read()
    } catch Error as e {
        MsgBox "File read error: " e.Message        
    }
    f.Close

    r:= MsgBox("Message from Service: " message, "Read Message", "OKCancel")
    if (r="Cancel")
        break

}
