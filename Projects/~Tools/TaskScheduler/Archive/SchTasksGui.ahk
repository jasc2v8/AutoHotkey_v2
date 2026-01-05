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
;#NoTrayIcon
SetWorkingDir A_ScriptDir

#Include <Debug>
;#Include <RunHelper>
;#Include <RunAsAdmin>

; TaskName := "AHK_LogArgs"
; TaskExe  := "D:\Software\DEV\Work\AHK2\Projects\ScheduleTask\LogArgs.exe"

;     taskName  := TaskName
;     app       := 'schtasks.exe'
;     exe       := TaskExe
;     schedule  := 'once'         ; on-demand
;     startDate := '01/01/1910'   ; far in the past so it will never run as scheduled
;     startTime := '00:00'        ; arbitrary
;     runLevel  := 'highest'      ; 'limited' or 'highest' ; highest requires Admin
;     runUser   := 'Users'        ; default is current user

;     ;SCHTASKS /create /tn "AhkOnDemand" /tr "D:\Software\DEV\Work\AHK2\Projects\ScheduleTask\LogArgs.exe" /sc ONCE /sd 01/01/1910 /st 00:00

;     output := RunHelper([app, "/create /tn", taskName, "/tr", exe, "/sc", schedule, "/st", startTime, "/rl", runLevel])
; ExitApp()

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

    ; ========================================================
    ; Centralized silent command execution
    ; ========================================================
    static ExecSilent(cmd)
    {
        try this.shell.Exec(cmd)
        catch
            MsgBox("Failed to execute: " cmd)
    }

    ; ========================================================
    ; Show main GUI
    ; ========================================================
    static Show()
    {
        this.gui := Gui("", "Scheduled AHK Tasks Manager v1.0")
        this.gui.SetFont("s10", "Segoe UI")

        this.lv := this.gui.AddListView("r20 w800 Grid", ["Name", "Status", "Next Run", "Last Run", "Target (Action)"])

        this.gui.AddGroupBox("w800 h60 Section", "Actions")

        this.gui.AddText("xs+5 ys+20 h1 w1") ; start row inside the group box

        ; Map will sort by label
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
        this.checkBox:=this.gui.AddCheckbox("x+125 yp Checked", "AHK Only")
        this.gui.OnEvent("Close", (*) => ExitApp)
        this.gui.Show()
        this.Refresh()
    }

    ; ========================================================
    ; Refresh task list
    ; ========================================================
    static Refresh(*)
    {
        this.lv.Delete()
        TaskList := this.QueryTasks()

        for task in TaskList {
            ; Convert numerical state to readable text
            stateMap := Map(0, "Unknown", 1, "Disabled", 2, "Queued", 3, "Ready", 4, "Running")
            taskState := stateMap.Has(task.State) ? stateMap[task.State] : "Other"
            try {
                action := task.Definition.Actions.Item(1)
                targetPath := action.Path
                arguments := action.Arguments
            } catch {
                targetPath := "[No Actions Defined]"
            }
            
            if (this.checkBox.Value = 1) {
                if (SubStr(task.Name, 1, 3) = "ahk")
                    this.lv.Add(, task.Name, taskState, task.NextRunTime, task.LastRunTime, targetPath)
            } else {
                this.lv.Add(, task.Name, taskState, task.NextRunTime, task.LastRunTime, targetPath)
            }
        }
        Loop this.lv.GetCount("Col") -1
           this.lv.ModifyCol(A_Index, "Auto")
        this.lv.ModifyCol(1, "Sort")
    }

    ; ========================================================
    ; Query scheduled tasks (returns Map keyed by task name)
    ; ========================================================
    static QueryTasks()
    {
        try {
            ; 1. Create the TaskService object and connect
            TaskService := ComObject("Schedule.Service")
            TaskService.Connect()

            ; 2. Get the root folder (or specify a subfolder like "\Microsoft")
            RootFolder := TaskService.GetFolder("\")
            
            ; 3. Get all tasks in that folder (1 = include hidden tasks)
            TaskList := RootFolder.GetTasks(1)

            ; 4. Loop through the task collection
            ; for task in TaskList {
            ;     ; Convert numerical state to readable text
            ;     stateMap := Map(0, "Unknown", 1, "Disabled", 2, "Queued", 3, "Ready", 4, "Running")
            ;     taskState := stateMap.Has(task.State) ? stateMap[task.State] : "Other"
                
            ;     LV.Add(, task.Name, taskState, task.LastRunTime)
            ; }
        } catch Error as err {
            MsgBox("Error accessing Task Scheduler: " err.Message)
        }

        return TaskList
    }

    ; ========================================================
    ; Get selected task
    ; ========================================================
    static GetSelectedTask()
    {
        row := this.lv.GetNext()
        return row ? this.lv.GetText(row, 1) : ""
    }

    ; ========================================================
    ; Run selected task silently
    ; ========================================================
    static RunSelected(*)
    {
        task := this.GetSelectedTask()
        if task {
            this.ExecSilent('schtasks /run /tn "' task '"')
            Sleep 250
            this.Refresh()
        }
    }

    ; ========================================================
    ; Delete selected task (with admin)
    ; ========================================================
    static DeleteSelected(*)
    {
        task := this.GetSelectedTask()
        if !task {
            MsgBox("Please select a task to delete", "Select Task", "IconI")
            return
        }

        if MsgBox("Delete task:`n`n" task, "Confirm", "YesNo Icon?") != "Yes"
            return

        this.RunAsAdmin("/delete", task)
    }

    static OpenTaskScheduler(*) {
        Run "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Administrative Tools\Task Scheduler.lnk"
    }
    ; ========================================================
    ; Create task GUI
    ; ========================================================
    static CreateTaskGui(*)
    {
        g := Gui("+Owner" this.gui.Hwnd, "Create Task")
        g.SetFont("s9", "Segoe UI")

        g.AddText(, "Task name:")
        name := g.AddEdit("w300", "AHK_")

        g.AddText("y+10", "Executable:")
        exe := g.AddEdit("w300")
        g.AddButton("x+5 w30", "…")
            .OnEvent("Click", (*) => exe.Value := FileSelect())

        g.AddButton("y+15 w80", "Create")
            .OnEvent("Click", (*) =>
                this.RunAsAdmin("/create", name.Value, exe.Value)
            )

        g.Show()
    }

    ; ========================================================
    ; Admin launch
    ; ========================================================
    static RunAsAdmin(action, p1 := "", p2 := "")
    {
        exe := A_AhkPath
        args := Format('"{}" /__Admin "{}" "{}" "{}"', A_ScriptFullPath, action, p1, p2)
        Run '*RunAs "' exe '" ' args, , "Hide"
    }

    ; ========================================================
    ; Admin-side actions (silent)
    ; ========================================================
    static AdminAction(args)
    {

        action := args[2]

        switch action
        {
            case "/delete":
                this.ExecSilent('schtasks /delete /f /tn "' args[3] '"')

            case "/create":
                name := args[3]
                exe  := args[4]

                ; TaskName := "AHK_LogArgs"
                ; TaskExe  := "D:\Software\DEV\Work\AHK2\Projects\ScheduleTask\LogArgs.exe"

                ;     taskName  := TaskName
                ;     app       := 'schtasks.exe'
                ;     exe       := TaskExe
                ;     schedule  := 'once'         ; on-demand
                ;     startDate := '01/01/1910'   ; far in the past so it will never run as scheduled
                ;     startTime := '00:00'        ; arbitrary
                ;     runLevel  := 'highest'      ; 'limited' or 'highest' ; highest requires Admin
                ;     runUser   := 'Users'        ; default is current user

                ;     ;SCHTASKS /create /tn "AhkOnDemand" /tr "D:\Software\DEV\Work\AHK2\Projects\ScheduleTask\LogArgs.exe" /sc ONCE /sd 01/01/1910 /st 00:00

                ;     output := RunHelper([app, "/create /tn", taskName, "/tr", exe, "/sc", schedule, "/st", startTime, "/rl", runLevel])
                if FileExist(exe)
                    ;this.ExecSilent('schtasks /create /f /sc ondemand /rl highest /tn "' name '" /tr "' exe '"')
                    this.ExecSilent('schtasks /create /f /sc once /rl highest /st 00:00 /tn "' name '" /tr "' exe '"')
        }

        Reload()
    }
}

; ------------------------------------------------------------
; Run the GUI
; ------------------------------------------------------------
TaskGui.Show()
