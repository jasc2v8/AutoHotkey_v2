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

/************************************************************************
 * PipeHelper v2 - Global Support, Security Descriptor, and UTF-16
 ***********************************************************************/

class PipeHelper {
    static PipeName := "AHK_GlobalUTF16Pipe"
    ;static PipePath := "\\.\pipe\GLOBAL\" . this.PipeName
    static PipePath := "\\.\pipe\" . this.PipeName
    static BufferSize := 8192 ; Increased for UTF-16 (2 bytes per char)

    ; --- Server Methods ---

    static RunServer() {
        psa := this._GetSecurityAttributes()

        Loop {
            ; Create pipe instance (Admin required for GLOBAL)
            hPipe := DllCall("CreateNamedPipe", "Str", this.PipePath, "UInt", 3, "UInt", 0, "UInt", 255, "UInt", this.BufferSize, "UInt", this.BufferSize, "UInt", 0, "Ptr", psa, "Ptr")
            
            if (hPipe = -1)
                throw Error("Server Failed. Error: " A_LastError "`nNote: Global pipes require Admin.")

            if DllCall("ConnectNamedPipe", "Ptr", hPipe, "Ptr", 0) {
                ; 1. Read Request (UTF-16)
                request := this._Read(hPipe)
                
                ; 2. Simulate Work
                result := "Server processed: " . request . " (at " . A_Now . ")"
                
                ; 3. Write Response (UTF-16)
                this._Write(hPipe, result)
            }
            
            DllCall("DisconnectNamedPipe", "Ptr", hPipe)
            DllCall("CloseHandle", "Ptr", hPipe)
        }
    }

    ; --- Client Methods ---

    static SendRequest(message) {
        if !DllCall("WaitNamedPipe", "Str", this.PipePath, "UInt", 3000)
            return "Error: Timeout"

        hPipe := DllCall("CreateFile", "Str", this.PipePath, "UInt", 0xC0000000, "UInt", 0, "Ptr", 0, "UInt", 3, "UInt", 0, "Ptr", 0, "Ptr")
        
        if (hPipe = -1)
            return "Error: " . A_LastError

        this._Write(hPipe, message)
        response := this._Read(hPipe)
        
        DllCall("CloseHandle", "Ptr", hPipe)
        return response
    }

    ; --- Internal Helpers ---

    static _Write(hPipe, text) {
        ; UTF-16 uses 2 bytes per character
        cbNeeded := StrPut(text, "UTF-16") * 2
        buf := Buffer(cbNeeded)
        StrPut(text, buf, "UTF-16")
        
        DllCall("WriteFile", "Ptr", hPipe, "Ptr", buf, "UInt", buf.Size, "UIntP", &written := 0, "Ptr", 0)
    }

    static _Read(hPipe) {
        buf := Buffer(this.BufferSize)
        if DllCall("ReadFile", "Ptr", hPipe, "Ptr", buf, "UInt", buf.Size, "UIntP", &read := 0, "Ptr", 0) {
            ; Length is read bytes divided by 2 for UTF-16 characters
            return StrGet(buf, read // 2, "UTF-16")
        }
        return ""
    }

    static _GetSecurityAttributes() {
        sd := Buffer(A_PtrSize == 8 ? 40 : 20, 0)
        DllCall("Advapi32\InitializeSecurityDescriptor", "Ptr", sd, "UInt", 1)
        ; Null DACL allows "Everyone"
        DllCall("Advapi32\SetSecurityDescriptorDacl", "Ptr", sd, "Int", 1, "Ptr", 0, "Int", 0)
        
        sa := Buffer(A_PtrSize == 8 ? 24 : 12, 0)
        NumPut("UInt", sa.Size, sa, 0)
        NumPut("Ptr", sd.Ptr, sa, 4)
        NumPut("Int", 0, sa, 4 + A_PtrSize)
        
        sa.SD := sd 
        return sa
    }
}