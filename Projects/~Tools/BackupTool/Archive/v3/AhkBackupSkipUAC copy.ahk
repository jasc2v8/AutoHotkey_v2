; TITLE: BackupControlTool v3.0
; Uses a Shared File to communicate with AhkRunCmdService who actually runs Syncback
; The RunCmd service runs with admin privs, so this does not need privs therefore no annoying UAC prompt!

/*
this is a comment block
*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
#NoTrayIcon
TraySetIcon('shell32.dll', 294) ; Backup/Restore Icon

#Include <RunCMD>

; #region Version Block

; Language codes (en-US=1033): https://www.autoitscript.com/autoit3/docs/appendix/OSLangCodes.htm
;@Ahk2Exe-Set CompanyName, jasc2v8
;@Ahk2Exe-Set FileDescription, AhkBackupSkipUAC
;@Ahk2Exe-Set FileVersion, 1.0.0.0
;@Ahk2Exe-Set InternalName, Ahk Backup Skip UAC
;@Ahk2Exe-Set Language, 1033
;@Ahk2Exe-Set LegalCopyright, ©2025 jasc2v8
;@Ahk2Exe-Set LegalTrademarks, NONE™
;@Ahk2Exe-Set OriginalFilename, AhkBackupSkipUAC.exe
;@Ahk2Exe-Set ProductName, AhkBackupSkipUAC
;@Ahk2Exe-Set ProductVersion, 1.0.0.0
;@Ahk2Exe-SetMainIcon security-high.ico

;@Inno-Set AppId, {{10D9F70C-88D1-428B-811D-5264CA644A87}}
;@Inno-Set AppPublisher, jasc2v8

; Runs as a scheduled Task with runLevel = 'highest'

; #region Globals

global logFile          := "D:\AhkBackupSkipUAC.txt"

global SyncBackPath     := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
global SyncBackProfiles := EnvGet("LOCALAPPDATA") "\2BrightSparks\SyncBack\Profiles Backup"
global logDir           := EnvGet("LOCALAPPDATA") "\2BrightSparks\SyncBack\Logs"
global DefaultProfile   := "~Backup JIM-PC folders to JIM-SERVER"
global TestProfile      := "TEST WITH SPACES"

; full_command_line := DllCall("GetCommandLine", "str")

if not (A_IsAdmin or RegExMatch(DllCall("GetCommandLine", "str"), " /restart(?!\\ S)"))
{
    try
    {
        if A_IsCompiled
            Run '*RunAs "' A_ScriptFullPath '" /restart'
        else
            Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
    }
    ExitApp  ; Exit the current, non-elevated instance
}

SyncBackSelectedProfile := TestProfile
SQ:="'"
DQ:='"'

; must elevate before running

;WORKS!!!!!!!!!!!!!!!!!!!
;MsgBox ,"SyncBack TEST"
;cmdExec := '"C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe" "TEST"'
;Output:=RunCMD.Exe(cmdExec) 
;MsgBox Output, "output"
;ExitApp()

;WORKS!!!!!!!!!!!!!!!!!!!
; MsgBox ,"SyncBack TEST Strings"
; param := "TEST"
; cmdExec := RunCMD.ConvertToCSV(SyncBackPath, param)
; MsgBox cmdExec, "cmdExec"
; Output:=RunCMD.CSV(cmdExec) 
; MsgBox Output, "output"
; ExitApp()

;WORKS!!!!!!!!!!!!!!!!!!!
; MsgBox ,"SyncBack TEST Variables"
; param := "TEST"
; cmdExec := RunCMD.ConvertToCSV(SyncBackPath, param)
; MsgBox cmdExec, "cmdExec"
; Output:=RunCMD.CSV(cmdExec) 
; MsgBox Output, "output"
;ExitApp()

;FIX!!!!!!!!!!!!!!!!!!!
;FIX!!!!!!!!!!!!!!!!!!!
;FIX!!!!!!!!!!!!!!!!!!!
; check the logs to make sure TEST didn't run instead of TEST WITH SPACES
;C:\Users\Jim\AppData\Local\2BrightSparks\SyncBack\Logs

MsgBox ,"SyncBack TEST WITH SPACES"
param := "'TEST  WITH SPACES'"
cmdExec := RunCMD.ConvertToCSV(SyncBackPath, param)
MsgBox cmdExec, "cmdExec"
Output:=RunCMD.CSV(cmdExec) 
MsgBox Output, "output"

ExitApp()


MsgBox ,"SyncBack TEST"
cmdExec := '"C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe" "TEST"'
Output:=RunCMD.Exe(cmdExec) 
MsgBox Output, "output"

MsgBox ,"SyncBack TEST WITH SPACES"
cmdExec := '"C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe" "TEST WITH SPACES"'
Output:=RunCMD.Exe(cmdExec) 
MsgBox Output, "output"

ExitApp()

;cmdExec ok with spaces or no spaces
MsgBox ,"RunCMD.Exe"
cmdExec := '"D:\Software\DEV\Work\AHK2\Projects\BackupControlTool\StdOutArgs.exe" "D:\NSSM\nssm.exe" "D:\2025 London Paris\Hotel London.odt"'
Output:=RunCMD.Exe(cmdExec) ; RunCMD.Exe()  Run.Exe() .CSV
MsgBox Output, "output"

MsgBox ,"RunCMD"
cmdCmd := '"dir /b "D:\2025 London Paris\"'
Output:=RunCMD(cmdCmd) ; RunCMD.Cmd()  Run.Cmd()
MsgBox Output, "output"
ExitApp()

;inop must run with A_ComSpec
MsgBox ,"cmdExec"
cmdExec := '"dir /b "D:\2025 London Paris\"'
cmdExec := '"dir /b "D:\NSSM\"'
shell := ComObject("WScript.Shell")
exec := shell.Exec(cmdExec) ; no console window
ExitApp()

;inop must run with A_ComSpec
MsgBox ,"cmdExec"
cmdExec := '"dir /b "D:\2025 London Paris\"'
Run cmdExec  ; no console window
ExitApp()


MsgBox ,"dir"
; all OK
cmdDir := '"dir /b "D:\NSSM\"'
cmdDir := '"dir /b "D:\2025 London Paris\"'
cmdDir := '"ipconfig /all"'
cmdDir := 'ipconfig /all'
cmdDir := "ipconfig /all"
;inop with spaces
cmdDir := '"D:\Software\DEV\Work\AHK2\Projects\BackupControlTool\ShowArgs.exe "D:\NSSM\nssm.exe" "D:\2025 London Paris\Hotel London.odt"'
Output := RunCMD.Raw(cmdDir)   ; no console window
MsgBox Output, "cmdExec Output"
ExitApp()

;cmdComSpec inop with spaces
cmdComSpec := '"D:\Software\DEV\Work\AHK2\Projects\BackupControlTool\ShowArgs.exe "D:\NSSM\nssm.exe" "D:\2025 London Paris\Hotel London.odt"'
;cmdExec inop with spaces or no spaces
cmdExec := '"D:\Software\DEV\Work\AHK2\Projects\BackupControlTool\ShowArgs.exe" "D:\NSSM\nssm.exe" "D:\2025 London Paris\Hotel London.odt"'
MsgBox ,"cmdComSpec"
Output := RunCMD.Raw(cmdComSpec)   ; no console window
MsgBox Output, "cmdComSpec Output"
MsgBox ,"cmdExec"
Output := RunCMD.Raw(cmdExec)   ; no console window
MsgBox Output, "cmdExec Output"
ExitApp()

;cmdComSpec inop with spaces
cmdComSpec := '"D:\Software\DEV\Work\AHK2\Projects\BackupControlTool\ShowArgs.exe "D:\NSSM\nssm.exe" "D:\2025 London Paris\Hotel London.odt"'
;cmdExec ok with spaces or no spaces
cmdExec := '"D:\Software\DEV\Work\AHK2\Projects\BackupControlTool\ShowArgs.exe" "D:\NSSM\nssm.exe" "D:\2025 London Paris\Hotel London.odt"'
MsgBox ,"cmdComSpec"
Run A_ComSpec ' /Q /C ' cmdComSpec  ; shows console window
MsgBox ,"cmdExec"
Run cmdExec  ; no console window

;cmdComSpec inop with spaces
cmdComSpec := '"D:\Software\DEV\Work\AHK2\Projects\BackupControlTool\ShowArgs.exe "D:\NSSM\nssm.exe" "D:\2025 London Paris\Hotel London.odt"'
;cmdExec ok with spaces or no spaces
cmdExec := '"D:\Software\DEV\Work\AHK2\Projects\BackupControlTool\Show Args.exe" "D:\NSSM\nssm.exe" "D:\2025 London Paris\Hotel London.odt"'
shell := ComObject("WScript.Shell")
MsgBox ,"cmdComSpec"
exec := shell.Exec(A_ComSpec ' /Q /C ' cmdComSpec) ; shows console window
MsgBox ,"cmdExec"
exec := shell.Exec(cmdExec) ; no console window

;Output:=RunCMD.Raw(cmd)
;MsgBox ;Output
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

