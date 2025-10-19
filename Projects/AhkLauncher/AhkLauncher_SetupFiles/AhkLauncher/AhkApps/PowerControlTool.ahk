; ABOUT: DownloadControlTool, changed icon for standalone version
; 
#Requires AutoHotkey >=2.0

#SingleInstance Force
#NoTrayIcon
TraySetIcon('shell32.dll', 28)

; #region Version Block
; Language codes (en-US=1033): https://www.autoitscript.com/autoit3/docs/appendix/OSLangCodes.htm
;@Ahk2Exe-Set CompanyName, jasc2v8
;@Ahk2Exe-Set FileDescription, Download Control Tool
;@Ahk2Exe-Set FileVersion, 1.0.1.2
;@Ahk2Exe-Set InternalName, DownloadControlTool
;@Ahk2Exe-Set Language, 1033
;@Ahk2Exe-Set LegalCopyright, ©2025 jasc2v8
;@Ahk2Exe-Set LegalTrademarks, NONE™
;@Ahk2Exe-Set OriginalFilename, DownloadControlTool.exe
;@Ahk2Exe-Set ProductName, DownloadControlTool
;@Ahk2Exe-Set ProductVersion, 1.0.1.1
;@Ahk2Exe-SetMainIcon DownloadControlTool.ico

;@Inno-Set AppId, {{09F686C0-6F29-43BC-88D4-0C51BEFEEB4B}}
;@Inno-Set AppPublisher, jasc2v8

; #region Admin Check

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
ButtonSignOut := MyGui.AddButton("yp w150", "Sign-Out")
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
    ; MyGui.Show()
    ; msgbox "display off"
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


RunGetOutput(command) {
 ; cmd window briefly shown
 shell := ComObject("WScript.Shell")
 exec := shell.Exec(A_ComSpec . " /C " . command)
 output := exec.StdOut.ReadAll()
 return output
}

RunSaveOutput(command) {
 ; no cmd window shown, tempFile must not have spaces (fix TBD)
 tempFile := A_Temp . "\MyOutput.txt"
 RunWait(A_ComSpec . " /C " . command . " > " . tempFile, , 'Hide')
 output := FileRead(tempFile)
 FileDelete(tempFile)
 FileDelete(A_Temp . "\xml_file*.xml") ; cleanup from RunWait function
 return output
}

CountdownAndBlock(Title, Seconds)
{
  ; Define initial variables
  ;global TimerGui := ''
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

  ; 3. Display the GUI and center it.
  TimerGui.Show("Center")

  ; 4. Set up the Timer function (runs every 1000ms / 1 second)
  ; We bind the TimerGui and TimerText controls to the UpdateTimer function
  SetTimer UpdateTimer, 1000

  ; 5. THE WAIT LOOP: This is how you "wait until finished" in AHK v2.
  ; It continually checks the TimerRunning flag in a tight loop.
  ; While the GUI is open and the timer is running, the main script thread pauses here.
  While (TimerRunning)
  {
      Sleep(100) ; Wait 100ms before checking the flag again
  }

  ; 6. Cleanup after the loop finishes
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
  ; This function is called every second by SetTimer
  UpdateTimer(*)
  {
    ;global TimerGui
    global TimerRunning
    global RemainingTime
      
    ; Check if time has run out
    if (RemainingTime <= 1)
    {
        ; Stop the timer from calling this function again
        SetTimer UpdateTimer, 0
        
        ; Update the global flag to break the 'While' loop in the main function
        TimerRunning := false
        
        return
    }
    
    ; 3. Decrement the time and update the GUI control (using its control variable)
    RemainingTime--
    
    ; GuiControl(GuiID, ControlID, NewText) - Here we use the Control object directly
    TimerGui["CountdownText"].Text := RemainingTime
  }
}
