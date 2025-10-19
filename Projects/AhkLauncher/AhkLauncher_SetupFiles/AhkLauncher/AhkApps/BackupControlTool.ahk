; ABOUT: BackupControlTool v1.0
; 
#Requires AutoHotkey >=2.0
#SingleInstance Force
#NoTrayIcon
TraySetIcon('shell32.dll', 294) ;46

; #region Version Block
; Language codes (en-US=1033): https://www.autoitscript.com/autoit3/docs/appendix/OSLangCodes.htm
;@Ahk2Exe-Set CompanyName, jasc2v8
;@Ahk2Exe-Set FileDescription, Backup Control Tool
;@Ahk2Exe-Set FileVersion, 1.0.0.0
;@Ahk2Exe-Set InternalName, BackupControlTool
;@Ahk2Exe-Set Language, 1033
;@Ahk2Exe-Set LegalCopyright, ©2025 jasc2v8
;@Ahk2Exe-Set LegalTrademarks, NONE™
;@Ahk2Exe-Set OriginalFilename, BackupControlTool.exe
;@Ahk2Exe-Set ProductName, BackupControlTool
;@Ahk2Exe-Set ProductVersion, 1.0.0.0
;@Ahk2Exe-SetMainIcon BackupControlTool.ico

;@Inno-Set AppId, {{10D9F70C-88D1-428B-811D-5264CA644A87}}
;@Inno-Set AppPublisher, jasc2v8

; #region Admin Check

; SyncBack requires Administrator privileges
full_command_line := DllCall("GetCommandLine", "str")

if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\\ S)"))
{
    try
    {
        if A_IsCompiled
            Run '*RunAs "' A_ScriptFullPath '" /restart'
        else
            Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
    }
    ExitApp  ; Exit the current, non-elevated instance
}

; #region Globals

global SyncBackPath := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
global SyncBackProfiles := EnvGet("LOCALAPPDATA") "\2BrightSparks\SyncBack\Profiles Backup"
global logDir := EnvGet("LOCALAPPDATA") "\2BrightSparks\SyncBack\Logs"

; #region Create Gui

MyGui := Gui(, "Backup Control Tool v1.0") ; "ToolWindow" does not have tray icon
MyGui.BackColor := "4682B4" ; Steel Blue
MyGui.SetFont("S12 CBlack w480", "Segouie UI")

; #region Create Controls

TextProfile := MyGui.AddText('xm w400 BackgroundDefault','~Backup JIM-PC folders to JIM-SERVER')
ButtonProfile := MyGui.AddButton("yp w60 h20", "Profile")

MyGui.AddGroupBox("xm w472 h100", "Action after Backup:")

TextFiller      := MyGui.AddText("xm yp+40 w50 +Hidden")
ButtonNothing   := MyGui.AddButton("yp w100", "Nothing")
ButtonSleep     := MyGui.AddButton("yp w100", "Sleep")
ButtonShutdown  := MyGui.AddButton("yp w100", "Shutdown")

;MyLine := MyGui.Add("Text", "xm w440 h1 0x10") ;SS_ETCHEDHORZ)

TextFiller    := MyGui.AddText("xm yp+75 w50 +Hidden")
ButtonLogs    := MyGui.AddButton("yp w100", "Logs")
ButtonClear   := MyGui.AddButton("yp w100", "Clear")
ButtonCancel  := MyGui.AddButton("yp w100", "Cancel")

SB := MyGui.AddStatusBar()

WriteStatus('Ready.')

; #region Event Handlers

ButtonProfile.OnEvent("Click", ButtonProfile_Click)
ButtonLogs.OnEvent("Click", ButtonLogs_Click)
ButtonClear.OnEvent("Click", ButtonClear_Click)
ButtonNothing.OnEvent("Click", ButtonNothing_Click)
ButtonSleep.OnEvent("Click", ButtonSleep_Click)
ButtonShutdown.OnEvent("Click", ButtonShutdown_Click)
ButtonCancel.OnEvent("Click", ButtonCancel_Click)
MyGui.OnEvent("Close", (*) => ExitApp())

; Show the GUI
MyGui.Show()

; #region Functions

ButtonCancel_Click(Ctrl, Info) {
 ExitApp()
}

ButtonNothing_Click(Ctrl, Info) {
  timeout := CountdownAndBlock(ButtonNothing.Text, 5)
  if (timeout) {

    WriteStatus('Running: ' TextProfile.Text)

    r := RunWait(SyncBackPath ' "' TextProfile.Text '"')

    if (r = 0)
      WriteStatus('Success.')
    else
      WriteStatus('Error, Code: ' r)

  }
}

ButtonShutdown_Click(Ctrl, Info) {  
  timeout := CountdownAndBlock(ButtonShutdown.Text, 5)
  if (timeout) {

    WriteStatus('Running: ' TextProfile.Text)

    r := RunWait(SyncBackPath ' -shutdown "' TextProfile.Text '"')

    if (r = 0)
      WriteStatus('Success.')
    else
      WriteStatus('Error, Code: ' r)
  }
}

ButtonSleep_Click(Ctrl, Info) {
  timeout := CountdownAndBlock(ButtonSleep.Text, 5)
  if (timeout) {

    WriteStatus('Running: ' TextProfile.Text)

    r := RunWait(SyncBackPath ' -standby "' TextProfile.Text '"')

    if (r = 0)
      WriteStatus('Success.')
    else
      WriteStatus('Error, Code: ' r)
  }
}

ButtonLogs_Click(Ctrl, Info) {
  Run('explorer.exe ' '"' logDir '"')
}

ButtonClear_Click(Ctrl, Info) {
  WriteStatus('Ready.')
}

ButtonProfile_Click(Ctrl, Info) {
  selectedProfile := FileSelect(0, SyncBackProfiles)
  if (selectedProfile) {
    SplitPath(selectedProfile, , , , &OutNameNoExt)
    TextProfile.Text := OutNameNoExt
  }
}

CountdownAndBlock(Title, Seconds)
{
  ; Define initial variables
  global TimerGui := ''
  global TimerRunning := true
  global RemainingTime := Seconds
  returnValue := true ; true=timedout, false=canceled

  ; Create the new GUI object
  TimerGui := Gui("+AlwaysOnTop -SysMenu")
  TimerGui.Title := ''

  ; Add a text control for the title
  TimerGui.SetFont("s18 bold", "Consolas")
  TimerText := TimerGui.AddText(, 'Backup then`n' Title ' in:')

  ; Add a text control to display the countdown
  TimerGui.SetFont("s48 bold cRed", "Consolas")
  TimerText := TimerGui.AddText("w200 Center vCountdownText", RemainingTime)

  ; add buttons
  TimerGui.SetFont("s12 Norm", "Consolas")
  TimerGui.AddButton("xm w100","OK").OnEvent("Click", ButtonOK_Click)
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
