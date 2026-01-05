; TITLE:    IPCRunTask v1.0
; SOURCE:   jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Runs an on-demand task then passes the program path using IPCSendMessage
;           Theto Run any program elevated without the UAC prompt
; USAGE  :  IPCRunTask(AHK_RunSkipUAC)
;           The on-demand Task AHK_RunSkipUAC must be created in Task Scheduler.
;           Client passes WorkerPath using IPCSendMessage.
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
#Include <IPCSendMessageBridge>
#Include <CRC>

Persistent

global SERVER_NAME := "IPCRunTask"

global SECRET_KEY := CRC.Get64(SERVER_NAME, 'Decimal') ; 64-bit numeric password Must match receiver

logger := LogFile("D:\IPCRunTask.log", "IPCRunTask")
;logger.Disable()

logger.Write(SERVER_NAME)

server:=IPCSendMessageBridge("Server", SERVER_NAME, SECRET_KEY, OnMessageReceived)

logger.Write("Server created")

logger.Write("Wait for Client request...")

OnMessageReceived(WorkerPath, clientHwnd) {

    logger.Write("Run " WorkerPath)

    try {
        Run(WorkerPath)
    } catch any as e {
        logger.Write("ERROR: " e.Message)
        ;MsgBox e.Message, "ERROR"
    }

    ;server.Send(clientHwnd, "Server ACK at " . FormatTime(A_Now, "HH:mm:ss") ": " request)
    server.Send(clientHwnd, "ACK")

    Persistent false
}
