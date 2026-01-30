; TITLE  :  ProcessMonitor v1.0.0.4 - Change Callback(this) to Callback("Reason")
; SOURCE :  jasc2v8 and Gemini
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Periodically monitors a process and signals status/completion.
; USAGE  :
; NOTES  :

; ==============================================================================
; Name .........: ProcessMonitor
; Description ..: Periodically monitors a process and signals status/completion.
; Version ......: 1.0.3
; AHK Version ..: v2.0
; ==============================================================================

class ProcessMonitor {
    static Version := "1.0.3"
    Reason := "Stop"
    __New(ProcessNameOrPID, CheckInterval := 500) {
        this.Target := ProcessNameOrPID
        this.Interval := CheckInterval
        this.IsRunning := false
        this.OnExitCallback := ""
        this.OnStatusCallback := ""
        this.OnStopCallback := ""
        this.TimerInstance := ObjBindMethod(this, "_CheckStatus")
    }

    ; Starts the monitoring loop
    ; OnExitNotify: Function to call when process stops naturally
    ; OnStatusNotify: Optional function to call every interval while running
    ; OnStopNotify: Optional function to call when Stop() is called manually
    Start(OnExitNotify, OnStatusNotify := "", OnStopNotify := "") {
        this.OnExitCallback := OnExitNotify
        this.OnStatusCallback := OnStatusNotify
        this.OnStopCallback := OnStopNotify
        this.IsRunning := true
        SetTimer(this.TimerInstance, this.Interval)
    }

    ; Stops the monitoring loop manually
    Stop() {
        SetTimer(this.TimerInstance, 0)
        this.IsRunning := false
        
        if (this.OnStopCallback != "")
        {
            this.OnStopCallback.Call("Stopped")
        }
    }

    ; Internal check logic
    _CheckStatus() {
        ; Check if process exists
        if (!ProcessExist(this.Target))
        {
            ; We call the internal timer stop here directly to avoid triggering OnStopCallback
            SetTimer(this.TimerInstance, 0)
            this.IsRunning := false
            
            if (this.OnExitCallback != "")
            {
                this.OnExitCallback.Call("Finished")
            }
            return
        }

        ; If still running, trigger status callback if defined
        if (this.OnStatusCallback != "")
        {
            this.OnStatusCallback.Call("Running")
        }
    }
}

/*
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
*/
