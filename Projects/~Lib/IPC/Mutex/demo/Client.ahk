#Requires AutoHotkey v2.0
Global MutexName := "Local\SharedResourceMutex"

; Open an existing Mutex
; SYNCHRONIZE (0x00100000)
hMutex := DllCall("OpenMutex", "UInt", 0x00100000, "Int", 0, "Str", MutexName, "Ptr")

MsgBox hMutex,"CLIENT"

if (!hMutex) {
    MsgBox("Could not open Mutex. Is the Server running?")
    ExitApp()
}

loop 5 {
    ToolTip("Client: Waiting for Server to finish...")
    
    ; Wait for the Server to ReleaseMutex
    DllCall("WaitForSingleObject", "Ptr", hMutex, "UInt", 0xFFFFFFFF)
    
    ToolTip("Client: Access GRANTED. Reading file...")
    try {
        txt := FileRead("shared_data.txt")
        MsgBox("Client read: `n" txt, "Data Received", "T2")
    }
    
    DllCall("ReleaseMutex", "Ptr", hMutex)
    ToolTip("Client: Access Released.")
    Sleep(1500)
}

DllCall("CloseHandle", "Ptr", hMutex)