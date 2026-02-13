; TITLE  :  RunAdminCreateTask v1.0.0.0
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
        guiTitle:="Modify Task Executable"
        btnTitle:="Modify"
    } else {
        guiTitle:="Create Task"
        btnTitle:="Create"
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

    btnRow := g.AddButton("xm y+20 w80", btnTitle)

    btnCancel := g.AddButton("yp w80 Default", "Cancel").OnEvent("Click", (*)=>ExitApp())

    btnRow.OnEvent("Click", (*) => (
        RunAsAdmin("/create", name.Value, exe.Value, sched.Text, sDate.Value, sTime.Value, rLevel.Text, rUser.Value),
        g.Destroy()
    ))

    g.Show()

    ;PostMessage(EM_SETSEL:=0xB1, -1, 0, exe.Hwnd) ; Deselect all text
    ControlFocus(exe, g)

    ; #region Functions

    Button_Click(*) {

        f := FileSelect(, g["Target"].Value)
        ;f := FileSelect(0,"C:\Users\Jim\AppData\Local\Programs\AutoHotkey\RunAdmin\", "MyTitle")
    }

    RunAsAdmin(action, p*)
    {
        params := ""
        for val in p
            params .= ' "' val '"'
        
        Run('*RunAs "' A_AhkPath '" "' A_ScriptFullPath '" /__Admin "' action '"' params, , "Hide")
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

