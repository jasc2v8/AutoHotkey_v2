#Requires AutoHotkey v2.0

; --- Cleanup Logic ---
OnExit(RestoreAndExit)

RestoreAndExit(*) {
    ; Reloads system cursors from registry to ensure nothing stays stuck
    DllCall("SystemParametersInfo", "UInt", 0x0057, "UInt", 0, "Ptr", 0, "UInt", 0)
        
    ExitApp()
}

; --- GUI Implementation ---
MyGui := Gui("+AlwaysOnTop", "Cursor Library Demo v1.1.8")
MyGui.OnEvent("Close", RestoreAndExit)
MyGui.SetFont("s10", "Segoe UI")

; Populate list from the class static map
CursorNames := SystemCursor.GetNames()

MyGui.Add("Text", "w260", "Select a Cursor Type:")
DDL := MyGui.Add("DropDownList", "vCursorType w260 Choose1", CursorNames)

MyGui.Add("GroupBox", "w260 h110", "Local GUI Cursors")
BtnStartLocal := MyGui.Add("Button", "xp+10 yp+25 w110", "Start (Local)")
BtnStopLocal  := MyGui.Add("Button", "x+10 w110", "Stop Local")

MyGui.Add("GroupBox", "xs-10 y+30 w260 h110", "TRUE System-Wide Cursors")
BtnStartSys := MyGui.Add("Button", "xp+10 yp+25 w110", "Start (Global)")
BtnStopSys  := MyGui.Add("Button", "x+10 w110", "Restore Global")

; --- Event Handlers ---
BtnStartLocal.OnEvent("Click", (*) => StartCursor(DDL.Text, MyGui))
BtnStopLocal.OnEvent("Click", (*) => StopCursor("Local"))

BtnStartSys.OnEvent("Click", (*) => StartCursor(DDL.Text, 0))
BtnStopSys.OnEvent("Click", (*) => StopCursor("System"))

MyGui.Show()

; --- Controller Logic ---
Global ActiveLocal := 0
Global ActiveSys := 0

StartCursor(TypeName, Target) {
    Global ActiveLocal, ActiveSys
    
    if (Target != 0) {
        if (ActiveLocal)
            ActiveLocal.Stop()
        ActiveLocal := SystemCursor(Target, TypeName)
        ActiveLocal.Start()
    } else {
        if (ActiveSys)
            ActiveSys.Stop()
        ActiveSys := SystemCursor(0, TypeName)
        ActiveSys.Start()
    }
}

StopCursor(Scope) {
    Global ActiveLocal, ActiveSys
    
    if (Scope = "Local" && ActiveLocal) {
        ActiveLocal.Stop()
        ActiveLocal := 0
    }
    
    if (Scope = "System" && ActiveSys) {
        ActiveSys.Stop()
        ActiveSys := 0
    }
}

; --- Library Classes ---

class SystemCursor {
    static Type := Map(
        "Arrow",    32512, "IBeam",    32513, "Wait",     32514,
        "Cross",    32515, "UpArrow",  32516, "SizeNWSE", 32642,
        "SizeNESW", 32643, "SizeWE",   32644, "SizeNS",   32645,
        "SizeAll",  32646, "No",       32648, "Hand",     32649,
        "AppStarting", 32650, "Help",  32651
    )

    static GetNames() {
        Names := []
        for Name in SystemCursor.Type
            Names.Push(Name)
        return Names
    }

    hCursor := 0
    isActive := false
    TargetHWND := 0
    isGlobal := false
    CursorID := 32512 

    __New(GuiObj := 0, CursorID := 0) {
        if (IsObject(GuiObj)) {
            this.TargetHWND := GuiObj.Hwnd
            this.isGlobal := false
        } else {
            this.TargetHWND := 0
            this.isGlobal := true
        }

        if (CursorID != 0) {
            if (SystemCursor.Type.Has(CursorID)) {
                this.CursorID := SystemCursor.Type[CursorID]
            } else {
                this.CursorID := CursorID
            }
        }
    }

    Start() {
        if (this.isActive)
            return

        this.hCursor := DllCall("LoadCursor", "Ptr", 0, "Ptr", this.CursorID, "Ptr")
        this.isActive := true
        
        if (this.isGlobal) {
            ; OCR_NORMAL = 32512. SetSystemCursor destroys the handle, so we copy it first.
            hCopy := DllCall("CopyIcon", "Ptr", this.hCursor, "Ptr")
            DllCall("SetSystemCursor", "Ptr", hCopy, "UInt", 32512)
        } else {
            this._TimerCallback := () => this._CheckAndSet()
            SetTimer(this._TimerCallback, 10)
        }
    }

    Stop() {
        if (!this.isActive)
            return

        if (this.isGlobal) {
            DllCall("SystemParametersInfo", "UInt", 0x0057, "UInt", 0, "Ptr", 0, "UInt", 0)
        } else {
            SetTimer(this._TimerCallback, 0)
            this._TimerCallback := ""
            
            hArrow := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32512, "Ptr")
            DllCall("SetCursor", "Ptr", hArrow)
        }
        
        this.isActive := false
    }

    _CheckAndSet() {
        if (!this.isActive)
            return

        MouseGetPos(,, &hoverHwnd)
        if (hoverHwnd = this.TargetHWND) {
            DllCall("SetCursor", "Ptr", this.hCursor)
        }
    }
}

class WaitCursor extends SystemCursor {
    CursorID := 32514 
}

class CrosshairCursor extends SystemCursor {
    CursorID := 32515 
}