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

global SF:= SharedFile("Server", ".\SharedFile.txt")

global LogFile:= ".\ServerLogFile.txt"

SF.SetEmpty()

Loop {

    WriteLog("WaitRead")

    command := SF.WaitRead(-1)
    ;Sleep 100

    WriteLog("Command: " command)

    ; handle terminate command from client
    if (command = "TERMINATE") {
        WriteLog(command)
        break
    }

    WriteLog("Simulate Work")

    Sleep 1 ; simulate work

    response:= "ACK" ; work complete

    WriteLog("ACK")

    SF.WaitWrite(response, -1)
    ;Sleep 100

    ;WriteLog("SetReady")

    ;SF.SetReady()
    ;Sleep 100

    ;WriteLog("WaitNotReady")

    ;SF.WaitNotReady(-1)
    ;Sleep 100

    ;WriteLog("WaitReady")

    ;SF.WaitReady(-1)
    ;Sleep 100

    Sleep 100
}

CheckTimeout(timeout, number) {
    if (timeout)
        MsgBox("Timeout Number: " number , "SERVER")
}

SF:=""

ExitApp()

WriteLog(Message) {
    currentTime := FormatTime(A_Now, "HH:mm:ss")
    FileAppend(currentTime ": " Message "`n", LogFile)
}