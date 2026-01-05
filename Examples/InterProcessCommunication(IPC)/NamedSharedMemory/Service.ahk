; ABOUT:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

; Admin service script (AHK v2)
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

global ServiceLogFile:= "D:\ServiceLog.txt"

global kName    := "Global\JimShared"
global kMutex   := "Global\JimShared_Mutex"
global kSize    := 4096

main() {
    hMutex := CreateNamedMutex(kMutex)
    if !hMutex {
        MsgBox "Failed to create mutex."
        return
    }

    sa := BuildNullDaclSA() ; permissive: allow non-admin access
    hMap := CreateGlobalMapping(kName, kSize, sa)
    if !hMap {
        MsgBox "Failed to create mapping."
        return
    }
    pView := MapView(hMap, kSize)
    if !pView {
        MsgBox "Failed to map view."
        return
    }

    ; Service loop: update shared memory periodically
    while true {
        msg := Format("Service alive at {}.{}", A_Now, A_TickCount)
        WriteUtf8Message(pView, kSize, msg, hMutex)

        FileAppend FormatTime(A_Now, "HH:mm:ss") ": " msg "`n", ServiceLogFile

        Sleep 1000
    }

    ; Normally unreachable in a service loop; included for completeness
    UnmapView(pView)
    DllCall("CloseHandle", "ptr", hMap)
    DllCall("CloseHandle", "ptr", hMutex)
}
main()

; ---------- Helpers ----------

CreateNamedMutex(name) {
    return DllCall("CreateMutexW", "ptr", 0, "int", false, "wstr", name, "ptr")
}

WaitMutex(hMutex, timeout := 5000) {
    return DllCall("WaitForSingleObject", "ptr", hMutex, "uint", timeout, "uint")
}

ReleaseMutex(hMutex) {
    DllCall("ReleaseMutex", "ptr", hMutex)
}

BuildNullDaclSA() {

    StructSize := A_PtrSize * 3 + 4 ; SECURITY_ATTRIBUTES structure size

; --- 1. Create a SECURITY_ATTRIBUTES structure (SA) for cross-user access ---
; Setting lpSecurityDescriptor to 0 (NULL) usually grants full access 
; for kernel objects to all authenticated users.
SA := Buffer(StructSize, 0)
NumPut('UInt', StructSize, SA, 0) ; nLength
NumPut('Ptr', 0, SA, 4) ; lpSecurityDescriptor (NULL for default, permissive security)
NumPut('Int', 0, SA, 4 + A_PtrSize) ; bInheritHandle


    ; SECURITY_DESCRIPTOR with NULL DACL (allows everyone full access).
    ; Use with caution; tighten in production.
    ; sd := Buffer(20, 0) ; SECURITY_DESCRIPTOR is opaque, but 20 bytes minimum for InitializeSecurityDescriptor
    ; if !DllCall("Advapi32\InitializeSecurityDescriptor", "ptr", sd, "uint", 1) ; SECURITY_DESCRIPTOR_REVISION = 1
    ;     return 0
    ; if !DllCall("Advapi32\SetSecurityDescriptorDacl", "ptr", sd, "int", true, "ptr", 0, "int", false)
    ;     return 0
    ; sa := Buffer(12, 0)
    ; NumPut("uint", sa.Size, sa, 0)                 ; nLength
    ; NumPut("ptr",  sd.Ptr,  sa, 4)                 ; lpSecurityDescriptor
    ; NumPut("int",  false,   sa, 4 + A_PtrSize)     ; bInheritHandle
    return sa
}

CreateGlobalMapping(name, size, sa := 0) {
    PAGE_READWRITE := 0x04
    ; INVALID_HANDLE_VALUE = (HANDLE)-1
    return DllCall("CreateFileMappingW"
        , "ptr", -1
        , "ptr", sa ? sa.Ptr : 0
        , "uint", PAGE_READWRITE
        , "uint", 0
        , "uint", size
        , "wstr", name
        , "ptr")
}

MapView(hMap, size) {
    FILE_MAP_ALL_ACCESS := 0xF001F
    return DllCall("MapViewOfFile"
        , "ptr", hMap
        , "uint", FILE_MAP_ALL_ACCESS
        , "uint", 0
        , "uint", 0
        , "uptr", size
        , "ptr")
}

UnmapView(pView) {
    DllCall("UnmapViewOfFile", "ptr", pView)
}

WriteUtf8Message(pView, size, msg, hMutex) {
    ; Layout: [DWORD length][bytes...]
    if WaitMutex(hMutex, 2000) != 0
        return false
    try {
        buf := Buffer(StrPut(msg, "UTF-8"))
        len := buf.Size
        if (len + 4) > size
            len := size - 4
        NumPut("uint", len, pView, 0)
        DllCall("RtlMoveMemory", "ptr", pView + 4, "ptr", buf.Ptr, "ptr", len)
        return true
    } finally {
        ReleaseMutex(hMutex)
    }
}

    mapping := unset

