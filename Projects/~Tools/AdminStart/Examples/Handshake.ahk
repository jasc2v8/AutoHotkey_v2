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

; Listen for the "Ready" signal from the worker
OnMessage(0x5555, WorkerIsReady)

try {
    ; Pass Launcher HWND so Worker knows where to send the "Ready" signal
    Run('*RunAs "' A_AhkPath '" "' TargetScript '" "' TaskToRun '" "' A_ScriptHwnd '"')
} catch {
    MsgBox("Failed to elevate.")
}

WorkerIsReady(wParam, lParam, msg, hwnd) {
    ; wParam contains the Worker's HWND
    WorkerHwnd := wParam
    
    ; Now that we know the worker is ready, send the data
    SendData(A_ScriptFullPath, WorkerHwnd)
}

SendData(StringToSend, TargetHwnd) {
    CopyDataStruct := Buffer(3 * A_PtrSize)
    SizeInBytes := (StrLen(StringToSend) + 1) * 2
    
    NumPut("Ptr", 0, "Ptr", SizeInBytes, "Ptr", StrPtr(StringToSend), CopyDataStruct)
    
    SendMessage(0x004A, A_ScriptHwnd, CopyDataStruct,, "ahk_id " TargetHwnd)
}


; --- MyWorkerScript.ahk ---
#SingleInstance Force

if (A_Args.Length < 2)
{
    return
}

Task := A_Args[1]
LauncherHwnd := A_Args[2]

; 1. Setup listeners
OnMessage(0x004A, ReceiveData)

; 2. Tell Launcher we are ready to receive data
; We send our own HWND as wParam
PostMessage(0x5555, A_ScriptHwnd, 0,, "ahk_id " LauncherHwnd)

ReceiveData(wParam, lParam, msg, hwnd) {
    pString := NumGet(lParam, 2 * A_PtrSize, "Ptr")
    ReceivedText := StrGet(pString)
    
    MsgBox("Elevated Worker received data:`n" . ReceivedText)
    return true
}

; Keep script alive
Persistent()
