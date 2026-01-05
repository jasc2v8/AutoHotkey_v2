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

ipc := SharedFileIPC(A_Temp "\ipc_request.txt", A_Temp "\ipc_response.txt")

Loop {

    ib := InputBox("Enter request:", "Send UTF‑16 IPC Request")

    if ib.Result = "Cancel" {
        ipc.Send("__SHUTDOWN__")
        ExitApp
    }

    msg := ib.Value
    if msg != "" {
        reply := ipc.Send(msg, 10000)
        MsgBox reply
    }
}

