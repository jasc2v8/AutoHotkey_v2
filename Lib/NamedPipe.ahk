; TITLE  :  NamedPipeHelper v1.0
; SOURCE :  chatGPT and jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Helper for Named Pipe IPC communication
; BENEFIT:  Send and Receive are Synchronous for easy read/write sharing.

/*
    TODO:
*/

#Requires AutoHotkey v2.0+

class NamedPipe
{
    PipeName := ""
    Handle   := 0

    static SDDL := "D:(A;;GA;;;BU)(A;;GA;;;BA)"

    __New(pipeName:="")
    {
        if (pipeName = "")
            this.PipeName := "\\.\pipe\Global\AHK_Pipe"
        else
            this.PipeName := "\\.\pipe\Global\" pipeName
    }

    ; =========================
    ; SERVICE SIDE (SERVER)
    ; =========================
    Create()
    {
        if this.PipeExists(this.PipeName) {
            throw Error("Pipe already exists")
            ;if DllCall("kernel32\ConnectNamedPipe", "Ptr", this.Handle, "Ptr", 0) = 0
            ;    throw Error("ConnectNamedPipe failed")

        }
        
        sa := this._CreateSecurityAttributes()

        this.Handle := DllCall("kernel32\CreateNamedPipeW"
            , "Str", this.PipeName
            , "UInt", 0x00000003                      ; PIPE_ACCESS_DUPLEX
            , "UInt", 0x00000004 | 0x00000002         ; MESSAGE | READMODE_MESSAGE
            , "UInt", 1
            , "UInt", 4096
            , "UInt", 4096
            , "UInt", 0
            , "Ptr", sa
            , "Ptr")

        if this.Handle = -1
            throw Error("CreateNamedPipe failed")

        if DllCall("kernel32\ConnectNamedPipe", "Ptr", this.Handle, "Ptr", 0) = 0
            throw Error("ConnectNamedPipe failed")
    }

    ; =========================
    ; USER SIDE (CLIENT)
    ; =========================
    Wait(timeout := -1) {

        sa := this._CreateSecurityAttributes()

        startTime := A_TickCount
        
        Loop {
            ; Attempt to open the pipe
            ; GENERIC_READ (0x80000000) | GENERIC_WRITE (0x40000000) = 0xC0000000
            ; OPEN_EXISTING = 3
            hPipe := DllCall("CreateFileW", 
                "Str",  this.PipeName, 
                "UInt", 0xC0000000, ; Access: Read/Write
                "UInt", 0,          ; No sharing
                "Ptr",  0,          ; Security attributes
                "UInt", 3,          ; Creation disposition: OPEN_EXISTING
                "UInt", 0,          ; Attributes
                "Ptr",  0)

            ; Success! Pipe is opened.
            if (hPipe != -1) {
                this.Handle := hPipe
                return true
            }

            lastErr := A_LastError

            ; Case 1: Pipe does not exist yet (Error 2)
            if (lastErr == 2) {
                if (timeout != -1 && (A_TickCount - startTime) >= timeout)
                    return 0
                Sleep(100) ; Wait and try again
                continue
            }

            ; Case 2: Pipe exists but all instances are busy (Error 231)
            if (lastErr == 231) {
                ; WaitNamedPipe will actually wait until an instance is free
                ; We use 500ms for the Win32 wait, then loop back to CreateFile
                DllCall("WaitNamedPipe", "Str", this.PipeName, "UInt", 500)
                continue
            }

            ; Case 3: Any other unexpected error
            return 0
        }
    }

    ; =========================
    ; SEND UTF-16 MESSAGE
    ; =========================
    Send(text)
    {
        len := StrPut(text, "UTF-16")
        buf := Buffer(len * 2)
        StrPut(text, buf, "UTF-16")

        ; Synchronous write then wait until a Read operation completes on the write end of the pipe.
        if !DllCall("kernel32\WriteFile"
            , "Ptr", this.Handle
            , "Ptr", buf
            , "UInt", buf.Size
            , "UInt*", 0
            , "Ptr", 0)
            throw Error("WriteFile failed")

        Sleep 10 ; Delay to allow buffers to reset
    }

    ; =========================
    ; RECEIVE UTF-16 MESSAGE
    ; =========================
    Receive()
    {
        buf := Buffer(4096)
        bytes := 0

        ; Synchronous read then wait until a Write operation completes on the write end of the pipe.
        if !DllCall("kernel32\ReadFile"
            , "Ptr", this.Handle
            , "Ptr", buf
            , "UInt", buf.Size
            , "UInt*", &bytes
            , "Ptr", 0)
            throw Error("ReadFile failed")

        return StrGet(buf, bytes // 2, "UTF-16")
    }

    ; =========================
    ; CLEANUP
    ; =========================
    Close()
    {
        if this.Handle
        {
            DllCall("kernel32\DisconnectNamedPipe", "Ptr", this.Handle)
            DllCall("kernel32\CloseHandle", "Ptr", this.Handle)
            this.Handle := 0
        }
    }

    PipeExists(PipeName) {

        ; GENERIC_READ = 0x80000000
        ; OPEN_EXISTING = 3
        hPipe := DllCall("CreateFile", 
            "Str", PipeName, 
            "UInt", 0x80000000, 
            "UInt", 0, 
            "Ptr", 0, 
            "UInt", 3, 
            "UInt", 0, 
            "Ptr", 0, 
            "Ptr")

        if (hPipe != -1) {
            DllCall("CloseHandle", "Ptr", hPipe)
            return true
        }
        
        ; If CreateFile failed, check if it's because the pipe is busy or doesn't exist
        lastError := A_LastError

        ; ERROR_PIPE_BUSY = 231
        ; If the pipe is busy, it definitely exists.
        return (lastError == 231)
    }

    ; =========================
    ; INTERNAL: SECURITY ATTRS
    ; =========================
    _CreateSecurityAttributes()
    {
        sa := Buffer(A_PtrSize * 3, 0)
        sd := 0

        if !DllCall("advapi32\ConvertStringSecurityDescriptorToSecurityDescriptorW"
            , "Str", NamedPipe.SDDL
            , "UInt", 1
            , "Ptr*", &sd
            , "Ptr", 0)
            throw Error("SDDL conversion failed")

        NumPut("Ptr", sd, sa, A_PtrSize)        ; lpSecurityDescriptor
        NumPut("Int", 0,  sa, A_PtrSize*2)      ; bInheritHandle = FALSE
        return sa
    }
}
