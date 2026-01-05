; TITLE:    Server v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include SharedFile.ahk

req  := A_Temp "\ipc_request.txt"
resp := A_Temp "\ipc_response.txt"

Loop {

    msg := InputBox("Enter request:", "Send UTF‑16 IPC Request")

    if (msg.Result = "Cancel") {
        SF_RequestResponse(req, resp, msg.Result)
        ExitApp

    } else if msg.Value != "" {
        reply := SF_RequestResponse(req, resp, msg.Value)
        MsgBox "Server replied:`n`n[" reply "]"
    }

}

