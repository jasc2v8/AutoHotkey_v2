; TITLE  :  ProcessMonitor v1.0.0.1
; SOURCE :  jasc2v8 and Gemini
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Periodically monitors a process and signals status/completion.
; USAGE  :
; NOTES  :

; ==============================================================================
; Name .........: ProcessMonitor
; Description ..: Periodically monitors a process and signals status/completion.
; Version ......: 1.0.2
; AHK Version ..: v2.0
; ==============================================================================

class ProcessMonitor {
    static Version := "1.0.2"

    __New(ProcessNameOrPID, CheckInterval := 500) {
        this.Target := ProcessNameOrPID
        this.Interval := CheckInterval
        this.IsRunning := false
        this.OnExitCallback := ""
        this.OnStatusCallback := ""
        this.TimerInstance := ObjBindMethod(this, "_CheckStatus")
    }

    ; Starts the monitoring loop
    ; OnExitNotify: Function to call when process stops
    ; OnStatusNotify: Optional function to call every interval while running
    Start(OnExitNotify, OnStatusNotify := "") {
        this.OnExitCallback := OnExitNotify
        this.OnStatusCallback := OnStatusNotify
        this.IsRunning := true
        SetTimer(this.TimerInstance, this.Interval)
    }

    ; Stops the monitoring loop
    Stop() {
        SetTimer(this.TimerInstance, 0)
        this.IsRunning := false
    }

    ; Internal check logic
    _CheckStatus() {
        ; Check if process exists
        if (!ProcessExist(this.Target))
        {
            this.Stop()
            if (this.OnExitCallback != "")
            {
                this.OnExitCallback.Call(this)
            }
            return
        }

        ; If still running, trigger status callback if defined
        if (this.OnStatusCallback != "")
        {
            this.OnStatusCallback.Call(this)
        }
    }
}