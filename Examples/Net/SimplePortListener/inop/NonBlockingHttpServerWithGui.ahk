#Requires AutoHotkey v2.0
#SingleInstance Force

; --- Configuration ---
Global Port := 5800
Global WM_SOCKET := 0x8000 + 1

; --- Create GUI ---
MyGui := Gui("+AlwaysOnTop", "AHK v2 HTTP Server")
MyGui.SetFont("s9", "Consolas")
LogCtrl := MyGui.Add("Edit", "r15 w500 ReadOnly vLog")
Status := MyGui.Add("Text", "w500", "Status: Starting...")
MyGui.OnEvent("Close", (*) => ExitApp())
MyGui.Show()

; --- Initialize Winsock ---
WSADATA := Buffer(394, 0)
if DllCall("Ws2_32\WSAStartup", "UShort", 0x0202, "Ptr", WSADATA) {
    UpdateLog("WSAStartup failed.")
    return
}

ListenSocket := DllCall("Ws2_32\socket", "Int", 2, "Int", 1, "Int", 6, "UPtr")

sockaddr := Buffer(16, 0)
NumPut("UShort", 2, sockaddr, 0)
NumPut("UShort", DllCall("Ws2_32\htons", "UShort", Port, "UShort"), sockaddr, 2)

if DllCall("Ws2_32\bind", "UPtr", ListenSocket, "Ptr", sockaddr, "Int", 16) {
    UpdateLog("Bind failed. Is port " Port " in use?")
    return
}

; Start listening
DllCall("Ws2_32\listen", "UPtr", ListenSocket, "Int", 5)

; Register for Async Messages
OnMessage(WM_SOCKET, ReceiveMsg)
;DllCall("Ws2_32\WSAAsyncSelect", "UPtr", ListenSocket, "Ptr", MyGui.Hwnd, "UInt", WM_SOCKET, "Int", 1 | 2 | 32)
DllCall("Ws2_32\WSAAsyncSelect", "UPtr", ListenSocket, "Ptr", A_ScriptHwnd, "UInt", WM_SOCKET, "Int", 1 | 2 | 32)

Status.Value := "Status: Listening on http://localhost:" Port
UpdateLog("Server started...")

; --- Functions ---

ReceiveMsg(wParam, lParam, msg, hwnd) {
    Socket := wParam
    Event  := lParam & 0xFFFF
    
    if (Event = 1) { ; FD_ACCEPT
        ClientSocket := DllCall("Ws2_32\accept", "UPtr", Socket, "Ptr", 0, "Int", 0, "UPtr")
        DllCall("Ws2_32\WSAAsyncSelect", "UPtr", ClientSocket, "Ptr", MyGui.Hwnd, "UInt", WM_SOCKET, "Int", 2 | 32)
    }
    
    else if (Event = 2) { ; FD_READ
        RecvBuf := Buffer(8192, 0)
        BytesReceived := DllCall("Ws2_32\recv", "UPtr", Socket, "Ptr", RecvBuf, "Int", 8192, "Int", 0)
        
        if (BytesReceived > 0) {
            Request := StrGet(RecvBuf, BytesReceived, "UTF-8")
            
            ; Extract the first line of the request (e.g., GET / HTTP/1.1)
            RequestLine := StrSplit(Request, "`r`n")[1]
            UpdateLog("INCOMING: " RequestLine)
            
            ; Prepare simple HTML response
            Html := "<html><body style='font-family:sans-serif;'><h1>AHK v2 Server</h1><p>Logged: " A_Now "</p></body></html>"
            Response := "HTTP/1.1 200 OK`r`nContent-Type: text/html`r`nContent-Length: " 
                      . StrLen(Html) . "`r`nConnection: close`r`n`r`n" . Html
            
            ResponseBuf := Buffer(StrPut(Response, "UTF-8"))
            StrPut(Response, ResponseBuf, "UTF-8")
            DllCall("Ws2_32\send", "UPtr", Socket, "Ptr", ResponseBuf, "Int", ResponseBuf.Size - 1, "Int", 0)
            
            DllCall("Ws2_32\closesocket", "UPtr", Socket)
        }
    }
}

UpdateLog(Text) {
    LogCtrl.Value .= "[" A_Hour ":" A_Min ":" A_Sec "] " Text "`r`n"
    SendMessage(0x0115, 7, 0, LogCtrl.Hwnd, "User32.dll") ; Scroll to bottom
}

OnExit((*) => (
    DllCall("Ws2_32\closesocket", "UPtr", ListenSocket),
    DllCall("Ws2_32\WSACleanup")
))