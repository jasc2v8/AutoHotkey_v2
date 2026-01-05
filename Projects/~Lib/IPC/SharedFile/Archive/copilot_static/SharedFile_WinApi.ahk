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

class SharedFileIPC
{
    reqPath := ""
    respPath := ""
    running := false

    __New(reqPath, respPath) {
        this.reqPath  := reqPath
        this.respPath := respPath
    }

    ; ------------------------------------------------------------
    ; Low-level helpers
    ; ------------------------------------------------------------
    Open(path) {
        h := DllCall("CreateFile", "Str", path
            , "UInt", 0xC0000000      ; GENERIC_READ | GENERIC_WRITE
            , "UInt", 0x00000003      ; FILE_SHARE_READ | FILE_SHARE_WRITE
            , "Ptr", 0
            , "UInt", 4               ; OPEN_ALWAYS
            , "UInt", 0x80            ; FILE_ATTRIBUTE_NORMAL
            , "Ptr", 0, "Ptr")
        if (h = -1)
            throw Error("Failed to open: " path)
        return h
    }

    Lock(h, timeout := 2000) {
        ov := Buffer(32, 0)

        ; Infinite wait
        if (timeout < 0) {
            Loop {
                ok := DllCall("LockFileEx"
                    , "Ptr", h
                    , "UInt", 0x2
                    , "UInt", 0
                    , "UInt", 0xFFFFFFFF
                    , "UInt", 0xFFFFFFFF
                    , "Ptr", ov)
                if ok
                    return true
                Sleep(10)
            }
        }

        ; Timed wait
        start := A_TickCount
        while (A_TickCount - start < timeout) {
            ok := DllCall("LockFileEx"
                , "Ptr", h
                , "UInt", 0x2
                , "UInt", 0
                , "UInt", 0xFFFFFFFF
                , "UInt", 0xFFFFFFFF
                , "Ptr", ov)
            if ok
                return true
            Sleep(10)
        }
        return false
    }

    Unlock(h) {
        ov := Buffer(32, 0)
        return DllCall("UnlockFileEx"
            , "Ptr", h
            , "UInt", 0
            , "UInt", 0xFFFFFFFF
            , "UInt", 0xFFFFFFFF
            , "Ptr", ov)
    }

    Write(h, text) {
        DllCall("SetFilePointer", "Ptr", h, "Int", 0, "Ptr", 0, "UInt", 0)
        bytes := StrPut(text, "UTF-16") * 2
        buf := Buffer(bytes)
        StrPut(text, buf, "UTF-16")
        DllCall("SetEndOfFile", "Ptr", h)
        DllCall("WriteFile", "Ptr", h, "Ptr", buf, "UInt", buf.Size, "UInt*", 0, "Ptr", 0)
    }

    Read(h) {
        DllCall("SetFilePointer", "Ptr", h, "Int", 0, "Ptr", 0, "UInt", 0)
        size := DllCall("GetFileSize", "Ptr", h, "UInt*", 0)
        if size = 0
            return ""
        buf := Buffer(size)
        DllCall("ReadFile", "Ptr", h, "Ptr", buf, "UInt", size, "UInt*", 0, "Ptr", 0)
        return StrGet(buf, "UTF-16")
    }

    ; ------------------------------------------------------------
    ; CLIENT: Send request and wait for response
    ; ------------------------------------------------------------
    Send(message, timeout := 3000) {
        hReq  := this.Open(this.reqPath)
        hResp := this.Open(this.respPath)

        ; Read last response to detect change
        lastResp := ""
        if this.Lock(hResp, timeout) {
            lastResp := this.Read(hResp)
            this.Unlock(hResp)
        }

        ; Write request
        if !this.Lock(hReq, timeout)
            throw Error("Timeout waiting for request lock")
        this.Write(hReq, message)
        this.Unlock(hReq)

        ; Wait for new response
        start := A_TickCount
        Loop {
            if (A_TickCount - start > timeout)
                throw Error("Timeout waiting for server response")

            if this.Lock(hResp, 50) {
                msg := this.Read(hResp)
                this.Unlock(hResp)

                if msg != "" && msg != lastResp {
                    DllCall("CloseHandle", "Ptr", hReq)
                    DllCall("CloseHandle", "Ptr", hResp)
                    return msg
                }
            }
            Sleep(20)
        }
    }

    ; ------------------------------------------------------------
    ; SERVER: Blocking listen loop
    ; callback(request) → response
    ; ------------------------------------------------------------
    Listen(callback, poll := 50) {
        this.running := true

        hReq  := this.Open(this.reqPath)
        hResp := this.Open(this.respPath)

        lastReq := ""

        while this.running {

            ; BLOCK FOREVER waiting for request lock
            this.Lock(hReq, -1)
            req := this.Read(hReq)
            this.Unlock(hReq)

            if req != "" && req != lastReq {
                lastReq := req
                resp := callback(req)

                ; Write response
                this.Lock(hResp, -1)
                this.Write(hResp, resp)
                this.Unlock(hResp)

                ; Clear request file
                this.Lock(hReq, -1)
                this.Write(hReq, "")
                this.Unlock(hReq)
            }

            Sleep(poll)
        }

        DllCall("CloseHandle", "Ptr", hReq)
        DllCall("CloseHandle", "Ptr", hResp)
    }

    ; ------------------------------------------------------------
    ; Stop server loop
    ; ------------------------------------------------------------
    Stop() {
        this.running := false
    }
}
