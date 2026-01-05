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

;@Ahk2Exe-ConsoleApp

global SF:= SharedFile("Server")

Loop {

    SF.WaitUnLock("Client")

    message:= SF.Read()

    SF.Lock("Client")

    if (message = "STATUS")
        response:= "OK"
    else 
        response:= "ACK: " message

    SF.Write(response)

    SF.UnLock("Server")

    if (message = "TERMINATE") 
        break

    Sleep 100
}

ExitApp()
