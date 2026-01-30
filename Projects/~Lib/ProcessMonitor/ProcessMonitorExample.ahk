; ProcessMonitorExample v1.0.0.3

#Requires AutoHotkey v2.0

#Include ProcessMonitor.ahk

ProcessMonitorClass__Example1()
;ProcessMonitorClass__Example2()

ProcessMonitorClass__Example1() {

    ; --- Testing Script ---

    MyGui := Gui(, "Process Monitor v1.0.7")
    StatusText := MyGui.Add("Text", "w300", "Status: Idle")
    BtnLaunch := MyGui.Add("Button", "w150", "Launch Notepad")
    BtnStart := MyGui.Add("Button", "w150 Default", "Start Monitoring Notepad")
    BtnStop := MyGui.Add("Button", "w150", "Stop Monitoring Notepad")

    OnExitNotify(Reason) {
        SoundBeep
        StatusText.Value := Reason . " at: " FormatTime(A_Now, "HH:mm:ss") ", Elapsed: " pm.Elapsed
    }

    OnStatusNotify(Reason) {
        StatusText.Value := Reason . " at: " FormatTime(A_Now, "HH:mm:ss") ", Elapsed: " pm.Elapsed
    }
    
    OnStopNotify(Reason) {
        StatusText.Value := Reason . " at: " FormatTime(A_Now, "HH:mm:ss") ", Elapsed: " pm.Elapsed
    }

    ; Initialize Monitor
    pm := ProcessMonitor("notepad.exe", A_ScriptDir, true, 1000)
    
    BtnLaunch.OnEvent("Click", (*) => Run("notepad.exe"))
    BtnStart.OnEvent("Click", (*) => StartTask())
    BtnStop.OnEvent("Click", (*) => StopTask())

    StartTask() {
        pm.Start(OnExitNotify, OnStatusNotify, OnStopNotify)
        StatusText.Value := "Start at: " . FormatTime(A_Now, "HH:mm:ss")

        ;Result := Proc.Start()

        ;if (SubStr(Result, 1, 10) = "Monitoring")
        ;    StatusText.Value := "Status: " . Result
        ;else
        ;    MsgBox(Result)
    }

    StopTask() {
        pm.Stop()
        ;StatusText.Value := "Stop: " . FormatTime(A_Now, "HH:mm:ss")

        ;Result := Proc.Start()

        ;if (SubStr(Result, 1, 10) = "Monitoring")
        ;    StatusText.Value := "Status: " . Result
        ;else
        ;    MsgBox(Result)
    }

    MyGui.Show()

    if ProcessExist("notepad.exe")
        StatusText.Value := "Running"
    else 
        StatusText.Value := "Idle"
}

ProcessMonitorClass__Example2() {

    ; Example Usage:
    Tracker := ProcessMonitor("notepad.exe", 1000)
    Tracker.Start(Finished, StillRunning, ManuallyStopped)

    ManuallyStopped(Obj) {
        MsgBox("Monitoring was cancelled manually.")
    }

    StillRunning(Obj) {
        ToolTip("Monitoring: " . Obj.Target)
    }

    Finished(Obj) {
        ToolTip()
        MsgBox("Process " . Obj.Target . " has finished naturally.")
    }
}