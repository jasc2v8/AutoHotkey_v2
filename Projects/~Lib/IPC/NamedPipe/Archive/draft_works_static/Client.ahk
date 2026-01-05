; TITLE  :  NamedPipeClient v1.0
; SOURCE :  Gemini, Copilot, and jasc2v8
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
    
    MsgBox("Server Response:`n`n" response)

}