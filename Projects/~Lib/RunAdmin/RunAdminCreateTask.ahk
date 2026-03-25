; TITLE  :  RunAdminCreateTask v1.1.0.0
; SOURCE :  Gemini and jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Create Scheduled Task RunAdmin
; USAGE  :
; NOTES  :

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force

#Include <RunAsAdmin>

    target:= GetTaskTarget("RunAdmin")

    if (target) {
        guiTitle:="Change Task Executable"
        btnTitle:="Change"
        MsgBox "Task already exists in the Task Scheduler.`n`nManually delete then run again to create a new Task.", "Task Exist", "Icon!"
        ExitApp()
    } else {
        guiTitle:="Create Task"
        btnTitle:="Create"
        target := EnvGet("USERPROFILE") "\Documents\AutoHotKey\Lib\RunAdmin.ahk"
    }

    g := Gui("", guiTitle)
    g.SetFont("s9", "Segoe UI")

    g.AddText("w100", "Task Name:")
    name := g.AddEdit("x+10 w200 +ReadOnly", "RunAdmin")

    g.AddText("xm w100", "Executable:")
    exe := g.AddEdit("x+10 w640 vTarget", target)
    g.AddButton("x+5 w30", "…").OnEvent("Click", Button_Click)

    g.AddText("xm w100", "Schedule:")
    sched := g.AddEdit("x+10 w200 +ReadOnly", "ONCE")

    g.AddText("xm w100", "Start Date (MM/DD/YYYY):")
    sDate := g.AddEdit("x+10 w200 +ReadOnly", A_MM "/" A_DD "/" A_YYYY)

    g.AddText("xm w100", "Start Time (HH:mm):")
    sTime := g.AddEdit("x+10 w200 +ReadOnly", "00:00")

    g.AddText("xm w100", "Run Level:")
    rLevel := g.AddEdit("x+10 w200 +ReadOnly", "HIGHEST")

    g.AddText("xm w100", "Run User:")
    rUser := g.AddEdit("x+10 w200 +ReadOnly", A_UserName)

    btnCreate := g.AddButton("xm y+20 w80", "Create")

    btnCancel := g.AddButton("yp w80 Default", "Cancel").OnEvent("Click", (*)=>ExitApp())

    btnCreate.OnEvent("Click", btnCreate_Click)

    g.Show()

    ;PostMessage(EM_SETSEL:=0xB1, -1, 0, exe.Hwnd) ; Deselect all text
    ControlFocus(exe, g)

    ; #region Functions

    btnCreate_Click(*) {

        cmd := "schtasks " .
            " /" btnTitle .
            " /tn " name.Value .
            " /tr " exe.Value .
            " /sc " sched.Text .
            " /sd " sDate.Value .
            " /st " sTime.Value .
            " /rl " rLevel.Text .
            " /ru " rUser.Value

        ;MsgBox cmd, "debug"

        r := ExecSilent(cmd)

        if (r) {
            MsgBox("Success", "Create Task", "OK Icon!")
        } else {
            MsgBox("Error", "Create Task", "OK IconX")
        }

        ExitApp()
    }

    Button_Click(*) {

        f := FileSelect(, g["Target"].Value)
    }

    ExecSilent(cmd)
    {
        result := true
        shell := ComObject("WScript.Shell")
        try shell.Exec(cmd)
        catch
            result := false
        return result
    }

/**
 * Retrieves the executable path/arguments of a scheduled task
 * @param {String} FullPath - The full path of the task (e.g., "\MyTask")
 * @returns {String} - The command line or executable path
 */
GetTaskTarget(FullPath) {
    try {
        Service := ComObject("Schedule.Service")
        Service.Connect()
        
        RootFolder := Service.GetFolder("\")
        Task := RootFolder.GetTask(FullPath)
        
        ; A task has a 'Definition', which contains 'Actions'
        ; Actions is a collection (1-based index)
        Actions := Task.Definition.Actions
        
        Loop Actions.Count {
            Action := Actions.Item(A_Index)
            
            ; Type 0 is 'ExecAction' (running a program)
            if (Action.Type = 0) {
                Path := Action.Path
                Args := Action.Arguments
                
                if (Args != "")
                    return Path " " Args
                
                return Path
            }
        }
    } catch Error as e {
        ; Return empty if task not found or access denied
        return ""
    }
    
    return ""
}

/**
 * Checks if a task exists in the Task Scheduler
 * @param {String} TaskPath - The full path/name of the task (e.g., "\MyTask")
 * @returns {Boolean}
 */
TaskExist(TaskPath) {
    try {
        Service := ComObject("Schedule.Service")
        Service.Connect()
        RootFolder := Service.GetFolder("\")
        TargetTask := RootFolder.GetTask(TaskPath)
        if (TargetTask)
            return true
    } catch {
        return false
    }    
    return false
}

