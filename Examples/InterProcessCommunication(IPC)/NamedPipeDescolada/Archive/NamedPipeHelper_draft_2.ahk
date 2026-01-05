; TITLE  :  NamedPipeHelper v0.0
; SOURCE :  Gemini
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Inter-Process Communication (IPC) between scripts with Global support

/*
    TODO:

    SERVER
    NP := NamedPipeHelper(PipeName)
    command := NP.Read() ; create pipe, wait, read, close pipe
    NP.Write(response) ; wait, write


    CLIENT
    NP := NamedPipeHelper(PipeName)
    NP.Write(command) ; wait, write
    response := NP.Read() ; wait, read

*/

#Requires AutoHotkey v2.0+

class NamedPipe {
    static PIPE_ACCESS_DUPLEX := 0x00000003
    static PIPE_TYPE_MESSAGE   := 0x00000004
    static PIPE_READMODE_MESSAGE := 0x00000002
    static PIPE_WAIT           := 0x00000000
    static INVALID_HANDLE_VALUE := -1

    __New(pipeName) {
        ; Use \\.\pipe\Global\name for cross-session communication
        this.Name := "\\.\pipe\" . (InStr(pipeName, "Global\") ? pipeName : "Global\" . pipeName)
        this.Handle := NamedPipe.INVALID_HANDLE_VALUE
    }

    Create() {
        ; Initialize Security Descriptor (SD)
        ; PSECURITY_DESCRIPTOR size is 20 bytes (x86) or 40 bytes (x64)
        ; SECURITY_DESCRIPTOR_REVISION = 1
        sd := Buffer(A_PtrSize == 8 ? 40 : 20, 0)
        DllCall("Advapi32\InitializeSecurityDescriptor", "Ptr", sd, "UInt", 1)
        
        ; Set Null DACL (grants access to everyone)
        ; bDaclPresent = true, pDacl = NULL (0), bDaclDefaulted = false
        DllCall("Advapi32\SetSecurityDescriptorDacl", "Ptr", sd, "Int", 1, "Ptr", 0, "Int", 0)

        ; Initialize SECURITY_ATTRIBUTES (SA)
        sa := Buffer(A_PtrSize == 8 ? 24 : 12, 0)
        NumPut("UInt", sa.Size, sa, 0)         ; nLength
        NumPut("Ptr", sd.Ptr, sa, A_PtrSize)   ; lpSecurityDescriptor
        NumPut("Int", 1, sa, A_PtrSize * 2)    ; bInheritHandle = true

        this.Handle := DllCall("CreateNamedPipe"
            , "Str", this.Name
            , "UInt", NamedPipe.PIPE_ACCESS_DUPLEX
            , "UInt", NamedPipe.PIPE_TYPE_MESSAGE | NamedPipe.PIPE_READMODE_MESSAGE | NamedPipe.PIPE_WAIT
            , "UInt", 255
            , "UInt", 0
            , "UInt", 0
            , "UInt", 0
            , "Ptr", sa.Ptr ; Pass the Security Attributes pointer here
            , "Ptr")
        
        if (this.Handle = NamedPipe.INVALID_HANDLE_VALUE)
            throw Error("Failed to create pipe. Error: " . A_LastError)
        return this.Handle
    }

    ; ... (Open, Connect, Write, Read methods remain the same as the UTF-16 version) ...

    Connect() {
        if !DllCall("ConnectNamedPipe", "Ptr", this.Handle, "Ptr", 0)
            if (A_LastError != 997) ; ERROR_IO_PENDING
                return false
        return true
    }

    Open() {
        this.Handle := DllCall("CreateFile", "Str", this.Name, "UInt", 0xC0000000, 
            "UInt", 3, "Ptr", 0, "UInt", 3, "UInt", 0, "Ptr", 0, "Ptr")
        return (this.Handle != NamedPipe.INVALID_HANDLE_VALUE)
    }

    Write(Text) {
        byteSize := StrLen(Text) * 2
        buf := Buffer(byteSize)
        StrPut(Text, buf, "UTF-16")
        if !DllCall("WriteFile", "Ptr", this.Handle, "Ptr", buf, "UInt", buf.Size, "UInt*", &written := 0, "Ptr", 0)
            return false
        return written
    }

    WaitRead(Timeout:=2000) {
        startTime := A_TickCount
        bytesAvail := 0
        while (A_TickCount - startTime < Timeout) {
            if DllCall("PeekNamedPipe", "Ptr", this.Handle, "Ptr", 0, "UInt", 0, "Ptr", 0, "UIntP", &bytesAvail, "Ptr", 0) && bytesAvail > 0
                break
            Sleep 20
        }
        if (bytesAvail > 0) {
            Text := this.Read()
            return Text
            ;reply := pipeFile.ReadLine()
        } else {
            MsgBox "Timeout."
        }
    }

    Read() {
        buf := Buffer(8192)
        if !DllCall("ReadFile", "Ptr", this.Handle, "Ptr", buf, "UInt", buf.Size, "UInt*", &read := 0, "Ptr", 0)
            return ""
        return StrGet(buf, read, "UTF-16")
    }

    Close() {
        if (this.Handle != NamedPipe.INVALID_HANDLE_VALUE) {
            DllCall("DisconnectNamedPipe", "Ptr", this.Handle)
            DllCall("CloseHandle", "Ptr", this.Handle)
            this.Handle := NamedPipe.INVALID_HANDLE_VALUE
        }
    }
}