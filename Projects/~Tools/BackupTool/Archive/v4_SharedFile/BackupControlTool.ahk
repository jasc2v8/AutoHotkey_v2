; TITLE   : BackupControlTool v3.0
; PURPOSE : Run SyncBack.exe as Admin with no UAC prompt.
; OVERVIEW: BackupControlTool Runs an on-demand Task AhkRunSkupUAC which runs BackupControlTask at runLevel='highest'
;           BackupControlTool uses a SharedFile to communicate with BackupControlTask who runs Syncback.
; FLOW:
;  1.  BackupControlTool sets PROGRAM=BackupControlTask.exe in "C:\ProgramData\AutoHotkey\AhkRunSkipUAC\AhkRunSkipUAC.ini"
;  2.  BackupControlTool Gui gets User parameter: 'Nothing', 'MonOff', 'LogOff', 'Sleep', 'Shutdown'
;  3.  BackupControlTool starts the on-demand Task 'AhkRunSkipUAC'
;  4.  The Task AhkRunSkipUAC reads AhkRunSkipUAC.ini to get PROGRAM=BackupControlTask.exe)
;  5.  The Task AhkRunSkipUAC runs BackupControlTask.exe at runLevel='highest'
;  6.  The Task AhkRunSkipUAC returns to 'Ready' state.
;  7.  BackupControlTask.exe reads the command from BackupControlTool: (SyncBackPath, SyncBackParams, SyncBackProfile)
;  8.  BackupControlTask.exe runs PATH at runLevel='highest'
;  9.  BackupControlTask.exe exits
; 10.  BackupControlTool repeats the above, or Exits.
;
/*
  TODO:

    
*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
;#NoTrayIcon
TraySetIcon('shell32.dll', 294) ; Backup/Restore Icon

#Include <IniHelper>
#Include <RunHelper>
#Include <SharedFile>

; #region Version Block

; Language codes (en-US=1033): https://www.autoitscript.com/autoit3/docs/appendix/OSLangCodes.htm
;@Ahk2Exe-Set CompanyName, jasc2v8
;@Ahk2Exe-Set FileDescription, Backup Control Tool
;@Ahk2Exe-Set FileVersion, 3.0.0.0
;@Ahk2Exe-Set InternalName, BackupControlTool
;@Ahk2Exe-Set Language, 1033
;@Ahk2Exe-Set LegalCopyright, ©2025 jasc2v8
;@Ahk2Exe-Set LegalTrademarks, NONE™
;@Ahk2Exe-Set OriginalFilename, BackupControlTool.exe
;@Ahk2Exe-Set ProductName, BackupControlTool
;@Ahk2Exe-Set ProductVersion, 3.0.0.0
;@Ahk2Exe-SetMainIcon BackupControlTool.ico

;@Inno-Set AppId, {{10D9F70C-88D1-428B-811D-5264CA644A87}}
;@Inno-Set AppPublisher, jasc2v8

; #region Admin Check

; SyncBack requires Administrator privileges
; full_command_line := DllCall("GetCommandLine", "str")

; if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\\ S)"))
; {
;     try
;     {
;         if A_IsCompiled
;             Run '*RunAs "' A_ScriptFullPath '" /restart'
;         else
;             Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
;     }
;     ExitApp  ; Exit the current, non-elevated instance
; }

; #region Globals

global TASK_PATH       := "C:\ProgramData\AutoHotkey\BackupControlTool\BackupControlTask.exe"

global INI_PROGRAM_PATH  := EnvGet("PROGRAMDATA") "\AutoHotkey\AhkRunSkipUAC\AhkRunSkipUAC.ini"
global INI_PROGRAM       := IniHelper(INI_PROGRAM_PATH)

global SyncBackPath     := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
global SyncBackProfiles := EnvGet("LOCALAPPDATA") "\2BrightSparks\SyncBack\Profiles Backup"
global logDir           := EnvGet("LOCALAPPDATA") "\2BrightSparks\SyncBack\Logs"
global DefaultProfile   := "~Backup JIM-PC folders to JIM-SERVER"

global SoundSuccess     := "C:\Windows\Media\Windows Notify Calendar.wav"
global SoundError       := "C:\Windows\Media\Windows Critical Stop.wav"

global INI_PATH         := EnvGet("PROGRAMDATA") "\AutoHotkey\BackupControlTool\BackupControlTool.ini"
global INI              := IniHelper(INI_PATH)

global Logging          := false
global LogFile          := EnvGet("PROGRAMDATA") "\AutoHotkey\BackupControlTool\BackupControlTool.log"

global SyncBackSelectedProfile := INI.ReadSettings("PROFILE")

global SharedFilePath   := EnvGet("PROGRAMDATA") "\AutoHotkey\BackupControlTool\SharedFile.txt"

global IsRunning        := false

OnExit(ExitHandler)

; #region Shared File

; The SharedFile will be created by the BackupControlTask Task when it is started
global SF := SharedFile("Client", SharedFilePath)

; #region Create Gui

MyGui := Gui("-AlwaysOnTop", "Backup Control Tool v3.0")
MyGui.BackColor := "4682B4" ; Steel Blue

; #region Create Controls

MyGui.SetFont("S11 CBlack w405", "Segouie UI")
TextProfile := MyGui.AddEdit('xm w410 h20 Center Backgrounda1e3a5', SyncBackSelectedProfile)
ButtonSelectProfile := MyGui.AddButton("yp w60 h20", "Profile")

MyGui.SetFont("S10 cWhite w700", "Segouie UI")
MyGui.AddGroupBox("xm w480 h100", "Action after Backup:")

MyGui.SetFont("S11 CBlack w400", "Segouie UI")
TextFiller      := MyGui.AddText("xm yp+40 w0 +Hidden")
ButtonNothing   := MyGui.AddButton("yp w70", "Nothing")
ButtonMonOff    := MyGui.AddButton("yp w70", "MonOff")
ButtonLogOff    := MyGui.AddButton("yp w70", "LogOff")
ButtonSleep     := MyGui.AddButton("yp w70 Default", "Sleep")
ButtonHibernate := MyGui.AddButton("yp w70", "Hibernate")
ButtonShutdown  := MyGui.AddButton("yp w70", "Shutdown")

MyGui.SetFont()
TextFiller    := MyGui.AddText("xm yp+75 w145 +Hidden")
ButtonLogs    := MyGui.AddButton("yp w75", "Logs")
;ButtonClear   := MyGui.AddButton("yp w75", "Clear")
ButtonCancel  := MyGui.AddButton("yp w75", "Cancel")

SB := MyGui.AddStatusBar()

WriteStatus('Ready.')

; #region Event Handlers

ButtonSelectProfile.OnEvent("Click", ButtonSelectProfile_Click)
ButtonLogs.OnEvent("Click", ButtonLogs_Click)
;ButtonClear.OnEvent("Click", ButtonClear_Click)

ButtonNothing.OnEvent("Click", ButtonCommon_Click)
ButtonMonOff.OnEvent("Click", ButtonCommon_Click)
ButtonLogOff.OnEvent("Click", ButtonCommon_Click)
ButtonSleep.OnEvent("Click", ButtonCommon_Click)
ButtonHibernate.OnEvent("Click", ButtonCommon_Click)
ButtonShutdown.OnEvent("Click", ButtonCommon_Click)
ButtonCancel.OnEvent("Click", ButtonCancel_Click)

MyGui.OnEvent("Close", (*) => ExitApp())

; Show the GUI
MyGui.Show()

; Focus on the default button to Unselect the text in the profile box
ControlFocus("Sleep", MyGui)

; #region Functions

ButtonCancel_Click(Ctrl, Info) {
 ExitApp()
}

ButtonCommon_Click(Ctrl, Info){
  global IsRunning

  if (IsRunning) {
    SoundBeep
    return
  }

  WriteStatus("Ready.")

  SyncBackPostAction:= Ctrl.Text

  timedOut := CountdownAndBlock(Ctrl.Text, 5)

  if (timedOut) {

    WriteStatus("Running...")

    IsRunning := true

    ;WinSetTransparent(200, MyGui.Hwnd)

    ; Start BackupControlToolWorker Task
    StartTask(TASK_PATH)

    ; Form the command to run
    command:= RunHelper.ConvertToCSV(SyncBackPath, SyncBackPostAction, SyncBackSelectedProfile)

    WriteLog("WaitWrite command to Server: " command)

    timedOut := SF.WaitWrite(command)

    if (timedOut)
        WriteLog("Timeout WaitWrite")
    
    WriteLog("Wait Read Response from Server")

    response := SF.WaitRead()

    if (response = "")
        WriteLog("Timeout WaitRead")

    WriteLog("response: [" response "]")

    if (SubStr(response, 1, 3) != "ACK") {
        MsgBox("Server not responding.`n`nPress OK to exit.", "CLIENT")
        ExitApp()
    }
    
    ; The Task will end itsself

    WriteLog("Finished.")

    WriteStatus("Finished.")

    IsRunning := false

    ; restore if user minimized
    WinActivate(MyGui.Hwnd)
  }
}

ButtonLogs_Click(Ctrl, Info) {
  Run('explorer.exe ' '"' logDir '"')
}

ButtonClear_Click(Ctrl, Info) {
  WriteStatus('Ready.')
}

ButtonSelectProfile_Click(Ctrl, Info) {
  global SyncBackSelectedProfile
  WriteStatus("Ready.")
  selection := FileSelect(0, SyncBackProfiles)
  if (selection != "") {
    SplitPath(selection, , , , &OutNameNoExt)
    SyncBackSelectedProfile := OutNameNoExt
    TextProfile.Text := SyncBackSelectedProfile
    INI.WriteSettings("PROFILE", SyncBackSelectedProfile)
  }
}

CheckTimeout(timeout, number) {
    if (timeout)
        MsgBox("Timeout Number: " number , A_ScriptName, "iconX")
}

CountdownAndBlock(Title, Seconds)
{
  ; Define initial variables
  global TimerGui := ''
  global TimerRunning := true
  global RemainingTime := Seconds
  returnValue := true ; true=timedout, false=canceled

  ; Create the new GUI object
  TimerGui := Gui("+AlwaysOnTop -Caption +Border")
  TimerGui.Title := ''
  TimerGui.BackColor := "Yellow"

  ; Add a text control for the title
  TimerGui.SetFont("s18 bold", "Consolas")
  TimerText := TimerGui.AddText("Center", 'Backup then`n' Title ' in:')

  ; Add a text control to display the countdown
  TimerGui.SetFont("s48 bold cRed", "Consolas")
  TimerText := TimerGui.AddText("w200 Center vCountdownText", RemainingTime)

  ; add buttons
  TimerGui.SetFont("s12 Norm", "Consolas")
  TimerGui.AddButton("xm w100 Default","OK").OnEvent("Click", ButtonOK_Click)
  TimerGui.AddButton("yp w100","Cancel").OnEvent("Click", ButtonCancel_Click)

  ; Display the GUI and center it.
  TimerGui.Show("Center")

  ; Set up the Timer function (runs every 1000ms / 1 second)
  SetTimer UpdateTimer, 1000

  ; While the GUI is open and the timer is running, the main script thread pauses here.
  While (TimerRunning)
  {
      Sleep(100) ; Wait 100ms before checking the flag again
  }

  ; Cleanup after the loop finishes
  TimerGui.Destroy()

  return returnValue

  ButtonOK_Click(*)
  {
    SetTimer UpdateTimer, 0
    TimerRunning := false
    returnValue := true
  }
  ButtonCancel_Click(*)
  {
    SetTimer UpdateTimer, 0
    TimerRunning := false
    returnValue := false
  }

  UpdateTimer(*)
  {
    global TimerGui
    global TimerRunning
    global RemainingTime
      
    if (RemainingTime <= 1)
    {
        SetTimer UpdateTimer, 0
        TimerRunning := false    
        return
    }
    RemainingTime--
    TimerGui["CountdownText"].Text := RemainingTime
  }
}

SetTaskProgram(TASK_PATH) {
  programPath := INI_PROGRAM.ReadSettings("PROGRAM")
  if (programPath != TASK_PATH)
    INI_PROGRAM.WriteSettings("PROGRAM", TASK_PATH)
}

StartTask(TASK_PATH) {

  ; Set AhkRunSkipUAC.ini to run BackupControlTask
  SetTaskProgram(TASK_PATH)

  ; Start Task to read command from the Shared Memory
  command := RunHelper.ConvertToArray('schtasks.exe', "/run /tn", 'AhkRunSkipUAC')
  output  := RunHelper(command)

  WriteLog("Waiting for SharedFile.")

  timedOut:= WaitFileExist(SharedFilePath, 5000)

  if (timedOut) {
    MsgBox("Worker Task did not start.`n`nPress OK to exit.", "BackupControlTool")
    ExitApp()
  }

  WriteLog("Started Task: " RTrim(output, "`n"))
}

WaitFileExist(FilePath, TimeoutMs:=-1)
{
      StartTime := A_TickCount
      EndTime := StartTime + TimeoutMs

      Loop {
          if FileExist(FilePath) {
              returnValue:= false
              break
          }

          if (TimeoutMs!=-1) and (A_TickCount >= EndTime) {
              returnValue:= true
              break
          }
          Sleep 100
      }

      return returnValue
}

WriteStatus(Message) {
  SB.Text := '    ' Message
}

ReadIni() {
  profilePath := INI.ReadSettings("PROFILE")
  if (profilePath = '') {
    profilePath := DefaultProfile
    INI.WriteSettings("PROFILE", profilePath)
  }
  return profilePath
}

WriteIni(profilePath) {
  INI.WriteSettings("PROFILE", profilePath)
}

WriteLog(Message) {
    if (Logging) {
        currentTime := FormatTime(A_Now, "HH:mm:ss")
        FileAppend(currentTime ": " Message "`n", LogFile)
    }
}

ExitHandler(*) {
    WriteLog(A_ScriptName " Exit!")
    ;SF.DeleteSharedFile()
    ExitApp()
}
