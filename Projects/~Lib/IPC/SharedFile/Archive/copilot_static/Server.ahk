; TITLE:    Server v0.0
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
;#NoTrayIcon

#Include SharedFile.ahk

TrayTip "Server is running...", "Server", "Iconi"

ipc := SharedFileIPC(A_Temp "\ipc_request.txt", A_Temp "\ipc_response.txt")

ServerCallback(request) {
    if request = "__SHUTDOWN__"
        ipc.Stop()

    ;SIMULATE WORK
    Sleep(5000)

    return "Server received: " request " at " FormatTime(A_Now, "HH:mm:ss")
}

ipc.Listen(ServerCallback)