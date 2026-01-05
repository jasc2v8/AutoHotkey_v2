; TITLE   : BackupControlTool  v6.0 (chatGPT)
; SOURCE  : jasc2v8 and chatGPT
; LICENSE : The Unlicense, see https://unlicense.org
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

#Include <IniFile>
#Include <LogFile>
#Include <RunCMD>
#Include <NamedPipe>
#Include RunSkipUAC.ahk

; #region Version Block

; Language codes (en-US=1033): https://www.autoitscript.com/autoit3/docs/appendix/OSLangCodes.htm
;@Ahk2Exe-Set CompanyName, jasc2v8
;@Ahk2Exe-Set FileDescription, Backup Control Tool
;@Ahk2Exe-Set FileVersion, 5.0.0.0
;@Ahk2Exe-Set InternalName, BackupControlTool
;@Ahk2Exe-Set Language, 1033
;@Ahk2Exe-Set LegalCopyright, ©2025 jasc2v8
;@Ahk2Exe-Set LegalTrademarks, NONE™
;@Ahk2Exe-Set OriginalFilename, BackupControlTool.exe
;@Ahk2Exe-Set ProductName, BackupControlTool
;@Ahk2Exe-Set ProductVersion, 5.0.0.0
;@Ahk2Exe-SetMainIcon BackupControlTool.ico

;@Inno-Set AppId, {{10D9F70C-88D1-428B-811D-5264CA644A87}}
;@Inno-Set AppPublisher, jasc2v8

; #region Globals

global LogPath          := EnvGet("PROGRAMDATA") "\AutoHotkey\BackupControlTool\Control.log"
global logger           := LogFile(LogPath, "CONTROL")
logger.Disable()

;global WorkerPath        := EnvGet("PROGRAMDATA") "\AutoHotkey\BackupControlTool\BackupControlWorker.ahk"
global WorkerPath        := "D:\Software\DEV\Work\AHK2\Projects\~Tools\BackupControlTool\Archive\v6_NamedPipe\BackupControlWorker.ahk"

global SyncBackPath     := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
global SyncBackProfiles := EnvGet("LOCALAPPDATA") "\2BrightSparks\SyncBack\Profiles Backup"
global SyncBackLogDir   := EnvGet("LOCALAPPDATA") "\2BrightSparks\SyncBack\Logs"
global DefaultProfile   := "~Backup JIM-PC folders to JIM-SERVER"

global SoundSuccess     := "C:\Windows\Media\Windows Notify Calendar.wav"
global SoundError       := "C:\Windows\Media\Windows Critical Stop.wav"

global INI_PATH         := EnvGet("PROGRAMDATA") "\AutoHotkey\BackupControlTool\BackupControlTool.ini"
global INI              := IniFile(INI_PATH)

global SyncBackSelectedProfile := INI.ReadSettings("PROFILE")

global IsRunning        := false

OnExit(ExitHandler)

; #region Create Gui

MyGui := Gui("-AlwaysOnTop", "Backup Control Tool v6.0")
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

    WinSetTransparent(200, MyGui.Hwnd)

    logger.Write("Run Worker: " WorkerPath)

    RunSkipUAC(WorkerPath)

    try
    {

      logger.Write("Create pipe Instance.")
      pipe := NamedPipe("WORKER")

      logger.Write("Wait for server to create pipe...")
      r := pipe.Wait(5000)
      if (!r) {
        logger.Write("Timeout Waiting for pipe.")
        ExitApp()
      }

      logger.Write("Pipe Ready.")

      ; Form the command to run
      request:= RunCMD.ConvertToCSV(SyncBackPath, SyncBackPostAction, SyncBackSelectedProfile)

      logger.Write("Send Request: " request)

      ; Send request to server
      pipe.Send(request)

      ; Receive reply from server
      reply := pipe.Receive()

      logger.Write("Reply Received: " reply)

    }
    catch any as e
    {
      logger.Write("ERROR: " e.Message)
    }
    finally
    {
      logger.Write("Pipe close.")
      pipe.Close()
      pipe:=""
    }

    logger.Write("Finished.")

    WriteStatus("Finished.")

    IsRunning := false

    ; restore if user minimized
    WinActivate(MyGui.Hwnd)

    WinSetTransparent("Off", MyGui.Hwnd)

  }
}

ButtonLogs_Click(Ctrl, Info) {
  Run('explorer.exe ' '"' SyncBackLogDir '"')
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

ExitHandler(*) {
    logger.Write(A_ScriptName " Exit!")
    ExitApp()
}
