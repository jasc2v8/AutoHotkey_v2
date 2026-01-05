; ABOUT:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon


; full_command_line := DllCall("GetCommandLine", "str")

; if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\\ S)"))
; {
;     try
;     {
;         if A_IsCompiled
;             Run '*RunAs "' A_ScriptFullPath '" /restart'
;         else
;             Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
;     }
;     ExitApp  ; Exit the current, non-elevated instance
; }

global ServiceLogFile:= "D:\ServiceLog.txt"

;; Non-admin client script (AHK v2)

global kName  := "Global\JimShared"
global kMutex := "Global\JimShared_Mutex"
global kSize  := 4096

main() {
    hMutex := OpenNamedMutex(kMutex)
    if !hMutex {
        MsgBox "Failed to open mutex."
        return
    }

    hMap := OpenGlobalMapping(kName)
    if !hMap {
        MsgBox "Failed to open mapping."
        return
    }
    pView := MapView(hMap, kSize)
    if !pView {
        MsgBox "Failed to map view."
        return
    }

    ; Read current message
    msg := ReadUtf8Message(pView, kSize, hMutex)
    ToolTip "Shared says: " msg

    FileAppend FormatTime(A_Now, "HH:mm:ss") ": " "Shared says: " msg "`n", ServiceLogFile


    Sleep 1500
    ToolTip

    ; Write a response
    WriteUtf8Message(pView, kSize, "Client updated at " A_Now, hMutex)

    ; Cleanup when done (keep open if you want to poll)
    UnmapView(pView)
    DllCall("CloseHandle", "ptr", hMap)
    DllCall("CloseHandle", "ptr", hMutex)
}
main()

; ---------- Helpers ----------

OpenNamedMutex(name) {
    ; SYNCHRONIZE (0x00100000) | MUTEX_MODIFY_STATE (0x00000001)
    desired := 0x00100000 | 0x00000001
    return DllCall("OpenMutexW", "uint", desired, "int", false, "wstr", name, "ptr")
}

WaitMutex(hMutex, timeout := 5000) {
    return DllCall("WaitForSingleObject", "ptr", hMutex, "uint", timeout, "uint")
}

ReleaseMutex(hMutex) {
    DllCall("ReleaseMutex", "ptr", hMutex)
}

OpenGlobalMapping(name) {
    FILE_MAP_ALL_ACCESS := 0xF001F
    return DllCall("OpenFileMappingW", "uint", FILE_MAP_ALL_ACCESS, "int", false, "wstr", name, "ptr")
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

ReadUtf8Message(pView, size, hMutex) {
    if WaitMutex(hMutex, 2000) != 0
        return ""
    try {
        len := NumGet(pView, 0, "uint")
        if (len < 0) || (len > size - 4)
            return ""
        buf := Buffer(len)
        DllCall("RtlMoveMemory", "ptr", buf.Ptr, "ptr", pView + 4, "ptr", len)
        return StrGet(buf, "UTF-8")
    } finally {
        ReleaseMutex(hMutex)
    }
}

WriteUtf8Message(pView, size, msg, hMutex) {
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