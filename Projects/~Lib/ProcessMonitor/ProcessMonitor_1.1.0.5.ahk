; TITLE  :  ProcessMonitor v1.1.0.5 - Add Timeout
; SOURCE :  jasc2v8 and Gemini
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Periodically monitors a process and signals status/completion.
; USAGE  :
; NOTES  :

; ==============================================================================
; Name .........: ProcessMonitor
; Description ..: Periodically monitors a process and signals status/completion.
; Version ......: 1.1.5
; AHK Version ..: v2.0
; ==============================================================================

class ProcessMonitor {
    static Version := "1.1.5"

    __New(ProcessNameOrPID, WorkingDir := "", AutoStart := false, CheckInterval := 500) {
        this.Target := ProcessNameOrPID
        this.Interval := CheckInterval
        this.AutoStart := AutoStart
        this.WorkingDir := WorkingDir
        this.IsRunning := false
        this.StartTime := 0
        this.OnExitCallback := ""
        this.OnStatusCallback := ""
        this.OnStopCallback := ""
        this.TimerInstance := ObjBindMethod(this, "_CheckStatus")

        ; Handle AutoStart logic immediately on creation
        if (this.AutoStart && !this.PID)
        {
            try 
            {
                Run(this.Target, this.WorkingDir)
            }
            catch Error as e
            {
                MsgBox("Failed to auto-start process: " . this.Target . "`n`n" . e.Message)
                return
            }
        }
    }

    ; Returns the Process ID if it exists, otherwise 0
    PID {
        get {
            return ProcessExist(this.Target)
        }
    }

    ; Returns the elapsed time as a formatted string (HH:mm:ss)
    Elapsed {
        get {
            if (this.StartTime = 0)
            {
                return "00:00:00"
            }
            
            Diff := DateDiff(A_Now, this.StartTime, "Seconds")
            return Format("{1:02}:{2:02}:{3:02}", Floor(Diff/3600), Floor(Mod(Diff,3600)/60), Mod(Diff,60))
        }
    }

    ; Change the process priority (Low, BelowNormal, Normal, AboveNormal, High, Realtime)
    SetPriority(Level := "Normal") {
        if (this.PID)
        {
            ProcessSetPriority(Level, this.PID)
        }
        return
    }

    ; Starts the monitoring loop
    Start(OnExitNotify, OnStatusNotify := "", OnStopNotify := "") {
        this.OnExitCallback := OnExitNotify
        this.OnStatusCallback := OnStatusNotify
        this.OnStopCallback := OnStopNotify

        this.IsRunning := true
        this.StartTime := A_Now
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

    ; Restarts the process and resets the timer
    Restart() {
        ; Kill current process if it exists
        if (this.PID)
        {
            ProcessClose(this.Target)
        }

        try 
        {
            Run(this.Target, this.WorkingDir)
            this.StartTime := A_Now
        }
        catch Error as e
        {
            MsgBox("Failed to restart process: " . this.Target . "`n`n" . e.Message)
            return
        }
    }

    ; Internal check logic
    _CheckStatus() {
        ; Check if process exists
        if (!this.PID)
        {
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