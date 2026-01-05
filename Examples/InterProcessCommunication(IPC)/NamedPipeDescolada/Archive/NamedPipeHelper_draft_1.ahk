; TITLE  :  NamedPipeHelper v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:

    SERVER
    NP := NamedPipeHelper(PipeName)
    command := NP.Read() ; wait, read, respond
    
    CLIENT
    NP := NamedPipeHelper(PipeName)
    response := NP.Write() ; wait, write, respond

*/

#Requires AutoHotkey v2.0+

;global PipeName := "\\.\pipe\global\AHK_UTF16_Loop"

class NamedPipeHelper {

    ServerTimeout   := 2000
    ResponseTimeout := 3000

    static READWRITE       := 0xC0000000
    static SHARED          := 3
    static OPEN_EXISTING   := 3

    static PipeName := "\\.\pipe\global\NamedPipe"

    static __Call(Name, Params) {
        if (Name)
            this.PipeName := Name
    }

    ; false=Timeout, true=Success
    static Wait(Timeout:=2000) {
        if (!DllCall("WaitNamedPipe", "Str", this.PipeName, "UInt", Timeout))
            return false
        return true
    }

    ; success=response text, failure=return 'TIMEOUT'
    static WriteWait(Text, ResponseTimeout:=3000) {

        try {

            hPipe := DllCall("CreateFile", "Str", this.PipeName, "UInt", this.READWRITE, "UInt", this.SHARED, "Ptr", 0, "UInt", this.OPEN_EXISTING, "UInt", 0, "Ptr", 0, "Ptr")
            pipeFile := FileOpen(hPipe, "h", "UTF-16")
            
            ; Send Text to server
            pipeFile.WriteLine(Text)
            pipeFile.Read(0)

            ; Wait for response
            startTime := A_TickCount
            bytesAvail := 0

            ; TODO: handle timout
            while (A_TickCount - startTime < ResponseTimeout) {
                if DllCall("PeekNamedPipe", "Ptr", hPipe, "Ptr", 0, "UInt", 0, "Ptr", 0, "UIntP", &bytesAvail, "Ptr", 0) && bytesAvail > 0
                    break
                Sleep 20
            }
            ; Handle response and local exit
            if (bytesAvail > 0) {
                response := pipeFile.ReadLine()
                return response

                ; If TERMINATE then exit the client after receiving the server's acknowledgment
                if (StrLower(Text) = "terminate")
                    ExitApp

            } else {
                return "TIMEOUT"
            }

        } catch Any as e {
            MsgBox "Error: " e.Message
        }

    }

    ; static Read() {
    ;     try {

    ;     }
    ; }
}


    try {
        hPipe := DllCall("CreateFile", "Str", PipeName, "UInt", READWRITE, "UInt", SHARED, "Ptr", 0, "UInt", OPEN_EXISTING, "UInt", 0, "Ptr", 0, "Ptr")
        pipeFile := FileOpen(hPipe, "h", "UTF-16")
        
        ; Send user input to server
        pipeFile.WriteLine(userInput)
        pipeFile.Read(0)

        ; Wait for response
        startTime := A_TickCount
        bytesAvail := 0
        while (A_TickCount - startTime < ResponseTimeout) {
            if DllCall("PeekNamedPipe", "Ptr", hPipe, "Ptr", 0, "UInt", 0, "Ptr", 0, "UIntP", &bytesAvail, "Ptr", 0) && bytesAvail > 0
                break
            Sleep 20
        }

        ; Handle response and local exit
        if (bytesAvail > 0) {
            reply := pipeFile.ReadLine()
            MsgBox "Server: " . reply, "Client", "T2"
            
            ; If we sent BYE, exit the client after receiving the server's acknowledgment
            if (StrLower(userInput) = "bye")
                ExitApp
        } else {
            MsgBox "Timeout."
        }
        
        pipeFile.Close()

    } catch Any as e {
        MsgBox "Error: " e.Message
    }
}