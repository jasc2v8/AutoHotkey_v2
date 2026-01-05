; ABOUT:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

global ServiceLog:= "D:\ServiceLog.txt"
global UpdateCount:=0

OnExit MyExit

; --- User Script (Non-Admin/Reader) ---

; WinAPI Constants
FILE_MAP_READ := 0x04 ; Read-only access

SharedMemName := 'Global\AHKSharedMemory'
BufferSize := 1024

; --- 1. Open the File Mapping Object ---
; This requires the permissive security created by the service.
hMapFile := DllCall("OpenFileMapping", 
    "UInt", FILE_MAP_READ,      ; dwDesiredAccess: Read-only
    "Int", 0,                   ; bInheritHandle: false
    "Str", SharedMemName,       ; lpName
    "Ptr")

if hMapFile = 0
{
    MsgBox("Cannot open shared memory (Service not running or permission issue). Error: " . A_LastError, "Error", 'IconX')
    ExitApp
}

; --- 2. Map the View (Get the memory address) ---
pData := DllCall("MapViewOfFile",
    "Ptr", hMapFile,             ; hFileMappingObject
    "UInt", FILE_MAP_READ,       ; dwDesiredAccess
    "UInt", 0,                   ; dwFileOffsetHigh
    "UInt", 0,                   ; dwFileOffsetLow
    "UInt", BufferSize,          ; dwNumberOfBytesToMap
    "Ptr")

if pData = 0
{
    MsgBox("Error mapping view: " . A_LastError, "Error", 'IconStop')
    DllCall("CloseHandle", "Ptr", hMapFile)
    ExitApp
}

; --- 3. Main Loop: Read Data from the Shared Memory ---
SetTimer ReadSharedData, 1000 ; Read every 1 second

ReadSharedData()
{
    global pData, BufferSize
    
    ; Create a buffer to read the data into
    DataBuf := Buffer(BufferSize, 0)
    
    ; Copy data from shared memory into the local buffer
    DllCall("RtlMoveMemory", "Ptr", DataBuf.Ptr, "Ptr", pData, "Ptr", BufferSize)
    
    ; Extract the string from the local buffer
    CurrentStatus := StrGet(DataBuf, BufferSize, "UTF-8")
    
    ;TraySetInfo("Service Status: " . CurrentStatus)
    FileAppend("User Read Status: " . CurrentStatus "`n", ServiceLog)

    MsgBox "User Pause for Service to Write."
    
    WriteSharedData()
}

WriteSharedData()
{
    global pData, BufferSize, UpdateCount
    
    UpdateCount++
    DataToWrite := "User Status: Running (" . UpdateCount . ")"
    
    try {
        
        ; Create a buffer to hold the string data
        DataBuf := Buffer(BufferSize, 0)
        
        ; Copy string data into the buffer
        StrPut(DataToWrite, DataBuf, BufferSize, "UTF-8")
        
        ; Copy the entire buffer into the shared memory space
        DllCall("RtlMoveMemory", "Ptr", pData, "Ptr", DataBuf.Ptr, "Ptr", BufferSize)

        FileAppend("User Write to Shared memory: " . DataToWrite . "`n", ServiceLog)

    } catch Error as e {

        FileAppend("User Write Error: " . e.Message . "`n", ServiceLog)
    }
}    
 
; --- 4. Cleanup (Executed when the script exits) ---
MyExit(*){
    DllCall("UnmapViewOfFile", "Ptr", pData)
    DllCall("CloseHandle", "Ptr", hMapFile)
}