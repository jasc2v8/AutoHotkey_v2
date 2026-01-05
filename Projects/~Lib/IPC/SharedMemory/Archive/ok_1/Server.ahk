; ABOUT: ShowArgs.ahk v10
; 
/*
    TODO:

*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
;#NoTrayIcon

#Include SharedMemory.ahk
#Include <LogFile>
#INclude <RunAsAdmin>

global logger:= LogFile("D:\Server.log", "SERVER")
logger.Clear()
;logger.Disable()

; Initialize Shared Memory
name := "MyFileMap"
size := 1024
mem := SharedMemory("Server", name, size)

TrayTip "Server Listening...", "Server Status"

SetTimer(HideTrayTip, -1000)

HideTrayTip() {
    TrayTip ; Calling with no arguments clears the current notification
}

Sleep 1000 ; wait for HideTrayTip to run before entering the Loop

Loop {

    logger.Write("Read")

    request := mem.Read()

    logger.Write("Request: " request)

    if (request = "TERMINATE") {
        logger.Write(request)
        mem.SetEvent("Received")
        Sleep 500
        break
    }

    logger.Write("Simulate Work")

    Sleep 1000

    reply:= "ACK: " request

    logger.Write(reply)

    mem.Write(reply)

    Sleep 100
}
