; TITLE:    AhkRunSkipUAC v1.0
; SOURCE:   jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
;#NoTrayIcon

TargetScriptTitle := "MyReceiverScript"

DataToSend := "Hello from the Sender Script!"

Send_WM_COPYDATA(TargetScriptTitle, DataToSend)

Send_WM_COPYDATA(TargetScriptTitle, "TERMINATE")

Send_WM_COPYDATA(TargetTitle, StringToSend) {

    DetectHiddenWindows true

    ; 1. Find the target window
    hw_target := WinExist(TargetTitle)
    if !hw_target {
        MsgBox("Receiver not found.")
        return
    }

    ; 2. Prepare the data
    ; We need a buffer for the string (UTF-16 uses 2 bytes per char + null terminator)
    cbData := (StrLen(StringToSend) + 1) * 2
    
    ; 3. Create the COPYDATASTRUCT
    ; Size is 3 * A_PtrSize (dwData, cbData, lpData)
    cds := Buffer(A_PtrSize * 3, 0)
    
    ; Offset 0: dwData (optional identifier, e.g., 123)
    NumPut("Ptr", 123, cds, 0)
    ; Offset A_PtrSize: cbData (size in bytes)
    NumPut("UInt", cbData, cds, A_PtrSize)
    ; Offset A_PtrSize*2: lpData (pointer to string)
    NumPut("Ptr", StrPtr(StringToSend), cds, A_PtrSize * 2)

    ; 4. Send the message
    ; WM_COPYDATA = 0x004A
    timeoutMS:=1000 ; wait indefinitely

    try {
        ;SendMessage(0x004A, A_ScriptHwnd, cds.Ptr, , "ahk_id " hw_target,,,,timeoutMS)
        SendMessage(0x004A, A_ScriptHwnd, cds.Ptr, , "ahk_id " hw_target)
    } catch any as e {
        if (e.Message != 'Timeout')
            MsgBox ("e: " e.Message)
    }

}