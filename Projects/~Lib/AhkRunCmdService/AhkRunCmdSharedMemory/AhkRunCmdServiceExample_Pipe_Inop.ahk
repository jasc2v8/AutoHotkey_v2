; TITLE: BackupControlTool v2.3, 
; 
/*

this is a comment block

*/
#Requires AutoHotkey >=2.0
#SingleInstance Ignore
#NoTrayIcon

#Include <IniLite>
#Include <RunCMD>

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

#Include <NamedPipe>

; #region Globals

global SyncBackPath := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
global SyncBackAction := "" ; "", "-shutdown", "-standby"
global SyncBackProfile := "~Backup JIM-PC folders to JIM-SERVER"
global SyncBackProfile := "TEST"

; Set the named pipe shared between the controller and this sserver 
PipeName := "\\.\pipe\AhkRunCmdService"

; create the named pipe
hPipe:= Pipe_Create(PipeName)

; connect to the named pipe
r := Pipe_Connect(hPipe)

; form the message
message:= SyncBackPath ", " SyncBackAction ", " SyncBackProfile

; send the message
Pipe_Write(hPipe, message)

; get response
 response := Pipe_Read(hPipe)

 MsgBox "RESPONSE: " response

; close the pip
Pipe_Close(hPipe)
