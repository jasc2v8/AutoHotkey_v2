#Requires AutoHotkey v2.0
; Mutex Name must be identical in both scripts
Global MutexName := "Local\SharedResourceMutex"

; Create the Mutex
hMutex := DllCall("CreateMutex", "Ptr", 0, "Int", 0, "Str", MutexName, "Ptr")

MsgBox hMutex,"SERVER"

loop 5 {
    ToolTip("Server: Requesting access...")
    
    ; Wait for ownership (Infinite wait)
    ; 0xFFFFFFFF = INFINITE
    DllCall("WaitForSingleObject", "Ptr", hMutex, "UInt", 0xFFFFFFFF)
    
    ToolTip("Server: Access GRANTED. Writing to file...")
    FileAppend("Server wrote at " A_Now "`n", "shared_data.txt")
    Sleep(2000) ; Simulate heavy work
    
    ; Release the Mutex so the Client can use it
    DllCall("ReleaseMutex", "Ptr", hMutex)
    
    ToolTip("Server: Access Released.")
    Sleep(1000) ; Wait before trying to grab it again
}

DllCall("CloseHandle", "Ptr", hMutex)
MsgBox("Server finished.")