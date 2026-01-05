; TITLE: LogArgs v0.0
/*
  TODO:
*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
#NoTrayIcon

#Include <NamedPipeHelper>

global LogFile:= "D:\LogArgs.txt"

if FileExist(LogFile)
    FileDelete(LogFile)

pipe := NamedPipe("AHK_RunSkipUAC")

try
{
    ; Create a fresh pipe instance and wait for client
    pipe.CreateServer()

    ; Read client request
    request := pipe.Receive()

    ; Run Program
    WriteLog(request)

    ; Handle request (your logic here)
    reply := "ACK: " request

    ; Send reply
    pipe.Send(reply)

    if (request = "TERMINATE") {
        pipe.Close()
        ExitApp()
    }
        
}
catch as err
{
    ; Optional: log err.Message to file/event log
}
finally
{
    ; REQUIRED: tear down instance so clients can reconnect
    pipe.Close()
}

WriteLog(text) {
    FileAppend(FormatTime(A_Now, "HH:mm:ss") ": " text "`n", LogFile)
}
