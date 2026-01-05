#Requires AutoHotkey v2.0+
#SingleInstance Force
;#Include <RunAsAdmin>

Persistent

; --- INITIALIZATION ---
global ClientSocket := 0
global ListenSocket := 0

inputObj := InputBox("Enter Port: ", "Async Server", , "5800")
if inputObj.Result = 'Cancel'
    ExitApp()
Port := inputObj.Value

; Initialize Winsock
WSADATA := Buffer(394, 0)
if DllCall("Ws2_32\WSAStartup", "UShort", 0x0202, "Ptr", WSADATA) {
    MsgBox "WSAStartup failed."
    ExitApp()
}

; Create Listening Socket
ListenSocket := DllCall("Ws2_32\socket", "Int", 2, "Int", 1, "Int", 6, "UPtr")
if (ListenSocket = -1) {
    MsgBox "Socket creation failed."
    ExitApp()
}

; Bind Socket
sockaddr := Buffer(16, 0)
NumPut("UShort", 2, sockaddr, 0) 
NumPut("UShort", DllCall("Ws2_32\htons", "UShort", Port, "UShort"), sockaddr, 2) 

if DllCall("Ws2_32\bind", "UPtr", ListenSocket, "Ptr", sockaddr, "Int", 16) {
    MsgBox "Bind failed. Is port " Port " already in use?"
    DllCall("Ws2_32\closesocket", "UPtr", ListenSocket)
    ExitApp()
}

; --- ASYNC CONFIGURATION ---
WM_USER := 0x0400
global ID_ASYNC := WM_USER + 1
global FD_ACCEPT := 1
global FD_READ := 2
global FD_CLOSE := 32

; Register the ListenSocket for the ACCEPT event
OnMessage(ID_ASYNC, ReceiveNotification)
DllCall("Ws2_32\WSAAsyncSelect", "UPtr", ListenSocket, "Ptr", A_ScriptHwnd, "UInt", ID_ASYNC, "Int", FD_ACCEPT)

; Start Listening
if DllCall("Ws2_32\listen", "UPtr", ListenSocket, "Int", 5) {
    MsgBox "Listen failed."
    ExitApp()
}

TrayTip "Listening on port " Port "..."

; --- THE CALLBACK FUNCTION ---
ReceiveNotification(wParam, lParam, msg, hwnd) {
    local Event := lParam & 0xFFFF
    local Error := lParam >> 16
    local Socket := wParam

    if (Error) {
        DllCall("Ws2_32\closesocket", "UPtr", Socket)
        return
    }

    if (Event == FD_ACCEPT) {
        ; 1. Accept the new client
        NewClient := DllCall("Ws2_32\accept", "UPtr", Socket, "Ptr", 0, "Int", 0, "UPtr")
        
        ; 2. IMPORTANT: Register this NEW socket for READ and CLOSE events
        ; Without this line, the script will never trigger the READ event below.
        DllCall("Ws2_32\WSAAsyncSelect", "UPtr", NewClient, "Ptr", A_ScriptHwnd, "UInt", ID_ASYNC, "Int", FD_READ | FD_CLOSE)
        
        TrayTip "New client connected!"
    }
    
    else if (Event == FD_READ) {
        RecvBuf := Buffer(4096, 0)
        Bytes := DllCall("Ws2_32\recv", "UPtr", Socket, "Ptr", RecvBuf, "Int", 4096, "Int", 0)
        
        if (Bytes > 0) {
            ReceivedText := StrGet(RecvBuf, Bytes, "UTF-8")
            
            ; ToolTip is less intrusive than MsgBox for rapid testing
            ToolTip "Received: " ReceivedText
            SetTimer () => ToolTip(), -3000 
            
            if InStr(ReceivedText, "GET /exit")
                ExitApp()
        }
    }
    
    else if (Event == FD_CLOSE) {
        DllCall("Ws2_32\closesocket", "UPtr", Socket)
        TrayTip "Client disconnected."
    }
}

; Cleanup on Exit
OnExit(Cleanup)
Cleanup(*) {
    Persistent false
    if (ListenSocket)
        DllCall("Ws2_32\closesocket", "UPtr", ListenSocket)
    DllCall("Ws2_32\WSACleanup")
}