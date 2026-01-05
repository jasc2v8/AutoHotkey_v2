#Requires AutoHotkey 2.0+
#SingleInstance Force
#NoTrayIcon

#Include <RunAsAdmin>
#Include <IniFile>
#Include <LogFile>
#Include <RunCMD>
#Include <NamedPipe>
#Include <RunTask>

;global LogPath         := EnvGet("PROGRAMDATA") "\AutoHotkey\BackupControlTool\Control.log"
global LogPath          := "D:\Control.log"
global logger           := LogFile(LogPath, "CONTROL")
logger.Disable()

global WorkerPath       := EnvGet("PROGRAMDATA") "\AutoHotkey\BackupControlTool\BackupControlWorker.ahk"

global SyncBackPath     := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
global SyncBackProfile  := "TEST WITH SPACES"
global DefaultProfile   := "~Backup JIM-PC folders to JIM-SERVER"
SyncBackPostAction := "Nothing"

 
BackupRequest:= RunCMD.ToArray(SyncBackPath, SyncBackPostAction, SyncBackProfile)

output:= RunCMD(BackupRequest)

MsgBox Output, "Output"

ExitApp()

    ;
    ; Start the Task AHK_RunSkipUAC which runs RunSkipUAC at runLevel='highest'
    ;

    TaskName:="AHK_RunSkipUAC"
    logger.Write("Run Task: " TaskName)
    RunTask(TaskName)

    ;
    ; Wait for RunSkipUAC to start and create pipe
    ;

    DetectHiddenWindows true
    SetTitleMatchMode 2 ; contains=default
    WinWait("RunSkipUAC")

    ;
    ; Send WorkerPath to RunSkipUAC
    ;

    try {

      logger.Write("Create pipe Instance.")

      pipe := NamedPipe("RunSkipUAC")

      logger.Write("Wait for RunSkipUAC to create pipe...")

      r := pipe.Wait(5000)
      if (!r) {
        logger.Write("Timeout Waiting for pipe.")
        ExitApp()
      }

      logger.Write("Pipe Ready.")

      ; Send WorkerPath to RunSkipUAC
      logger.Write("Send Request: " WorkerPath)

      ; Send request to server
      pipe.Send(WorkerPath)

      ; Receive reply from server
      reply := pipe.Receive()

      logger.Write("Reply Received: " reply)

    }
    catch any as e
    {
      logger.Write("ERROR: " e.Message)
    }
    finally
    {
      logger.Write("Pipe close.")
      pipe.Close()
      pipe:=""
    }

    ;
    ; Send BackupRequest to Worker
    ;

    try
    {

      logger.Write("Create pipe Instance.")

      pipe := NamedPipe("BackupControlWorker")

      logger.Write("Wait for BackupControlWorker to create pipe...")

      r := pipe.Wait(5000)
      if (!r) {
        logger.Write("Timeout Waiting for pipe.")
        ExitApp()
      }

      logger.Write("Pipe Ready.")

      BackupRequest:= RunCMD.ToArray(SyncBackPath, SyncBackPostAction, SyncBackProfile)

      ; Send BackupRequest to Worker
      logger.Write("Send Request: " BackupRequest)

      ; Send request to server
      pipe.Send(BackupRequest)

      ; Receive reply from server
      reply := pipe.Receive()

      logger.Write("Reply Received: " reply)

    }
    catch any as e
    {
      logger.Write("ERROR: " e.Message)
    }
    finally
    {
      logger.Write("Pipe close.")
      pipe.Close()
      pipe:=""
    }

    logger.Write("Finished.")


