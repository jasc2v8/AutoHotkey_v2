; TITLE: BackupControlTool v3.0
; Uses a Shared File to communicate with Ahk_RunService who actually runs Syncback
; The _Run service runs with admin privs, so this does not need privs therefore no annoying UAC prompt!

/*
this is a comment block
*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
#NoTrayIcon
TraySetIcon('shell32.dll', 294) ; Backup/Restore Icon

#Include <_Run>
#Include <SharedFile>

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

global Logging          := true
global logFile          := "D:\AhkBackupSkipUAC.txt"

global SyncBackPath     := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
global SyncBackProfiles := EnvGet("LOCALAPPDATA") "\2BrightSparks\SyncBack\Profiles Backup"
global logDir           := EnvGet("LOCALAPPDATA") "\2BrightSparks\SyncBack\Logs"
global DefaultProfile   := "~Backup JIM-PC folders to JIM-SERVER"
global TestProfile      := "TEST WITH SPACES"

global SF:= SharedFile("Server")

; grant normal user client to access the shared file
Run 'icacls ' SF.SharedFilePath ' /grant "Everyone:F'

global Runner := _Run

; Required if run standalone, not requires running as a task?

; if not (A_IsAdmin or RegExMatch(DllCall("GetCommandLine", "str"), " /restart(?!\\ S)"))
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

OnExit(ExitHandler)

; Enable the Service to WaitRead()
SF.SetWrite()

WriteLog("Service Start!")

Loop {

    ; ; Wait forever until the Client writes a cmd to the SharedFile
    success := SF.WaitRead(-1)
    ; success := TRUE
    ; ;Sleep 1000

    ; ;WriteLog("Service Acquired Mutex")

    ; ;WriteLog("DEBUG Service Acquired Mutex, GetMutexAttributes): " SF.GetMutexAttributes())

    if (!success) {
        MsgBox "Timeout waiting for Client to Write a Command.`n`nPress OK to exit.", "SERVICE", "iconX"
        SetTimer , 0
        ExitApp()
    }

    WriteLog("DEBUG Service Read")

    ; Read the command from the SharedFile
    command:= SF.Read()

    ; Log the command
    if (Logging)
        WriteLog("Service Command: [" command "]")

    WriteLog("DEBUG Service SetWrite")

    ; Signal Client to write a command
    SF.SetWrite()

    ;msgCSV:= ConvertToCSV(command)
    msgCSV:= command

    ;WriteLog("Service Run Command: [" msgCSV "]")

    ; Includes both StdOut and StdErr in the Output
    Runner.SetOutput("StdOutStdErr")

    WriteLog("DEBUG Service _Run")

    ; Run the command and capture Output
    Output := Runner(msgCSV)

    WriteLog("DEBUG Service ACK")

    ; Share the Output with the Client
    SF.Write("ACK: [" Output "]")

    WriteLog("DEBUG Service SetRead")

    ; Signal Client to read the Output
    SF.SetRead()

    WriteLog("DEBUG Service WaitWrite")

    ; Wait for Client to Read the Output
    success := SF.WaitWrite(5000)

    if (!success) {
        MsgBox "Timeout waiting for Client to Read the Output.`n`nPress OK to exit.", "SERVICE", "iconX"
        SetTimer , 0
        ExitApp()
    }

}

; the SharedFile Class Destructor will delete the shared file
ExitHandler(*) {
    WriteLog("Service Exit!")
}

;DEBUG
;A_Clipboard := DefaultProfile


; COPY TO CLIPBOARD:
;
; C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe, TEST WITH SPACES
;
; A_Clipboard := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe, TEST WITH SPACES"

; Get command from Clipboard
; clipBoardCommand := A_Clipboard

; WriteLog("PARAMS FROM CLIPBOARD: " clipBoardCommand)

; ;command := _Run.ConvertToArray(SyncBackPath, TestProfile)
; command := _Run.ConvertToCSV(clipBoardCommand)
; ;command := clipBoardCommand
; Output := _Run(command)

; WriteLog("EXIT!")

; ExitApp()

; WriteLog("PARAMS FROM CLIPBOARD: " params)

; if SubStr(params,1,1) != DQ
;   params := DQ params
; if InStr(params,-1,1) != DQ
;   params := params DQ

; WriteLog("PARAMS PARSED: " params)

; command := _Run.ConvertToCSV(SyncBackPath "," params)

; MsgBox command
; Output := _Run.CSV(command)
; ExitApp()

; parse params
; -hybernate      DllCall('PowrProf\SetSuspendState', 'Int', 1, 'Int', 0, 'Int', 0)
; -logoff         Shutdown(0)     ; 0=Logoff, 1=Shutdown, 2=Reboot, 3=Force, 4=Power down
; -logoffforce    Shutdown(0+3)   ; 0=Logoff, 1=Shutdown, 2=Reboot, 3=Force, 4=Power down
; -monoff         SendMessage 0x0112, 0xF170, 2,, "Program Manager"  ; 0x0112 is WM_SYSCOMMAND, 0xF170 is SC_MONITORPOWER.
; -shutdown       Shutdown(1)     ; 0=Logoff, 1=Shutdown, 2=Reboot, 3=Force, 4=Power down
; -shutdownforce  Shutdown(1+3)   ; 0=Logoff, 1=Shutdown, 2=Reboot, 3=Force, 4=Power down
; -sleep          DllCall('PowrProf\SetSuspendState', 'Int', 0, 'Int', 0, 'Int', 0)
; -standby        alias for -sleep

; if (params = "")
;   ExitApp()

; ;WriteLog(SyncBackPath ' ' params)

; ;cmdArray:= [SyncBackPath, params]
; ;Output := _Run.Array(cmdArray)


; command := _Run.ConvertToCSV(SyncBackPath "," params)

; split := StrSplit(params, ",")
; for i, param in split {
;   value := Trim(param)
;   WriteLog( i ": " value)
; }

; WriteLog("START: " command)

; ;WriteLog(params "," command)
; Output := _Run.CSV(command)

; WriteLog("FINISH: [" Output "]")


;DQ:= '"'
;cmdRaw:= DQ DQ SyncBackPath DQ A_Space DQ params DQ A_Space

;Output := _Run.Raw(cmdRaw)

; ExitApp()

; split:= StrSplit(params, " ")

; for param in split {

;   value:= Trim(param)

;   if (A_Index = 1) {
;     SyncBackProfile := value
;     command := _Run.ConvertToCSV(SyncBackPath, SyncBackProfile)

;     WriteLog(params "," command)

;     ;Output := _Run.CSV(command)

;     cmdArray:= [SyncBackPath, SyncBackProfile]
;     Output := _Run.Array(cmdArray)


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

