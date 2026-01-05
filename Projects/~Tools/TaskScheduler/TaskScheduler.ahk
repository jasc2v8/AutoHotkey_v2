; TITLE  :  SchTasksGui v1.0
; SOURCE :  chatGPT and jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Gui manager for schtasks.exe
; USAGE  :
; NOTES  :

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
SetWorkingDir A_ScriptDir

; Global variables separated on two lines
global IL_Large := 0
global IL_Small := 0

; ------------------------------------------------------------
; Admin re-entry handler
; ------------------------------------------------------------
if A_Args.Length && A_Args[1] = "/__Admin"
{
    TaskGui.AdminAction(A_Args)
    ExitApp
}

; ------------------------------------------------------------
class TaskGui
{
    static gui   := unset
    static lv    := unset
    static shell := ComObject("WScript.Shell")

    static ExecSilent(cmd)
    {
        try this.shell.Exec(cmd)
        catch
            MsgBox("Failed to execute: " cmd)
    }

    static Show()
    {
        this.gui := Gui("", "Task Scheduler v1.0")
        this.gui.SetFont("s10", "Segoe UI")

        this.lv := this.gui.AddListView("r20 w800 Grid", ["Name", "Status", "Next Run", "Last Run", "Target (Action)"])

        this.gui.AddGroupBox("w800 h60 Section", "Actions")
        this.gui.AddText("xs+5 ys+20 h1 w1") 

        for label, fn in Map(
            "Refresh"   , "Refresh",
            "Run"       , "RunSelected",
            "Scheduler" , "OpenTaskScheduler",
            "Create"    , "CreateTaskGui",
            "Delete"    , "DeleteSelected"
        )
        {
            b := this.gui.AddButton("yp w90", label)
            b.OnEvent("Click", ObjBindMethod(this, fn))
        }

        this.gui.AddButton("yp w90", "Cancel").OnEvent("Click", (*) => this.gui.Destroy())
        
        this.checkBox := this.gui.AddCheckbox("x+75 yp Checked", "Targets .ahk Only")
        this.checkBox.OnEvent("Click", (*) => this.Refresh())
        
        this.gui.OnEvent("Close", (*) => ExitApp())
        this.gui.Show()
        this.Refresh()
    }

    static Refresh(*)
    {
        this.lv.Delete()
        try {
            TaskList := this.QueryTasks()
            for task in TaskList {
                stateMap := Map(0, "Unknown", 1, "Disabled", 2, "Queued", 3, "Ready", 4, "Running")
                taskState := stateMap.Has(task.State) ? stateMap[task.State] : "Other"
                
                try {
                    action := task.Definition.Actions.Item(1)
                    targetPath := action.Path
                } catch {
                    targetPath := ""
                }
                
                isAhkFile := (SubStr(targetPath, -4) = ".ahk")

                if (this.checkBox.Value = 0 || isAhkFile) {
                    displayPath := targetPath = "" ? "[No Actions Defined]" : targetPath
                    this.lv.Add(, task.Name, taskState, task.NextRunTime, task.LastRunTime, displayPath)
                }
            }
        }
        Loop this.lv.GetCount("Col")
           this.lv.ModifyCol(A_Index, "Auto")
        this.lv.ModifyCol(1, "Sort")
    }

    static QueryTasks()
    {
        try {
            TaskService := ComObject("Schedule.Service")
            TaskService.Connect()
            RootFolder := TaskService.GetFolder("\")
            return RootFolder.GetTasks(1)
        } catch Error as err {
            MsgBox("Error accessing Task Scheduler: " err.Message)
            return []
        }
    }

    static GetSelectedTask() => (row := this.lv.GetNext()) ? this.lv.GetText(row, 1) : ""

    static RunSelected(*)
    {
        if (task := this.GetSelectedTask()) {
            this.ExecSilent('schtasks /run /tn "' task '"')
            Sleep 500
            this.Refresh()
        }
    }

    static DeleteSelected(*)
    {
        if !(task := this.GetSelectedTask())
            return MsgBox("Please select a task", , "IconI")

        if MsgBox("Delete task:`n`n" task, "Confirm", "YesNo Icon?") == "Yes"
            this.RunAsAdmin("/delete", task)
    }

    static OpenTaskScheduler(*) => Run("taskschd.msc")

    static CreateTaskGui(*)
    {
        g := Gui("+Owner" this.gui.Hwnd, "Create Task")
        g.SetFont("s9", "Segoe UI")

        g.AddText("w100", "Task Name:")
        name := g.AddEdit("x+10 w200", "AHK_NewTask")

        g.AddText("xm w100", "Executable:")
        exe := g.AddEdit("x+10 w200")
        g.AddButton("x+5 w30", "…").OnEvent("Click", (*) => exe.Value := FileSelect())

        g.AddText("xm w100", "Schedule:")
        sched := g.AddDDL("x+10 w200 Choose1", ["ONCE", "DAILY", "WEEKLY", "ONLOGON", "ONSTART"])

        g.AddText("xm w100", "Start Date (M/D/Y):")
        sDate := g.AddEdit("x+10 w200", A_MM "/" A_DD "/" A_YYYY)

        g.AddText("xm w100", "Start Time (HH:mm):")
        sTime := g.AddEdit("x+10 w200", "00:00")

        g.AddText("xm w100", "Run Level:")
        rLevel := g.AddDDL("x+10 w200 Choose2", ["LIMITED", "HIGHEST"])

        g.AddText("xm w100", "Run User:")
        rUser := g.AddEdit("x+10 w200", A_UserName)

        btnRow := g.AddButton("xm y+20 w80 Default", "Create")
        btnRow.OnEvent("Click", (*) => (
            this.RunAsAdmin("/create", name.Value, exe.Value, sched.Text, sDate.Value, sTime.Value, rLevel.Text, rUser.Value),
            g.Destroy()
        ))

        g.Show()
    }

    static RunAsAdmin(action, p*)
    {
        params := ""
        for val in p
            params .= ' "' val '"'
        
        Run('*RunAs "' A_AhkPath '" "' A_ScriptFullPath '" /__Admin "' action '"' params, , "Hide")
    }

    static AdminAction(args)
    {
        action := args[2]

        switch action
        {
            case "/delete":
                this.ExecSilent('schtasks /delete /f /tn "' args[3] '"')

            case "/create":
                target := args[4]
                ; Logic: Only wrap in double quotes if a space is found
                finalTarget := InStr(target, " ") ? '\"' target '\"' : target

                cmd := 'schtasks /create /f'
                cmd .= ' /tn "' args[3] '"'
                cmd .= ' /tr ' finalTarget
                cmd .= ' /sc ' args[5]
                cmd .= ' /sd ' args[6]
                cmd .= ' /st ' args[7]
                cmd .= ' /rl ' args[8]
                cmd .= ' /ru "' args[9] '"'
                
                this.ExecSilent(cmd)
        }
        Reload()
    }
}

TaskGui.Show()
