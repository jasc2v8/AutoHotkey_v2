; TITLE: RestartFontCacheTask v1.0

; Runs as a scheduled Task with runLevel = 'highest'
; The client must run this Task first before sending commands
; The client must end this Task before exiting

/*
    TODO:
*/

#Requires AutoHotkey 2.0+
#SingleInstance Force
;#NoTrayIcon
TraySetIcon('dsuiext.dll', 36   ) ; Two cogs

#Include <LogFile>
#Include <RunCMD>
#Include <NamedPipe>

; #region Version Block

; Language codes (en-US=1033): https://www.autoitscript.com/autoit3/docs/appendix/OSLangCodes.htm
;@Ahk2Exe-Set CompanyName, jasc2v8
;@Ahk2Exe-Set FileDescription, RestartFontCacheTask
;@Ahk2Exe-Set FileVersion, 1.0.0.0
;@Ahk2Exe-Set InternalName, Ahk Restart Font Cache Task
;@Ahk2Exe-Set Language, 1033
;@Ahk2Exe-Set LegalCopyright, ©2025 jasc2v8
;@Ahk2Exe-Set LegalTrademarks, NONE™
;@Ahk2Exe-Set OriginalFilename, RestartFontCacheTask.exe
;@Ahk2Exe-Set ProductName, RestartFontCacheTask
;@Ahk2Exe-Set ProductVersion, 1.0.0.0
;@Ahk2Exe-SetMainIcon D:\Software\DEV\Work\AHK2\Projects\RestartFontCache\Cogs.ico

;@Inno-Set AppId, {{AD23A6D8-E83F-46DE-B54D-EFB69FB69D73}}
;@Inno-Set AppPublisher, jasc2v8

; #region Globals

LogFilePath := "D:\RestartFontCacheWorker.log"
global logger := LogFile(LogFilePath, "TASK")
logger.Disable()

logger.Write("START Worker")

try
{
    ; This server creates the pipe
    logger.Write("Create pipe.")
    pipe:=NamedPipe("Worker")
    pipe.Create()

    ; Receive the request from the client
    logger.Write("Read request.")
    request := pipe.Receive()
    logger.Write("Request Received: " request)
    
    ; Run the commandLine and wait to capture Output
    ; reply := RunCMD(request)
    ; reply:= Trim(reply, " `t`r`n")

    ;
    ; Perform Work
    ;
    logger.Write("Work Start")
    r := PerformWork(request)

    ; Sleep 1000
    ; logger.Write("Perform Work...")
    ; Sleep 1000

    logger.Write("Work End")

    ; Send ACK
    logger.Write("Send reply.")
    reply := "ACK: " (r:=true) ? "Success" : "Fail"
    pipe.Send(reply)

    if (request = "TERMINATE") {
        logger.Write("TERMINATE")
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

PerformWork(request) {

    ; 0=success, non-zero=failure
    result := ServiceControl("stop", "FontCache")

    ;logger.Write("ServiceControl STOP   Result: " result.ExitCode "`n`nOutput: " result.Output)
    logger.Write("ServiceControl STOP   Result: " result.ExitCode)

    if (result.ExitCode) {
        logger.Write("Failed to stop FontCache.")
        return false
    }

    ; Allow time to stop
    Sleep 200

    ; 0=success, non-zero=failure
    success := ServiceControl("start", "FontCache")

    ;logger.Write("ServiceControl START Result: " result.ExitCode "`n`nOutput: " result.Output)
    logger.Write("ServiceControl START Result: " result.ExitCode)

    if (result.ExitCode) {
        logger.Write("Failed to restart FontCache.")
        ExitApp()
    }

    ; Allow time to start
    Sleep 200

    ;
    ; Restart explorer.exe
    ;

    ; try {
    ;     ; Kill explorer.exe
    ;     RunWait("taskkill /f /im explorer.exe", , "Hide")

    ;     ; Delay to ensure it's terminated
    ;     Sleep(1000)

    ;     ; Relaunch explorer.exe
    ;     Run("explorer.exe", , "Hide")

    ;     ;Delay to ensure it's restarted
    ;     Sleep(1000)

    ; } catch Error as e {
    ;     logger.Write("Failed to restart Explorer:`n" e.Message)
    ; }

    return true

}

; --- Service Control Wrapper ---
ServiceControl(action, serviceName) {
    ; action: "start", "stop", "query"
    ; serviceName: internal service name (not display name)

    ; Build command
    cmd := Format('sc {} "{}"', action, serviceName)

    ; Run and capture output
    shell := ComObject("WScript.Shell")
    exec  := shell.Exec(cmd)
    output := ""
    while !exec.StdOut.AtEndOfStream {
        output .= exec.StdOut.ReadLine() . "`n"
    }

    ; Return structured result
    return {
        Action: action,
        Service: serviceName,
        Output: output,
        ExitCode: exec.ExitCode
    }
}

 



ExitApp()

CheckTimeout(timeout, number) {
    if (timeout)
        MsgBox("Timeout Number: " number , A_ScriptName, "iconX")
}

; the Client will delete the shared file
ExitHandler(*) {
    logger.Write("Task Exit!")
}

