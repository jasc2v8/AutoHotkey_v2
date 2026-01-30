; TITLE   : BackupTool v3.3.0.13
; SOURCE  : Gemini and jasc2v8
; LICENSE : The Unlicense, see https://unlicense.org
; PURPOSE : Run SyncBack.exe as Admin with no UAC prompt.
; OVERVIEW: BackupTool run Task RunAdmin, which runs RunAdmin.ahk, which runs BackupWorker at runLevel='highest'
;           Uses NamedPipe IPC to communicate with other scripts.
; SCRIPTS : BackupTool.ahk => run Task RunAdmin => RunAdmin.ahk => BackupControlWorker.ahk

/*
  TODO:
    fix exe, profile, postaction
*/
#Requires AutoHotkey 2+
#SingleInstance Off ; must allow multiple instances
TraySetIcon('shell32.dll', 294) ; Backup/Restore Icon

#Include <RunAdmin>
#Include <IniFile>
#Include <LogFile>
#Include <NamedPipe>
#Include <RunCMD>
#Include <ProcessMonitor>
#Include <SystemCursor>

; #region Version Block

; Language codes (en-US=1033): https://www.autoitscript.com/autoit3/docs/appendix/OSLangCodes.htm
;@Ahk2Exe-Set CompanyName, jasc2v8
;@Ahk2Exe-Set FileDescription, Backup Tool
;@Ahk2Exe-Set FileVersion, 3.3.0.13
;@Ahk2Exe-Set InternalName, BackupTool
;@Ahk2Exe-Set Language, 1033
;@Ahk2Exe-Set LegalCopyright, ©2025 jasc2v8
;@Ahk2Exe-Set LegalTrademarks, NONE™
;@Ahk2Exe-Set OriginalFilename, BackupTool.exe
;@Ahk2Exe-Set ProductName, BackupTool
;@Ahk2Exe-Set ProductVersion, 3.3.0.13
;@Ahk2Exe-SetMainIcon D:\Software\DEV\Work\AHK2\Projects\~Tools\BackupTool\Icons\backup.ico

;@Inno-Set AppId, {{C65404BE-5F4B-4A2D-962E-389622530D4D}}
;@Inno-Set AppPublisher, jasc2v8

; #region Globals

global LogPath          := "D:\BackupTool.log"
global logger           := LogFile(LogPath, "CONTROL", false)  ; true=Enable, false=Disable

;global WorkerPath       := "C:\ProgramData\AutoHotkey\BackupTool\BackupWorker.ahk"
;global WorkerPath       := '"' A_AhkPath '"' A_Space "D:\Software\DEV\Work\AHK2\Projects\~Tools\BackupTool\BackupTool.ahk  /worker"
;global WorkerPath       := '"' A_AhkPath '"' A_Space "C:\Users\Jim\Documents\AutoHotkey\Ahkrunner\AhkApps\BackupTool.ahk"
global WorkerPath       := "D:\Software\DEV\Work\AHK2\Projects\~Tools\BackupTool\BackupTool.ahk /worker"

global SyncBackPath     := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
global SyncBackProfiles := EnvGet("LOCALAPPDATA") "\2BrightSparks\SyncBack\Profiles Backup"
global SyncBackLogDir   := EnvGet("LOCALAPPDATA") "\2BrightSparks\SyncBack\Logs"
global SyncBackPostAction := "Nothing"
global DefaultProfile   := "~Backup JIM-PC folders to JIM-SERVER"
global SyncBackProcessName  := "SyncBackSE.exe"

global SoundSuccess     := "C:\Windows\Media\Windows Notify Calendar.wav"
global SoundError       := "C:\Windows\Media\Windows Critical Stop.wav"

global INI_PATH         := "C:\ProgramData\AutoHotkey\BackupTool\BackupTool.ini"
global INI              := IniFile(INI_PATH)

global SyncBackSelectedProfile := INI.ReadSettings("PROFILE")

global IsRunning        := false
global CancelPressed    := false
global StartTime := 0
global BackupJob:=""
global BackupRequest :=""

global pm := 0

; #region Create Gui

MyGui := Gui("-AlwaysOnTop", "Backup Tool v3.1.0.1")
;MyGui.BackColor := "4682B4" ; Steel Blue
;MyGui.BackColor := StrReplace("6B9BC2", "#") ; Steel Blue Light
;MyGui.BackColor := StrReplace("517FBF", "#") ; Steel Blue 5% lighter (ChatGPT)
;MyGui.BackColor := StrReplace("5888B9", "#") ; Steel Blue 10% lighter (ChatGPT)
MyGui.BackColor := StrReplace("628FBE", "#") ; Steel Blue 15% lighter (ChatGPT)
;MyGui.BackColor := StrReplace("6B9BC3", "#") ; Steel Blue 20% lighter (ChatGPT)
;MyGui.BackColor := StrReplace("74A1C7", "#") ; Steel Blue 25% lighter (ChatGPT)

; #region Create Controls

MyGui.SetFont("S10", "Segouie UI")
TextProfile := MyGui.AddEdit('xm w410 h20 Center Backgroundeffeaa7', SyncBackSelectedProfile) ; #ffeaa7 Sour Lemon (flatuicolors)
ButtonSelectProfile := MyGui.AddButton("yp w60 h20", "Profile")

MyGui.AddGroupBox("xm w480 h100", "Action after Backup:")

;MyGui.SetFont("S11 CBlack w400", "Segouie UI")
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

global sc := SystemCursor(MyGui, "AppStarting")

pm := ProcessMonitor("SyncBackSE.exe")

;
; #region Classes
;

class SyncBackParams {
  static Path       := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
  static Profile    := "TEST"
  static PostAction := "Nothing"
}

;
; #region Functions
;

ButtonCancel_Click(Ctrl, Info) {

  if !ProcessExist(SyncBackProcessName) {
    ExitApp()

  } else {

    buttonPress:= Msgbox("Stop Backup Job?", "Cancel Pressed", "YesNo Icon?")

    if (buttonPress = "Yes")
    {
      if ProcessExist(SyncBackProcessName)
      {
        ProcessClose(SyncBackProcessName)
        pm.Stop()
      } 
    }
  }
}

;
; #region START
;

ButtonCommon_Click(Ctrl, Info){

  WriteStatus("Ready.")

  timedOut := CountdownAndBlock(Ctrl.Text, 5)

  if (timedOut) {

    SyncBackParams.PostAction := Ctrl.Text

    StartBackup() ; Waits for Process to exist

    pm.Start(OnFinishedNotify, OnStatusNotify, OnStopNotify)

    ToggleButtons()

    sc.Start()
  }

}

OnFinishedNotify(Reason) {
    WriteStatus(Reason . " at: " pm.Now ", Elapsed: " pm.Elapsed)

    sc.Stop()

    SoundPlay "C:\Windows\Media\Windows Hardware Insert.wav"

    ; Restore if user minimized
    WinActivate(MyGui.Hwnd)

    ToggleButtons()

    if (Reason = "Finished")
      PostActionHandler()

}

OnStatusNotify(Status) {
    WriteStatus("Backup then " SyncBackParams.PostAction . " " . Status . " at: " pm.Now ", Elapsed: " pm.Elapsed)
}

OnStopNotify(Reason) {
    WriteStatus(Reason . " at: " pm.Now ", Elapsed: " pm.Elapsed)

    SoundPlay "C:\Windows\Media\Windows Hardware Fail.wav"
    
    ; Restore if user minimized
    WinActivate(MyGui.Hwnd)

    ToggleButtons()

    sc.Stop()

}

StartBackup() {

  WriteStatus("Backup then " SyncBackParams.PostAction " Started at: " FormatTime(A_Now, "HH:mm:ss"))

  ;
  ; Start the Task RunAdmin which runs RunAdmin.ahk, which launches this script as /worker
  ;

  logger.Write("Run Task")

  runner:= RunAdmin()

  runner.StartTask()

  ;
  ; Send BackupRequest to RunAdmin
  ;

  BackupRequest:= RunCMD.ToCSV(SyncBackPath, SyncBackPostAction, SyncBackSelectedProfile)

  runner.Run(BackupRequest)

  timeout := ProcessWait(SyncBackProcessName) 

  if (timeout=0) {
    MsgBox "Timeout Waiting for Process: " SyncBackProcessName
    return
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
    SyncBackParams.Profile:= OutNameNoExt

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

ToggleButtons() {

    static IsActive := true
    
    IsActive := !IsActive
    
    if (IsActive) {
      for GuiCtrlObj in MyGui
          if (GuiCtrlObj.Type = "Button") and (GuiCtrlObj.Text != "Cancel")
              GuiCtrlObj.Enabled := true
    } else {
      for GuiCtrlObj in MyGui
          if (GuiCtrlObj.Type = "Button") and (GuiCtrlObj.Text != "Cancel")
              GuiCtrlObj.Enabled := false
    }

    ControlFocus("Cancel", MyGui)
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

PostActionHandler() {

    ; BackupParameters = (SyncBackPath, SyncBackParams, SyncBackProfile)

    ; parse params
    ; -hybernate      DllCall('PowrProf\SetSuspendState','Int',1,'Int',0,'Int',0,'Int',0) ; Hibernate Mode (S4) (USB off, mouse)
    ; -logoff         Shutdown(0)     ; 0=Logoff, 1=Shutdown, 2=Reboot, 4=Force, 8=Power down
    ; -logoffforce    Shutdown(0+3)   ; 0=Logoff, 1=Shutdown, 2=Reboot, 4=Force, 8=Power down
    ; -monoff         SendMessage 0x0112, 0xF170, 2,, "Program Manager"  ; 0x0112 is WM_SYScommandLine, 0xF170 is SC_MONITORPOWER.
    ; -shutdown       Shutdown(1+8)   ; 0=Logoff, 1=Shutdown, 2=Reboot, 4=Force, 8=Power down
    ; -shutdownforce  Shutdown(1+3)   ; 0=Logoff, 1=Shutdown, 2=Reboot, 4=Force, 8=Power down
    ; -sleep          DllCall('PowrProf\SetSuspendState','Int',0,'Int',0,'Int',0,'Int',0) ; Sleep Mode (S3) USB poweron, mouse will wakeup
    ; -standby        alias for -sleep

    ; if (BackupParameters = "")
    ;   ExitApp()

    ;logger.Write("DEBUG BackupParameters: [" BackupParameters "]")

    ; Get Post Action from Parameters (SyncBackPath, SyncBackParams, SyncBackProfile)
    ; split := StrSplit(BackupParameters, ",")
    ; if (split.Length < 3) {
    ;     logger.Write("ERROR Expected 3 parameters, got: " split.Length)
    ;     return
    ; }

    ;postAction:= split[2]

    postAction :=  SyncBackParams.PostAction

    ;MsgBox postAction, "POST ACTION"

    ;logger.Write("DEBUG PostAction: [" postAction "]")

    switch postAction, CaseSense:="Off" {
        case "MonOff":
            action:= "-monoff"
        case "LogOff":
            action:= "-logoffforce"
        case "Sleep":
            action:= "-sleep"
        case "Hibernate":
            action:= "-hybernate"
        case "Shutdown":
            action:= "-shutdown"
        default:
            action:= "Nothing"
    }

    switch action {
        case "-monoff":
            SendMessage 0x0112, 0xF170, 2,, "Program Manager"  ; 0x0112 is WM_SYScommandLine, 0xF170 is SC_MONITORPOWER.
        case "-logoff", "-signoff":
            Shutdown(0)  ; PowerControlTool
        case "-sleep", "-standby":
            DllCall('PowrProf\SetSuspendState', 'Int', 0, 'Int', 0, 'Int', 0, 'Int') ; Sleep with USB power off
        case "-hybernate":
            DllCall('PowrProf\SetSuspendState', 'Int', 1, 'Int', 0, 'Int', 0, 'Int') ; SAME AS SLEEP! PowerControlTool
        case "-shutdown":
            Shutdown(1+8)  ; PowerControlTool
        case "-shutdownforce":
            Shutdown(1+4+8) 
        case "-logoffforce", "-signoffforce":
            Shutdown(0+4)
        default:
            doNothing:=true
    }

    logger.Write("FINISH: [" postAction "]") ; may not have time to write this.

}
