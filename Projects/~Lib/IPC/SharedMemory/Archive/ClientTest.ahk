#Requires AutoHotkey v2
Persistent()
#Include SharedMemory.ahk

try {
    mem := SharedMemory("TestMap", 4096, false)
    
    ; Setup the callback listener
    mem.ReadWaitCallback((data) => MsgBox("Client Received: " . data))
    
    ToolTip("Client is listening...")
} catch Any as e {
    MsgBox("Connection failed: " . e.Message)
}