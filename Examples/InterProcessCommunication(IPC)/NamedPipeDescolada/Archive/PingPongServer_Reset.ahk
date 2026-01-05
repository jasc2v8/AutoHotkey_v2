; ABOUT:    MyScript v0.0
; SOURCE:   Copilot
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:

    msg := "Hello from server!"

    client ony received "Hello fro"
*/

#Requires AutoHotkey v2+
#SingleInstance Force
#NoTrayIcon

PipeName := "\\.\pipe\testpipe"

OutputDebug "DBGVIEWCLEAR"

; need this somewhere: OnExit((*) => DllCall("CloseHandle", "ptr", hPipe))
OnExit(ExitFunc)

global PipeReset:=true


Loop {

    if (PipeReset) {

        PipeReset:=false

        Debug("Creating named pipe...")
        hPipe := CreateNamedPipe(PipeName)
        If (hPipe = -1)
            throw Error("Creating the named pipe failed")
        Debug("Named pipe created")

        Debug("Waiting for client connection...")
        ; Wait for a client to connect. This can be made non-blocking as well (https://www.codeproject.com/Articles/5347611/Implementing-an-Asynchronous-Named-Pipe-Server-Par)
        DllCall("ConnectNamedPipe", "ptr", hPipe, "ptr", 0)
        Debug("Client connected")


    }
    
    ; Wrap the handle in a file object
    f := FileOpen(hPipe, "h", "UTF-16")

    ; Apparently the server needs to write something first?
    f.WriteLine("")
    DllCall("FlushFileBuffers", "ptr", f.Handle)

    Loop {
        ; Wait for a response
        ; while !(msg := f.ReadLine())
        ;     Sleep 200

        msg := ""
        err := ""
        while !(msg) {
            msg := f.ReadLine()

            ;err := A_LastError

            if (msg="" AND A_LastError=183) {          ; ERROR_ALREADY_EXISTS means ERROR_BROKEN_PIPE
                Debug("Client disconnected - Reloading...")
                ;ResetPipe()
                ResetNamedPipe()
                break 2       
            }

            Sleep 200
        }

        Debug("Client wrote: " msg)

        ; Just respond whatever
        f.WriteLine("Pong")

        if (msg == "BYE") {
            Debug("Got BYE")
            f.WriteLine("Confirmed")
            ResetNamedPipe()
        }

        if (msg == "TERMINATE") {
            Debug("Terminating...")
            f.WriteLine("Confirmed")
            Exit
        }

    }

    ; Debug("Closing connection")
    ; ;DllCall("CloseHandle", "ptr", hPipe)
    ; f.Close()
    ; Sleep 1000
}
ExitApp

ExitFunc(ExitReason, ExitCode) {
    Debug("EXIT FUNCTION!")
    f.WriteLine("BYE")
    DllCall("FlushFileBuffers", "Ptr", hPipe)
    DllCall("DisconnectNamedPipe", "Ptr", hPipe)
    DllCall("CloseHandle", "ptr", hPipe)
    f.Close()
    Sleep 1000
    ExitApp()
}

ResetNamedPipe() {
    global hPipe
    global f
    global PipeReset

    PipeReset:=true

    Debug("Resetting connection")
    DllCall("FlushFileBuffers", "Ptr", hPipe)
    DllCall("DisconnectNamedPipe", "Ptr", hPipe)
    DllCall("CloseHandle", "ptr", hPipe)
    f.Close()
    Sleep 1000
}

ResetPipe() {
    global hPipe
    global f

    Debug("Resetting connection")
    DllCall("FlushFileBuffers", "Ptr", hPipe)
    DllCall("DisconnectNamedPipe", "Ptr", hPipe)
    DllCall("CloseHandle", "ptr", hPipe)
    f.Close()
    Sleep 1000

    Reload

}

Debug(text){

    OutputDebug("AHK| CLIENT: " text)

    static logFile:= A_ScriptDir "\pingPongLog.txt"

    CurrentTime := FormatTime("YYYYMMDDHH24MISS", "HH:mm:ss")

    if !FileExist(logFile)
        FileAppend(CurrentTime " SERVER Created LogFile.`n", logFile)


    FileAppend(CurrentTime " SERVER " text "`n", logFile)

}
 
;f.Close() wouldn't close the handle
DllCall("CloseHandle", "ptr", hPipe)
ExitApp

CreateNamedPipe(Name, OpenMode:=3, PipeMode:=0, MaxInstances:=255) => DllCall("CreateNamedPipe", "str", Name, "uint", OpenMode, "uint", PipeMode, "uint", MaxInstances, "uint", 0, "uint", 0, "uint", 0, "ptr", 0, "ptr")
