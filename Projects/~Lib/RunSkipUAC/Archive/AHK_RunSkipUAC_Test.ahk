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
#Include <IPCSendMessage>
#Include <CRC>

logger := LogFile("C:\ProgramData\AutoHotkey\AhkRunSkipUAC\AHK_RunSkipUAC_Test.log", "AHK_RunSkipUAC_Test")
;logger.Disable()

SyncBackPath     := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
;SyncBackProfile  := "~Backup JIM-PC folders to JIM-SERVER"
SyncBackProfile  := "TEST WITH SPACES"
request:= "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe TEST WITH SPACES"

global SERVER_NAME := "AHK_RunSkipUAC"

global SECRET_KEY := CRC.Get64(SERVER_NAME, 'Decimal') ; 64-bit numeric password Must match receiver
;global SECRET_KEY := 123456

; Initialize the Client
server:= IPCSendMessage("Client", SERVER_NAME, SECRET_KEY, OnMessageReceived2)

;Sleep 1000

; Both of these work
serverHwnd:= server.GetHwnd()
;serverHwnd:= WinExist(SERVER_NAME)

if !serverHwnd {
    MsgBox "Server failed to start."
    ExitApp()
}

logger.Write("Sending: " request)

;MsgBox 

r:= server.Send(serverHwnd, request)

if (r>0)
    MsgBox "Result: " r , "Client send #1"

OnMessageReceived2(reply, serverHwnd) {

    logger.Write("Reply from Server: " reply)

    ;MsgBox("Reply from Server:`n`n" reply, "Client")

    ;Sleep 5000

    logger.Write("Sending: IPC_EXIT")

    r:= server.Send(serverHwnd, "IPC_EXIT")

    if (r>0)
        MsgBox "Result: " r , "Client send #2"

    ;Sleep 5000

    ExitApp()
}

Persistent
