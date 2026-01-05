; TITLE:    IPCBridgeClient v1.0
; SOURCE:   Gemini, Copilot, chageGPT, and jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
;#NoTrayIcon

#Include IPCBridge.ahk

global SECRET_KEY := 998877 ; 64-bit numeric password Must match receiver

global WM_COPYDATA := 0x4A

DetectHiddenWindows true 

; 1. Find or start server
 hwnd := WinExist("MySecretAdminServer")
; if !hwnd {
;     ; Run('schtasks /run /tn "AdminTask_Server"', , "Hide")
;     ; if !hwnd := WinWait("MySecretAdminServer", , 5)
;     MsgBox "Server failed to start."
;         ExitApp()
; }

IPCBridge.Listen("Client", hwnd, SECRET_KEY, OnMessageReceived)
;hwnd:= IPCBridge.Listen("Client", 0, SECRET_KEY, OnMessageReceived)

if !hwnd {
    MsgBox "Server failed to start."
        ExitApp()
}

OnMessageReceived(text, hwnd) {

    MsgBox("Received:`n`n" text, "Client")
    
}

r:= IPCBridge.Send(hwnd, "Do some work!")

if (r>0)
    MsgBox "Result: " r , "Client send #1"

IPCBridge.Send(hwnd, "IPC_EXIT")

if (r>0)
    MsgBox "Result: " r , "Client send #2"

; OnMessage(WM_COPYDATA, ReceiveData)

; ReceiveData(wParam, lParam, msg, hwnd) {

;     ; Check the Secret Key stored in dwData (first member of the struct)
;     IncomingKey := NumGet(lParam, 0, "Ptr")
    
;     ; if (IncomingKey != SECRET_KEY) {
;     ;     ; Potential unauthorized attempt
;     ;     return 0 ; Fail/Reject
;     ; }

;     cbData := NumGet(lParam, A_PtrSize, "UInt")
;     lpData := NumGet(lParam, A_PtrSize * 2, "Ptr")
    
;     if (lpData != 0) {
;         ReceivedStr := StrGet(lpData, cbData / 2, "UTF-16")
        
;         MsgBox("Received from Server:`n`n" ReceivedStr, "Client")

;         if (ReceivedStr = "TERMINATE")
;             ExitApp

;         return true
;     }
; }
; ; 2. Setup listener for the reply
; ;IPCBridge.Listen("MyClientResponseWindow", (reply, *) => MsgBox("Server replied: " reply))

; ;IPCBridge.Listen("MySecretAdminServer", OnServerMessage)
; ;IPCBridge.Listen(hwnd, OnServerMessage)

; ;OnServerMessage(text, clientHwnd) {

; ;    MsgBox("Received from Server:`n`n" text, "Client")
    
; ;}

; ; 3. Send message and wait for the reply logic to trigger
; ;r:= IPCBridge.Send("MySecretAdminServer", "Hello from User!")
; r:= IPCBridge.Send(hwnd, "Hello from User!")

; result := r << 32 >> 32

; if (result>0)
;     MsgBox "Result: " result , "Client send #1"

; r:= IPCBridge.Send(hwnd, "IPC_EXIT")

; result := r << 32 >> 32

; if (result>0)
;     MsgBox "Result: " result , "Client send #3"

; ; Keep client alive for 2 seconds to catch the reply, then close
;SetTimer(() => ExitApp(), -1000)