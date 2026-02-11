; TITLE  :  PowerTool v1.0.0.3
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Push Button Gui for Sleep, Signout, Shutdown, Restart, and Display Off.  
; USAGE  :  The DDL choice is saved as the default for next run.
; NOTES  :

/*
    TODO:
*/

#Requires AutoHotkey 2.0+

#SingleInstance Force
TraySetIcon('shell32.dll', 28) ; power button

; #region Version Block
; Language codes (en-US=1033): https://www.autoitscript.com/autoit3/docs/appendix/OSLangCodes.htm
;@Ahk2Exe-Set CompanyName, jasc2v8
;@Ahk2Exe-Set FileDescription, Power Tool Mini
;@Ahk2Exe-Set FileVersion, 1.0.0.3
;@Ahk2Exe-Set InternalName, PowerToolMini
;@Ahk2Exe-Set Language, 1033
;@Ahk2Exe-Set LegalCopyright, ©2025 jasc2v8
;@Ahk2Exe-Set LegalTrademarks, NONE™
;@Ahk2Exe-Set OriginalFilename, PowerToolMini.exe
;@Ahk2Exe-Set ProductName, PowerToolMini
;@Ahk2Exe-Set ProductVersion, 1.0.0.3
;@Ahk2Exe-SetMainIcon PowerToolMini.ico

;@Inno-Set AppId, {{F97722EF-93DE-46A2-A95C-2A69609DF4D7}}
;@Inno-Set AppPublisher, jasc2v8

; #region Admin Check

; in this appliation, the only need for admin is RestartUEFI
full_command_line := DllCall("GetCommandLine", "str")
if (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)")) {
  DoRestartUEFI()
  ExitApp
}

#Include <Colors>
#Include <RegSettings>

; #region Globals

global reg := RegSettings()

; #region Create Gui

MyGui := Gui("+AlwaysOnTop", "Power Tool Mini v1.0.0.3") ; "ToolWindow" does not have tray icon
MyGui.BackColor := Colors.AirSuperiorityBlue
MyGui.SetFont("S12", "Segouie UI")

; #region Create Buttons

listArray:= ["Display Off", "Restart", "Restart UEFI", "Restart RE", "Settings", "Shutdown", "Sign Out", "Sleep", "Shutdown"]

DDL := MyGui.AddDropDownList(, listArray)

choose := reg.Read("DDL_CHOOSE")

if (choose != '')
  DDL.Choose(choose)

ButtonOK      := MyGui.AddButton("yp w57 h27 Default","OK")
ButtonCancel  := MyGui.AddButton("yp w57 h27", "Cancel")

; #region Event Handlers

ButtonOK.OnEvent("Click", ButtonOK_Click)
ButtonCancel.OnEvent("Click", ButtonCancel_Click)
MyGui.OnEvent("Close", (*) => ExitApp())

; Show the GUI
MyGui.Show()

; #region Functions

ButtonOK_Click(Ctrl, Info) {

  ;MsgBox "[" DDL.Text "]"

  timeout:= CountdownGui(DDL.Text, 5)
  
  DDL.Choose(DDL.Text)

  reg.Write("DDL_CHOOSE", DDL.Text)

  if (!timeout)
    return

  ; ,  "Display Off", "Restart", "Restart UEFI", "Restart RE","Settings", "Shutdown", "Sign Out", "Sleep"]

  switch DDL.Text {
    case "Display Off":
      SendMessage(0x112,0xF170,2,,"Program Manager")
    case "Restart":
      Shutdown(10) ; 0=Logoff, 6=ForceReboot, 9=StdShutdown, 10=StdReboot, 13=ForceShutdown
    case "Restart UEFI":
      MyGui.Hide()
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
    case "Restart RE":
      Run(A_ComSpec ' /c shutdown.exe /r /o /t 0')
    case "Settings":
      Run "ms-settings:powersleep"
    case "Shutdown":
      Shutdown(9) ; 0=Logoff, 6=ForceReboot, 9=StdShutdown, 10=StdReboot, 13=ForceShutdown
    case "Sign Out":
      Shutdown(0) ; 0=Logoff, 6=ForceReboot, 9=StdShutdown, 10=StdReboot, 13=ForceShutdown
    case "Sleep":
      ; DllCall('PowrProf\SetSuspendState', 'Int', bHibernate, 'Int', bForce, 'Int', bWakeupEventsDisabled)
      ; Parameter 1 (0): Sets bHibernate to FALSE (i.e., perform Suspend/Sleep)
      ; Parameter 2 (0): Sets bForce to FALSE (allow applications to prompt for permission to close, though this parameter is often ignored now)
      ; Parameter 3 (0): Sets bWakeupEventsDisabled to FALSE (wake-up events remain enabled)
       DllCall('PowrProf\SetSuspendState', 'Int', 1, 'Int', 0, 'Int', 0) ; Hibernate

    default:
      
  }
 ExitApp()
}

ButtonCancel_Click(Ctrl, Info) {
 ExitApp()
}


DoRestartUEFI() {
  Run(A_ComSpec ' /c shutdown.exe /r /t 0 /fw')
  ExitApp
}

CountdownGui(Title, Seconds)
{
  ; Define initial variables
  global TimerGui := ''
  global TimerRunning := true
  global RemainingTime := Seconds
  returnValue := true ; true=timedout, false=canceled

  ; Create the new GUI object
  TimerGui := Gui("+AlwaysOnTop -Caption +Border")
  TimerGui.BackColor := "Yellow"
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

  ; Set up the Timer function (runs every 1000ms = 1 second)
  SetTimer UpdateTimer, 1000

  ; While the GUI is open and the timer is running, the main script thread pauses here.
  While (TimerRunning)
      Sleep(100) ; Wait 100ms before checking the flag again

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
