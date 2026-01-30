; ProcessMonitorExample v1.0.0.2

#Requires AutoHotkey v2.0

#Include ProcessMonitor.ahk

;ProcessMonitorClass__Example1()
ProcessMonitorClass__Example2()

ProcessMonitorClass__Example1() {

    ; --- Testing Script ---

    MyGui := Gui(, "Process Monitor v1.0.7")
    StatusText := MyGui.Add("Text", "w300", "Status: Idle")
    BtnStart := MyGui.Add("Button", "Default", "Start Monitoring Notepad")
    BtnStop := MyGui.Add("Button", "", "Stop Monitoring Notepad")

    ; Define the callback
    OnProcEnd(Reason, Name) {
        StatusText.Value := "Status: " . Name . " " . Reason
        MsgBox(Name . " has been closed.", "Process Watcher", 64)
    }

    OnExitNotify(ProcessMonitorObj) {

        SoundBeep

        StatusText.Value := "Finished: " . FormatTime(A_Now, "HH:mm:ss")
        
        MsgBox ProcessMonitorObj.Test()
    }

    OnStatusNotify(Obj) {

        StatusText.Value := "Status: " . FormatTime(A_Now, "HH:mm:ss")
        
    }
    ; Initialize Monitor
    ; Note: Ensure Notepad is open before clicking Start
    pm := ProcessMonitor("notepad.exe", 1000)
    
    BtnStart.OnEvent("Click", (*) => StartTask())

    StartTask() {
        pm.Start(OnExitNotify, OnStatusNotify)
        StatusText.Value := "Start: " . FormatTime(A_Now, "HH:mm:ss")

        ;Result := Proc.Start()

        ;if (SubStr(Result, 1, 10) = "Monitoring")
        ;    StatusText.Value := "Status: " . Result
        ;else
        ;    MsgBox(Result)
    }

    StopTask() {
        pm.Stop()
        StatusText.Value := "Start: " . FormatTime(A_Now, "HH:mm:ss")

        ;Result := Proc.Start()

        ;if (SubStr(Result, 1, 10) = "Monitoring")
        ;    StatusText.Value := "Status: " . Result
        ;else
        ;    MsgBox(Result)
    }

    MyGui.Show()
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