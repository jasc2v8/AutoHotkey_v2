; TITLE: LogArgs v0.0
/*
  TODO:
*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
#NoTrayIcon


#Requires AutoHotkey v2.0

MyGui := Gui(, "Task Scheduler Targets")
LV := MyGui.Add("ListView", "r20 w800", ["Task Name", "Target (Action)", "Arguments"])

try {
    TaskService := ComObject("Schedule.Service")
    TaskService.Connect()
    RootFolder := TaskService.GetFolder("\")
    
    ; Get tasks in the root folder
    for task in RootFolder.GetTasks(1) {
        taskName := task.Name
        targetPath := ""
        arguments := ""
        
        ; A task can have multiple actions; we check the first one (Index 1)
        ; Action Type 6 is "Exec" (Execute a program)
        try {
            action := task.Definition.Actions.Item(1)
            ;if (action.Type = 6) { 
                targetPath := action.Path
                arguments := action.Arguments
            ;} else {
            ;    targetPath := "[Non-Exec Action]"
            ;}
        } catch {
            targetPath := "[No Actions Defined]"
        }

        LV.Add(, taskName, targetPath, arguments)
    }
} catch Error as err {
    MsgBox("Error: " err.Message)
}

LV.ModifyCol(1, "AutoHdr")
LV.ModifyCol(2, "AutoHdr")
MyGui.Show()