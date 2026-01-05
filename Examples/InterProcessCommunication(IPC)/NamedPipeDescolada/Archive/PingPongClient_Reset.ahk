; ABOUT:    MyScript v0.0
; SOURCE:   Copilot
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
        Why debug printing leadin ?

        If client starts before server, throw an error
            catch this and notify server not responding.
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon
; OutputDebug "DBGVIEWCLEAR"

OnExit(ExitFunc)

PipeName := "\\.\pipe\testpipe"

; Wait for a server instance
Debug("Waiting for named pipe...")

ok := DllCall("WaitNamedPipe", "str", PipeName, "uint", 0xFFFFFFFF, "int")
if (!ok){
    Debug("WaitNamedPipe failed")
    throw Error("WaitNamedPipe failed. LastError=" . A_LastError)
}
Debug("Named pipe open")

; Wrap the handle so we can use ReadLine/Write
f := FileOpen(PipeName, "rw", "UTF-16")
; Client first needs to read something
f.ReadLine()

Loop {
    ip := InputBox("Type a message for the server", "Client")

    if (ip.Result="Cancel" OR ip.Value ="BYE")
        break

    f.Write(ip.Value "`n")

    reply := f.ReadLine()

    if (reply == "BYE"){
        Debug("BYE")
        ExitApp
        break
    }

    if (ip.Value == "TERMINATE"){
        Debug("TERMINATE")
        ExitApp
        break
    }

    Debug("Got reply: " reply)
}

ExitApp

; This is critical to signale the Server to reset!
ExitFunc(ExitReason, ExitCode) {
    Debug("EXIT FUNCTION!")
    f.WriteLine("BYE")
    f.ReadLine()
    f.Close()
    ExitApp()
}

Debug(text){


    ;OutputDebug("AHK| CLIENT: " text)

    static logFile:= A_ScriptDir "\pingPongLog.txt"

    CurrentTime := FormatTime("YYYYMMDDHH24MISS", "HH:mm:ss")

    if !FileExist(logFile)
        FileAppend(CurrentTime " CLIENT Created LogFile.`n", logFile)


    FileAppend(CurrentTime " CLIENT " text "`n", logFile)

}
 
