; TITLE  :  IPCRunTask v1.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Run any program elevated without the UAC prompt
; USAGE 1:  task := IPCRunTask(TaskName, WorkerPath, WorkerRequest)
; USAGE 2:  task := IPCRunTask()
;           task.Run(TaskName, WorkerPath, WorkerRequest)
; NOTES  :  On-Demand Task must be in Task Scheduler: AHK_RunSkipUAC
;           Client passes WorkerPath using NamedPipeHelper: RunSkipUACHelper(WorkerPath)
;           RunSkipUAC runs the WorkerPath with runLevel = 'highest'
;           Client now communicates with Program via NamedPipeHelper

/*
    TODO:
*/

#Requires AutoHotkey v2.0+

#Include <LogFile>
#Include <CRC>
#Include <IPCSendMessageBridge>

; ------------------------------------------------------------
class IPCRunTask
{
    ;TASK_NAME := "AHK_RunSkipUAC"

    __New(TaskName:="", WorkerPath:="", WorkerRequest:="")
    {
        return this.Run(TaskName, WorkerPath, WorkerRequest)
    }

    Run(TaskName, WorkerPath, WorkerRequest)
    {
        ; Check parameters
        if (!TaskName)
            Throw "Error TaskName missing."
        if (!WorkerPath)
            Throw "Error WorkerPath missing."
        if (!WorkerRequest)
            Throw "Error WorkerRequest missing."

        ; Check exist
        if !this.TaskExist(Taskname)
            throw Error("Task not found in the Scheduler: " Taskname)

        if !FileExist(WorkerPath)
            throw Error("Worker Path not found: " WorkerPath)

        ; Save parameters
        this.TaskName      := TaskName
        this.WorkerPath    := WorkerPath
        this.WorkerRequest := WorkerRequest

        splt:= SplitPath(WorkerPath,  &OutName, &OutDir, &OutExt, &OutNameNoExt, &OutDrive)
        this.WorkerName    := OutNameNoExt

        ; Create logger
        this.logger:= LogFile("D:\IPCRunTask.log", "IPCRunTask")
	    ;this.logger.Disable()
	
        ; Log parameters
        this.logger.Write("TaskName    : " TaskName)
        this.logger.Write("WorkerPath  : " WorkerPath)
        this.logger.Write("WorkerRequest: " WorkerRequest)

        ; Start the pre-created On-Demand Task in the Task Scheduler
        if !this.IsTaskRunning(TaskName)
            this.RunTask(Taskname)

        Sleep 1000
        if this.IsTaskRunning(TaskName) {
            this.logger.Write("Task Running  : " TaskName)
        } else {
            Throw "Error Task didn't start: " TaskName
        }

        Persistent

        this.logger.Write("Send: " WorkerPath)

        this.SendMessage(this.TaskName, this.WorkerPath, TaskMessageReceived)

        TaskMessageReceived(message, serverHwnd) {
            this.logger.Write("Received from Task: " message)

            Sleep 1000

            this.logger.Write("Send Message to: " this.WorkerName)
            this.logger.Write("Send Message   : " this.WorkerRequest)

            this.SendMessage(this.WorkerName, this.WorkerRequest, WorkerMessageReceived)
        }

        WorkerMessageReceived(message, serverHwnd) {
            this.logger.Write("Received from Worker: " message)
            Persistent false
        }
        return true
    }

    SendMessage(ServerName, ServerRequest, Callback) {
        ServerKey := CRC.Get64(ServerName, 'Decimal') ; 64-bit numeric password Must match receiver
        server:=IPCSendMessageBridge("Client", ServerName, ServerKey, Callback)
        server.Send(ServerName, ServerRequest)
    }

    TaskExist(Taskname)
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
