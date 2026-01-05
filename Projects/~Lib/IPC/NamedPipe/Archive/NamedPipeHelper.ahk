; TITLE  :  NamedPipeHelper v1.0
; SOURCE :  chatGPT
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0

class NamedPipe
{
    PipeName := ""
    Handle   := 0

    static SDDL := "D:(A;;GA;;;BU)(A;;GA;;;BA)"

    __New(pipeName:="")
    {
        if pipeName
            this.PipeName := "\\.\pipe\Global\AHK_Pipe"
        else
            this.PipeName := "\\.\pipe\Global\" pipeName
    }

    ; =========================
    ; SERVICE SIDE (SERVER)
    ; =========================
    CreateServer()
    {
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

        DllCall("kernel32\ConnectNamedPipe", "Ptr", this.Handle, "Ptr", 0)
    }

    ; =========================
    ; USER SIDE (CLIENT)
    ; =========================
    ConnectClient(timeoutMs := 5000)
    {
        if !DllCall("kernel32\WaitNamedPipeW", "Str", this.PipeName, "UInt", timeoutMs)
            throw Error("Pipe not available")

        this.Handle := DllCall("kernel32\CreateFileW"
            , "Str", this.PipeName
            , "UInt", 0xC0000000                      ; GENERIC_READ | GENERIC_WRITE
            , "UInt", 0
            , "Ptr", 0
            , "UInt", 3                               ; OPEN_EXISTING
            , "UInt", 0
            , "Ptr", 0
            , "Ptr")

        if this.Handle = -1
            throw Error("CreateFile failed")
    }

    ; =========================
    ; SEND UTF-16 MESSAGE
    ; =========================
    Send(text)
    {
        len := StrPut(text, "UTF-16")
        buf := Buffer(len * 2)
        StrPut(text, buf, "UTF-16")

        if !DllCall("kernel32\WriteFile"
            , "Ptr", this.Handle
            , "Ptr", buf
            , "UInt", buf.Size
            , "UInt*", 0
            , "Ptr", 0)
            throw Error("WriteFile failed")
    }

    ; =========================
    ; RECEIVE UTF-16 MESSAGE
    ; =========================
    Receive()
    {
        buf := Buffer(4096)
        bytes := 0

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
