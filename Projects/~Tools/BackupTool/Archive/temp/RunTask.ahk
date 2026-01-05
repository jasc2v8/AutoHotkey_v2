; TITLE  :  RunSkipUAC v1.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Run any program elevated without the UAC prompt
; USAGE  :  RunSkipUACHelper(WorkerPath)
; NOTES  :  On-Demand Task must be in Task Scheduler: AHK_RunSkipUAC
;           Client passes WorkerPath using NamedPipeHelper: RunSkipUACHelper(WorkerPath)
;           RunSkipUAC runs the WorkerPath with runLevel = 'highest'
;           Client now communicates with Program via NamedPipeHelper
; SCRIPTS: BackupControlTool.ahk => RunTask.ahk => RunSkipUAC.ahk => BackupControlWorker.ahk
; SCRIPTS: BackupControlTool.ahk => RunTask(AHK_RunSkipUAC) => RunSkipUAC.ahk => BackupControlWorker.ahk

/*
    TODO:

    PSUEDOCODE:
    BackupControlTool.ahk => RunTask(AHK_RunSkipUAC)
    Task AHK_RunSkipUAC runs RunSkipUAC.ahk
    RunSkipUAC creates SharedMemory waits for WorkerPath from BackupControlTool
    BackupControlTool sends WorkerPath to RunSkipUAC
    RunSkipUAC runs WorkerPath at runLevel='highest'

    BackupControlTool send BackupRequest to BackupControlWorker
    BackupControlWorker runs BackupRequest
    BackupControlWorker Handles PostAction
    BackupControlWorker sends ACK to BackupControlTool

*/

#Requires AutoHotkey v2.0+

#Include <LogFile>

; ------------------------------------------------------------
class RunTask
{
    DEFAULT_TASK_NAME   := "AHK_RunSkipUAC"

    RunSkipUACPath      := "C:\ProgramData\AutoHotkey\RunSkipUAC\RunSkipUAC.ahk"

    __New(Taskname:= this.DEFAULT_TASK_NAME)
    {

        this.logger:= LogFile("D:\RunTask.log", "RunTask")
	    ;this.logger.Disable()
	
        this.logger.Write("TaskName  : " TaskName)

        return this._Start(Taskname)

    }

    _Start(Taskname)
    {
        if !this.TaskExists(Taskname)
            throw Error("Task does not exist: " Taskname)

        if this.IsTaskRunning(TaskName)
            return true

            this.logger.Write("RunTask: " TaskName)

        ; Start the Task which will run the Worker
        this.RunTask(Taskname)

        ; Wait for the Worker to start and created the SharedMemory
        SplitPath(this.RunSkipUACPath, &OutName, &OutDir, &OutExt, &OutNameNoExt, &OutDrive)
        RunSkipUACName:= OutNameNoExt

        DetectHiddenWindows true
        SetTitleMatchMode 2 ; contains

            this.logger.Write("WinWait: " RunSkipUACName)

        success:= WinWait(RunSkipUACName,, 1000)

        ;ok MsgBox success

        if not success
            throw "Timeout waiting for Worker to start: " RunSkipUACName 

        this.logger.Write("Worker Running   : " RunSkipUACName)

        this.logger.Write("EXIT")
    }

    TaskExists(Taskname)
    {
        cmd := Format('schtasks /query /tn "{}" >nul 2>&1', TaskName)
        exitCode:= RunWait(A_ComSpec ' /c ' cmd, , "Hide")
        return exitCode=0 ; 0=task exists, 1=task does not exist
    }

    RunTask(Taskname)
    {
        cmd := Format('schtasks /run /tn "{}"', TaskName)

        try
        {
            Run(A_ComSpec ' /c ' cmd, , "Hide")
        }
        catch
        {
            throw Error("Failed to run scheduled task.")
        }
        finally {
        }
    }

    IsTaskRunning(TaskName)
    {
        try
        {
            service := ComObject("Schedule.Service")
            service.Connect()
            root := service.GetFolder("\")
            task := root.GetTask(TaskName)          
            return task.State = 4 ; 4 = TASK_STATE_RUNNING
        }
        catch
            return false
    }

}
