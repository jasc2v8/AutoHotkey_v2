; TITLE   : ResetShellWorker v1.0
; SOURCE  : jasc2v8 
; LICENSE : The Unlicense, see https://unlicense.org
; PURPOSE : ResetShell runs this ResetShellWorer using NamedPipe IPC.

/*
    TODO:
*/

#Requires AutoHotkey 2.0+
#SingleInstance Ignore
#NoTrayIcon

#Include <LogFile>
#Include <NamedPipe>
#Include <RunCMD>

; #region Version Block

; Language codes (en-US=1033): https://www.autoitscript.com/autoit3/docs/appendix/OSLangCodes.htm
;@Ahk2Exe-Set CompanyName, jasc2v8
;@Ahk2Exe-Set FileDescription, ResetShellWor1er
;@Ahk2Exe-Set FileVersion, 1.0.0.0
;@Ahk2Exe-Set InternalName, Reset Shell Worker
;@Ahk2Exe-Set Language, 1033
;@Ahk2Exe-Set LegalCopyright, ©2025 jasc2v8
;@Ahk2Exe-Set LegalTrademarks, NONE™
;@Ahk2Exe-Set OriginalFilename, ResetShellWorker.1xe
;@Ahk2Exe-Set ProductName, ResetShellWor1er
;@Ahk2Exe-Set ProductVersion, 1.0.0.0
; ;@Ahk2Exe-SetMainIcon D:\Software\DEV\Work\AHK2\Projects\ResetShell\Icons\Cogs.ico
;@Ahk2Exe-SetMainIcon ..\Icons\Cogs.ico

;@Inno-Set AppId, {{FACAFAD1-6E57-473B-AB25-3BE3CD1FD0A5}}
;@Inno-Set AppPublisher, jasc2v8

; #region Globals

;global LogPath := EnvGet("PROGRAMDATA") "\AutoHotkey\ResetShell\ResetShellWorker.log"
global LogPath := "D:\ResetShellWorker.log"
global logger := LogFile(LogPath, "WORKER")
;logger.Disable()

logger.Write("START")

try
{
    ; Create a pipe instance
    logger.Write("Create pipe.")
    pipe:=NamedPipe("ResetShellWorker")
    pipe.Create()

    ; Receive the request from the client
    logger.Write("Read request.")
    request := pipe.Receive()
    logger.Write("Request Received: " request)

    ; Run the commandLine and wait to capture Output
    reply := RunCMD(request)

    reply:= Trim(reply, " `t`r`n")

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
