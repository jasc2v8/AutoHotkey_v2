; TITLE  :  RunTask v1.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Run an on-demand Task in the Scheduler, then optionally run a program elevated without the UAC prompt
; USAGE 1:  task := RunTask(TaskName, WorkerPath)
;           task.Run()
; NOTES  :  On-Demand Task must be in Task Scheduler (AHK_RunSkipUAC)
;           Client passes WorkerPath using Messenger IPC
;           RunSkipUAC runs the WorkerPath with runLevel = 'highest'
;           Client now communicates with Program via Messenger IPC

/*
    TODO:
*/

#Requires AutoHotkey v2.0+

#Include <LogFile>
#Include <Messenger>
#Include <CRC>

; ------------------------------------------------------------
class RunTask
{
    __New(TaskName:="", ProgramPath:="", WorkerPath:="")
    {
        return this.Run(TaskName, ProgramPath, WorkerPath)
    }

    Run(TaskName, ProgramPath, WorkerPath)
    {
        ; Check exist
        if !this.TaskExist(Taskname)
            throw Error("Task not found in the Scheduler: " Taskname)
        if !FileExist(ProgramPath)
            Throw "Error Program path not found: " ProgramPath
        if !FileExist(WorkerPath)
            throw Error("Worker path not found: " WorkerPath)

        ; Save parameters
        this.TaskName      := TaskName
        this.ProgramPath   := ProgramPath
        this.ProgramTitle  := this.GetTitle(ProgramPath)
        this.WorkerPath    := WorkerPath
        this.WorkerTitle   := this.GetTitle(WorkerPath)

        ; Create logger
        this.logger:= LogFile("D:\RunTask.log", "RunTask")
	    this.logger.Disable()
	
        ; Log parameters
        this.logger.Write("TaskName    : " this.TaskName)
        this.logger.Write("ProgramPath : " this.ProgramPath)
        this.logger.Write("ProgramTitle: " this.ProgramTitle)
        this.logger.Write("WorkerPath  : " this.WorkerPath)
        this.logger.Write("WorkerTitle : " this.WorkerTitle)

        ; RunTask starts TaskName AHK_RunSkipUAC)
        if !this.IsTaskRunning(this.TaskName)
            this.RunTask(this.Taskname)

        ; RunTask wait for ProgramPath RunSkipUAC to start
        this.logger.Write("Waiting for Title: " this.ProgramTitle ", Path:" this.ProgramPath)

        Sleep 1000

        DetectHiddenWindows True
        
        ; TODO Timeout 10 seconds?
        success:= WinWait(this.ProgramTitle)
        ;ok WinWait("RunSkipUAC ahk_class AutoHotkey")
        ;ok pid:= ProcessWait("RunSkipUAC.exe")
    
        ; RunTask send WorkerPath to RunSkipUAC
        this.logger.Write("Send to: " this.ProgramTitle ", Path: " this.WorkerPath)

        ;ipc:= Messenger(1234)
        ipc:= Messenger(CRC.Get64("BackupControlTool"))

        ipc.Send(this.ProgramTitle, this.WorkerPath)

        ; RunTask Exit
        return true
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

    GetTitle(Path) {       
        splt:= SplitPath(Path,  &OutName, &OutDir, &OutExt, &OutNameNoExt, &OutDrive)
        return OutNameNoExt
    }

}
