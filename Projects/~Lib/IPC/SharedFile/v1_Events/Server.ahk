; ABOUT: Server.ahk v1.0 (SharedFile)
; 
/*
    TODO:

*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
; #NoTrayIcon

;#Include <RunAsAdmin>
#Include <LogFile>
#Include SharedFile.ahk

global logger:= LogFile("D:\Server.log", "SERVER")
logger.Clear()
logger.Disable()

logger.Write("START")

; Initialize as Server
mem := SharedFile("Server")

Loop {
    
    data := mem.WaitRead()
    
    logger.Write("Client sent: " data )
    
    ;MsgBox "Client sent: " data ; Pause the server to force timeout for debugging

    mem.Write("ACK: " data)

    if (data="TERMINATE")
        break
    
}
