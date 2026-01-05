; TITLE:    MyScript v0.0
; SOURCE:   AHKv2 https://www.autohotkey.com/boards/viewtopic.php?f=13&t=31695&p=212511&hilit=schtasks#p212511
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

; if runLevel = 'highest' then this DOES REQUIRE Admin

; #region Admin Check

if not (A_IsAdmin or RegExMatch(DllCall("GetCommandLine", "str"), " /restart(?!\\ S)"))
{
    try
    {
        if A_IsCompiled
            Run '*RunAs "' A_ScriptFullPath '" /restart'
        else
            Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
    }
    ExitApp  ; Exit the current, non-elevated instance
}

; --- Configuration ---
;TargetTaskName := "My Test Task" ; **Change this to the name of your existing task**
TargetTaskName := "AhkLogArgsOnDemand"

;NewArguments := '"New Arg 1" "New Arg 2" /flag' ; **The new string of arguments to use**
NewArguments := '-displayOFF' ; **The new string of arguments to use**

; Note: Arguments must include double-quotes if they contain spaces.

try
{
    ; 1. Connect to the Task Scheduler Service
    Service := ComObject("Schedule.Service")
    Service.Connect()

    ; 2. Get the Task Folder and Registered Task object
    RootFolder := Service.GetFolder("\" )
    
    ; Get the RegisteredTask object. This will throw an error if the task doesn't exist.
    RegisteredTask := RootFolder.GetTask(TargetTaskName)
    
    ; 3. Get the Task Definition (the settings object)
    ; This object contains all the configuration details (triggers, actions, etc.)
    TaskDefinition := RegisteredTask.Definition
    
    ; 4. Access the Actions Collection
    ; Tasks usually have at least one action (e.g., Start a program).
    Actions := TaskDefinition.Actions
    
    ;MsgBox("Actions Len: " Actions.Count "`n`nType: " Type(Actions), "DEBUG")

    ; 5. Check if the task has any actions and if the first one is a program action
    if (Actions.Count > 0)
    {
        ; Get the first action in the collection (index 1)
        Action := Actions.Item(1)
        
        ;MsgBox("Action Path: " Action.Path "`n`nAction.Type: " Action.Type, "DEBUG")

        ; Verify it is a program action (TASK_ACTION_EXEC = 0)
        ; The Type property defines the action type.
        if (Action.Type = 0) ; 0 = TASK_ACTION_EXEC (Start a program)
        {
            ; 6. Update the Arguments property of the ExecAction object
            OldArguments := Action.Arguments ; Get the original arguments for the message
            Action.Arguments := NewArguments
            
            ; MsgBox("BEFORE: Arguments for task '" TargetTaskName "`n`n"
            ;      . "Old Arguments: " OldArguments "`n"
            ;      . "New Arguments: " NewArguments, "Task Update BEFORE")
            
            ; 7. Re-register (save) the modified task definition
            TASK_CREATE_OR_UPDATE := 0x06
            TASK_LOGON_INTERACTIVE_TOKEN := 0x03 ; The task will only run if the specified user is logged on.
            RootFolder.RegisterTaskDefinition(TargetTaskName, TaskDefinition, TASK_CREATE_OR_UPDATE, "", "", TASK_LOGON_INTERACTIVE_TOKEN)
            
            MsgBox("Success: Arguments for task '" TargetTaskName "' updated!`n`n"
                 . "Old Arguments: " OldArguments "`n`n"
                 . "New Arguments: " NewArguments, "Task Update Complete")
        }
        else
        {
            MsgBox("Error: The first action for task '" TargetTaskName 
                 . "' is not a 'Start a program' action. It is type: " Action.Type, "Error", "IconX")
        }
    }
    else
    {
        MsgBox("Error: The task '" TargetTaskName "' has no actions defined.", "Error", "IconX")
    }

}
catch as e
{
    ; Display a detailed error message if COM connection or task retrieval fails
    MsgBox("An error occurred during Task Scheduler interaction:`n"
         . "Message: " e.Message "`n"
         . "Target Task: " TargetTaskName, "COM Error", "IconX")
}