; ABOUT: PowerControlTool v1.0
; 
#Requires AutoHotkey >=2.0

#SingleInstance Force
#NoTrayIcon
TraySetIcon('shell32.dll', 28)

; #region Version Block
; Language codes (en-US=1033): https://www.autoitscript.com/autoit3/docs/appendix/OSLangCodes.htm
;@Ahk2Exe-Set CompanyName, jasc2v8
;@Ahk2Exe-Set FileDescription, Power Control Tool
;@Ahk2Exe-Set FileVersion, 1.0.0.0
;@Ahk2Exe-Set InternalName, PowerControlTool
;@Ahk2Exe-Set Language, 1033
;@Ahk2Exe-Set LegalCopyright, ©2025 jasc2v8
;@Ahk2Exe-Set LegalTrademarks, NONE™
;@Ahk2Exe-Set OriginalFilename, PowerControlTool.exe
;@Ahk2Exe-Set ProductName, PowerControlTool
;@Ahk2Exe-Set ProductVersion, 1.0.0.0
;@Ahk2Exe-SetMainIcon PowerControlTool.ico

;@Inno-Set AppId, {{09F686C0-6F29-43BC-88D4-0C51BEFEEB4B}}
;@Inno-Set AppPublisher, jasc2v8

; #region Admin Check

; in this appliation, the only need for admin is RestartUEFI
full_command_line := DllCall("GetCommandLine", "str")
if (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)")) {
  DoRestartUEFI()
  ExitApp
}

; #region Create Gui

MyGui := Gui("+AlwaysOnTop", "Power Control Tool v1.0") ; "ToolWindow" does not have tray icon
MyGui.BackColor := "4682B4" ; Steel Blue
MyGui.SetFont("S12 CBlack w480", "Segouie UI")

; #region Create Buttons

ButtonSleep := MyGui.AddButton("w150", "Sleep")
ButtonSignOut := MyGui.AddButton("yp w150", "Sign out")
ButtonShutdown := MyGui.AddButton("yp w150", "Shutdown")
ButtonRestart := MyGui.AddButton("xm y+10 w150", "Restart")
ButtonRestartUEFI := MyGui.AddButton("yp w150", "Restart to UEFI")
ButtonRestartRE := MyGui.AddButton("yp w150", "Restart to RE")
ButtonDisplayOff := MyGui.AddButton("xm y+10 w150", "Display Off")
ButtonSettings := MyGui.AddButton("yp w150", "Settings")
ButtonCancel := MyGui.AddButton("yp w150", "Cancel")

; #region Event Handlers

ButtonCancel.OnEvent("Click", ButtonCancel_Click)
ButtonDisplayOff.OnEvent("Click", ButtonDisplayOff_Click)
ButtonRestart.OnEvent("Click", ButtonRestart_Click)
ButtonRestartUEFI.OnEvent("Click", ButtonRestartUEFI_Click)
ButtonRestartRE.OnEvent("Click", ButtonRestartRE_Click)
ButtonSettings.OnEvent("Click", ButtonSettings_Click)
ButtonSignOut.OnEvent("Click", ButtonSignOut_Click)
ButtonSleep.OnEvent("Click", ButtonSleep_Click)
ButtonShutdown.OnEvent("Click", ButtonShutdown_Click)
MyGui.OnEvent("Close", (*) => ExitApp())

; Show the GUI
MyGui.Show()

; #region Functions

ButtonCancel_Click(Ctrl, Info) {
 ExitApp()
}

ButtonDisplayOff_Click(Ctrl, Info) {
  MyGui.Hide()
  timeout := CountdownAndBlock(ButtonDisplayOff.Text, 5)
  if (timeout) {
    SendMessage(0x112,0xF170,2,,"Program Manager")
    ExitApp()
  } else {
    MyGui.Show()
  }
}

ButtonRestart_Click(Ctrl, Info) {
  MyGui.Hide()
  timeout := CountdownAndBlock(ButtonRestart.Text, 5)
  if (timeout) {
    Shutdown(10) ; 0=Logoff, 6=ForceReboot, 9=StdShutdown, 10=StdReboot, 13=ForceShutdown
  } else {
    MyGui.Show()
  }
}

ButtonRestartRE_Click(Ctrl, Info) {
  MyGui.Hide()
  timeout := CountdownAndBlock(ButtonRestartRE.Text, 5)
  if (timeout) {
    Run(A_ComSpec ' /c shutdown.exe /r /o /t 0')
  } else {
    MyGui.Show()
  }
}

DoRestartUEFI() {
  Run(A_ComSpec ' /c shutdown.exe /r /t 0 /fw')
  ExitApp
}

ButtonRestartUEFI_Click(Ctrl, Info) {
  MyGui.Hide()
  timeout := CountdownAndBlock(ButtonRestartUEFI.Text, 5)
  if A_IsAdmin {
    DoRestartUEFI()
  } else {
    try {
      if A_IsCompiled
        Run '*RunAs "' A_ScriptFullPath '" /restart'
      else
        Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
    } catch {
      ;User answered NO to the UAC prompt so just resume without admin privs
      MyGui.Show()
    } 
  }
}

ButtonSettings_Click(Ctrl, Info) {
  Run "ms-settings:powersleep"
  ExitApp()
}

ButtonShutdown_Click(Ctrl, Info) {  
  MyGui.Hide()
  timeout := CountdownAndBlock(ButtonShutdown.Text, 5)
  if (timeout) {
    Shutdown(9) ; 0=Logoff, 6=ForceReboot, 9=StdShutdown, 10=StdReboot, 13=ForceShutdown
  } else {
    MyGui.Show()
  }
}

ButtonSignOut_Click(Ctrl, Info) {  
  MyGui.Hide()
  timeout := CountdownAndBlock(ButtonSignOut.Text, 5)
  if (timeout) {
    Shutdown(0) ; 0=Logoff, 6=ForceReboot, 9=StdShutdown, 10=StdReboot, 13=ForceShutdown
  } else {
    MyGui.Show()
  }
}
ButtonSleep_Click(Ctrl, Info) {
  MyGui.Hide()
  timeout := CountdownAndBlock(ButtonSleep.Text, 5)
  if (timeout) {
    ; DllCall('PowrProf\SetSuspendState', 'Int', bHibernate, 'Int', bForce, 'Int', bWakeupEventsDisabled)
    ; Parameter 1 (0): Sets bHibernate to FALSE (i.e., perform Suspend/Sleep)
    ; Parameter 2 (0): Sets bForce to FALSE (allow applications to prompt for permission to close, though this parameter is often ignored now)
    ; Parameter 3 (0): Sets bWakeupEventsDisabled to FALSE (wake-up events remain enabled)
    DllCall('PowrProf\SetSuspendState', 'Int', 1, 'Int', 0, 'Int', 0) ; Hibernate
    ExitApp()
  } else {
    MyGui.Show()
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
  TimerText := TimerGui.AddText(, Title ' in:')

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
