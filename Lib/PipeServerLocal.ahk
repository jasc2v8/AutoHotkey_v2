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


class PipeServer {
    __New(pipeName, callback) {
        this.pipeName := "\\.\pipe\ " . pipeName
        this.callback := callback
        this.listen := true
        SetTimer(() => this.ServerLoop(), -10)
    }

    ServerLoop() {
        while this.listen {
            ; PIPE_ACCESS_DUPLEX = 0x3 (Read/Write)
            hPipe := DllCall("CreateNamedPipe", "Str", this.pipeName, "UInt", 3, "UInt", 4 | 2, "UInt", 255, "UInt", 0, "UInt", 0, "UInt", 0, "Ptr", 0, "Ptr")
            
            if (hPipe = -1)
                continue

            if DllCall("ConnectNamedPipe", "Ptr", hPipe, "Ptr", 0) {
                buf := Buffer(4096)
                if DllCall("ReadFile", "Ptr", hPipe, "Ptr", buf, "UInt", buf.Size, "UInt*", &bytesRead := 0, "Ptr", 0) {
                    request := StrGet(buf, bytesRead, "UTF-8")
                    
                    ; Execute callback and get the result string
                    try {
                        response := String(this.callback(request))
                    } catch Any as e {
                        response := "Error: " e.Message
                    }

                    ; Send response back to client
                    resBuf := Buffer(StrPut(response, "UTF-8"))
                    StrPut(response, resBuf, "UTF-8")
                    DllCall("WriteFile", "Ptr", hPipe, "Ptr", resBuf, "UInt", resBuf.Size, "UInt*", &bytesWritten := 0, "Ptr", 0)
                }
            }
            DllCall("DisconnectNamedPipe", "Ptr", hPipe)
            DllCall("CloseHandle", "Ptr", hPipe)
        }
    }

    Stop() => this.listen := false

    ; WriteLog(text) {
    ;     if (this.Logging) {
    ;         try {
    ;             FileAppend(FormatTime(A_Now, "HH:mm:ss") ": " text "`n", this.LogFile)
    ;         }
    ;     }
    ; }
}
