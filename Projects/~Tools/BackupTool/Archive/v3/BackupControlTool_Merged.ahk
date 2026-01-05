;====================================================================================================
;D:\Software\DEV\Work\AHK2\Projects\BackupControlTool\BackupControlTool_Merged.ahk
;====================================================================================================
;C:\Users\Jim\Documents\AutoHotkey\Lib\IniLite.ahk
;C:\Users\Jim\Documents\AutoHotkey\Lib\RunCMD.ahk
;D:\Software\DEV\Work\AHK2\Projects\BackupControlTool\BackupControlTool.ahk
;====================================================================================================
;C:\Users\Jim\Documents\AutoHotkey\Lib\IniLite.ahk
;====================================================================================================

class IniLite
{
    IniPath := ''

    __New(IniFilePath:="")
    {
        if IniFilePath = "" {
            IniFilePath := A_ScriptFullPath.SplitPath().NameNoExt ".ini"
            if !FileExist(IniFilePath)
                FileAppend("[Settings]`r`n", IniFilePath)
            ;FileAppend("INI_PATH=" IniFilePath "`r`n", IniFilePath)
        } else {
            SplitPath(IniFilePath,, &IniDir)
            if !DirExist(IniDir)
            DirCreate(IniDir)
        }
        this.IniPath := IniFilePath
	}

    Read(section, key) {

        try {
            if FileExist(this.IniPath) {
                return IniRead(this.IniPath, section, key)
            } else {
                return ; default is ''
            }
        } catch Error as e {
            return ; default is ''
        }
	}

    ReadSection(section) {
        try {
            if FileExist(this.IniPath) {
                return IniRead(this.IniPath, section)
            } else {
                return ; default is ''
            }
        } catch Error as e {
            return ; default is ''
        }
	}

    ReadSectionNames() {
        try {
            if FileExist(this.IniPath) {
                return IniRead(this.IniPath)
            } else {
                return ; default is ''
            }
        } catch Error as e {
            return ; default is ''
        }
	}

	ReadSettings(key) {
        try {
            if FileExist(this.IniPath) {
        		return IniRead(this.IniPath, "Settings", key)
            } else {
                return ; default is ''
            }
        } catch Error as e {
            return ; default is ''
        }
	}

    Write(section, key, value) {
		try {
			if FileExist(this.IniPath) {
				IniWrite(value, this.IniPath, section, key)
				return true
			} else {
				return false
			}
		} catch Error as e {
			return false
		}
	}
	
	WriteSettings(key, value) {
                try {
            if FileExist(this.IniPath) {
                return IniWrite(value, this.IniPath, "Settings", key )
            } else {
                return false
            }
        } catch Error as e {
            return false
        }
	}
}

;====================================================================================================
;C:\Users\Jim\Documents\AutoHotkey\Lib\RunCMD.ahk
;====================================================================================================

RunCMD(Parameters*) {

    fso := ComObject("Scripting.FileSystemObject")
    randomFileame := fso.GetTempName()
    TempFile := A_Temp "\" randomFileame

    EndQuote := ""

    CommandLine := A_ComSpec . " /D /Q /C " 

    for index, value in Parameters {

        ; If the first parameter is an executable, add extra quotes and EndQuote
        if (index = 1) {
            ; If an executable, add quotes
            if InStr(value, "\") AND InStr(value, A_Space){
                CommandLine .= '"' '"' value '"' A_Space
                EndQuote := '"'
            } else {
                ; Not an executable, no quotes
                CommandLine .= value A_Space
            }
        } else {
            ; If a Parameter is an executable, add quotes
            if InStr(value, "\") AND InStr(value, A_Space) {
                CommandLine .= '"' value '"' A_Space
                EndQuote := ""
            } else {
                ; Not an executable, no quotes
                CommandLine .= value A_Space
            }
        }
    }

    CommandLine .= " > " '"' TempFile '"' " 2>&1" EndQuote

    r := RunWait(A_ComSpec ' /C ' CommandLine, , 'Hide')

    Output := FileRead(TempFile)

    FileDelete(TempFile)

    RunCMD.Output  := Output

    return r
}

;====================================================================================================
;D:\Software\DEV\Work\AHK2\Projects\BackupControlTool\BackupControlTool.ahk
;====================================================================================================
#SingleInstance Ignore ;Force
#NoTrayIcon
TraySetIcon('shell32.dll', 294) ; Backup/Restore Icon

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

global SyncBackPath := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
global SyncBackProfiles := EnvGet("LOCALAPPDATA") "\2BrightSparks\SyncBack\Profiles Backup"
global logDir := EnvGet("LOCALAPPDATA") "\2BrightSparks\SyncBack\Logs"
global DefaultProfile := "~Backup JIM-PC folders to JIM-SERVER"

global SoundSuccess := "C:\Windows\Media\Windows Notify Calendar.wav"
global SoundError := "C:\Windows\Media\Windows Critical Stop.wav"

global INI_PATH := EnvGet("LOCALAPPDATA") "\" StrReplace(A_ScriptName, ".ahk", ".ini")
global INI := IniLite(INI_PATH)

SyncBackSelectedProfile := ReadIni()

MyGui := Gui("+AlwaysOnTop", "Backup Control Tool v2.2")
MyGui.BackColor := "4682B4" ; Steel Blue

MyGui.SetFont("S11 CBlack w400", "Segouie UI")
TextProfile := MyGui.AddEdit('xm w400 h20 Center Backgrounda1e3a5', SyncBackSelectedProfile)
ButtonProfile := MyGui.AddButton("yp w60 h20", "Profile")

MyGui.AddGroupBox("xm w472 h100", "Action after Backup:")

MyGui.SetFont("S11 CBlack w400", "Segouie UI")
TextFiller      := MyGui.AddText("xm yp+40 w50 +Hidden")
ButtonNothing   := MyGui.AddButton("yp w100", "Nothing")
ButtonSleep     := MyGui.AddButton("yp w100", "Sleep")
ButtonShutdown  := MyGui.AddButton("yp w100", "Shutdown")

MyGui.SetFont()
TextFiller    := MyGui.AddText("xm yp+75 w85 +Hidden")
ButtonLogs    := MyGui.AddButton("yp w75", "Logs")
ButtonClear   := MyGui.AddButton("yp w75", "Clear")
ButtonCancel  := MyGui.AddButton("yp w75 Default", "Cancel")

SB := MyGui.AddStatusBar()

WriteStatus('Ready.')

ButtonProfile.OnEvent("Click", ButtonProfile_Click)
ButtonLogs.OnEvent("Click", ButtonLogs_Click)
ButtonClear.OnEvent("Click", ButtonClear_Click)
ButtonNothing.OnEvent("Click", ButtonCommon_Click)
ButtonSleep.OnEvent("Click", ButtonCommon_Click)
ButtonShutdown.OnEvent("Click", ButtonCommon_Click)
ButtonCancel.OnEvent("Click", ButtonCancel_Click)
MyGui.OnEvent("Close", (*) => ExitApp())

MyGui.Show()

ControlFocus("Cancel", MyGui)

ButtonCancel_Click(Ctrl, Info) {
 ExitApp()
}

ButtonCommon_Click(Ctrl, Info){

 WriteStatus("Ready.")

  timeout := CountdownAndBlock(Ctrl.Text, 5)

  if (timeout) {

    MyGui.Opt("+Disabled")

    WinSetTransparent(150, MyGui.Hwnd)

    WriteStatus('Running Profile...')

    switch Ctrl.Text {
      case "Nothing":
        BackupParameter := ""
      case "Sleep":
        BackupParameter := "-standby"
      case "Shutdown":
        BackupParameter := "-shutdown"
    }

    Profile := '"' Trim(TextProfile.Text) '"'

    ; success = output, error = ""
    r := RunCMD(SyncBackPath, BackupParameter, Profile)

    if (r = 0) {
      SoundPlay SoundSuccess
      WriteStatus('Success.')
    } else {
      SoundPlay SoundError
      WriteStatus('Error ExitCode: ' r)  
    }

    MyGui.Opt("-Disabled")
    WinSetTransparent("Off", MyGui.Hwnd)
    WinActivate(MyGui.Hwnd)
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
    SyncBackSelectedProfile := OutNameNoExt
    TextProfile.Text := SyncBackSelectedProfile
    INI.WriteSettings("PROFILE", SyncBackSelectedProfile)
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