; TITLE: BackupControlTool v3.0
; Uses a Shared File to communicate with AhkRunCmdService who actually runs Syncback
; The RunCmd service runs with admin privs, so this does not need privs therefore no annoying UAC prompt!

/*
this is a comment block
*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
#NoTrayIcon

#Include <RunCMD>

global logFile          := "D:\AhkBackupSkipUAC.txt"

global SyncBackPath     := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
global SyncBackProfiles := EnvGet("LOCALAPPDATA") "\2BrightSparks\SyncBack\Profiles Backup"
global logDir           := EnvGet("LOCALAPPDATA") "\2BrightSparks\SyncBack\Logs"
global DefaultProfile   := "~Backup JIM-PC folders to JIM-SERVER"
global TestProfile      := "TEST WITH SPACES"

;  full_command_line := DllCall("GetCommandLine", "str")

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

CheckFile:= SyncBackPath

if FileExist(CheckFile)
    MsgBox "File Exist:`n`n" CheckFile
else
    MsgBox "File NOT Exist:`n`n" CheckFile

ExitApp()


SyncBackSelectedProfile := TestProfile
SQ:="'"
DQ:='"'

; cmd :=  SQ DQ "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe" DQ A_Space DQ "TEST WITH SPACES" DQ SQ
; cmd := '""C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"" ""TEST WITH SPACES""'
; RunCMD.Raw(cmd)

cmd := '"C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe" "TEST WITH SPACES"'

; Note the single quotes around the entire string for Run
;Run A_ComSpec ' /Q /C ' cmd
;Run cmd

shell := ComObject("WScript.Shell")
;exec := shell.Exec(A_ComSpec ' /Q /C ' cmd)
exec := shell.Exec(cmd)

MsgBox cmd
ExitApp()


A_Clipboard := DefaultProfile
; Get params from Clipboard
params := A_Clipboard ; "PROFILE -switch1 -switch2 -switch3"

cmdCSV := RunCMD.ConvertToCSV(SyncBackPath "," params)

;cmdCSV := DQ SyncBackPath A_Space "," A_Space  params DQ
cmdCSV := SyncBackPath A_Space "," A_Space  params

MsgBox cmdCSV

Output := RunCMD.CSV(cmdCSV)

ExitApp()

WriteLog("PARAMS FROM CLIPBOARD: " params)

if SubStr(params,1,1) != DQ
  params := DQ params
if InStr(params,-1,1) != DQ
  params := params DQ

WriteLog("PARAMS PARSED: " params)

cmdCSV := RunCMD.ConvertToCSV(SyncBackPath "," params)

MsgBox cmdCSV
Output := RunCMD.CSV(cmdCSV)
ExitApp()

; parse params
; -hybernate      DllCall('PowrProf\SetSuspendState', 'Int', 1, 'Int', 0, 'Int', 0)
; -logoff         Shutdown(0)     ; 0=Logoff, 1=Shutdown, 2=Reboot, 3=Force, 4=Power down
; -logoffforce    Shutdown(0+3)   ; 0=Logoff, 1=Shutdown, 2=Reboot, 3=Force, 4=Power down
; -monoff         SendMessage 0x0112, 0xF170, 2,, "Program Manager"  ; 0x0112 is WM_SYSCOMMAND, 0xF170 is SC_MONITORPOWER.
; -shutdown       Shutdown(1)     ; 0=Logoff, 1=Shutdown, 2=Reboot, 3=Force, 4=Power down
; -shutdownforce  Shutdown(1+3)   ; 0=Logoff, 1=Shutdown, 2=Reboot, 3=Force, 4=Power down
; -sleep          DllCall('PowrProf\SetSuspendState', 'Int', 0, 'Int', 0, 'Int', 0)
; -standby        alias for -sleep

if (params = "")
  ExitApp()

;WriteLog(SyncBackPath ' ' params)

;cmdArray:= [SyncBackPath, params]
;Output := RunCMD.Array(cmdArray)


cmdCSV := RunCMD.ConvertToCSV(SyncBackPath "," params)

split := StrSplit(params, ",")
for i, param in split {
  value := Trim(param)
  WriteLog( i ": " value)
}

WriteLog("START: " cmdCSV)

;WriteLog(params "," cmdCSV)
Output := RunCMD.CSV(cmdCSV)

WriteLog("FINISH: [" Output "]")


;DQ:= '"'
;cmdRaw:= DQ DQ SyncBackPath DQ A_Space DQ params DQ A_Space

;Output := RunCMD.Raw(cmdRaw)

; ExitApp()

; split:= StrSplit(params, " ")

; for param in split {

;   value:= Trim(param)

;   if (A_Index = 1) {
;     SyncBackProfile := value
;     cmdCSV := RunCMD.ConvertToCSV(SyncBackPath, SyncBackProfile)

;     WriteLog(params "," cmdCSV)

;     ;Output := RunCMD.CSV(cmdCSV)

;     cmdArray:= [SyncBackPath, SyncBackProfile]
;     Output := RunCMD.Array(cmdArray)


;     continue
;   }

;   switch value {
;     case "-hybernate":
;       DllCall('PowrProf\SetSuspendState', 'Int', 1, 'Int', 0, 'Int', 0) ; PowerControlTool
;     case "-logoff", "-signoff":
;       Shutdown(0)  ; PowerControlTool
;     case "-logoffforce", "-signoffforce":
;       Shutdown(0+3)
;     case "-monoff":
;       SendMessage 0x0112, 0xF170, 2,, "Program Manager"  ; 0x0112 is WM_SYSCOMMAND, 0xF170 is SC_MONITORPOWER.
;     case "-shutdown":
;       Shutdown(1)  ; PowerControlTool
;     case "-shutdownforce":
;       Shutdown(1+3) 
;     case "-sleep", "-standby":
;       DllCall('PowrProf\SetSuspendState', 'Int', 0, 'Int', 0, 'Int', 0)
;     default:
;       doNoting:=true
;   }
; }

ExitApp()

WriteLog(Message) {
  currentTime := FormatTime(A_Now, "HH:mm:ss")
  FileAppend(currentTime ": " Message "`n", LogFile)
}

