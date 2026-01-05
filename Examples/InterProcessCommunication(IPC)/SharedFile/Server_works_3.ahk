; ABOUT:    Server v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:

    The Server is intended to be run as a Windows Service and will:
        Create the SharedFile and grant access to everyone
        Waits for a command from the Client
        Executes the command
        Replies with a response
        Loop

    The Client sends commands to the Server and reads the server response
    When the Client exits, the Server will remain running.

*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include .\SharedFile.ahk

global SF:= SharedFile("Server")

; initial state is the server WaitReady, so we SetNotReady to wait for a command from the client
SF.SetNotReady()

Loop {

    ; wait for client to send command indefinately
    timeout:= SF.WaitReady(-1)

    ; signal client to not r/w anything
    SF.SetNotReady()

    CheckTimeout(timeout, 1)

    ; read command from client
    command:= SF.Read()

    ; formulate response
    response:= "ACK: " command

    ; write response to client
    SF.Write(response)

    ; signal client to read response
    SF.SetReady()

    ; handle terminate command from client
    if (command = "TERMINATE") 
        break

    ; wait until client read response and set not ready
    timeout:= SF.WaitNotReady(1000)

    CheckTimeout(timeout, 2)

    ; loop with server WaitReady

    Sleep 100
}

CheckTimeout(timeout, number) {
    if (timeout)
        MsgBox("Timeout Number: " number , "SERVER")
}

SF:=""

ExitApp()
