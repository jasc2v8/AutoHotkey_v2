; TITLE: BackupControlTool v2.3, 
; 
/*
    TODO:
        SharedMemory("AhkRunCmdService")

*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
#NoTrayIcon

#Warn Unreachable, Off

#Include <RunCMD>
#Include <SharedRegistry>

; #region Admin Check

; SyncBack requires Administrator privileges
; full_command_line := DllCall("GetCommandLine", "str")

; if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\\ S)"))
; {
;     try
;     {
;         if A_IsCompiled
;             Run '*RunAs "' A_ScriptFullPath '" /restart'
;         else
;             Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
;     }
;     ExitApp  ; Exit the current, non-elevated instance
; }

OnExit(ExitFunc)

global Logging := true
global ServiceLogFile := "D:\ServerLog.txt"

global reg := SharedRegistry("AhkRunCmd", "Message")

; ExePath:= "D:\Software\DEV\Work\AHK2\Projects\AhkRunCmdService\StdOutArgs.exe"
; p1:= "arg1"
; p2:= "arg2"
; p3:= "arg3"

; MsgBox cmd:= RunCMD.ConvertToCSV(ExePath, p1, p2, p3)

; MsgBox cmd

; Output := RunCMD.CSV(cmd)

; MsgBox Output

if DirExist("D:\Docs_Backup")
    DirDelete("D:\Docs_Backup", Recurse:=1)

global SyncBackPath := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
global SyncBackAction := "" ; "", "-shutdown", "-standby"
;global SyncBackProfile := "~Backup JIM-PC folders to JIM-SERVER"
global SyncBackProfile := "TEST"

cmd:= reg.ConvertToCSV(SyncBackPath, SyncBackAction, SyncBackProfile)

MsgBox cmd

Output := RunCMD.CSV(cmd)

MsgBox Output

ExitApp

ExitFunc(*) {
    mem:=""
    ExitApp()
}