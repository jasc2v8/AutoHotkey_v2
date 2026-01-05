; TITLE: BackupControlTask v1.0

; Runs as a scheduled Task with runLevel = 'highest'
; The client must run this Task first before sending commands
; The client must end this Task before exiting

/*
    TODO:
*/

#Requires AutoHotkey 2.0+
#SingleInstance Force
#NoTrayIcon
;TraySetIcon('shell32.dll', 294) ; Backup/Restore Icon
TraySetIcon("D:\Software\DEV\Work\AHK2\Projects\BackupControlTool\Icons\Cogs.ico")

#Include <RunHelper>
#Include <NamedPipeHelper>

; #region Version Block

; Language codes (en-US=1033): https://www.autoitscript.com/autoit3/docs/appendix/OSLangCodes.htm
;@Ahk2Exe-Set CompanyName, jasc2v8
;@Ahk2Exe-Set FileDescription, BackupControlTask
;@Ahk2Exe-Set FileVersion, 1.0.0.0
;@Ahk2Exe-Set InternalName, Backup Task
;@Ahk2Exe-Set Language, 1033
;@Ahk2Exe-Set LegalCopyright, ©2025 jasc2v8
;@Ahk2Exe-Set LegalTrademarks, NONE™
;@Ahk2Exe-Set OriginalFilename, BackupControlTask.exe
;@Ahk2Exe-Set ProductName, BackupControlTask
;@Ahk2Exe-Set ProductVersion, 1.0.0.0
;@Ahk2Exe-SetMainIcon D:\Software\DEV\Work\AHK2\Projects\BackupControlTool\Icons\Cogs.ico

;@Inno-Set AppId, {{10D9F70C-88D1-428B-811D-5264CA644A87}}
;@Inno-Set AppPublisher, jasc2v8

; #region Globals

global Logging := false
global LogFile := EnvGet("PROGRAMDATA") "\AutoHotkey\BackupControlTool\BackupControlTask.log"

; Runs as a scheduled Task with runLevel = 'highest'

MyWork(input) {

    WriteLog("MyWork START: " input)

    if (input = 'TERMINATE')
        ExitApp()
    
    ; Include both StdOut and StdErr in the Output
    RunHelper.SetOutput("StdOutStdErr")

    ; Run the commandLine and wait to capture Output
    response := RunHelper(input)

    WriteLog("TASK Command : " input)
    WriteLog("TASK Response: " Trim(response, "`n"))

    ; Handle the backup post action at an elevated level (e.g. shutdown requires admin)
    PostActionHandler(input)

    return "ACK: " response
}


WriteLog("PipeHelper().RunTask(MyWork)")

myPipe := PipeHelper().RunTask(MyWork)

WriteLog("ExitApp")

ExitApp()

PostActionHandler(BackupParameters) {

    ; BackupParameters = (SyncBackPath, SyncBackParams, SyncBackProfile)

    ; parse params
    ; -hybernate      DllCall('PowrProf\SetSuspendState','Int',1,'Int',0,'Int',0,'Int',0) ; Hibernate Mode (S4) (USB off, mouse)
    ; -logoff         Shutdown(0)     ; 0=Logoff, 1=Shutdown, 2=Reboot, 3=Force, 4=Power down
    ; -logoffforce    Shutdown(0+3)   ; 0=Logoff, 1=Shutdown, 2=Reboot, 3=Force, 4=Power down
    ; -monoff         SendMessage 0x0112, 0xF170, 2,, "Program Manager"  ; 0x0112 is WM_SYScommandLine, 0xF170 is SC_MONITORPOWER.
    ; -shutdown       Shutdown(1)     ; 0=Logoff, 1=Shutdown, 2=Reboot, 3=Force, 4=Power down
    ; -shutdownforce  Shutdown(1+3)   ; 0=Logoff, 1=Shutdown, 2=Reboot, 3=Force, 4=Power down
    ; -sleep          DllCall('PowrProf\SetSuspendState','Int',0,'Int',0,'Int',0,'Int',0) ; Sleep Mode (S3) USB poweron, mouse will wakeup
    ; -standby        alias for -sleep

    ; if (BackupParameters = "")
    ;   ExitApp()

    WriteLog("DEBUG BackupParameters: [" BackupParameters "]")

    ; Get Post Action from Parameters (SyncBackPath, SyncBackParams, SyncBackProfile)
    split := StrSplit(BackupParameters, ",")
    if (split.Length < 3) {
        WriteLog("ERROR Expected 3 parameters, got: " split.Length)
        return
    }

    postAction:= split[2]

    WriteLog("DEBUG PostAction: [" postAction "]")

    switch postAction, CaseSense:="Off" {
        case "MonOff":
            action:= "-monoff"
        case "LogOff":
            action:= "-logoffforce"
        case "Sleep":
            action:= "-sleep"
        case "Hibernate":
            action:= "-hybernate"
        case "Shutdown":
            action:= "-shutdownforce"
        default:
            action:= "Nothing"
    }

    switch action {
        case "-monoff":
            SendMessage 0x0112, 0xF170, 2,, "Program Manager"  ; 0x0112 is WM_SYScommandLine, 0xF170 is SC_MONITORPOWER.
        case "-logoff", "-signoff":
            Shutdown(0)  ; PowerControlTool
        case "-sleep", "-standby":
            DllCall('PowrProf\SetSuspendState', 'Int', 0, 'Int', 0, 'Int', 0, 'Int') ; Sleep with USB power off
        case "-hybernate":
            DllCall('PowrProf\SetSuspendState', 'Int', 1, 'Int', 0, 'Int', 0, 'Int') ; SAME AS SLEEP! PowerControlTool
        case "-shutdown":
            Shutdown(1)  ; PowerControlTool
        case "-shutdownforce":
            Shutdown(1+4) 
        case "-logoffforce", "-signoffforce":
            Shutdown(0+4)
        default:
            doNothing:=true
    }

    WriteLog("FINISH: [" postAction "]") ; may not have time to write this.

}

WriteLog(text) {
    if (Logging) {
        try {
            FileAppend(FormatTime(A_Now, "HH:mm:ss") ": " text "`n", LogFile)
        }
    }
}