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

;myPipe := PipeHelper("\\.\pipe\AHK_LocalUTF16Pipe")
;myPipe := PipeHelper("\\.\pipe\GLOBAL\AHK_GlobalUTF16Pipe")

myPipe := PipeHelper()

Loop {
    message := InputBox("Enter data to send to server:", "Pipe Client").Value

    if (message = "") or (message = "BYE")
        break

    ToolTip("Waiting for server...")
    
    response := myPipe.Send(message)

    ToolTip() ; Clear tooltip
    
    MsgBox("Server Response:`n`n" response)

}