; TITLE:    Sender for IPC v1.0
; SOURCE:   Gemini and jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
;#NoTrayIcon

DetectHiddenWindows true

SECRET_KEY := 998877 ; 64-bit numeric password Must match receiver
TargetTitle := "MyReceiverScript"
Data := "Hello with AHK Timeout!"

try {
    ; SendMessage(Msg, wParam, lParam, Control, WinTitle, WinText, ExcludeTitle, ExcludeText, Timeout)
    ; Timeout is in Milliseconds
    Response := Send_WM_COPYDATA(TargetTitle, Data, SECRET_KEY, TimeoutMS := 2000)
    
    if (Response = 1)
        MsgBox("Success: Receiver acknowledged.")
    else
        MsgBox("Receiver received it but returned: " Response)

    Send_WM_COPYDATA(TargetTitle, "TERMINATE", SECRET_KEY, 0)

} catch TargetError {
    MsgBox("Check failed: Target window not found.")
} catch OSError as err {
    if (err.number = 0 || err.ExtraInfo = "Timeout") ; Handling timeout specifically
        MsgBox("Message failed: The receiver timed out.")
    else
        MsgBox("OS Error: " err.Message)
}

Send_WM_COPYDATA(TargetTitle, StringToSend, Key, TimeoutMS := 1000) {
    
    hw_target := WinExist(TargetTitle)

    if !hw_target
        throw TargetError("Target window not found", -1)

    ; Prepare Buffer
    cbData := (StrLen(StringToSend) + 1) * 2
    cds := Buffer(A_PtrSize * 3, 0)
    NumPut("Ptr", Key, cds, 0)
    NumPut("UInt", cbData, cds, A_PtrSize)
    NumPut("Ptr", StrPtr(StringToSend), cds, A_PtrSize * 2)

   ; The 9th parameter is the Timeout in ms
    static WM_COPYDATA := 0x004A
    return SendMessage(WM_COPYDATA, A_ScriptHwnd, cds.Ptr, , "ahk_id " hw_target, , , , TimeoutMS)
}