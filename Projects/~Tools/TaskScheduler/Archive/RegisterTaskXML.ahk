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

global TaskName     :=  "AHK_RunSkipUAC"

global ProgramPath  :=  "C:\ProgramData\AutoHotkey\AhkRunSkipUAC\AhkRunSkipUAC.ahk"

split:= SplitPath(ProgramPath, &OutName, &OutDir, &OutExt, &OutNameNoExt, &OutDrive)

if OutExt = '.ahk'
  fullCmd := '"' . A_AhkPath . A_Space . ProgramPath . '"'
else
  fullCmd := '"' . ProgramPath . '"'

;MsgBox fullCmd

RegisterTask(TaskName, ProgramPath, "")

ExitApp()

; ------------------------------------------------------------
RegisterTask(TaskName, ProgramPath, Arguments) {

    author  := A_UserName
    command := ProgramPath
    args    := Arguments

    ; XML template for a "Highest Priority" on-demand task
    xml := '
    (
    <?xml version="1.0" encoding="UTF-16"?>
    <Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
      <RegistrationInfo>
        <Date>2023-01-01T00:00:00</Date>
        <Author>Administrator</Author>
        <Description>This task runs only when manually triggered.</Description>
      </RegistrationInfo>

      <Triggers />

      <Principals>
        <Principal id="Author">
          <LogonType>InteractiveToken</LogonType>
          <RunLevel>HighestAvailable</RunLevel>
        </Principal>
      </Principals>

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

      <Actions Context="Author">
        <Exec>
          <Command>" command "</Command>
          <Arguments>" args "</Arguments>
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
        RunWait('schtasks /create /tn "' TaskName '" /xml "' tempFile '" /f', , "Hide")
        MsgBox "Task '" TaskName "' registered successfully!`nUAC will now be skipped for this script."
    } catch {
        MsgBox "Failed to register task."
    }
    
    FileDelete(tempFile)
}


