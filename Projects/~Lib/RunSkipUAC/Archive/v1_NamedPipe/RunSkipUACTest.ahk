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
; Handle elevated re-entry (MUST be at top of script)
; ------------------------------------------------------------
if A_Args.Length >= 2 && A_Args[1] = "/__SkipUAC"
{
    RunSkipUAC.CreateTaskAsAdmin(A_Args[2])
    ExitApp
}

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

    ; =========================
    ; ADMIN HANDLING
    ; =========================
    static CreateTask(Target)
    {
        if A_IsAdmin
        {
            this.CreateTaskAsAdmin(Target)
            return
        }

        exe    := A_AhkPath
        script := A_ScriptFullPath

        args := Format(
            '"{}" /__SkipUAC "{}"',
            script,
            Target
        )

        Run('*RunAs "' exe '" ' args)
        ExitApp
    }

    ; =========================
    ; TASK MANAGEMENT
    ; =========================
    static TaskExists()
    {
        cmd := Format(
            'schtasks /query /tn "{}" >nul 2>&1',
            this.TaskName
        )
        return RunWait(A_ComSpec ' /c ' cmd, , "Hide") = 0
    }

    static CreateTaskAsAdmin(Target)
    {
        Target := StrReplace(Target, '"', '""')

        cmd := Format(
            'schtasks /create /f ' .
            '/rl highest ' .
            '/sc ondemand ' .
            '/tn "{}" ' .
            '/tr "{}"',
            this.TaskName,
            Target
        )

        rc := RunWait(A_ComSpec ' /c ' cmd, , "Hide")
        if rc != 0
            throw Error("Failed to create scheduled task.")
    }

    static RunTask(Args := "", WorkingDir := "")
    {
        EnvSet("AHK_SKIPUAC_ARGS", Args)
        EnvSet("AHK_SKIPUAC_CWD",  WorkingDir)

        cmd := Format(
            'schtasks /run /tn "{}"',
            this.TaskName
        )

        rc := RunWait(A_ComSpec ' /c ' cmd, , "Hide")
        if rc != 0
            throw Error("Failed to run scheduled task.")
    }

    ; =========================
    ; RUNNING STATE (COM API)
    ; =========================
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
