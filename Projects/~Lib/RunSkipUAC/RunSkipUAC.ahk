; TITLE  :  RunSkipUAC v1.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Run any program elevated without the UAC prompt
; USAGE  :  TaskName AHK_RunSkipUAC runs RunSkipUAC.ahk 
; NOTES  :  On-Demand Task must be in Task Scheduler: AHK_RunSkipUAC
;           Controller starts TaskName AHK_RunSkipUAC
;           AHK_RunSkipUAC runs RunSkipUAC.ahk at runLevel='highest'
;           Controller Sends the WorkerPath to RunSkipUAC using NamedPipe IPC.
;           RunSkipUAC runs the WorkerPath with runLevel = 'highest'
;           Controller now communicates with the Worker using NamedPipe IPC.
;           Controllser sends BackupRequest to Worker, Worker runs BackupRequest.

/*
    TODO:
*/

#Requires AutoHotkey v2.0+

#SingleInstance Ignore
#NoTrayIcon

#Include <LogFile>
#Include <NamedPipe>

logger := LogFile("D:\RunSkipUAC.log", "RunSkipUAC")
;logger.Disable()

logger.Write("START")

class RunSkipUAC {

    __New(TaskName := "AHK_RunSkipUAC") {

        logger.Write("Start Task: " TaskName)
        this.StartTask(TaskName)

        logger.Write("Create pipe")
        pipe := NamedPipe("RunSkipUAC")
        pipe.Create()

        logger.Write("Pipe Listen")
        path:= pipe.Receive()
        logger.Write("Received      : " path)
        logger.Write("Run Elevated: " path)
        Run(path)
            
        ;logger.Write("Close Path")
        ;pipe.Close()

        logger.Write("Exit")
        ExitApp()
    }

    Start(WorkerPath) {
        pipe := NamedPipe("RunSkipUAC")
        pipe.Send(WorkerPath)
        pipe.Close()
    }

    StartTask(TaskName) {

        cmd := Format('schtasks /run /tn "{}"', TaskName)

        try
        {
            Run(A_ComSpec ' /c ' cmd, , "Hide")
        }
        catch
        {
            throw Error("Failed to run scheduled task.")
        }
        finally {
        }

    }

    __Destroy() {
        logger.Write("Destroy")
        pipe.Close()
    }
}

RunSkipUAC()
