; ABOUT:    Server v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:

    The Server is intended to be run as a Windows Service and will:
        Create the shared memory, client lock, and server lock files.
        Handle the cleanup upon exit.

    The Client simply read/writes to the lock and shared memory files.
    When the Client exits, the Server will remain running.

*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include .\SharedFile.ahk

;  ;@Ahk2Exe-ConsoleApp

global SF:= SharedFile("Server")

SF.SetNotReady()

 ; timeout=true/false
; MsgBox (SF.IsReady()?"true":"false"), "AFTER"

;  timeout:= SF.WaitReady(3000)

;      if(timeout)
;          MsgBox "timeout", "timeout"
;      else
;         MsgBox "no timeout", "timeout"

;       ; timeout=true, success=false, don't wait=0Ms, wait forever=-1Ms
;      MsgBox (timeout)?"timeout":"Success", "timeout"

;  ExitApp()

Loop {

    ; wait for client to send command
    timeout:= SF.WaitReady(-1)

    ; signal client to not r/w anything
    SF.SetNotReady()

    CheckTimeout(timeout, 1)

    command:= SF.Read()

    ;SF.SetNotReady()

    response:= "ACK: " command

    ; timeout:= SF.WaitReady(1000)

    ; SF.SetNotReady()

    ; CheckTimeout(timeout, 2)

    ; if (timeout)
    ;     MsgBox "Server Timeout waiting for Client to send command.", "SERVER"\

    SF.Write(response)

    ; signal client to read response
    SF.SetReady()

    if (command = "TERMINATE") 
        break

    ; wait until client read response and set not ready
    timeout:= SF.WaitNotReady(1000)

    CheckTimeout(timeout, 2)

    ; ; wait until client has processed response and set ready
    ; timeout:= SF.WaitReady(1000)

    ; CheckTimeout(timeout, 3)

    ; ; reset ready for next command
    ; SF.SetNotReady()

    Sleep 100
}

CheckTimeout(timeout, number) {
    if (timeout)
        MsgBox("Timeout Number: " number , "SERVER")
}

SF:=""

ExitApp()
