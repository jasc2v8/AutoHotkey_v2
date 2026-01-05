; TITLE  :  Sharedfile with Enmpty/Full Sync
; SOURCE :  jasc2v8 12/15/2025
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:

    SharedFile.txt Attributes
    -------------------------
     A = Full
    -A = Empty

*/

#Requires AutoHotkey v2.0+

; PURPOSE : Manages Inter-Process Communication with a Shared File.
; OVERVIEW: Uses the FileAttributes of the shared file to signal "Full" or "Empty". (A = Full, -A = Empty)
; USAGE   : Enables a normal user to send a command to a Windows Service or Task running as Admin.
;           The Service or Task then runs a process that requires Admin and bypasses the UAC prompt.
; TYPE    : "Server" is typically a Windows Service always running that receives commands from the Client.
;           "Server" can also be an on-demand task scheduled in the Task Scheduler.
;           "Server" creates and destroys the SharedFile.
;           "Client" sends commands to the Server or Task then recevies it's StdOutErr.
;-----------------------------------------------------------------------------------------------------------

;class SharedFile {

; ======================================================================
; SharedFile IPC Library (AHK v2) — UTF‑16LE
; ======================================================================

SF_Open(path) {
    hFile := DllCall("CreateFile", "Str", path
        , "UInt", 0xC0000000      ; GENERIC_READ | GENERIC_WRITE
        , "UInt", 0x00000003      ; FILE_SHARE_READ | FILE_SHARE_WRITE
        , "Ptr", 0
        , "UInt", 4               ; OPEN_ALWAYS
        , "UInt", 0x80            ; FILE_ATTRIBUTE_NORMAL
        , "Ptr", 0, "Ptr")
    if (hFile = -1)
        throw Error("Failed to open shared file: " path)
    return hFile
}

SF_Lock(hFile, timeout := 2000) {
    start := A_TickCount
    OVERLAPPED := Buffer(32, 0)

    while (A_TickCount - start < timeout) {
        ok := DllCall("LockFileEx"
            , "Ptr", hFile
            , "UInt", 0x2          ; LOCKFILE_EXCLUSIVE_LOCK
            , "UInt", 0
            , "UInt", 0xFFFFFFFF
            , "UInt", 0xFFFFFFFF
            , "Ptr", OVERLAPPED)

        if ok
            return true

        Sleep(10)
    }
    return false
}

SF_Unlock(hFile) {
    OVERLAPPED := Buffer(32, 0)
    return DllCall("UnlockFileEx"
        , "Ptr", hFile
        , "UInt", 0
        , "UInt", 0xFFFFFFFF
        , "UInt", 0xFFFFFFFF
        , "Ptr", OVERLAPPED)
}

; ----------------------------------------------------------------------
; UTF‑16LE Write
; ----------------------------------------------------------------------
SF_Write(hFile, text) {

    DllCall("SetFilePointer", "Ptr", hFile, "Int", 0, "Ptr", 0, "UInt", 0)
    ;bytes := StrLen(text) * 2 ; StrPut(text, "UTF-16") * 2   ; UTF‑16LE, no BOM
    bytes := StrPut(text, "UTF-16")   ; UTF‑16LE, no BOM
    buf := Buffer(bytes)
    StrPut(text, buf, "UTF-16")
    DllCall("SetEndOfFile", "Ptr", hFile)
    DllCall("WriteFile", "Ptr", hFile, "Ptr", buf, "UInt", buf.Size, "UInt*", 0, "Ptr", 0)
}

; ----------------------------------------------------------------------
; UTF‑16LE Read
; ----------------------------------------------------------------------
SF_Read(hFile) {
    DllCall("SetFilePointer", "Ptr", hFile, "Int", 0, "Ptr", 0, "UInt", 0)
    size := DllCall("GetFileSize", "Ptr", hFile, "UInt*", 0)
    if size = 0
        return ""
    buf := Buffer(size)
    DllCall("ReadFile", "Ptr", hFile, "Ptr", buf, "UInt", size, "UInt*", 0, "Ptr", 0)
    return StrGet(buf, "UTF-16")
}

; ----------------------------------------------------------------------
; Client: Send request and wait for response
; ----------------------------------------------------------------------
SF_RequestResponse(reqPath, respPath, message, timeout := 3000) {
    hReq  := SF_Open(reqPath)
    hResp := SF_Open(respPath)

    ; Read current response so we can detect a *change*
    lastResp := ""
    if SF_Lock(hResp, timeout) {
        lastResp := SF_Read(hResp)
        SF_Unlock(hResp)
    }

    ; Write request
    if !SF_Lock(hReq, timeout) {
        DllCall("CloseHandle", "Ptr", hReq)
        DllCall("CloseHandle", "Ptr", hResp)
        throw Error("Timeout waiting for request lock")
    }
    SF_Write(hReq, message)
    SF_Unlock(hReq)

    ; Wait for *new* response (different from lastResp)
    start := A_TickCount
    Loop {
        if (A_TickCount - start > timeout) {
            DllCall("CloseHandle", "Ptr", hReq)
            DllCall("CloseHandle", "Ptr", hResp)
            throw Error("Timeout waiting for server response")
        }

        if SF_Lock(hResp, 50) {
            msg := SF_Read(hResp)
            SF_Unlock(hResp)

            if msg != "" && msg != lastResp {
                DllCall("CloseHandle", "Ptr", hReq)
                DllCall("CloseHandle", "Ptr", hResp)
                return msg
            }
        }
        Sleep(20)
    }
}

; ----------------------------------------------------------------------
; Server: Wait for requests and respond
; callback(request) → response string
; ----------------------------------------------------------------------
SF_ServerLoop(reqPath, respPath, callback, poll := 100) {
    hReq  := SF_Open(reqPath)
    hResp := SF_Open(respPath)

    lastReq := ""

    Loop {
        if SF_Lock(hReq, 2000) {
            req := SF_Read(hReq)
            SF_Unlock(hReq)

            if req != "" && req != lastReq {
                lastReq := req

                ToolTip "LastReq: " lastReq "`nCurrentReq: " req

                resp := callback(req)

                ; Write response
                if SF_Lock(hResp, 2000) {
                    SF_Write(hResp, resp)
                    SF_Unlock(hResp)
                }
                
                ; Clear request file so next request is always detected
                if SF_Lock(hReq, 2000) {
                    SF_Write(hReq, "")
                    SF_Unlock(hReq)
                }

            }
        }
        Sleep(poll)
    }
}