; TITLE: AhkRunCmdService v0.1
/*
  TODO:
    fix icon (does it need one?)

*/
#Requires AutoHotkey 2.0+
#SingleInstance Ignore
#NoTrayIcon

#Include <RunCMD>

; #region Version Block

; Language codes (en-US=1033): https://www.autoitscript.com/autoit3/docs/appendix/OSLangCodes.htm
;@Ahk2Exe-Set CompanyName, jasc2v8
;@Ahk2Exe-Set FileDescription, Ahk RunCMD Service
;@Ahk2Exe-Set FileVersion, 1.0.0.0
;@Ahk2Exe-Set InternalName, AhkRunCmdService
;@Ahk2Exe-Set Language, 1033
;@Ahk2Exe-Set LegalCopyright, ©2025 jasc2v8
;@Ahk2Exe-Set LegalTrademarks, NONE™
;@Ahk2Exe-Set OriginalFilename, AhkRunCmdService.exe
;@Ahk2Exe-Set ProductName, AhkRunCmdService
;@Ahk2Exe-Set ProductVersion, 1.0.0.0
;@Ahk2Exe-SetMainIcon .\Icons\BackupControlTool.ico

;@Inno-Set AppId, {{83BEBE1D-34CD-4ACC-BE79-B0CC93983818}}
;@Inno-Set AppPublisher, jasc2v8

#Include <NamedPipe>

; #region Admin Check

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

; #region Main

; Set the named pipe shared between the controller and this sserver 
PipeName := "\\.\pipe\AhkRunCmdService"

; create the named pipe
hPipe:= Pipe_CreateAsync(PipeName)

;if (hPipe=-1) {
  ;INVALID_HANDLE_VALUE
  ; Exit to terminate service and inform NSSM?
;}
ok:="error"

MsgBox "hPipe: " hPipe

  ; TODO: make this UNblocking?
  ; connect to the named pipe (NOT BLOCKING)
  ; ok=Success=return nonzero. Fail=return value is zero
ok := Pipe_ConnectAsync(hPipe)

; if (!ok) {
; }

; Success=return nonzero. Fail=return value is zero
MsgBox "PIPE_CONNECT: " ok

MsgBox
ExitApp()

  ; loop until NSSM kills this process
Loop {

  ; wait for the message from the controller (client)
  Pipe_Wait(PipeName)

  MsgBox "PIPE_READY: " PipeName

  ; receive the message from the controller (client)
  ; msg:= "ExePath, Param1, Param2, Param3, etc."
  ; msg:= "BackupExePath, ActionAfterBackup, BackupProfile"
  messageCSV := Pipe_Read(hPipe)

  MsgBox "MESSAGE: " messageCSV

  Pipe_Write(hPipe, "Received message")

  split:= StrSplit(messageCSV, ",")

  if (split.Length=3) {

      ExePath := split[1]
      Params := split[2]
      Target := split[3]

      r := RunCMD(ExePath, Params, Target)

      resultValue:= (r="") ? "Error": "Success"

      Pipe_Write(hPipe, resultValue)

  } else {
      Pipe_Write(hPipe, "Error: Expected 3 parameters, got " split.Length)
  }
}
