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

global SF:= SharedFile("Client")

; sharedFilePath:= SF.SharedFilePath

; MsgBox "sharedFilePath: " sharedFilePath

; if !FileExist(sharedFilePath) {
;     MsgBox "Server not started!`n`nPress OK to exit.", "CLIENT"
;     ExitApp()
; }

Loop {

    IB:= InputBox("Enter Message:", "CLIENT",,"TERMINATE")

    if (IB.Result="Cancel")
        break

    SF.Write(IB.Value)
    SF.UnLock("Client")

    if (IB.Value="TERMINATE")
        break

    unlocked := SF.WaitUnLock("Server", 1000)

    if (unlocked) {
        message:= SF.Read()
        SF.Lock("Server")
        MsgBox "From Server:`n`n[" message "]", "CLIENT"  
    } else {
        MsgBox "Timeout!`n`nCheck if Server is running?", "CLIENT"
        break
    }
}

