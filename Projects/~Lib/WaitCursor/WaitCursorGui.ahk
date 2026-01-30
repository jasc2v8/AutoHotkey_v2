/*
 * WaitCursor v1.0.2
 * Only displays the wait cursor when the mouse is over the specified GUI.
 */
class WaitCursor {
    static hCursor := 0
    static isWaiting := false
    static TargetHWND := 0

    static Start(GuiObj) {
        if (this.isWaiting)
            return

        this.TargetHWND := GuiObj.Hwnd
        ; IDC_WAIT = 32514
        this.hCursor := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32514, "Ptr")
        this.isWaiting := true
        
        SetTimer(() => this._CheckAndSet(), 10)
    }

    static Stop() {
        if (!this.isWaiting)
            return

        SetTimer(() => this._CheckAndSet(), 0)
        this.isWaiting := false
        this.TargetHWND := 0
        
        ; Restore the default arrow
        hArrow := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32512, "Ptr")
        DllCall("SetCursor", "Ptr", hArrow)
    }

    static _CheckAndSet() {
        if (!this.isWaiting)
            return

        MouseGetPos(,, &hoverHwnd)
        
        ; Only apply the cursor if the mouse is over our GUI
        if (hoverHwnd = this.TargetHWND) {
            DllCall("SetCursor", "Ptr", this.hCursor)
        }
    }
}