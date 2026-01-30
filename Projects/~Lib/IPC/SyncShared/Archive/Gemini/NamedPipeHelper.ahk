; TITLE  :  NamedPipeHelper v1.0
; SOURCE :  Gemini, Copilot, and jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Inter-Process Communication (IPC) between scripts
;           Includes Global support which means the Client can run without Admin while the Server or Task run as Admin
;           Server runs continuously to receive, execute, respond, repeat
;           Task runs once on-demand to receive, execute, respond, exit
;           Client sends a message to Server or Task and receives a response
;           Helper creates the pipe and provides for r/w syncronization for both server and client
; USAGE  :  Start the Server or Task first, then start the Client

/*
    TODO:
*/

#Requires AutoHotkey v2.0+

/************************************************************************
 * PipeHelper with Global Support, Security Descriptor, and UTF-16
 ***********************************************************************/

class PipeHelper {
    
    Logging := false
    LogFile := EnvGet("PROGRAMDATA") "\AutoHotkey\BackupControlTool\NamedPipeHelper.log"

    ; PipeName := "\\.\pipe\GLOBAL\AHK_GlobalUTF16Pipe"
    ; PipeName := "\\.\pipe\AHK_LocalUTF16Pipe"

    BufferSize := 4096

    __New(PipeName:="") {

        if (PipeName)
            this.PipeName := PipeName
        else
            this.PipeName := "\\.\pipe\GLOBAL\AHK_GlobalUTF16Pipe"
        
        WriteLog "PipeHelper New, PipeName: [" this.PipeName "]"
    }

    ; --- Server Methods ---

    /**
     * @param ProcessCallback - A function that accepts (messageString) and returns (resultString)
     */

    ; Run a task then exit
    RunTask(ProcessCallback) {

        WriteLog "RunTask START, PipeName: [" this.PipeName "]"

        this._InternalRun(ProcessCallback)
    }

    RunServer(ProcessCallback) {
        Loop {
            this._InternalRun(ProcessCallback)        
        }
    }

    ; --- Client Methods ---

    Send(message) {

        ; Wait up to 2 seconds for the pipe to become available
        if !DllCall("WaitNamedPipe", "Str", this.PipeName, "UInt", 2000)
            return "Error: Server not responding."

        ; Open pipe with Read/Write access (0xC0000000)
        hPipe := DllCall("CreateFile", "Str", this.PipeName, "UInt", 0xC0000000, "UInt", 0, "Ptr", 0, "UInt", 3, "UInt", 0, "Ptr", 0, "Ptr")
        
        if (hPipe = -1)
            return "Error: Connection failed."

        ; Send data to server
        this._InternalWrite(hPipe, message)
        
        ; Read the server's response
        response := this._InternalRead(hPipe)
        
        DllCall("CloseHandle", "Ptr", hPipe)
        return response
    }

    ; # region Internal Functions

    _InternalRun(ProcessCallback) {

        WriteLog "_InternalRun START"

        sa := this._GetSecurityAttributes()

        ; Create named pipe and return its handle. Pass the 'sa' buffer as the lpSecurityAttributes parameter
        ; Access 3 = PIPE_ACCESS_DUPLEX (Bidirectional)
        hPipe := DllCall("CreateNamedPipe", "Str", this.PipeName, "UInt", 3, "UInt", 0, "UInt", 255, "UInt", this.BufferSize, "UInt", this.BufferSize, "UInt", 0, "Ptr", sa, "Ptr")

        if (hPipe = -1)
            throw Error("Failed to create pipe. Check if another instance is running.")

        WriteLog "_InternalRun Wait for a client to connect"

        ; Wait for a client to connect
        if DllCall("ConnectNamedPipe", "Ptr", hPipe, "Ptr", 0) {

            ; Read the input from the client
            message := this._InternalRead(hPipe)

            WriteLog "_InternalRun message: [" message "]"

            if (message = "TERMINATE") {
                this._InternalWrite(hPipe, "TERMINATE")
                DllCall("DisconnectNamedPipe", "Ptr", hPipe)
                DllCall("CloseHandle", "Ptr", hPipe)
                ExitApp()
            }

            ; EXECUTE EXTERNAL WORK - call the function passed by the server script
            try {
                result := ProcessCallback(message)
            } catch Any as e {
                result := "Error in Server Logic: " . e.Message
            }
            
            ; Write the result back to the client
            this._InternalWrite(hPipe, String(result))
            
            ; Disconnect and close handle so the pipe can reset for the next connection
            DllCall("DisconnectNamedPipe", "Ptr", hPipe)
            DllCall("CloseHandle", "Ptr", hPipe)
        }
    }

    _InternalWrite(hPipe, text) {
        buf := Buffer(StrPut(text, "UTF-16"))
        StrPut(text, buf, "UTF-16")
        return DllCall("WriteFile", "Ptr", hPipe, "Ptr", buf, "UInt", buf.Size, "UIntP", &written := 0, "Ptr", 0)
    }

    _InternalRead(hPipe) {
        buf := Buffer(this.BufferSize)
        if DllCall("ReadFile", "Ptr", hPipe, "Ptr", buf, "UInt", buf.Size, "UIntP", &read := 0, "Ptr", 0)
            return StrGet(buf, read, "UTF-16")
        return ""
    }

    _GetSecurityAttributes() {

        ; SECURITY_ATTRIBUTES struct
        sa := Buffer(A_PtrSize + 8, 0)
        NumPut("UInt", sa.Size, sa, 0) ; nLength

        ; SECURITY_DESCRIPTOR struct
        sd := Buffer(20 + A_PtrSize * 2, 0) 

        ; Initialize Security Descriptor
        DllCall("Advapi32\InitializeSecurityDescriptor", "Ptr", sd, "UInt", 1)

        ; Set NULL DACL (Allow Everyone)
        DllCall("Advapi32\SetSecurityDescriptorDacl", "Ptr", sd, "Int", 1, "Ptr", 0, "Int", 0)

        ; Put SD pointer into SA struct (Offset 4 on 32-bit, Offset 8 on 64-bit)
        NumPut("Ptr", sd.Ptr, sa, A_PtrSize)

        return sa
    }

    WriteLog(text) {
    if (this.Logging) {
        try {
            FileAppend(FormatTime(A_Now, "HH:mm:ss") ": " text "`n", this.LogFile)
        }
    }
}
}