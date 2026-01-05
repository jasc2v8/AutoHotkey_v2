; ABOUT:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Requires AutoHotkey v2.0

DetectHiddenWindows true

; Find the target script's window by title/class
;targetHwnd := WinExist("ahk_class AutoHotkey") ; adjust if multiple scripts
;targetHwnd := WinExist("SendMessageDemo") ; adjust if multiple scripts
;targetHwnd := WinExist("ahk_id " myPID) ; adjust if multiple scripts

;HWND := WinGetID("SendMessageDemo")
;targetHwnd := WinExist("ahk_id " HWND) ; adjust if multiple scripts

;PID := WinGetPID("SendMessageDemo")
;targetHwnd := WinExist("ahk_pid " PID) ; adjust if multiple scripts

;MsgBox PID

PID:= 0x5870
targetHwnd := WinExist("ahk_pid " PID) ; adjust if multiple scripts

WM_COPYDATA := 0x4A


SendTextToScript(targetHwnd, "Hello from sender!")

SendTextToScript(hWnd, text) {
    ; Prepare COPYDATASTRUCT
    strBuf := Buffer(StrPut(text, "UTF-16"))
    StrPut(text, strBuf, "UTF-16")

    cds := Buffer(A_PtrSize*3, 0)
    NumPut("uptr", 1, cds, 0)                  ; dwData (custom ID)
    NumPut("uptr", strBuf.Size, cds, A_PtrSize) ; cbData (bytes)
    NumPut("ptr", strBuf.Ptr, cds, A_PtrSize*2) ; lpData (pointer)

    ; Send WM_COPYDATA
    DllCall("SendMessageW"
        , "ptr", hWnd
        , "uint", WM_COPYDATA
        , "ptr", 0
        , "ptr", cds.Ptr)
}