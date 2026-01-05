; TITLE  :  RunSkipUAC v1.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Run any program elevated without the UAC prompt
; USAGE  :  RunSkipUAC(TaskName)
; NOTES  :  On-Demand TaskName must be in Task Scheduler: AHK_RunSkipUAC

/*
    TODO:
*/

#Requires AutoHotkey v2.0+

#Include <LogFile>

class RunTask
{
    DEFAULT_TASK_NAME   := "AHK_RunSkipUAC"

    __New(Taskname:= this.DEFAULT_TASK_NAME)
    {

        this.logger:= LogFile("D:\RunTask.log", "RunTask")

	    this.logger.Disable()
	
        this.logger.Write("TaskName  : " TaskName)

        r := this._Start(Taskname)
    }

    _Start(Taskname)
    {
        if !this.TaskExists(Taskname) {
            this.logger.Write("Task does not exist: " TaskName)
        }

        if this.IsTaskRunning(TaskName) {
            this.logger.Write("Task is already running: " TaskName)
            return true
        }

        this.logger.Write("RunTask: " TaskName)

        this.RunTask(Taskname)

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
