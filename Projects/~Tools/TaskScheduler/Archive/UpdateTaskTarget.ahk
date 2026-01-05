; TITLE:    MyScript v0.0
; SOURCE:   AHKv2 https://www.autohotkey.com/boards/viewtopic.php?f=13&t=31695&p=212511&hilit=schtasks#p212511
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Requires AutoHotkey v2.0

; Note: Must run as Admin to modify most tasks
if !A_IsAdmin {
    Run('*RunAs "' A_ScriptFullPath '"')
    ExitApp()
}

TaskName := "MyTestTask"
NewPath := "C:\Windows\System32\notepad.exe"
NewArgs := "/open" ; Optional arguments

try {
    Service := ComObject("Schedule.Service")
    Service.Connect()
    
    ; 1. Get the folder and the task
    RootFolder := Service.GetFolder("\")
    Task := RootFolder.GetTask(TaskName)
    
    ; 2. Access the Definition
    Definition := Task.Definition
    
    ; 3. Modify the first Action (Index 1)
    ; Action Type 6 is ExecAction
    Action := Definition.Actions.Item(1)
    if (Action.Type = 6) {
        Action.Path := NewPath
        Action.Arguments := NewArgs
        
        ; 4. Save the changes back to the system
        ; Parameter 6 = TASK_UPDATE (Update existing task)
        ; The following parameters are for credentials (use 0/blank for current user)
        RootFolder.RegisterTaskDefinition(
            TaskName, 
            Definition, 
            6,          ; Update flag
            ,,          ; User ID and Password (blank for current)
            3           ; LogonType: 3 = TASK_LOGON_INTERACTIVE_TOKEN
        )
        
        MsgBox("Task '" TaskName "' updated successfully!")
    }
} catch Error as err {
    MsgBox("Failed to update task:`n" err.Message)
}