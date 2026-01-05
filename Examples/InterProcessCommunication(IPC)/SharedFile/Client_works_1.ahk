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
;MsgBox (SF.IsReady()?"true":"false"), "CLIENT"

Loop {

    ; initial state signals client to send a command
    ; yes, it seems like this should be wait ready, but this works
    timeout:= SF.WaitNotReady(-1)
    CheckTimeout(timeout, 1)

    ; initial state signals server not to r/w
    ;SF.SetNotReady()

    IB:= InputBox("Enter Message:", "CLIENT",,"TERMINATE")

    if (IB.Result="Cancel")
        break

    ; write command to server
    SF.Write(IB.Value)

    ; signal server to read command
    SF.SetReady()

    if (IB.Value="TERMINATE")
        break

    ; wait for server to read command
    ;timeout:= SF.WaitNotReady(1000)

    ; wait for server to process command
    timeout:= SF.WaitReady(1000)

    ; read response from server
    response := SF.Read()

    SF.SetNotReady()

    MsgBox "From Server:`n`n[" response "]", "CLIENT"  
}

CheckTimeout(timeout, number) {
    if (timeout)
        MsgBox("Timeout Number: " number , "CLIENT")
}

