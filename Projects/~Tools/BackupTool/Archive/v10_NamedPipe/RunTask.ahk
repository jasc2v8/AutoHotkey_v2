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
#NoTrayIcon

class RunTask
{
    DEFAULT_TASK_NAME   := "AHK_RunSkipUAC"

    RunSkipUACPath      := "C:\ProgramData\AutoHotkey\RunSkipUAC\RunSkipUAC.ahk"

    __New(Taskname:= this.DEFAULT_TASK_NAME)
    {

        this.logger:= LogFile("D:\RunTask.log", "RunTask")

	    this.logger.Disable()
	
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
