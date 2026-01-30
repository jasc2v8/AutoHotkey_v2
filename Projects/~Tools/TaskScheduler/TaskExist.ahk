#Requires AutoHotkey v2+
#SingleInstance

; Version 1.0.4
; Function to check if a Scheduled Task exists

TaskName := "AdminLauncher" ; Change this to the task name you are looking for

Exists := TaskExists(TaskName)

if (Exists)
    MsgBox("Task '" TaskName "' exists.")
else
    MsgBox("Task '" TaskName "' does not exist.")

TaskExists(Name) {
    try {
        Service := ComObject("Schedule.Service")
        Service.Connect()
        RootFolder := Service.GetFolder("\")
        ; Attempt to get the task. If it doesn't exist, it throws an error.
        Task := RootFolder.GetTask(Name)
        return true
    } catch {
        return false
    }
}