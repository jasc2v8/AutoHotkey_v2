; TITLE:    MyScript v0.0
; SOURCE:   AHKv2 https://www.autohotkey.com/boards/viewtopic.php?f=13&t=31695&p=212511&hilit=schtasks#p212511
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

; Constants used by the Task Scheduler COM interface
TASK_ENUM_HIDDEN := 0x1 ; Flag to include hidden tasks in the enumeration

try
{
    ; 1. Create the Task Scheduler Service COM Object
    Service := ComObject("Schedule.Service")
    
    ; 2. Connect to the local machine's Task Scheduler service
    ; The arguments can be used to connect to a remote computer (hostname, user, domain, password)
    Service.Connect()
    
    ; 3. Get the root folder for tasks ("\")
    ; This is the main directory where tasks are stored.
    RootFolder := Service.GetFolder("\")
    
    ; 4. Get the collection of tasks in the root folder
    ; 0 is the task flags parameter (use TASK_ENUM_HIDDEN for all tasks)
    Tasks := RootFolder.GetTasks(TASK_ENUM_HIDDEN)
    
    ; 5. Iterate through the task collection and build a list
    TaskNames := ""
    TaskCount := 0
    
    ; The Tasks object is a collection; loop through it using a For-Loop
    for Task in Tasks
    {
        ; Task.Name is the name of the scheduled task
        TaskNames .= Task.Name "`n"
        TaskCount++
    }
    
    ; 6. Display the result
    MsgBox("Successfully connected to Task Scheduler.`n"
         . "Total Tasks Found: " TaskCount "`n`n"
         . "--- Task List ---`n"
         . TaskNames)

}
catch as e
{
    MsgBox("An error occurred connecting to or querying the Task Scheduler:`n"
         . "Error: " e.Message)
}