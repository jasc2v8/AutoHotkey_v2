; ABOUT:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

; --- Service Script (Admin/Writer) --

full_command_line := DllCall("GetCommandLine", "str")

if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\\ S)"))
{
    try
    {
        if A_IsCompiled
            Run '*RunAs "' A_ScriptFullPath '" /restart'
        else
            Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
    }
    ExitApp  ; Exit the current, non-elevated instance
}

OnExit MyExit

global ServiceLog:= "D:\ServiceLog.txt"

; WinAPI Constants
PAGE_READWRITE := 0x04
FILE_MAP_ALL_ACCESS := 0xF001F ; Includes necessary sync and R/W rights

SharedMemName := 'Global\AHKSharedMemory'
BufferSize := 1024
StructSize := A_PtrSize * 3 + 4 ; SECURITY_ATTRIBUTES structure size

; --- 1. Create a SECURITY_ATTRIBUTES structure (SA) for cross-user access ---
; Setting lpSecurityDescriptor to 0 (NULL) usually grants full access 
; for kernel objects to all authenticated users.
SA := Buffer(StructSize, 0)
NumPut('UInt', StructSize, SA, 0) ; nLength
NumPut('Ptr', 0, SA, 4) ; lpSecurityDescriptor (NULL for default, permissive security)
NumPut('Int', 0, SA, 4 + A_PtrSize) ; bInheritHandle

; --- 2. Create the File Mapping Object (Shared Memory) ---
hMapFile := DllCall("CreateFileMapping", 
    "Ptr", -1,                   ; hFile: -1 (INVALID_HANDLE_VALUE) for file-less mapping
    "Ptr", SA.Ptr,               ; lpFileMappingAttributes: Pointer to the security structure
    "UInt", PAGE_READWRITE,      ; flProtect: Read/Write
    "UInt", 0,                   ; dwMaximumSizeHigh
    "UInt", BufferSize,          ; dwMaximumSizeLow
    "Str", SharedMemName,        ; lpName: MUST use "Global\" prefix
    "Ptr")

if hMapFile = 0
{
    FileAppend("Error creating shared memory: " . A_LastError . "`n", ServiceLog)
    ExitApp
}

; --- 3. Map the View (Get the memory address) ---
pData := DllCall("MapViewOfFile",
    "Ptr", hMapFile,             ; hFileMappingObject
    "UInt", FILE_MAP_ALL_ACCESS, ; dwDesiredAccess
    "UInt", 0,                   ; dwFileOffsetHigh
    "UInt", 0,                   ; dwFileOffsetLow
    "UInt", BufferSize,          ; dwNumberOfBytesToMap
    "Ptr")

if pData = 0
{
    FileAppend("Error mapping view: " . A_LastError . "`n", ServiceLog)
    DllCall("CloseHandle", "Ptr", hMapFile)
    ExitApp
}

; --- 4. Main Loop: Write Data to the Shared Memory ---

FileAppend("Service starting Main Loop`n", ServiceLog)

UpdateCount := 0
SetTimer WriteSharedData, 2000 ; Write every 2 seconds

WriteSharedData()
{
    global pData, BufferSize, UpdateCount
    
    UpdateCount++
    DataToWrite := "Service Status: Running (" . UpdateCount . ")"
    
    try {
        
        ; Create a buffer to hold the string data
        DataBuf := Buffer(BufferSize, 0)
        
        ; Copy string data into the buffer
        StrPut(DataToWrite, DataBuf, BufferSize, "UTF-8")
        
        ; Copy the entire buffer into the shared memory space
        DllCall("RtlMoveMemory", "Ptr", pData, "Ptr", DataBuf.Ptr, "Ptr", BufferSize)

        FileAppend("Service Write to Shared memory: " . DataToWrite . "`n", ServiceLog)

    } catch Error as e {

        FileAppend("Service Write Error: " . e.Message . "`n", ServiceLog)
    }
    
    MsgBox "User Pause for User to Write."

    ReadSharedData()
}    
 

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
    FileAppend("Service Read Status: " . CurrentStatus "`n", ServiceLog)
}

;FileAppend("Service starting Pause`n", ServiceLog)

; Keep the service alive (Service Manager will handle stopping/exiting)
;Pause

; --- 5. Cleanup (Executed when the script exits) ---
MyExit(*){
    DllCall("UnmapViewOfFile", "Ptr", pData)
    DllCall("CloseHandle", "Ptr", hMapFile)
}