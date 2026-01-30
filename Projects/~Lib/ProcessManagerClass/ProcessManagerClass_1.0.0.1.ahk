; TITLE  :  MyScript v1.0.0.1
; SOURCE :  jasc2v8 and Gemini
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

/*
    TODO:
*/

#Requires AutoHotkey v2.0

class ProcessManager {
    ; Updated version: 1.0.5
    ; Replaced Iteration logic with ProcessExist monitoring
    
    __New(GuiObj, ProcessName, Interval := 500, OnStopCallback := "") {
        this.GuiObj := GuiObj
        this.ProcessName := ProcessName
        this.Interval := Interval
        this.OnStopCallback := OnStopCallback
        this.IsRunning := false
        this.TimerTick := this.Tick.Bind(this)
        
        this.IDC_WAIT := 32514
        this.hWaitCursor := DllCall("LoadCursor", "Ptr", 0, "Ptr", this.IDC_WAIT, "Ptr")
        
        OnMessage(0x0020, this.HandleCursor.Bind(this))
    }

    Start() {
        if (this.IsRunning)
            return "Monitor already active"
        
        if (!ProcessExist(this.ProcessName))
            return "Target process '" this.ProcessName "' is not running"

        this.IsRunning := true
        SetTimer(this.TimerTick, this.Interval)
        this.UpdateCursor()
        return "Monitoring " this.ProcessName
    }

    Stop(Reason := "Stopped") {
        if (!this.IsRunning)
            return
        
        SetTimer(this.TimerTick, 0)
        this.IsRunning := false
        
        this.UpdateCursor()

        if (this.OnStopCallback is Func || this.OnStopCallback is BoundFunc) {
            this.OnStopCallback(Reason, this.ProcessName)
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
        ; Main logic: Check if the process has closed
        if (!ProcessExist(this.ProcessName)) {
            this.Stop("Process Terminated")
        }
    }
}

;If (A_LineFile == A_ScriptFullPath)  ; if run directly, not included
    ProcessManagerClass__Example()

ProcessManagerClass__Example() {

    ; --- Example Usage ---

    MyGui := Gui(, "Process Monitor v1.0.5")
    StatusText := MyGui.Add("Text", "w300", "Status: Idle")
    EditProc := MyGui.Add("Edit", "w200", "notepad.exe")
    BtnStart := MyGui.Add("Button",, "Start Monitoring")

    ; Callback when the exe closes
    OnProcEnd(Reason, Name) {
        StatusText.Value := "Status: " Name " closed (" Reason ")"
        MsgBox(Name " is no longer running!")
    }

    ; Initialize with the GUI, the process to watch, and the callback
    ; We don't create Proc yet because we want to grab the name from the Edit box
    Proc := ""

    BtnStart.OnEvent("Click", (*) => StartMonitoring())

    StartMonitoring() {
        global Proc
        ProcName := EditProc.Value
        Proc := ProcessManager(MyGui, ProcName, 500, OnProcEnd)
        
        Result := Proc.Start()
        if (Result != "Monitoring " ProcName)
            MsgBox(Result)
        else
            StatusText.Value := "Status: Watching " ProcName "..."
    }

    MyGui.Show()
}
