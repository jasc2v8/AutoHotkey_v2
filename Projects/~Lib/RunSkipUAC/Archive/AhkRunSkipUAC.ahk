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

#Include <RunHelper>
#Include <IniHelper>
#Include <NamedPipeHelper>

; #region Globals

global INI_PATH := EnvGet("PROGRAMDATA") "\AutoHotkey\AhkRunSkipUAC\AhkRunSkipUAC.ini"

global INI      := IniHelper(INI_PATH)

ProgramPath := INI.ReadSettings("PROGRAM")

pipe := NamedPipe("AHK_RunSkipUAC")

    try
    {
        ; Create a fresh pipe instance and wait for client
        pipe.CreateServer()

        ; Read client request
        ProgramPath := pipe.Receive()

        ; Run Program
        if !FileExist(ProgramPath) 
            MsgBox "File not Exist: " ProgramProgramOutput := RunHelper(ProgramPath)
        else
            Sleep 2000
        }

        ; Handle request (your logic here)
        reply := "ACK: " request

        ; Send reply
        pipe.Send(reply)

        if (request = "TERMINATE")
            break
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

if !FileExist(ProgramPath) {
    MsgBox "File not Exist: " ProgramPath, "AhkRunSkipUAC", "IconX"
    ExitApp()
}

; Run
Output := RunHelper(ProgramPath)

; DEBUG
;FileAppend(Output "`n", EnvGet("PROGRAMDATA") "\AutoHotkey\AhkRunSkipUAC\AhkRunSkipUAC.log")
