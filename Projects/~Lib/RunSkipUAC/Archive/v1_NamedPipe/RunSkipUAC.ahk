; TITLE:    AhkRunSkipUAC v1.0
; SOURCE:   jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:

    BackupControlTool.ah
        task:= RunTaskHelper("AHK_RunSkipUAC")
        task.Run("C:\ProgramData\AutoHotkey\BackupControlTool\BackupControlTask.exe")

    task:= RunTaskHelper("AHK_RunSkipUAC")
        task:= RunTaskHelper("AHK_RunSkipUAC")
        pipe := NamedPipe("AHK_RunSkipUAC")

    

    AHK_RunSkipUAC.ahk
        task:= RunTaskHelper("AHK_RunSkipUAC")
        task.Run(ProgramPath)




        pipe := NamedPipe("AHK_RunSkipUAC")
        ProgramPathpipe.ConnectClient()

    AhkRunSkipUAC.ini
    [SETTINGS]
    PROGRAM := "C:\ProgramData\AutoHotkey\BackupControlTool\BackupControlTask.exe"
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include <LogFileHelper>
#Include <NamedPipeHelper>
#Include <RunHelper>

; #region Globals

logger := LogFile("D:\RunSkipUAC2.txt")

;logger.Disable()

; true logger.Write("IsAdmin: " A_IsAdmin)

pipe := NamedPipe("AHK_RunSkipUAC")

logger.Write("pipe=NamedPipe")

try
{
    logger.Write("Try CreateServer")

    ; Create a fresh pipe instance and wait for client
    pipe.CreateServer()

    logger.Write("pipe.CreateServer")

    ; Read client request
    ProgramPath := pipe.Receive()

    logger.Write("ProgramPath: " ProgramPath)

    ; Include both StdOut and StdErr in the Output
    RunHelper.SetOutput("StdOutStdErr")

    ; Run Program
    if FileExist(ProgramPath) 
        Output := RunHelper(ProgramPath)
    else
        Output:= "File not Exist: " ProgramPath

    reply := "ACK: [" Trim(Output, " `t`r`n") "]"

    ; Send reply
    pipe.Send(reply)

    returnValue:= true

}
catch as err
{
    returnValue:= false
}
finally
{
    ; REQUIRED: tear down instance so clients can reconnect
    pipe.Close()
}
