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

global SF:= SharedFile("Client", "MySharedFileName", "UTF-16")


;SF.Write("TERMINATE")

;SF.MyLockName:= "Client"
;SF.SetSkipDelete(True)

;MsgBox SF.SharedFilePath, "DEBUG"
;MsgBox SF.SharedFilePath, "DEBUG"

; MsgBox "MyStaticClass: " MyStaticClass.getProperty()

sharedFilePath:= SF.SharedFilePath

MsgBox "sharedFilePath: " sharedFilePath

if !FileExist(sharedFilePath) {
    MsgBox "Server not started!`n`nPress OK to exit.", "CLIENT"
    ExitApp()
}


; no SF.CreateLock("Client")
; no SF.CreateLock("Server")

;TODO check if server running?
; if the lock and shared memory files exist that is a good indication that the server is running

;PID:= FileRead(SF.GetLockFilename("Server"))
;MsgBox "PID: " PID
; if !ProcessExist(PID) {
;     MsgBox "Server not running!`n`nPress OK to exit.", "CLIENT"
;     ;ExitApp()
; }

Loop {

    IB:= InputBox("Enter Message:", "CLIENT",,"TERMINATE")

    if (IB.Result="Cancel")
        break

    SF.Write(IB.Value)
    SF.UnLock("Client")

    ;if (IB.Value = "TERMINATE") {
        ;unlocked := SF.WaitUnLock("Server", 1000)
        ;break
    ;}

    ;unlocked := SF.WaitMessageReady("Server", 1000)

    unlocked := SF.WaitUnLock("Server", 1000)

    ;MsgBox unlocked, "DEBUG"

    if (unlocked) {
        message:= SF.Read()
        SF.Lock("Server")
        MsgBox "From Server:`n`n[" message "]", "CLIENT"  
    } else {
        MsgBox "Timeout!`n`nCheck if Server is running?", "CLIENT"
        break
    }

}

