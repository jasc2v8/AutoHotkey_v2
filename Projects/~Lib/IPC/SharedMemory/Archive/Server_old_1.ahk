; ABOUT: SharedmemoryMutex.ahk v1.0
; 
/*
    TODO:

*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
; #NoTrayIcon

#Include <LogFile>
#Include SharedMemory.ahk
#Include <RunAsAdmin>

global logger:= LogFile("D:\Server.log", "SERVER")
logger.Clear()
;logger.Disable()

logger.Write("START")

mem := SharedMemory("MySharedMemory",, IsServer:=true)

;MsgBox "START"

Loop {

    request := Mem.Read()

    ; if (request = "")
    ;     continue

    logger.Write("Request: " request)

    reply:= "ACK: " request

    mem.Write(reply)

    logger.Write(reply)

    if (request = "TERMINATE") {
        logger.Write(request)
        break
    }
}

logger.Write("EXIT")

ExitApp()
