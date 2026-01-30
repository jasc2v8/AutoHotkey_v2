;;TITLE  :  MyScript v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

;;TODO: Fix something

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

; --- Launcher Script ---
#SingleInstance Force

global IL_Large := 0
global IL_Small := 0

TargetScript := "MyWorkerScript.ahk"
TaskToRun := "ProcessUpdates"

; Listen for the "Ready" signal
OnMessage(0x5555, WorkerIsReady)

try {
    Run('*RunAs "' A_AhkPath '" "' TargetScript '" "' TaskToRun '" "' A_ScriptHwnd '"')
    
    ; Start a 5-second timeout timer
    SetTimer(HandleTimeout, -5000) 
} catch {
    MsgBox("The script elevation was aborted or failed.")
}

WorkerIsReady(wParam, lParam, msg, hwnd) {
    ; Disable the timeout timer because the worker responded
    SetTimer(HandleTimeout, 0)
    
    WorkerHwnd := wParam
    SendData(A_ScriptFullPath, WorkerHwnd)
}

HandleTimeout() {
    MsgBox("Error: The worker script failed to signal readiness within 5 seconds.", "Timeout", 16)
}

SendData(StringToSend, TargetHwnd) {
    CopyDataStruct := Buffer(3 * A_PtrSize)
    SizeInBytes := (StrLen(StringToSend) + 1) * 2
    
    NumPut("Ptr", 0, "Ptr", SizeInBytes, "Ptr", StrPtr(StringToSend), CopyDataStruct)
    
    SendMessage(0x004A, A_ScriptHwnd, CopyDataStruct,, "ahk_id " TargetHwnd)
}
