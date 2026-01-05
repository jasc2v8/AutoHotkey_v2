; TITLE  :  RunSkipUACHelper v1.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Run any program elevated without the UAC prompt
; USAGE  :  RunSkipUACHelper(WorkerPath)
; NOTES  :  On-Demand Task must be in Task Scheduler: AHK_RunSkipUAC
;           Client passes WorkerPath using NamedPipeHelper: RunSkipUACHelper(WorkerPath)
;           RunSkipUAC runs the WorkerPath with runLevel = 'highest'
;           Client now communicates with Program via NamedPipeHelper

/*
    TODO:
*/

#Requires AutoHotkey v2.0+

#Include <NamedPipeHelper>
#Include <LogFileHelper>

; ------------------------------------------------------------
class RunSkipUACHelper
{
    logger:= LogFile("D:\RunSkipUACHelper.log", "RunSkipUACHelper")

    TASK_NAME := "AHK_RunSkipUAC"

    __New(WorkerPath, Taskname:=this.TASK_NAME)
    {
        this.WorkerPath    := WorkerPath
        this.TaskName       := Taskname

        if not WorkerPath
            return "WorkerPath required." ;false

        this.logger.Write("WorkerPath: " WorkerPath)
        this.logger.Write("TaskName  : " TaskName)

        return this.Run(WorkerPath, Taskname)

    }

    Run(WorkerPath:=this.WorkerPath, Taskname:=this.TaskName)
    {
        if !FileExist(WorkerPath)
            throw Error("Program Path not found: " WorkerPath)

        if !this.TaskExists(Taskname)
            throw Error("Task does not exist: " Taskname)

        if this.IsTaskRunning(TaskName)
            return true

        this.RunTask(Taskname)

        this.logger.Write("Task Running   : " TaskName)

        ;this.logger.Write("Is Task Running1: " this.IsTaskRunning(TaskName))
        ; This is the right wait time for a Task either .ahk or .exe
        Sleep 500
       ;this.logger.Write("Is Task Running2: " this.IsTaskRunning(TaskName))
 
       ;this.WorkerWait()

        ; works for .exe but not .ahk, not sure whay
        ;r:= this.TaskWait(Taskname, 1000)
        ;MsgBox (r=true) ? "True" : "False"
        ;if (!r)
        ;     throw Error("Task failed to start: " Taskname)

        try {
            logger.Write("Wait for pipe?.")

            pipe := NamedPipe("AHK_RunSkipUAC")

            r := pipe.WaitPipe(1000)
            if (!r) {
                logger.Write("Timeout Waiting for pipe.")
                ExitApp()
            }

            ;pipe.Wait()

            logger.Write("Pipe Ready?.")
            ;Sleep 500

            logger.Write("Send: " WorkerPath)

            pipe.Send(WorkerPath)
            ; reply := pipe.Receive()
            ; this.logger.Write("reply received: " reply)
        }

        catch any as e{

            this.logger.Write("ERROR: " e.Message)

        } finally {

            this.logger.Write("pipe.Close")
            pipe.Close()
            pipe:=""

        }

        ;logger.Write("Reply: " reply, "RunSkipUACHelper")

		; if (reply != "")
		; 	return true
		; else
		; 	return false
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
