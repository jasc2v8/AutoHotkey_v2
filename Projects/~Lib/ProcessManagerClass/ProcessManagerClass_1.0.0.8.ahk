#Requires AutoHotkey v2.0

class ProcessManager {
    ; Updated version: v1.0.0.8
    ; Fixed: ProcessExist check logic to ensure callback triggers
    
    __New(GuiObj, ProcessName, Interval := 500, OnStopCallback := "") {
        this.GuiObj := GuiObj
        this.ProcessName := ProcessName
        this.Interval := Interval
        this.OnStopCallback := OnStopCallback
        this.IsRunning := false
        this.TimerTick := this.Tick.Bind(this)
        
        this.IDC_WAIT := 32514
        this.hWaitCursor := DllCall("LoadCursor", "Ptr", 0, "Ptr", this.IDC_WAIT, "Ptr")
        
        ; Register cursor handler
        OnMessage(0x0020, this.HandleCursor.Bind(this))
    }

    Start() {
        if (this.IsRunning)
            return "Monitor already active"
        
        ; Verify process exists before starting
        this.PID := ProcessExist(this.ProcessName)
        if (this.PID = 0)
            return "Target process '" this.ProcessName "' is not running"

        this.IsRunning := true
        SetTimer(this.TimerTick, this.Interval)
        this.UpdateCursor()
        this.StartTime:=A_Now
        return "Start " this.ProcessName " (PID: " this.PID ") at " FormatTime(this.StartTime, "HH:mm:ss")
    }

    Stop(Reason := "Stopped") {
        if (!this.IsRunning)
            return
        
        SetTimer(this.TimerTick, 0)
        this.IsRunning := false
        this.UpdateCursor()

        if (this.OnStopCallback != "") {
            ; Execute callback with parameters

            duration := DateDiff(A_Now, this.StartTime, "Seconds")

            Reason := Reason " at " FormatTime(A_Now, "HH:mm:ss") ", Elapsed: " duration " seconds."
            this.OnStopCallback.Call(Reason, this.ProcessName)
        }
    }

    UpdateCursor() {
        DllCall("SendMessage", "Ptr", this.GuiObj.Hwnd, "UInt", 0x0020, "Ptr", this.GuiObj.Hwnd, "Ptr", 1)
    }

    HandleCursor(wParam, lParam, msg, hwnd) {
        if (this.IsRunning && hwnd = this.GuiObj.Hwnd && (lParam & 0xFFFF) = 1) {
            DllCall("SetCursor", "Ptr", this.hWaitCursor)
            return 1
        }
    }

    Tick() {
        ; Use the stored PID or Name to check existence
        if (ProcessExist(this.ProcessName) = 0)
        {
            this.Stop("Process Terminated")
        }
    }
}

If (A_LineFile == A_ScriptFullPath)  ; if run directly, not included
    ProcessManagerClass__Example()

ProcessManagerClass__Example() {

    ; --- Testing Script ---

    MyGui := Gui(, "Process Monitor v1.0.7")
    StatusText := MyGui.Add("Text", "w300", "Status: Idle")
    BtnStart := MyGui.Add("Button", "Default", "Start Monitoring Notepad")

    ; Define the callback
    OnProcEnd(Reason, Name) {
        StatusText.Value := "Status: " . Name . " " . Reason
        MsgBox(Name . " has been closed.", "Process Watcher", 64)
    }

    ; Initialize Manager
    ; Note: Ensure Notepad is open before clicking Start
    Proc := ProcessManager(MyGui, "notepad.exe", 500, OnProcEnd)

    BtnStart.OnEvent("Click", (*) => StartTask())

    StartTask() {
        Result := Proc.Start()
        if (SubStr(Result, 1, 10) = "Monitoring")
            StatusText.Value := "Status: " . Result
        else
            MsgBox(Result)
    }

    MyGui.Show()
}

