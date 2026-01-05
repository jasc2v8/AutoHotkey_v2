; ABOUT: SharedmemoryMutex.ahk v1.0
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

logger.Write("START")

; Setup as Server
mem := SharedMemory("MyIPC", 4096, true)

;mem.ReadWaitCallback(HandleIncoming)

mem.ReadWaitCallback((data) => MsgBox("Background received: " . data))


; Define the callback function
HandleIncoming(text) {
    MsgBox("Received from Client: " . text)
}

; Start listening
;mem.OnMessage(HandleIncoming)

; Script stays open and responsive
Persistent()
