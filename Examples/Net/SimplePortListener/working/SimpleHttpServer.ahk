#Requires AutoHotkey v2.0+
#SingleInstance Force

; Initialize Winsock
WSADATA := Buffer(394, 0)
if DllCall("Ws2_32\WSAStartup", "UShort", 0x0202, "Ptr", WSADATA) {
    MsgBox "WSAStartup failed."
    ExitApp
}

Port := 5800
ListenSocket := DllCall("Ws2_32\socket", "Int", 2, "Int", 1, "Int", 6, "UPtr")

; Bind and Listen
sockaddr := Buffer(16, 0)
NumPut("UShort", 2, sockaddr, 0)
NumPut("UShort", DllCall("Ws2_32\htons", "UShort", Port, "UShort"), sockaddr, 2)
DllCall("Ws2_32\bind", "UPtr", ListenSocket, "Ptr", sockaddr, "Int", 16)
DllCall("Ws2_32\listen", "UPtr", ListenSocket, "Int", 5)

MsgBox "Server started on port " Port ". Press OK to begin waiting for a request."

count:= 1

Loop {
    ; 1. Wait for connection
    ClientSocket := DllCall("Ws2_32\accept", "UPtr", ListenSocket, "Ptr", 0, "Int", 0, "UPtr")
    if (ClientSocket = -1 || ClientSocket = 0xFFFFFFFF)
        continue

    ; 2. Receive the Request
    RecvBuf := Buffer(4096, 0)
    BytesReceived := DllCall("Ws2_32\recv", "UPtr", ClientSocket, "Ptr", RecvBuf, "Int", 4096, "Int", 0)
    
    if (BytesReceived > 0) {
        RequestText := StrGet(RecvBuf, BytesReceived, "UTF-8")
        
        ; 3. Prepare the HTTP Response
        ; The browser needs the "HTTP/1.1 200 OK" header and a blank line before the body
        HtmlBody := "<html><body><h1>AHK v2 Server</h1><p>Received your request!</p></body></html>"
        Response := "HTTP/1.1 200 OK`r`n"
                  . "Content-Type: text/html`r`n"
                  . "Content-Length: " . StrLen(HtmlBody) . "`r`n"
                  . "Connection: close`r`n"
                  . "`r`n" ; Crucial blank line
                  . HtmlBody

        ; 4. Send the Response
        ResponseBuf := Buffer(StrPut(Response, "UTF-8"))
        StrPut(Response, ResponseBuf, "UTF-8")
        DllCall("Ws2_32\send", "UPtr", ClientSocket, "Ptr", ResponseBuf, "Int", ResponseBuf.Size - 1, "Int", 0)
        
        TrayTip "Handled request at " A_Now ", count: " count++
        Sleep 1500
        TrayTip
    }

    ; 5. Close client connection
    DllCall("Ws2_32\closesocket", "UPtr", ClientSocket)
}

; Cleanup
OnExit((*) => (
    DllCall("Ws2_32\closesocket", "UPtr", ListenSocket),
    DllCall("Ws2_32\WSACleanup")
))