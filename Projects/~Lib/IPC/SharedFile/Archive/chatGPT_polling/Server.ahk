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

TrayTip "Server is running...", "Server", "Iconi"

#Requires AutoHotkey v2.0

#Include shared_helpers.ahk

serverSeq := 0
lastClientSeq := -1

SetTimer(ServerLoop, 300)

ServerLoop() {
    global serverSeq, lastClientSeq, SharedFile

    data := ReadIni(SharedFile)

    clientSeq := data.Get("client_seq", -1)
    if (clientSeq != lastClientSeq) {
        lastClientSeq := clientSeq
        clientMsg := data.Get("client_data", "")
        if (clientMsg != "")
            ToolTip "Server received: " clientMsg
    }

    ; send update
    serverSeq++
    data["server_seq"] := serverSeq
    data["server_data"] := "Hello from server @ " A_TickCount

    WriteIni(SharedFile, data)
}
