/*
 * Script: WaitCursor Manager
 * Version: v1.0.1
 */

class WaitCursor {
    static _refCount := 0
    static _hWaitCursor := 0

    static Start() {
        if (this._refCount = 0) {
            ; IDC_WAIT = 32514
            this._hWaitCursor := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32514, "Ptr")
            ; Replace the standard arrow (32512) with the wait cursor
            DllCall("SetSystemCursor", "Ptr", this._hWaitCursor, "Int", 32512)
            
            ; Ensure restoration if script exits
            OnExit(this._OnExitRestore)
        }
        this._refCount++
    }

    static Stop() {
        this._refCount--
        if (this._refCount <= 0) {
            this._refCount := 0
            this.Restore()
        }
    }

    static Restore() {
        ; SPI_SETCURSORS = 0x0057
        DllCall("SystemParametersInfo", "UInt", 0x0057, "UInt", 0, "Ptr", 0, "UInt", 0)
    }

    static _OnExitRestore(*) {
        WaitCursor.Restore()
    }
}

; --- Usage Example ---

F1:: {
    WaitCursor.Start()
    
    ; Logic to check if an object is a GUI vs Control
    myGui := Gui()
    myBtn := myGui.Add("Button",, "Test")
    
    if (myGui is Gui)
    {
        MsgBox("The Wait cursor is active while this Gui exists.")
    }
    
    WaitCursor.Stop()
}