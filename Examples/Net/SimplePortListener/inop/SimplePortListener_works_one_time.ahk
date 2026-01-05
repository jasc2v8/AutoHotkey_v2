; TITLE  :  MyScript v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

#Requires AutoHotkey v2.0+
#SingleInstance Force
; #INclude <RunAsAdmin>

    inputObj := InputBox("Enter Port: ", "New Socket Every Loop",,"5800")

    If inputObj.Result = 'Cancel'
        ExitApp()
    else
        Port := inputObj.Value

    ; --- SETTINGS ---

    ; Initialize Winsock
    WSADATA := Buffer(394, 0)
    if DllCall("Ws2_32\WSAStartup", "UShort", 0x0202, "Ptr", WSADATA) {
        MsgBox "WSAStartup failed."
        ExitApp()
    }

    ; Create Socket
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

    ; Start Listening
    if DllCall("Ws2_32\listen", "UPtr", ListenSocket, "Int", 5) {
        MsgBox "Listen failed."
        ExitApp()
    }

    TrayTip "Listening for connection on port " Port "..."
    Sleep 1500
    TrayTip

Loop {

    ; --- ACCEPT CONNECTION ---
    ; This script will pause here until a connection is made
    ClientSocket := DllCall("Ws2_32\accept", "UPtr", ListenSocket, "Ptr", 0, "Int", 0, "UPtr")
    
    if (ClientSocket != -1) {
        TrayTip "Connection received! Reading data..."
        
        ; --- RECEIVE DATA ---
        RecvBuf := Buffer(4096, 0) ; Create a 4KB buffer
        BytesReceived := DllCall("Ws2_32\recv", "UPtr", ClientSocket, "Ptr", RecvBuf, "Int", 4096, "Int", 0)
        
        if (BytesReceived > 0) {
            ReceivedText := StrGet(RecvBuf, BytesReceived, "UTF-8")
            MsgBox "Received " BytesReceived " bytes:`n`n" ReceivedText, "Data Received"
        } else {
            MsgBox "Connection closed or error receiving data."
        }

        if (InStr(ReceivedText,"GET /exit"))
            break
        
    }
}    

ExitApp()

; Cleanup on Exit
OnExit((*) => (
        DllCall("Ws2_32\closesocket", "UPtr", ClientSocket)
    DllCall("Ws2_32\WSACleanup")
))