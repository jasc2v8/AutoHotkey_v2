;;TITLE  :  Responsive Gui v1.0.0.1
; SOURCE :  jasc2v8 and Gemini
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

;;TODO: Fix something

#Requires AutoHotkey v2+
#SingleInstance Force
#NoTrayIcon

#Requires AutoHotkey v2.0
; Version 1.0.2

MyGui := Gui("-AlwaysOnTop", "Worker Example")
MyGui.SetFont("s10", "Segoe UI")
MyStatus := MyGui.Add("Text", "w200", "Idle...")
MyProgress := MyGui.Add("Progress", "w200 h20 Range0-100", 0)

StartBtn := MyGui.Add("Button", "w80 Default", "Start")
StartBtn.OnEvent("Click", StartProcess)

CancelBtn := MyGui.Add("Button", "x+10 w80", "Cancel")
CancelBtn.OnEvent("Click", CancelProcess)
CancelBtn.Enabled := false

MyGui.Show()

; --- Global Variables ---
IsRunning := false
CurrentIteration := 0
MaxIterations := 100

StartProcess(*) {
    global IsRunning, CurrentIteration
    
    if (IsRunning)
        return
        
    IsRunning := true
    CurrentIteration := 0
    StartBtn.Enabled := false
    CancelBtn.Enabled := true
    MyStatus.Value := "Running..."
    
    ; Change cursor to busy
    ToggleWaitCursor(true)
    
    SetTimer(Worker, 10)
}

Worker() {
    global IsRunning, CurrentIteration, MaxIterations
    
    if (!IsRunning) {
        SetTimer(, 0)
        return
    }

    CurrentIteration++
    MyProgress.Value := (CurrentIteration / MaxIterations) * 100
    MyStatus.Value := "Processing step " . CurrentIteration . "..."
    
    if (CurrentIteration >= MaxIterations) {
        FinishProcess("Complete!")
    }
}

CancelProcess(*) {
    FinishProcess("Cancelled by user.")
}

FinishProcess(Msg) {
    global IsRunning
    IsRunning := false
    SetTimer(Worker, 0)
    
    ; Restore normal cursor
    ToggleWaitCursor(false)
    
    StartBtn.Enabled := true
    CancelBtn.Enabled := false
    MyStatus.Value := Msg
    MsgBox(Msg, "Task Finished", "Iconi")
}

/**
 * Toggles the system cursor between Busy (IDC_WAIT) and Default.
 * @param {Boolean} On - Pass true to show wait cursor, false to restore.
 */
ToggleWaitCursor(On := true) {
    if (On) {
        ; IDC_WAIT = 32514
        hCursor := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32514, "Ptr")
        ; Set the system arrow (32512) to the wait cursor
        DllCall("SetSystemCursor", "Ptr", hCursor, "UInt", 32512)
    } else {
        ; Restore all system cursors to defaults
        DllCall("SystemParametersInfo", "UInt", 0x57, "UInt", 0, "Ptr", 0, "UInt", 0)
    }
}

MyGui.OnEvent("Close", (*) => (ToggleWaitCursor(false), ExitApp()))
