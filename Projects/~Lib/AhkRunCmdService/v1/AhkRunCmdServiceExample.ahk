; TITLE: BackupControlTool v2.3, 
; 
/*
    TODO:
        SharedMemory("AhkRunCmdService")

*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
#NoTrayIcon

#Include <IniLite>
#Include <RunCMD>
#Include <SharedMemory>

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


; #region Globals
DQ := Chr(34)
SQ := Chr(39)

SyncBackPath := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
SyncBackAction := "" ; "", "-shutdown", "-standby"
;SyncBackProfile := "~Backup JIM-PC folders to JIM-SERVER"
SyncBackProfile := "TEST"

; connect to shared memory
mem := SharedMemory()

; form the message
;message:= SyncBackPath ", " SyncBackAction ", " SyncBackProfile
;message:= "dir , /s /b, \D:\NSSM"
message := SyncBackPath ", " SyncBackAction ", " SyncBackProfile

; YES YES YES message := mem.ConvertToCSV(SyncBackPath, SyncBackAction, SyncBackProfile)

; messageArray := Array()
; messageArray := [SyncBackPath, SyncBackAction, SyncBackProfile]
App:= "D:\Software\DEV\Work\AHK2\Projects\AhkRunCmdService\StdOutArgs.exe"
Arg1:= "one"
Arg2:= "two"
;Arg3:= 3.14

message := mem.ConvertToCSV(App, Arg1, Arg2)

;message := mem.ConvertToCSV("echo TEST")
;message := "echo TEST"
;message := ""
;Retry:=0
Retry:=10

MsgBox "MESSAGE TO SERVER:`n`n" message
;ExitApp

; send the message
mem.Write(message)

; get response
response := mem.ReadWait(Retry) ; 0 for demo, () to test AhkRunCmdService

mem.Clear()

MsgBox "MESSAGE FROM SERVER:`n`n" response

; YES

;r := RunCMD(response)
;resultValue:= (r="") ? "Error": "Success"
;MsgBox "resultValue: " r

mem.Write("TERMINATE")
ExitApp

ExitFunc(*) {
    mem:=""
    ExitApp()
}