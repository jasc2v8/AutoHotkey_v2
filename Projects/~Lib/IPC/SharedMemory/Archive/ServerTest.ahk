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
Persistent()

#Include SharedMemory.ahk

global logger:= LogFile("D:\Server.log", "SERVER")
logger.Clear()
;logger.Disable()

mem := SharedMemory("TestMap", 4096, true)

MsgBox("Server is running. Press F1 to send data to Client.")

F1:: {
    mem.Write("Hello from Server! Time: " . A_TickCount)
    ToolTip("Data Sent!")
    SetTimer(() => ToolTip(), -2000)
}