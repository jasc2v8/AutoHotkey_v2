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

class RunSkipUAC {
    /**
     * Runs a program with highest privileges bypassing UAC
     * @param Target Path to the executable
     * @param Args Command line arguments
     * @param WorkingDir Start in directory
     */
    static Run(Target, Args := "", WorkingDir := "") {
        TaskName := "AHK_SkipUAC_" . StrReplace(Target, "\", "_")
        
        try {
            Service := ComObject("Schedule.Service")
            Service.Connect()
            RootFolder := Service.GetFolder("\")

            ; 1. Define the Task
            Definition := Service.NewTask(0)
            Definition.RegistrationInfo.Description := "Temporary task to bypass UAC for AHK"
            Definition.Settings.AllowDemandStart := true
            Definition.Settings.ExecutionTimeLimit := "PT0S" ; No time limit

            ; 2. Set Principal to Highest Privileges (Admin)
            Principal := Definition.Principal
            Principal.LogonType := 3 ; TASK_LOGON_INTERACTIVE_TOKEN
            Principal.RunLevel := 1  ; TASK_RUNLEVEL_HIGHEST

            ; 3. Add the Action (The program to run)
            Action := Definition.Actions.Create(6) ; 6 = ExecAction
            Action.Path := Target
            Action.Arguments := Args
            Action.WorkingDirectory := WorkingDir

            ; 4. Register (Create) the Task
            ; 6 = TASK_CREATE_OR_UPDATE
            RootFolder.RegisterTaskDefinition(TaskName, Definition, 6, , , 3)

            ; 5. Run the Task
            Task := RootFolder.GetTask(TaskName)
            Task.Run("")

            ; 6. Cleanup: Delete the task immediately (it remains running as a process)
            RootFolder.DeleteTask(TaskName, 0)
            
        } catch Error as err {
            MsgBox("Failed to RunSkipUAC:`n" . err.Message)
        }
    }
    
    /**
     * Checks if a task is set to "Run with highest privileges"
     * @param TaskName The name of the task in Task Scheduler
     * @returns {Object} {IsElevated: Bool, Target: String, Arguments: String}
     */
    static GetInfo(TaskName) {
        try {
            Service := ComObject("Schedule.Service")
            Service.Connect()
            Task := Service.GetFolder("\").GetTask(TaskName)
            
            Definition := Task.Definition
            Action := Definition.Actions.Item(1)
            
            return {
                IsElevated: (Definition.Principal.RunLevel = 1),
                Target: (Action.Type = 6 ? Action.Path : "N/A"),
                Args: (Action.Type = 6 ? Action.Arguments : "")
            }
        } catch {
            return {IsElevated: false, Target: "Not Found", Args: ""}
        }
    }

}

; --- Usage Example ---
F1::RunSkipUAC.Run("cmd.exe") ; Runs Admin Command Prompt without UAC popup
F2::RunSkipUAC.Run("taskmgr.exe")

