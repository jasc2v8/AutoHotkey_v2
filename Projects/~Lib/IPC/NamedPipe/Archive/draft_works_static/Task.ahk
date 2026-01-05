; TITLE  :  NamedPipeTask v1.0
; SOURCE :  Gemini, Copilot, and jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
/*
    TODO:    
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include .\NamedPipeHelper.ahk

; no not for a Task! Persistent

global Logging := false
global LogFile := "D:\NamedPipeTask_log.txt"

; Ensure Admin for GLOBAL pipe creation
; COMMENT OUT WHEN RUN AS TASK
if !A_IsAdmin {
    Run('*RunAs "' A_AhkPath '" "' A_ScriptFullPath '"')
    ExitApp()
}

TraySetIcon("Shell32.dll", 15) ; Optional: change icon to show it's a server (blue terminal with globe)

;MsgBox("Server is running. Waiting for client requests...", "Pipe Server", "Iconi T5")

MyWork(input) {

    if (input = 'TERMINATE')
        ExitApp()
    
    ; Simulate work
    output := StrUpper(input)
    Sleep(1000) 
    return "WORK COMPLETE: " . output
}

PipeHelper.RunTask(MyWork)

; yes MsgBox "TASK END?"

WriteLog(text) {
    if (Logging) {
        try {
            FileAppend(FormatTime(A_Now, "HH:mm:ss") ": " text "`n", LogFile)
        }
    }
}