; TITLE  :  NamedPipeServer v0.0
; SOURCE :  Gemini and Copilot
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Inter-Process Communication (IPC) between scripts
; USAGE  :  Use AhkRunSkipUAC to run this as a Task with runLevel='highest'.
;        :  The Client script can be run with normal user privleges.
/*
    TODO:    
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include .\NamedPipeHelper.ahk

Persistent

global Logging := false
global LogFile := "D:\NamedPipeServer_log.txt"

; Ensure Admin for GLOBAL pipe creation
; COMMENT OUT WHEN RUN AS TASK
; if !A_IsAdmin {
;     Run('*RunAs "' A_AhkPath '" "' A_ScriptFullPath '"')
;     ExitApp()
; }

TraySetIcon("Shell32.dll", 15) ; Optional: change icon to show it's a server (blue terminal with globe)

;MsgBox("Server is running. Waiting for client requests...", "Pipe Server", "Iconi T5")

MyServerWork(input) {
    ; Simulate work (e.g., regex, file writing, math)
    output := StrUpper(input)
    Sleep(1000) 
    return "WORK COMPLETE: " . output
}

PipeHelper.RunServer(MyServerWork)

; StartPipe
; WaitClientConnect
; command:=Read
; DO WORK
; Write(response)
; ExitApp
WriteLog(text) {
    if (Logging) {
        try {
            FileAppend(FormatTime(A_Now, "HH:mm:ss") ": " text "`n", LogFile)
        }
    }
}