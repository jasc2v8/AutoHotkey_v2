; TITLE   : BackupControlTool  v7.0
; SOURCE  : Gemini and jasc2v8
; LICENSE : The Unlicense, see https://unlicense.org
; PURPOSE : Run SyncBack.exe as Admin with no UAC prompt.
; OVERVIEW: RunTask AHK_RunSkipUAC which runs RunSkupUAC which runs BackupControlWorker at runLevel='highest'
;           Uses Messenger IPC to communicate with other scripts.
; SCRIPTS: BackupControlTool.ahk => RunTask.ahk => RunSkipUAC.ahk => BackupControlWorker.ahk
;
/*
  PSUEDOCODE:
  -----------
  BackupControlTool status "Running..."
  BackupControlTool creates RunTask(TaskName, ProgramPath, WorkerPath)
    RunTask starts TaskName AHK_RunSkipUAC
      Task AHK_RunSkipUAC run RunSkipUAC at runLevel='highest'
      Task AHK_RunSkipUAC Exit
        RunSkipUAC listen for WorkerPath from RunTask
        RunSkipUAC run WorkerPath at runLevel='highest'
        RunSkipUAC Exit
    RunTask wait for ProgramPath RunSkipUAC to start
    RunTask send WorkerPath to RunSkipUAC
    RunTask Exit
    
  BackupControlTool wait for Worker to start
  BackupControlTool send BackupRequest to Worker
    Worker listen for BackupRequest  ([Backup.exe, BackupProfile, BackupPostAction])
    Worker run BackupRequest ('Backup.exe BackupProfile')
    Worker handles 'BackupPostAction'
    Worker Exit
  BackupControlTool listen for Worker ACK
  BackupControlTool status "Finished."
*/
/*
  TODO:
    Keep Gui active so it can detect Cancel?
    Or just disable gui like before?

*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
;#NoTrayIcon
TraySetIcon('shell32.dll', 294) ; Backup/Restore Icon

#Include <CRC>
#Include <IniFile>
#Include <LogFile>
#Include <Messenger>
#Include <RunAny>
#Include <RunTask>

; #region Version Block

; Language codes (en-US=1033): https://www.autoitscript.com/autoit3/docs/appendix/OSLangCodes.htm
;@Ahk2Exe-Set CompanyName, jasc2v8
;@Ahk2Exe-Set FileDescription, Backup Control Tool
;@Ahk2Exe-Set FileVersion, 7.0.0.0
;@Ahk2Exe-Set InternalName, BackupControlTool
;@Ahk2Exe-Set Language, 1033
;@Ahk2Exe-Set LegalCopyright, ©2025 jasc2v8
;@Ahk2Exe-Set LegalTrademarks, NONE™
;@Ahk2Exe-Set OriginalFilename, BackupControlTool.exe
;@Ahk2Exe-Set ProductName, BackupControlTool
;@Ahk2Exe-Set ProductVersion, 7.0.0.0
;@Ahk2Exe-SetMainIcon BackupControlTool.ico

;@Inno-Set AppId, {{10D9F70C-88D1-428B-811D-5264CA644A87}}
;@Inno-Set AppPublisher, jasc2v8

; #region Globals

;global LogPath          := EnvGet("PROGRAMDATA") "\AutoHotkey\BackupControlTool\Control.log"
global LogPath          := "D:\Control.log"
global logger           := LogFile(LogPath, "CONTROL")
logger.Disable()

global WorkerPath   := EnvGet("PROGRAMDATA") "\AutoHotkey\BackupControlTool\BackupControlWorker.ahk"
global WorkerParams := ",TEST WITH SPACES"

global SyncBackProfiles := EnvGet("LOCALAPPDATA") "\2BrightSparks\SyncBack\Profiles Backup"
global SyncBackLogDir   := EnvGet("LOCALAPPDATA") "\2BrightSparks\SyncBack\Logs"
global DefaultProfile   := "~Backup JIM-PC folders to JIM-SERVER"

SyncBackPath     := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
;SyncBackProfile  := "~Backup JIM-PC folders to JIM-SERVER"
SyncBackProfile  := "TEST WITH SPACES"

global SoundSuccess     := "C:\Windows\Media\Windows Notify Calendar.wav"
global SoundError       := "C:\Windows\Media\Windows Critical Stop.wav"

global INI_PATH         := EnvGet("PROGRAMDATA") "\AutoHotkey\BackupControlTool\BackupControlTool.ini"
global INI              := IniFile(INI_PATH)

global SyncBackSelectedProfile := INI.ReadSettings("PROFILE")

global IsRunning        := false

OnExit(ExitHandler)

; #region Create Gui

MyGui := Gui("-AlwaysOnTop", "Backup Control Tool v7.0")
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

    myGui.Opt("+Disabled")
    WinSetTransparent(200, MyGui.Hwnd)

    logger.Write("Create RunTask")

    ; BackupControlTool creates RunTask(TaskName, ProgramPath, WorkerPath)
    task:= RunTask("AHK_RunSkipUAC", "C:\ProgramData\AutoHotkey\RunSkipUAC\RunSkipUAC.ahk", WorkerPath)
    logger.Write("Wait for Worker to start")
    
    Persistent ; Required to listen

    ; BackupControlTool listen for Worker ACK
    logger.Write("Listen for Worker ACK")
    ipc:= Messenger(CRC.Get64("BackupControlTool"))
    ipc.Listen(OnMessageReceived)

    ; BackupControlTool wait for Worker to start
    DetectHiddenWindows True
    timeout:= WinWait("BackupControlWorker")
    ;pid:=ProcessWait("BackupControlWorker.exe")

    ; BackupControlTool send BackupRequest to Worker
    WorkerTitle:= "BackupControlWorker"
    logger.Write("Send BackupRequest to Worker")
    ; SyncBack.exe ignores the invalid PostAction parameters used here
    BackupRequest:= SyncBackPath "," SyncBackPostAction "," SyncBackSelectedProfile
    ipc.Send(WorkerTitle, BackupRequest)

    OnMessageReceived(message, SenderHWND) {
      logger.Write("ACK Received: " message)
      Persistent false
    }

    logger.Write("Finished.")
    WriteStatus("Finished.")
    IsRunning := false

    ; restore if user minimized
    WinActivate(MyGui.Hwnd)

    myGui.Opt("-Disabled")
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
