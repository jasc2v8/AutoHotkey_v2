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

req  := A_Temp "\ipc_request.txt"
resp := A_Temp "\ipc_response.txt"

if FileExist(req)
    FileDelete(req)
if FileExist(resp)
    FileDelete(resp)

SF_ServerLoop(req, resp, ServerCallback)

ServerCallback(request) {
    
    if (request = "Cancel") {
        ExitApp
    }
    return "ACK: " request " at " FormatTime(A_Now, "HH:mm:ss")

}


; SF_ServerLoopFatArrow(req, resp, (msg) => (
;     "Server received (UTF‑16): " msg "`n`nat " FormatTime(A_Now, "HH:mm:ss")
; ))
