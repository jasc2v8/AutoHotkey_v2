; TITLE:    RestartFontCache v1.0
; SOURCE:   jasc2v8 12/15/2025
; LICENSE:  The Unlicense, see https://unlicense.org

; TITLE:    A work-around for the Win11 issue of empty Sarch bar results
;           Intended to be on-demand Task scheduled in Task Scheduler with runLevel='highest'
;           Recommend to run at login until windows 11 gets fixed

/*
    TODO:
*/

#Requires AutoHotkey v2.0+

; Requires Admin

; #region Version Block

; Language codes (en-US=1033): https://www.autoitscript.com/autoit3/docs/appendix/OSLangCodes.htm
;@Ahk2Exe-Set CompanyName, jasc2v8
;@Ahk2Exe-Set FileDescription, RestartFontCache
;@Ahk2Exe-Set FileVersion, 1.0.0.0
;@Ahk2Exe-Set InternalName, Restart Font Cache Task
;@Ahk2Exe-Set Language, 1033
;@Ahk2Exe-Set LegalCopyright, ©2025 jasc2v8
;@Ahk2Exe-Set LegalTrademarks, NONE™
;@Ahk2Exe-Set OriginalFilename, RestartFontCache.exe
;@Ahk2Exe-Set ProductName, RestartFontCache
;@Ahk2Exe-Set ProductVersion, 1.0.0.0
;@Ahk2Exe-SetMainIcon D:\Software\DEV\Work\AHK2\Projects\RestartFontCache\Cogs.ico

;@Inno-Set AppId, {{D27EC431-B8B5-4171-B68A-8B123DCD5BED}}
;@Inno-Set AppPublisher, jasc2v8

#Include <LogFile>
#Include <NamedPipe>
#Include <RunTask>

; #region Globals

global logger := LogFile("D:\RestartFontCache.log", "CONTROL")
logger.Disable()

WorkerPath := "D:\Software\DEV\Work\AHK2\Projects\~Tools\RestartFontCache\RestartFontCacheWorker.ahk"

; #region Main

MsgBox "Press OK to Restart Windows Font Cache.", "Icon?"

StartTask("AHK_RunSkipUAC") ; RunSkipUAC runs RunSkipUAC.ahk at runLevel='highest'

SendPathToRunSkipUAC(WorkerPath)

SendRequestToWorker("START")
    
logger.Write("Finished.")

MsgBox "Finished Restarting Windows Font Cache.", "Iconi"

ExitApp()

SendPathToRunSkipUAC(WorkerPath) {

    logger.Write("Send WorkerPath to RunSkipUAC: " WorkerPath)

    try {

        logger.Write("Create pipe Instance.")

        pipe := NamedPipe("RunSkipUAC")

        logger.Write("Wait for RunSkipUAC to create pipe...")

        r := pipe.Wait(5000)

        if (!r) {
            logger.Write("Timeout Waiting for pipe.")
            MsgBox "Timeout Waiting for pipe.", "Timeout", "IconX"
            ExitApp()
        }

        logger.Write("Pipe Ready.")

        logger.Write("Send Request: " WorkerPath)
        pipe.Send(WorkerPath)

        reply := pipe.Receive()
        logger.Write("Reply Received: " reply)

    }
    catch any as e
    {
        logger.Write("ERROR: " e.Message)
    }
    finally
    {
        logger.Write("Pipe close.")
        pipe.Close()
        pipe:=""
    }

}

SendRequestToWorker(Request) {

    try
    {
        logger.Write("Create pipe Instance.")
        pipe := NamedPipe("Worker")

        logger.Write("Wait for Worker to create pipe...")
        r := pipe.Wait(5000)

        if (!r) {
            logger.Write("Timeout Waiting for pipe.")
            MsgBox "Timeout Waiting for pipe.", "Timeout", "IconX"
            ExitApp()
        }

        logger.Write("Pipe Ready.")

        logger.Write("Send Request: " Request)
        pipe.Send(Request)

        reply := pipe.Receive()
        logger.Write("Reply Received: " reply)

    }
    catch any as e
    {
        logger.Write("ERROR: " e.Message)
    }
    finally
    {
        logger.Write("Pipe close.")
        pipe.Close()
        pipe:=""
    }
}

StartTask(TaskName) {

    logger.Write("StartTask: " TaskName)

    task := RunTask(TaskName)  ; RunSkipUAC runs RunSkipUAC.ahk at runLevel='highest'

    logger.Write("Wait for TaskName: " TaskName)

    DetectHiddenWindows true
    SetTitleMatchMode 2 ; contains=default

    timeout := WinWait("RunSkipUAC",,5)

    if !timeout {
        logger.Write("Timeout waiting for Worker to start.")
        ExitApp()
    }

}
