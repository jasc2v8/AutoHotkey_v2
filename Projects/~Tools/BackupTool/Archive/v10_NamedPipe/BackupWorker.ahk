; TITLE   : Backup Worker v1.0
; SOURCE  : jasc2v8 and chatGPT
; LICENSE : The Unlicense, see https://unlicense.org
; PURPOSE : BackupTool runs SyncBack.exe who communicates with this BackupWorker using NamedPipe IPC.

/*
    TODO:
*/

#Requires AutoHotkey 2.0+
#SingleInstance Ignore
#NoTrayIcon
;TraySetIcon('shell32.dll', 294) ; Backup/Restore Icon
TraySetIcon("C:\Users\Jim\Documents\AutoHotkey\Lib\Icons\Cogs.ico")

#Include <LogFile>
#Include <NamedPipe>
#Include <RunCMD>

; #region Version Block

; Language codes (en-US=1033): https://www.autoitscript.com/autoit3/docs/appendix/OSLangCodes.htm
;@Ahk2Exe-Set CompanyName, jasc2v8
;@Ahk2Exe-Set FileDescription, BackupWorker
;@Ahk2Exe-Set FileVersion, 1.0.0.0
;@Ahk2Exe-Set InternalName, Backup Worker
;@Ahk2Exe-Set Language, 1033
;@Ahk2Exe-Set LegalCopyright, ©2025 jasc2v8
;@Ahk2Exe-Set LegalTrademarks, NONE™
;@Ahk2Exe-Set OriginalFilename, BackupControlWorker.exe
;@Ahk2Exe-Set ProductName, BackupWorker
;@Ahk2Exe-Set ProductVersion, 1.0.0.0
;@Ahk2Exe-SetMainIcon D:\Software\DEV\Work\AHK2\Projects\~Tools\BackupTool\Icons\Cogs.ico

;@Inno-Set AppId, {{530BC47A-DA2E-4C11-8BCB-C2D3649620DD}}
;@Inno-Set AppPublisher, jasc2v8

; #region Globals

;global LogPath := EnvGet("PROGRAMDATA") "\AutoHotkey\BackupTool\BackupWorker.log"
global LogPath := "D:\BackupWorker.log"
global logger := LogFile(LogPath, "WORKER")
logger.Disable()

logger.Write("START BackupWorker")

try
{
    ; This server creates the pipe
    logger.Write("Create pipe.")
    pipe:=NamedPipe("BackupWorker")
    pipe.Create()

    ; Receive the request from the client
    logger.Write("Read request.")
    request := pipe.Receive()
    logger.Write("Request Received: " request)
    
    ; Run the commandLine and wait to capture Output
    reply := RunCMD(request)
    reply:= Trim(reply, " `t`r`n")

    ; Handle the backup post action at an elevated level (e.g. shutdown requires admin)
    logger.Write("PostActionHandler start.")
    PostActionHandler(request)

    ; Send ACK
    logger.Write("Send reply.")
    reply := "ACK: " reply
    pipe.Send(reply)

    if (request = "TERMINATE") {
        pipe.Close()
        ExitApp()
    }
}
catch any as e
{
    logger.Write("Error: " e.Message)
}
finally
{
    logger.Write("Pipe close.")
    pipe.Close()
    pipe:=""
}

logger.Write("ExitApp")

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

    logger.Write("DEBUG BackupParameters: [" BackupParameters "]")

    ; Get Post Action from Parameters (SyncBackPath, SyncBackParams, SyncBackProfile)
    split := StrSplit(BackupParameters, ",")
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
