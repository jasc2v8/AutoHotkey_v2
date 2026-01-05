#Requires AutoHotkey 2.0+

#SingleInstance Force
#NoTrayIcon

#Include <RunAsAdmin>
#Include <RunCMD>

; Runs the PowerShell command as Administrator
;Run("*RunAs powershell.exe -Command `"Get-AppxPackage Microsoft.Windows.ShellExperienceHost | Reset-AppxPackage`"")

; YES! MsgBox "Flicker?"

Request:= RunCMD.ToArray(
    "powershell",
    "Get-AppxPackage Microsoft.Windows.ShellExperienceHost",
    " | Reset-AppxPackage")

;Request:= "powershell Get-AppxPackage Microsoft.Windows.ShellExperienceHost | Reset-AppxPackage"

MsgBox RunCMD(Request), "Flicker?"
