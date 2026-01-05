; TITLE:    Receiver for IPC v1.0
; SOURCE:   Gemini and jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
;#NoTrayIcon

#Include <RunAsAdmin>

Persistent

SECRET_KEY := 998877  ; 64-bit numeric password Must match sender

TrayTip "Receiver Listening...", "Receiver"

; 1. Define constants
WM_COPYDATA := 0x004A
MSGFLT_ALLOW := 1

; 2. Create the hidden window to receive data
TargetTitle := "MyReceiverScript"
MyGui := Gui(, TargetTitle)
MyGui.Show("Hide") ; The window must exist for the filter to apply to it

; 3. CRITICAL: Bypass UIPI (User Interface Privilege Isolation)
; This allows a non-admin Sender to talk to this Admin Receiver
try {
    DllCall("User32.dll\ChangeWindowMessageFilterEx", 
            "Ptr", MyGui.Hwnd, 
            "UInt", WM_COPYDATA, 
            "UInt", MSGFLT_ALLOW, 
            "Ptr", 0)
} catch {
    MsgBox "Failed to set message filter. Sending may fail if scripts have different integrity levels."
}

; 4. Listen for the message
OnMessage(WM_COPYDATA, ReceiveData)

ReceiveData(wParam, lParam, msg, hwnd) {

    ; Check the Secret Key stored in dwData (first member of the struct)
    IncomingKey := NumGet(lParam, 0, "Ptr")
    
    if (IncomingKey != SECRET_KEY) {
        ; Potential unauthorized attempt
        return 0 ; Fail/Reject
    }

    cbData := NumGet(lParam, A_PtrSize, "UInt")
    lpData := NumGet(lParam, A_PtrSize * 2, "Ptr")
    
    if (lpData != 0) {
        ReceivedStr := StrGet(lpData, cbData / 2, "UTF-16")
        ; ToolTip("Received: " ReceivedStr)
        ; SetTimer () => ToolTip(), -3000 ; Clear tooltip after 3s
        
        MsgBox("Received: " ReceivedStr, "Receiver", "IconI")

        if (ReceivedStr = "TERMINATE")
            ExitApp

        return true
    }
}