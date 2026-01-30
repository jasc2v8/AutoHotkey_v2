/*
 * Script: WaitCursor Manager
 * Version: v1.0.0.9
 */

class WaitCursor {
    static _refCount := 0
    static _hWaitCursor := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32514, "Ptr")
    static _hookedGuis := Map()
    static _boundHandleMessage := 0

    static Start(TargetGui := 0) {
        if (TargetGui = 0) {
            ; Global Wait Cursor
            if (this._refCount = 0) {
                ; 32512 is IDC_ARROW
                DllCall("SetSystemCursor", "Ptr", this._hWaitCursor, "Int", 32512)
                OnExit(WaitCursor._OnExitRestore)
            }
            this._refCount++
        }
        else if (TargetGui is Gui) {
            ; GUI-Specific Wait Cursor
            if (!this._hookedGuis.Has(TargetGui.Hwnd)) {
                this._hookedGuis[TargetGui.Hwnd] := true
                
                ; Auto-unbind if the GUI is destroyed externally
                TargetGui.OnEvent("Close", (*) => this.Stop(TargetGui))
                
                if (this._boundHandleMessage = 0)
                    this._boundHandleMessage := this._HandleMessage.Bind(this)
                
                OnMessage(0x20, this._boundHandleMessage)
            }
        }
    }

    static Stop(TargetGui := 0) {
        if (TargetGui = 0) {
            this._refCount--
            if (this._refCount <= 0) {
                this._refCount := 0
                this.Restore()
            }
        }
        else if (TargetGui is Gui) {
            if (this._hookedGuis.Has(TargetGui.Hwnd)) {
                this._hookedGuis.Delete(TargetGui.Hwnd)
            }
            
            if (this._hookedGuis.Count = 0 && this._boundHandleMessage != 0) {
                OnMessage(0x20, this._boundHandleMessage, 0)
            }
        }
    }

    static Restore() {
        ; SPI_SETCURSORS = 0x0057
        DllCall("SystemParametersInfo", "UInt", 0x0057, "UInt", 0, "Ptr", 0, "UInt", 0)
    }

    static _HandleMessage(params*) {
        if (params.Length >= 4) {
            currHwnd := params[4]
            
            ; GA_ROOT = 2 (Get the top-level GUI handle)
            rootHwnd := DllCall("GetAncestor", "Ptr", currHwnd, "UInt", 2, "Ptr")
            
            ; Safety check: if the GUI was destroyed but somehow still in our Map
            if (!WinExist(rootHwnd)) {
                if (WaitCursor._hookedGuis.Has(rootHwnd)) {
                    WaitCursor._hookedGuis.Delete(rootHwnd)
                }
                return
            }

            if (WaitCursor._hookedGuis.Has(rootHwnd)) {
                DllCall("SetCursor", "Ptr", WaitCursor._hWaitCursor)
                return True
            }
        }
        return
    }

    static _OnExitRestore(*) {
        WaitCursor.Restore()
    }
}

; --- Usage Example ---

; myGui := Gui()
; myGui.Add("Text",, "Close this GUI while Wait is active to test cleanup.")
; myGui.Show("w300 h200")

; F2:: {
;     WaitCursor.Start(myGui)
;     ToolTip("GUI Wait Active. Close the GUI now.")
; }

; F3:: {
;     ; Manually destroying the GUI
;     ToolTip
;     myGui.Destroy()
;     ExitApp()
; }