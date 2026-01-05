; TITLE:    AhkRunSkipUAC v1.0
; SOURCE:   jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:

*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include <RunAsAdmin>

RegisterTask() {
    if !A_IsAdmin {
        MsgBox "Please run this registration script as Admin once."
        return
    }

    taskName := "AdminTask_" . StrReplace(A_ScriptName, " ", "_")
    author := A_UserName
    ; The command to run: AHK executable + the script path
    fullCmd := '\"' . A_AhkPath . '\"'
    args := '\"' . A_ScriptFullPath . '\"'

    ; XML template for a "Highest Priority" task
    xml := '
    (
    <?xml version="1.0" encoding="UTF-16"?>
    <Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
      <RegistrationInfo>
        <Author>' author '</Author>
      </RegistrationInfo>
      <Settings>
        <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
        <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
        <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
        <AllowHardTerminate>true</AllowHardTerminate>
        <StartWhenAvailable>false</StartWhenAvailable>
        <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
        <IdleSettings>
          <StopOnIdleEnd>true</StopOnIdleEnd>
          <RestartOnIdle>false</RestartOnIdle>
        </IdleSettings>
        <AllowStartOnDemand>true</AllowStartOnDemand>
        <Enabled>true</Enabled>
        <Hidden>false</Hidden>
        <RunOnlyIfIdle>false</RunOnlyIfIdle>
        <WakeToRun>false</WakeToRun>
        <ExecutionTimeLimit>PT72H</ExecutionTimeLimit>
        <Priority>7</Priority>
      </Settings>
      <Principals>
        <Principal id="Author">
          <LogonType>InteractiveToken</LogonType>
          <RunLevel>HighestAvailable</RunLevel>
        </Principal>
      </Principals>
      <Actions Context="Author">
        <Exec>
          <Command>' fullCmd '</Command>
          <Arguments>' args '</Arguments>
        </Exec>
      </Actions>
    </Task>
    )'

    ; Save XML to temp and import via schtasks
    tempFile := A_Temp "\ahk_task.xml"
    if FileExist(tempFile)
        FileDelete(tempFile)
    FileAppend(xml, tempFile, "UTF-16")

    try {
        RunWait('schtasks /create /tn "' taskName '" /xml "' tempFile '" /f', , "Hide")
        MsgBox "Task '" taskName "' registered successfully!`nUAC will now be skipped for this script."
    } catch {
        MsgBox "Failed to register task."
    }
    
    FileDelete(tempFile)
}

RegisterTask()
