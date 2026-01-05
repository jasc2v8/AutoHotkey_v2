; TITLE:    AhkRunSkipUAC v1.0
; SOURCE:   jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:

    BackupControlTool.ah
        task:= RunTaskHelper("AHK_RunSkipUAC")
        task.Run("C:\ProgramData\AutoHotkey\BackupControlTool\BackupControlTask.exe")

    task:= RunTaskHelper("AHK_RunSkipUAC")
        task:= RunTaskHelper("AHK_RunSkipUAC")
        pipe := NamedPipe("AHK_RunSkipUAC")

    

    AHK_RunSkipUAC.ahk
        task:= RunTaskHelper("AHK_RunSkipUAC")
        task.Run(ProgramPath)




        pipe := NamedPipe("AHK_RunSkipUAC")
        ProgramPathpipe.ConnectClient()

    AhkRunSkipUAC.ini
    [SETTINGS]
    PROGRAM := "C:\ProgramData\AutoHotkey\BackupControlTool\BackupControlTask.exe"
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Requires AutoHotkey v2.0
#SingleInstance Force

; Automatically elevate the script to Admin (Required for Task Scheduler modification)
if !A_IsAdmin {
    Run('*RunAs "' A_ScriptFullPath '"')
    ExitApp()
}

; --- GUI CONSTRUCTION ---
MyGui := Gui("+Resize", "AHK v2 Task Library")
MyGui.SetFont("s9", "Segoe UI")

; Group 1: Task List
MyGui.Add("GroupBox", "w780 h300 Section", "Current Scheduled Tasks")
LV := MyGui.Add("ListView", "xs+10 ys+25 r12 w760", ["Task Name", "Target Path", "Args", "Admin?"])

; Group 2: Actions
MyGui.Add("GroupBox", "xs w780 h80 Section", "Actions")
MyGui.Add("Button", "xs+10 ys+25 w120", "Refresh List").OnEvent("Click", (*) => TaskLib.Refresh(LV))
MyGui.Add("Button", "x+10 yp w120", "Run Selected").OnEvent("Click", (*) => TaskLib.RunSelected(LV))
MyGui.Add("Button", "x+10 yp w150", "Toggle Admin/UAC").OnEvent("Click", (*) => TaskLib.ToggleUAC(LV))
MyGui.Add("Button", "x+10 yp w120", "Close").OnEvent("Click", (*) => MyGui.Destroy())

; Initialize and Show
TaskLib.Refresh(LV)
MyGui.Show()

; --- THE LIBRARY CLASS ---
class TaskLib {
    
    ; 1. GET: Populate ListView with Task Data (Bidirectional)
    static Refresh(LVObj) {
        LVObj.Delete()
        try {
            Service := ComObject("Schedule.Service")
            Service.Connect()
            RootFolder := Service.GetFolder("\")
            
            for task in RootFolder.GetTasks(1) {
                Definition := task.Definition
                Principal := Definition.Principal
                
                ; Extract Action Target
                target := "[No Exec Action]"
                args := ""
                try {
                    Action := Definition.Actions.Item(1)
                    if (Action.Type = 6) { ; ExecAction
                        target := Action.Path
                        args := Action.Arguments
                    }
                }
                
                ; Add data to ListView
                isElevated := (Principal.RunLevel = 1) ? "YES" : "No"
                LVObj.Add(, task.Name, target, args, isElevated)
            }
            
            ; Auto-size all columns
            Loop LVObj.GetCount("Col")
                LVObj.ModifyCol(A_Index, "AutoHdr")
                
        } catch Error as err {
            MsgBox("Error reading tasks: " err.Message)
        }
    }

    ; 2. MODIFY: Toggle "Highest Privileges" (Bidirectional Update)
    static ToggleUAC(LVObj) {
        if !(Row := LVObj.GetNext())
            return MsgBox("Select a task first!")
            
        TaskName := LVObj.GetText(Row, 1)
        
        try {
            Service := ComObject("Schedule.Service")
            Service.Connect()
            Folder := Service.GetFolder("\")
            Task := Folder.GetTask(TaskName)
            Definition := Task.Definition
            
            ; Flip the RunLevel (0 = Standard, 1 = Highest)
            currentLevel := Definition.Principal.RunLevel
            Definition.Principal.RunLevel := (currentLevel = 1 ? 0 : 1)
            
            ; Save changes back to Scheduler (Flag 6 = Update)
            Folder.RegisterTaskDefinition(TaskName, Definition, 6, , , 3)
            
            this.Refresh(LVObj) ; Update GUI
            MsgBox("Task privileges updated for: " . TaskName)
        } catch Error as err {
            MsgBox("Failed to toggle UAC: " err.Message)
        }
    }

    ; 3. RUN: Trigger the task immediately
    static RunSelected(LVObj) {
        if !(Row := LVObj.GetNext())
            return MsgBox("Select a task first!")
            
        TaskName := LVObj.GetText(Row, 1)
        
        try {
            Service := ComObject("Schedule.Service")
            Service.Connect()
            Task := Service.GetFolder("\").GetTask(TaskName)
            Task.Run("")
            MsgBox("Task '" TaskName "' triggered.")
        } catch Error as err {
            MsgBox("Failed to run task: " err.Message)
        }
    }
}
