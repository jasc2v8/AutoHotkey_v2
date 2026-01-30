/*
 * SystemCursor v1.1.0.6
 * Added 'Type' helper for friendly name mapping.
 */
class SystemCursor {
    ; Static map of friendly names to Windows IDs
    static Type := Map(
        "Arrow",    32512,
        "IBeam",    32513,
        "Wait",     32514,
        "Cross",    32515,
        "UpArrow",  32516,
        "SizeNWSE", 32642,
        "SizeNESW", 32643,
        "SizeWE",   32644,
        "SizeNS",   32645,
        "SizeAll",  32646,
        "No",       32648,
        "Hand",     32649,
        "AppStarting", 32650,
        "Help",     32651
    )

    hCursor := 0
    isActive := false
    TargetHWND := 0
    isGlobal := false
    CursorID := 32512 

    /**
     * @param GuiObj - Pass a Gui Object for local, or 0 for system-wide.
     * @param CursorID - Pass a number (32514) OR a string ("Hand").
     */
    __New(GuiObj := 0, CursorID := 0) {
        if (IsObject(GuiObj)) {
            this.TargetHWND := GuiObj.Hwnd
            this.isGlobal := false
        } else {
            this.TargetHWND := 0
            this.isGlobal := true
        }

        ; Check if the user provided a custom ID or Name
        if (CursorID != 0) {
            if (SystemCursor.Type.Has(CursorID)) {
                this.CursorID := SystemCursor.Type[CursorID]
            } else {
                this.CursorID := CursorID
            }
        } else {
            this.CursorID := SystemCursor.Type["Wait"]
        }
    }

    Start() {
        if (this.isActive)
            return

        this.hCursor := DllCall("LoadCursor", "Ptr", 0, "Ptr", this.CursorID, "Ptr")
        this.isActive := true
        
        if (this.isGlobal) {
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

class AppStartingCursor extends SystemCursor {
    CursorID := 32650 
}

class CrossCursor extends SystemCursor {
    CursorID := 32515 
}

class WaitCursor extends SystemCursor {
    CursorID := 32514 
}

