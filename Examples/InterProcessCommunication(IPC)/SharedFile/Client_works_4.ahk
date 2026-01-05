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

    ; initial state server is WaitReady, so we WaitNotReady to send a command
    timeout:= SF.WaitNotReady(-1)

    CheckTimeout(timeout, 1)

    ; get user input
    IB:= InputBox("Enter Message:", "CLIENT",,"TERMINATE")

    ; if user pressed Cancel then break out of loop to exit
    if (IB.Result="Cancel")
        break

    ; write command to server
    SF.Write(IB.Value)

    ; signal server to read command
    SF.SetReady()

    ; handle terminate command from user
    if (IB.Value="TERMINATE")
        break

    ; short delay for server to SetNotReady()
    if SF.IsReady()
        Sleep 150 ; 200
    
    ; wait for server to process command
    timeout:= SF.WaitReady(1000)

    ; read response from server
    response := SF.Read()

    ; signal server to wait for next command
    SF.SetNotReady()

    if (SubStr(response, 1, 3) != "ACK") {
        MsgBox("Server not responding.`n`nPress OK to exit.", "CLIENT")
        SF.DeleteSharedFile()
        ExitApp()
    }

    MsgBox "From Server:`n`n[" response "]", "CLIENT"  
}

CheckTimeout(timeout, number) {
    if (timeout)
        MsgBox("Timeout Number: " number , "CLIENT")
}

