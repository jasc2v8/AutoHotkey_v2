; ABOUT: Server.ahk v1.0  (SharedMemory)
; 
/*
    TODO:

*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
; #NoTrayIcon

#Include <RunAsAdmin>
#Include <LogFile>
#Include SharedMemory.ahk

global logger:= LogFile("D:\Server.log", "SERVER")
logger.Clear()
;logger.Disable()

logger.Write("Start")

; Initialize as Server (3rd param = true)
;mem := SharedMemory("MyBridge", 4096, true)
mem := SharedMemory("MyBridge", , IsServer:=true)

Loop {

    data := mem.WaitRead()
    
    logger.Write("Client sent: " data )
    
    ;MsgBox "Client sent: " data

    mem.Write("ACK: " data)

        if (data="TERMINATE")
        break
}