; TITLE  :  NamedPipeClient v0.0
; SOURCE :  Gemini and Copilot
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include .\NamedPipeHelper.ahk


Loop {
    payload := InputBox("Enter data to send to server:", "Pipe Client").Value

    if (payload = "") or (payload = "BYE")
        break

    ToolTip("Waiting for server...")
    
    response := PipeHelper.SendRequest(payload)

    ToolTip() ; Clear tooltip
    
    MsgBox("Server Replied:`n`n" response)

}