; TITLE:    RunSkipUAC v2.0
; SOURCE:   jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  On-demand task to Run any program elevated without the UAC prompt
; USAGE  :  This on-demand Task must be in Task Scheduler: AHK_RunSkipUAC
;           Client passes WorkerPath using NamedPipe: RunSkipUAC(WorkerPath)
;           RunSkipUAC starts this on-demand Task: AHK_RunSkipUAC
;           AHK_RunSkipUAC runs the WorkerPath with runLevel = 'highest'
;           Client now communicates with WorkerPath via IPCSendMessage

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include <LogFile>
#Include <NamedPipe>

; #region Globals

logger := LogFile("C:\ProgramData\AutoHotkey\AhkRunSkipUAC\AHK_RunSkipUAC.log", "AHK_RunSkipUAC")

;logger.Disable()

; true logger.Write("IsAdmin: " A_IsAdmin)

logger.Write("pipe=NamedPipe")

try
{
    ; Create a pipe instance for the RunSkipUAC program
    pipe := NamedPipe("AHK_RunSkipUAC")

    logger.Write("Create pipe")

    ; This server creates the pipe
    pipe.Create()

    logger.Write("Server created")

    ; Read client request
    WorkerPath := pipe.Receive()

    logger.Write("WorkerPath: " WorkerPath)

    ; Run Program
    if FileExist(WorkerPath) 
        Run(WorkerPath)

}
catch any as e
{
  logger.Write("ERROR: " e.Message)
}
finally
{
    logger.Write("pipe.Close")
    pipe.Close()
    pipe:=""
    ExitApp()
}

