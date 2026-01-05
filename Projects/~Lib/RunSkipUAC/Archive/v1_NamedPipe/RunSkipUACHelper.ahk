; TITLE  :  RunSkipUACHelper v1.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Run any program elevated without the UAC prompt
; USAGE  :  RunSkipUACHelper(ProgramPath)
; NOTES  :  On-Demand Task must be in Task Scheduler: AHK_RunSkipUAC
;           Client passes ProgramPath using NamedPipeHelper: RunSkipUACHelper(ProgramPath)
;           RunSkipUAC runs the ProgramPath with runLevel = 'highest'
;           Client now communicates with Program via NamedPipeHelper

/*
    TODO:
*/

#Requires AutoHotkey v2.0+

#Include <NamedPipeHelper>

; ------------------------------------------------------------
class RunSkipUAC
{
    TASK_NAME := "AHK_RunSkipUAC"

    __New(ProgramPath, Taskname:=this.TASK_NAME)
    {
        this.ProgramPath    := ProgramPath
        this.TaskName       := Taskname

        if not ProgramPath
            return "ProgramPath required." ;false

        return this.Run(ProgramPath, Taskname)

    }

    Run(ProgramPath:=this.ProgramPath, Taskname:=this.TaskName)
    {
        if !FileExist(ProgramPath)
            throw Error("Program Path not found: " ProgramPath)

        if !this.TaskExists(Taskname)
            throw Error("Task does not exist: " Taskname)

        if this.IsTaskRunning(TaskName)
            return true

        this.RunTask(Taskname)

        ; This is the right wait time for a Task either .ahk or .exe
        Sleep 500

        ; works for .exe but not .ahk, not sure whay
        ; r:= this.TaskWait(Taskname)
        ; ;MsgBox (r=true) ? "True" : "False"
        ; if (!r)
        ;     throw Error("Task failed to start: " Taskname)

		pipe := NamedPipe(this.TASK_NAME)
		pipe.ConnectClient()
		pipe.Send(ProgramPath)
		reply := pipe.Receive()
		if (reply != "")
			return true
		else
			return false
    }

    TaskExists(Taskname)
    {
        cmd := Format('schtasks /query /tn "{}" >nul 2>&1', TaskName)
        stdOut:= RunWait(A_ComSpec ' /c ' cmd, , "Hide") = 0
        ;MsgBox (stdOut=true) ? "True" : "False"
        return stdOut

    }

    RunTask(Taskname)
    {
        cmd := Format('schtasks /run /tn "{}"', TaskName)

        try
        {
            RunWait(A_ComSpec ' /c ' cmd, , "Hide")
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

    TaskWait(TaskName, LoopCount:=100)
    {
        Sleep 100
        Loop LoopCount {
            r:= this.IsTaskRunning(TaskName)
            if (r)
                return true
        }
        return false
    }
}
