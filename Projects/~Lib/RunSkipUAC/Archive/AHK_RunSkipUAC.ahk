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
#SingleInstance Ignore
;#NoTrayIcon

;Disable when run as a Task with runLevel='highest'
;#Include <RunAsAdmin>
#Include <LogFile>
#Include <IPCSendMessage>
#Include <CRC>

Persistent

global SERVER_NAME := "AHK_RunSkipUAC"

global SECRET_KEY := CRC.Get64(SERVER_NAME, 'Decimal') ; 64-bit numeric password Must match receiver

logger := LogFile("C:\ProgramData\AutoHotkey\AhkRunSkipUAC\AHK_RunSkipUAC.log", "AHK_RunSkipUAC")
logger.Disable()

logger.Write(SERVER_NAME)

server:=IPCSendMessage("Server", SERVER_NAME, SECRET_KEY, OnMessageReceived)

logger.Write("Server created")

logger.Write("Wait for Client request...")

OnMessageReceived(request, clientHwnd) {

    logger.Write("Run " request)

    try {
        Run(request)
    } catch any as e {
        logger.Write("ERROR: " e.Message)
        MsgBox e.Message, "ERROR"
    }

    ;server.Send(clientHwnd, "Server ACK at " . FormatTime(A_Now, "HH:mm:ss") ": " request)
    server.Send(clientHwnd, "ACK")

    Persistent false
}
