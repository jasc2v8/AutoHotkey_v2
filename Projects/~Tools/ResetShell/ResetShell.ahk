; TITLE   : ResetShell v1.0
; SOURCE  : jasc2v8
; LICENSE : The Unlicense, see https://unlicense.org
; PURPOSE : Workaround to fix Windows 11 Search Bar Empty (How stupid!)
; OVERVIEW: ResetShell.ahk run Task AdminLauncher, which runs AdminLauncher.ahk, then runs the command
;           Uses NamedPipe IPC to communicate with other scripts.
; SCRIPTS: ResetShell.ahk => AdminLauncher.ahk
; NOTES  : Example of using AdminLaucher to run a command verses a script.
/*
  TODO:

*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
;#NoTrayIcon

#Include <AdminLauncher>
#Include <LogFile>
#Include <NamedPipe>
#Include <RunCMD>

; #region Version Block

; Language codes (en-US=1033): https://www.autoitscript.com/autoit3/docs/appendix/OSLangCodes.htm
;@Ahk2Exe-Set CompanyName, jasc2v8
;@Ahk2Exe-Set FileDescription, ResetShell
;@Ahk2Exe-Set FileVersion, 1.0.0.0
;@Ahk2Exe-Set InternalName, ResetShell
;@Ahk2Exe-Set Language, 1033
;@Ahk2Exe-Set LegalCopyright, ©2025 jasc2v8
;@Ahk2Exe-Set LegalTrademarks, NONE™
;@Ahk2Exe-Set OriginalFilename, ResetShell.exe
;@Ahk2Exe-Set ProductName, ResetShell
;@Ahk2Exe-Set ProductVersion, 1.0.0.0
;@Ahk2Exe-SetMainIcon D:\Software\DEV\Work\AHK2\Projects\ResetShell\Icons\Cogs.ico

;@Inno-Set AppId, {{6877021E-6AF8-4D69-85E2-DB46C3203E13}}
;@Inno-Set AppPublisher, jasc2v8

; #region Globals

global LogPath          := "D:\ResetShell.log"
global logger           := LogFile(LogPath, "CONTROL", false)

;global WorkerPath       := EnvGet("PROGRAMDATA") "\AutoHotkey\ResetShell\ResetShellWorker.ahk"

; #region START


  ; Request:= RunCMD.ToCSV(
  ;   "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe",
  ;   "Get-AppxPackage Microsoft.Windows.ShellExperienceHost",
  ;   " | Reset-AppxPackage")


MsgBox(,"Reset Shell", "Icon?")

logger.Write("Run Task")

launcher:= AdminLauncher()

launcher.StartTask()

Request:= "powershell.exe " '"' "Get-AppxPackage Microsoft.Windows.ShellExperienceHost | Reset-AppxPackage" '"'

launcher.Run(Request)

MsgBox("Complete.", "Reset Shell", "Iconi")

;Request:= RunCMD.ToArray("powershell.exe", "Get-AppxPackage Microsoft.Windows.ShellExperienceHost",  "|", "Reset-AppxPackage")
; no output for this request
;RunCMD(Request)

ExitApp()
