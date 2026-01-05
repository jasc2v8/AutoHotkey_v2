; TITLE:    AhkRunSkipUAC v1.0
; SOURCE:   jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

class RunSkipUAC {
    static WM_COPYDATA := 0x004A
    static MSGFLT_ALLOW := 1

    /**
     * Attempts to run the script via Task Scheduler to skip the UAC prompt.
     * Requires a Task named "AdminTask_%A_ScriptName%" set to "Run with highest privileges".
     */
    static RunAsAdmin() {
        if A_IsAdmin
            return true
        
        taskName := "AdminTask_" . StrReplace(A_ScriptName, " ", "_")
        try {
            ; Attempt to run the pre-created Task
            Run('schtasks /run /tn "' taskName '"', , "Hide")
            ExitApp()
        } catch {
            ; Fallback: Standard UAC prompt if task is missing
            try {
                Run('*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"')
                ExitApp()
            } catch {
                MsgBox("Failed to elevate process.")
                return false
            }
        }
    }

    /**
     * Prepares the Admin process to receive messages from non-admin processes.
     */
    static InitializeServer(Callback) {
        if !A_IsAdmin
            return false
        
        this.OnMessageReceived := Callback
        
        ; Allow WM_COPYDATA through the UAC filter
        DllCall("user32\ChangeWindowMessageFilterEx", 
                "Ptr", A_ScriptHwnd, 
                "UInt", this.WM_COPYDATA, 
                "UInt", this.MSGFLT_ALLOW, 
                "Ptr", 0)
        
        OnMessage(this.WM_COPYDATA, ObjBindMethod(this, "HandleIncoming"))
    }

    /**
     * Sends a string to a target window (bidirectional)
     */
    static Send(TargetHwnd, DataString) {
        if !TargetHwnd
            return false

        ; Format data for WM_COPYDATA
        size := (StrLen(DataString) + 1) * 2
        cds := Buffer(A_PtrSize * 3, 0)
        NumPut("Ptr", 0, "Ptr", size, "Ptr", StrPtr(DataString), cds)
        
        return SendMessage(this.WM_COPYDATA, A_ScriptHwnd, cds, , "ahk_id " TargetHwnd)
    }

    static HandleIncoming(wParam, lParam, msg, hwnd) {
        if (msg = this.WM_COPYDATA) {
            lpData := NumGet(lParam, A_PtrSize * 2, "Ptr")
            receivedText := StrGet(lpData)
            this.OnMessageReceived(receivedText, wParam) ; wParam is the Sender's HWND
            return true
        }
    }
}