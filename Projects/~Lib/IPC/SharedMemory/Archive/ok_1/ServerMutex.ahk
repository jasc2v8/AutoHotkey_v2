; ABOUT: SharedmemoryMutex.ahk v1.0
; 
/*
    TODO:

*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
; #NoTrayIcon

#Include <LogFile>
#Include SharedmemoryMutex.ahk
#Include <RunAsAdmin>

global logger:= LogFile("D:\ServerMutex.log", "SERVER")
logger.Clear()
;logger.Disable()

logger.Write("START")

mem := Sharedmemory("MyProject", 1024)

MsgBox "START"

Loop {

    request := Mem.WaitForWrite()

    if (request = "")
        continue

    logger.Write("Read")

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
