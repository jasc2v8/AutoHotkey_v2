; ABOUT:    Server v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include .\SharedFile.ahk

; SharedFile

ServerFile := SharedFile("MyServerFile")
ClientFile := SharedFile("MyClientFile")
SF := SharedFile("MySharedFile")

SF.CreateLock("Client")
SF.Lock("Client")

SF.CreateLock("Server")
SF.Lock("Server")

Loop {

    SF.WaitUnLock("Client")
    message:= SF.Read()

    MsgBox "From Server: " message, "CLIENT"

    message:= "ACK"
    SF.Write(message)
    SF.UnLock("Server")

}

