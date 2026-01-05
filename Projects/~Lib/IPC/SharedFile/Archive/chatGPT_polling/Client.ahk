; TITLE:    Server v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Requires AutoHotkey v2.0

#Include shared_helpers.ahk

clientSeq := 0
lastServerSeq := -1

SetTimer(ClientLoop, 300)

ClientLoop() {
    global clientSeq, lastServerSeq, SharedFile

    data := ReadIni(SharedFile)

    serverSeq := data.Get("server_seq", -1)
    if (serverSeq != lastServerSeq) {
        lastServerSeq := serverSeq
        serverMsg := data.Get("server_data", "")
        if (serverMsg != "")
            ToolTip "Client received: " serverMsg
    }

    ; send update
    clientSeq++
    data["client_seq"] := clientSeq
    data["client_data"] := "Hello from client @ " A_TickCount

    WriteIni(SharedFile, data)
}
