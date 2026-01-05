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
logger.Disable()

logger.Write("Create Pipe")

pipe := NamedPipe("RunSkipUAC")

try {

    ; Create a fresh pipe instance
    pipe.Create()

    ; RunSkipUAC listen for WorkerPath from BackupControlTool
    WorkerPath := pipe.Receive()

    logger.Write("Recevied    : " WorkerPath)
    logger.Write("Run Elevated: " WorkerPath)

    ; RunSkipUAC run WorkerPath at runLevel='highest'
    Run(WorkerPath)

    ; Handle request
    reply := "ACK: " WorkerPath

    logger.Write("Reply: " reply)

    ; Send reply
    pipe.Send(reply)

}
catch as err
{
    logger.Write("ERROR: " err.Message)
}
finally
{
    pipe.Close()

    logger.Write("Exit")

    ;ExitApp()
}

