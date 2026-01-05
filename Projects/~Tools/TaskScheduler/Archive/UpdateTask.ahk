; TITLE:    MyScript v0.0
; SOURCE:   AHKv2 https://www.autohotkey.com/boards/viewtopic.php?f=13&t=31695&p=212511&hilit=schtasks#p212511
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

; Note: Must run as Admin to modify most tasks

UpdateTaskDefinition(TaskName, TaskDefinition, Flags := 6, UserId := "", Password := "", LogonType := 3) {
    ; Constants for readability
    TASK_CREATE := 2
    TASK_UPDATE := 4
    TASK_CREATE_OR_UPDATE := 6

    TASK_LOGON_NONE := 0
    TASK_LOGON_PASSWORD := 1
    TASK_LOGON_S4U := 2
    TASK_LOGON_INTERACTIVE_TOKEN := 3
    TASK_LOGON_GROUP := 4
    TASK_LOGON_SERVICE_ACCOUNT := 5
    TASK_LOGON_INTERACTIVE_TOKEN_OR_PASSWORD := 6

    try {
        Service := ComObject("Schedule.Service")
        Service.Connect()

        RootFolder := Service.GetFolder("\")
        RootFolder.RegisterTaskDefinition(
            TaskName,
            TaskDefinition,
            Flags,
            UserId,
            Password,
            LogonType
        )

        return RootFolder.GetTask(TaskName) ; return updated RegisteredTask object
    }
    catch as e {
        MsgBox("Task update failed:`n" e.Message, "Error", "IconX")
        return ""
    }
}