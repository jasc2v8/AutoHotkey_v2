/*
 * WaitCursor v1.0.1
 * Provides a simple way to toggle the busy/waiting cursor.
 */
class WaitCursor {
    static hCursor := 0
    static isWaiting := false

    static Start() {
        if (this.isWaiting)
            return

        ; IDC_WAIT = 32514
        this.hCursor := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32514, "Ptr")
        this.isWaiting := true
        
        DllCall("SetCursor", "Ptr", this.hCursor)
        
        ; We use a timer to ensure the cursor stays set if the app is busy
        SetTimer(() => this._Set(), 10)
    }

    static Stop() {
        if (!this.isWaiting)
            return

        SetTimer(() => this._Set(), 0) ; Turn off timer
        this.isWaiting := false
        
        ; Restore the default arrow cursor
        hArrow := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32512, "Ptr")
        DllCall("SetCursor", "Ptr", hArrow)
    }

    static _Set() {
        ;if (this.isWaiting)
           ; DllCall("SetCursor", "Ptr", this.hCursor)
    }
}