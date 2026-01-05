; TITLE  :  MyScript v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Run any program elevated without the UAC prompt
; USAGE  :  RunSkipUAC.Run("C:\Windows\System32\cmd.exe")
; NOTES  :

/*
    TODO:
*/

#Requires AutoHotkey v2.0+

; ------------------------------------------------------------
class RunSkipUAC
{
    static TaskName := "AHK_RunSkipUAC"

    ; =========================
    ; PUBLIC ENTRY POINT
    ; =========================
    static Run(Target, Args := "", WorkingDir := "")
    {
        if !FileExist(Target)
            throw Error("Target not found: " Target)

        if !this.TaskExists()
        {
            this.CreateTask(Target)
            return
        }

        if !this.IsTaskRunning()
            this.RunTask(Args, WorkingDir)
    }

    static TaskExists()
    {
        cmd := Format(
            'schtasks /query /tn "{}" >nul 2>&1',
            this.TaskName
        )
        return RunWait(A_ComSpec ' /c ' cmd, , "Hide") = 0
    }

    static RunTask(Args := "", WorkingDir := "")
    {
        EnvSet("AHK_SKIPUAC_ARGS", Args)
        EnvSet("AHK_SKIPUAC_CWD",  WorkingDir)

        cmd := Format(
            'schtasks /run /tn "{}"',
            this.TaskName
        )

        try
        {
            RunWait(A_ComSpec ' /c ' cmd, , "Hide")
        }
        catch
        {
            throw Error("Failed to run scheduled task.")
        }
        finally {
            EnvSet("AHK_SKIPUAC_ARGS", "")
            EnvSet("AHK_SKIPUAC_CWD", "")
        }
    }

    static IsTaskRunning()
    {
        try
        {
            service := ComObject("Schedule.Service")
            service.Connect()

            root := service.GetFolder("\")
            task := root.GetTask(this.TaskName)

            ; 4 = TASK_STATE_RUNNING
            return task.State = 4
        }
        catch
            return false
    }
}
