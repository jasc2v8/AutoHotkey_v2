; TITLE  :  RunSkipUAC v1.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Run any program elevated without the UAC prompt
; USAGE  :  RunSkipUACHelper(WorkerPath)
; NOTES  :  On-Demand Task must be in Task Scheduler: AHK_RunSkipUAC
;           Client passes WorkerPath using NamedPipeHelper: RunSkipUACHelper(WorkerPath)
;           RunSkipUAC runs the WorkerPath with runLevel = 'highest'
;           Client now communicates with Program via NamedPipeHelper

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
Persistent

#SingleInstance Ignore
#NoTrayIcon

;Disable when run as a Task with runLevel='highest', Enable for debugging.
;#Include <RunAsAdmin>
#Include <LogFile>
#Include <SharedMemory>

logger := LogFile("D:\RunSkipUAC.log", "RunSkipUAC")
;logger.Disable()

; RunSkipUAC listen for WorkerPath from BackupControlToo
logger.Write("Listening...")

mem := SharedMemory("Server", "RunSkipUAC", 2048)

logger.Write("WaitForWrite...")

;request := Mem.WaitRead()
request := Mem.WaitForWrite()

;   RunSkipUAC run WorkerPath at runLevel='highest'
logger.Write("Request: " request)

Sleep 200

logger.Write("ACK: " request)

mem.Write("ACK: " request)

try {
    Run(request)
} catch any as e {
    logger.Write("ERROR: " e.Message)
}

mem:=""

Persistent false

; Task has exited, noone to send ACK to.
    ;ipc.Send(SenderHWND, "ACK from RunSkipUAC")
