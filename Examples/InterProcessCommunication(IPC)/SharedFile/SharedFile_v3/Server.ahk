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

    response:= ""

    command:= SF.WaitRead(-1)

    if (command = "")
        MsgBox "Server Timeout waiting for Client to send command.", "SERVER"
    else if (command = "STATUS")
        response:= "OK"
    else 
        response:= "ACK: " command

    timeout:= SF.WaitWrite(response)

    if(timeout)
        MsgBox "Server Timeout waiting to write to Client.", "SERVER"

    if (command = "TERMINATE") 
        break

    Sleep 100
}

SF:=""

ExitApp()
