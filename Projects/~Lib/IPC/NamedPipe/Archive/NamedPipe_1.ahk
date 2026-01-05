; TITLE  :  MyScript v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

class NamedPipe
{
    static PIPE_ACCESS_DUPLEX := 0x00000003
    static PIPE_TYPE_BYTE     := 0x00000000
    static PIPE_READMODE_BYTE := 0x00000000
    static PIPE_WAIT          := 0x00000000
    static INVALID_HANDLE     := -1

    _pSD := 0

    __New(name, isServer, encoding := "UTF-16")
    {
        this.name     := "\\.\pipe\Global\" name
        this.encoding := encoding
        this.handle   := 0

        if isServer
            this._CreateServer()
        else
            this._CreateClient()
    }

    ; ================= SERVER =================
    _CreateServer()
    {
        sa := this._SecurityAttributes()

        this.handle := DllCall("CreateNamedPipeW"
            , "Str",  this.name
            , "UInt", NamedPipe.PIPE_ACCESS_DUPLEX
            , "UInt", NamedPipe.PIPE_TYPE_BYTE
                     | NamedPipe.PIPE_READMODE_BYTE
                     | NamedPipe.PIPE_WAIT
            , "UInt", 1
            , "UInt", 8192
            , "UInt", 8192
            , "UInt", 0
            , "Ptr",  sa
            , "Ptr")

        if (this.handle = NamedPipe.INVALID_HANDLE)
            throw Error("CreateNamedPipe failed")

        DllCall("ConnectNamedPipe", "Ptr", this.handle, "Ptr", 0)
    }

    ; ================= CLIENT =================
    _CreateClient()
    {
        this.handle := DllCall("CreateFileW"
            , "Str",  this.name
            , "UInt", 0xC0000000 ; GENERIC_READ | GENERIC_WRITE
            , "UInt", 0
            , "Ptr",  0
            , "UInt", 3          ; OPEN_EXISTING
            , "UInt", 0
            , "Ptr",  0
            , "Ptr")

        if (this.handle = NamedPipe.INVALID_HANDLE)
            throw Error("Unable to connect to service pipe")
    }

    ; ================= SECURITY =================
    _SecurityAttributes()
    {
        sddl := "D:(A;;GA;;;BU)(A;;GA;;;BA)"

        DllCall("advapi32\ConvertStringSecurityDescriptorToSecurityDescriptorW"
            , "Str",  sddl
            , "UInt", 1
            , "Ptr*", &pSD := 0
            , "Ptr",  0)

        sa := Buffer(A_PtrSize * 3, 0)
        NumPut("UInt", sa.Size, sa, 0)
        NumPut("Ptr",  pSD,     sa, A_PtrSize)
        NumPut("Int",  0,       sa, A_PtrSize * 2)

        this._pSD := pSD
        return sa
    }

    ; ================= IO =================
    Write(text)
    {
        bytes := StrPut(text, this.encoding)
        buf := Buffer(bytes)
        StrPut(text, buf, this.encoding)

        if !DllCall("WriteFile"
            , "Ptr", this.handle
            , "Ptr", buf
            , "UInt", buf.Size
            , "UInt*", &written := 0
            , "Ptr", 0)
            throw Error("Write failed")

        return written
    }

    Read(maxBytes := 8192)
    {
        buf := Buffer(maxBytes)

        ok := DllCall("ReadFile"
            , "Ptr", this.handle
            , "Ptr", buf
            , "UInt", maxBytes
            , "UInt*", &read := 0
            , "Ptr", 0)

        if !ok || read = 0
            return ""

        return StrGet(buf, read, this.encoding)
    }

    ; ================= CLEAN UP =================
    Close()
    {
        if this.Handle
        {
            DllCall("kernel32\DisconnectNamedPipe", "Ptr", this.Handle)
            DllCall("kernel32\CloseHandle", "Ptr", this.Handle)
            this.Handle := 0
        }

        if this._pSD
            DllCall("LocalFree", "Ptr", this._pSD)
    }
}

