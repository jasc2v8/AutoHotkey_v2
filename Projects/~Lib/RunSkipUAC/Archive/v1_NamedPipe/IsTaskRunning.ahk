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

;#Include <RunAsAdmin>

    r := IsTaskRunning("AHK_RunSkipUAC")

    r := WaitTask("AHK_RunSkipUAC")

    result:= (r=true) ? "True" : "False"

    MsgBox "Result: " result, "IsTaskRunning"

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

    WaitTask(TaskName, LoopCount:=100)
    {
        Loop LoopCount {
            if IsTaskRunning(TaskName)
                return true
            Sleep 100
        }
    }
