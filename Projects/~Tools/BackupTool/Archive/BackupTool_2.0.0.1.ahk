; TITLE   : BackupTool v2.0.0.1
; SOURCE  : Gemini and jasc2v8
; LICENSE : The Unlicense, see https://unlicense.org
; PURPOSE : Run SyncBack.exe as Admin with no UAC prompt.
; OVERVIEW: BackupTool run Task AdminLauncher, which runs AdminLauncher.ahk, which runs BackupWorker at runLevel='highest'
;           Uses NamedPipe IPC to communicate with other scripts.
; SCRIPTS : BackupTool.ahk => run Task AdminLauncher => AdminLauncher.ahk => BackupControlWorker.ahk
global Version := "2.0.0.11"
/*
  TODO:

  Can we dual start BackupTool?
	  1st  is the GuiLayout code							  BackupTool.ahk
  	2nd is the worker and post-action code		BackupTool.ahk /worker	

*/
#Requires AutoHotkey 2+
#SingleInstance Off ; must allow multiple instances
#NoTrayIcon
TraySetIcon('shell32.dll', 294) ; Backup/Restore Icon

#Include <AdminLauncher>
#Include <IniFile>
#Include <LogFile>
#Include <NamedPipe>
#Include <RunCMD>

; #region Version Block

; Language codes (en-US=1033): https://www.autoitscript.com/autoit3/docs/appendix/OSLangCodes.htm
;@Ahk2Exe-Set CompanyName, jasc2v8
;@Ahk2Exe-Set FileDescription, Backup Tool
;@Ahk2Exe-Set FileVersion, 2.0.0.11
;@Ahk2Exe-Set InternalName, BackupTool
;@Ahk2Exe-Set Language, 1033
;@Ahk2Exe-Set LegalCopyright, ©2025 jasc2v8
;@Ahk2Exe-Set LegalTrademarks, NONE™
;@Ahk2Exe-Set OriginalFilename, BackupTool.exe
;@Ahk2Exe-Set ProductName, BackupTool
;@Ahk2Exe-Set ProductVersion, 2.0.0.11
;@Ahk2Exe-SetMainIcon D:\Software\DEV\Work\AHK2\Projects\~Tools\BackupTool\Icons\backup.ico

;@Inno-Set AppId, {{C65404BE-5F4B-4A2D-962E-389622530D4D}}
;@Inno-Set AppPublisher, jasc2v8

; #region Duplicate Check

; DetectHiddenWindows true
; SetTitleMatchMode 1

; if WinExist("Backup Control Tool") {
;   MsgBox "Activating..."
;   WinActivate("A")

; }

; #region Globals

global LogPath          := "D:\BackupTool.log"
global logger           := LogFile(LogPath, "CONTROL", true)  ; true=Enable, false=Disable

;global WorkerPath       := "C:\ProgramData\AutoHotkey\BackupTool\BackupWorker.ahk"
global WorkerPath       := "C:\Users\Jim\Documents\AutoHotkey\AhkLauncher\AhkApps\BackupTool.ahk /worker"

global SyncBackPath     := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
global SyncBackProfiles := EnvGet("LOCALAPPDATA") "\2BrightSparks\SyncBack\Profiles Backup"
global SyncBackLogDir   := EnvGet("LOCALAPPDATA") "\2BrightSparks\SyncBack\Logs"
global DefaultProfile   := "~Backup JIM-PC folders to JIM-SERVER"

global SoundSuccess     := "C:\Windows\Media\Windows Notify Calendar.wav"
global SoundError       := "C:\Windows\Media\Windows Critical Stop.wav"

global INI_PATH         := "C:\ProgramData\AutoHotkey\BackupTool\BackupTool.ini"
global INI              := IniFile(INI_PATH)

global SyncBackSelectedProfile := INI.ReadSettings("PROFILE")

global IsRunning        := false

; #region check Args

if (A_Args.Length > 0) {

  if (A_Args[1] = "/worker")
    RunAsWorker()

  ExitApp()

}

; #region Create Gui

MyGui := Gui("-AlwaysOnTop", "Backup Tool v" Version)
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

  ; #region START

  if (timedOut) {

    WriteStatus("Running...")

    IsRunning := true

    WinSetTransparent(200, MyGui.Hwnd)

    ;
    ; Start the Task AdminLauncher which runs AdminLauncher.ahk
    ;

    logger.Write("Run Task")

    launcher:= AdminLauncher()

    launcher.StartTask()

    logger.Write("Run Worker")

    ;
    ; Start the Worker at runLevel='highest'
    ;

    launcher.StartWorker(WorkerPath)

    ;
    ; Send BackupRequest to Worker
    ;

    BackupRequest:= RunCMD.ToCSV(SyncBackPath, SyncBackPostAction, SyncBackSelectedProfile)

    launcher.Send(BackupRequest)

    logger.Write("Sent Request: " BackupRequest)

    ;
    ; Receive the reply from the Worker after it runs the PostAction
    ;

    reply:= launcher.Receive()

    logger.Write("Reply Received: " reply)

    ;
    ; Report Finished.
    ;

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

RunAsWorker() {

  ;global LogPath := EnvGet("PROGRAMDATA") "\AutoHotkey\BackupTool\BackupWorker.log"
  LogPath := "D:\BackupWorker.log"
  loggerWorker := LogFile(LogPath, "WORKER", true) ; true=Enable, false=Disable

  loggerWorker.Write("START BackupWorker")

  launcher:= AdminLauncher()

  request:= launcher.Receive()

  loggerWorker.Write("Run Request: " request)

  reply := RunCMD(request)

  reply:= Trim(reply, " `t`r`n")

  loggerWorker.Write("Run Reply: " reply)

  loggerWorker.Write("PostAction START")

  PostActionHandler(request)

  loggerWorker.Write("PostAction END")

  r := launcher.Send("ACK: " request)

  loggerWorker.Write("Reply Sent: ACK:" request ", r: " r)

  loggerWorker.Write("ExitApp")

}

PostActionHandler(BackupParameters) {

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

    loggerWorker.Write("DEBUG BackupParameters: [" BackupParameters "]")

    ; Get Post Action from Parameters (SyncBackPath, SyncBackParams, SyncBackProfile)
    split := StrSplit(BackupParameters, ",")
    if (split.Length < 3) {
        loggerWorker.Write("ERROR Expected 3 parameters, got: " split.Length)
        return
    }

    postAction:= split[2]

    loggerWorker.Write("DEBUG PostAction: [" postAction "]")

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

    loggerWorker.Write("FINISH: [" postAction "]") ; may not have time to write this.

}
