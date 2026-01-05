; TITLE: BackupControlTask v6.0 (chatGPT)
; SOURCE  : jasc2v8 and chatGPT
; LICENSE : The Unlicense, see https://unlicense.org
; PURPOSE : Run SyncBack.exe as Admin with no UAC prompt.
; FLOW:
;           Runs as a scheduled Task with runLevel = 'highest'
;           The client must run this Task first before sending commands
;           The client must end this Task before exiting

/*
    TODO:
*/

#Requires AutoHotkey 2.0+
#SingleInstance Ignore
;#NoTrayIcon
;TraySetIcon('shell32.dll', 294) ; Backup/Restore Icon
TraySetIcon("C:\Users\Jim\Documents\AutoHotkey\Lib\Icons\Cogs.ico")

#Include <LogFile>
#Include <RunAny>
#Include <SharedMemory>

; #region Version Block

; Language codes (en-US=1033): https://www.autoitscript.com/autoit3/docs/appendix/OSLangCodes.htm
;@Ahk2Exe-Set CompanyName, jasc2v8
;@Ahk2Exe-Set FileDescription, BackupControlWorker
;@Ahk2Exe-Set FileVersion, 7.0.0.0
;@Ahk2Exe-Set InternalName, Backup Control Worker
;@Ahk2Exe-Set Language, 1033
;@Ahk2Exe-Set LegalCopyright, ©2025 jasc2v8
;@Ahk2Exe-Set LegalTrademarks, NONE™
;@Ahk2Exe-Set OriginalFilename, BackupControlWorker.exe
;@Ahk2Exe-Set ProductName, BackupControlWorker
;@Ahk2Exe-Set ProductVersion, 7.0.0.0
;@Ahk2Exe-SetMainIcon C:\Users\Jim\Documents\AutoHotkey\Lib\Icons\Cogs.ico

;@Inno-Set AppId, {{10D9F70C-88D1-428B-811D-5264CA644A87}}
;@Inno-Set AppPublisher, jasc2v8

;global LogPath := EnvGet("PROGRAMDATA") "\AutoHotkey\BackupControlTool\Worker.log"
global LogPath := "D:\Worker.log"
global logger := LogFile(LogPath, "WORKER")
;logger.Disable()

logger.Write("Listening...")

mem := SharedMemory("Server", "BackupControlWorker", 2048)

logger.Write("WaitForWrite")

;request := Mem.WaitRead()
request := Mem.WaitForWrite()

logger.Write("Request: " request)

    ; Note that SyncBack will ignore the BackupPostAction parameters

    ; Worker run BackupRequest ('Backup.exe BackupProfile')
    output:= RunAny(request)

    logger.Write("RunAny output: [" output "]")

    logger.Write("PostActionHandler start.")

    ; Handle the backup post action at an elevated level (e.g. shutdown requires admin)
    PostActionHandler(request)

    logger.Write("ACK from Worker: " request)

    mem.Write("ACK: " request)

PostActionHandler(BackupRequest) {

    ; BackupRequest = ("SyncBackPath, SyncBackParams, SyncBackProfile")

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

    logger.Write("DEBUG BackupParameters: [" BackupRequest "]")

    ; Get Post Action from Parameters (SyncBackPath, SyncBackParams, SyncBackProfile)
    split := StrSplit(BackupRequest, ",")
    if (split.Length < 3) {
        logger.Write("ERROR Expected 3 parameters, got: " split.Length)
        return
    }

    postAction:= split[2]

    logger.Write("DEBUG PostAction: [" postAction "]")

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

    logger.Write("FINISH: [" postAction "]") ; may not have time to write this.

}
