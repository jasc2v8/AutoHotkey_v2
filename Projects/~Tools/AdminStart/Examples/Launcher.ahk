
; launcher AND worker scripts

; --- Launcher Script ---
#SingleInstance Force

global IL_Large := 0
global IL_Small := 0

TargetScript := "MyWorkerScript.ahk"
TaskToRun := "ProcessUpdates"

; 1. Run the worker script
try {
    Run('*RunAs "' A_AhkPath '" "' TargetScript '" "' TaskToRun '"')
} catch {
    MsgBox("Failed to elevate.")
    return
}

; Give the worker a moment to initialize its message monitor
Sleep(500)

; 2. Find the worker window and send the string
if (targetHwnd := WinExist(TargetScript " - AutoHotkey"))
{
    SendData(A_ScriptFullPath, targetHwnd)
}

SendData(StringToSend, TargetHwnd) {
    CopyDataStruct := Buffer(3 * A_PtrSize)
    SizeInBytes := (StrLen(StringToSend) + 1) * 2
    
    NumPut("Ptr", 0, "Ptr", SizeInBytes, "Ptr", StrPtr(StringToSend), CopyDataStruct)
    
    SendMessage(0x004A, A_ScriptHwnd, CopyDataStruct,, "ahk_id " TargetHwnd) ; 0x004A is WM_COPYDATA
}


; --- MyWorkerScript.ahk ---
#SingleInstance Force

; Monitor for incoming data strings
OnMessage(0x004A, ReceiveData) 

ReceiveData(wParam, lParam, msg, hwnd) {
    ; lParam points to the CopyDataStruct
    pString := NumGet(lParam, 2 * A_PtrSize, "Ptr")
    ReceivedText := StrGet(pString)
    
    MsgBox("Worker received this path from Launcher:`n" . ReceivedText)
    return true
}

; Keep script alive to receive messages
Persistent()
