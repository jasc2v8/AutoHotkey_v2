#Requires AutoHotkey v2.0
#SingleInstance Force

#Include <LogFile>

logger:=LogFile("D:\HttpServer.log")

; --- Configuration ---
Global Port := 5800
Global WM_SOCKET := 0x8000 + 1 ; Custom Windows Message

; --- Initialize Winsock ---
WSADATA := Buffer(394, 0)
DllCall("Ws2_32\WSAStartup", "UShort", 0x0202, "Ptr", WSADATA)

; Create Listening Socket
Global ListenSocket := DllCall("Ws2_32\socket", "Int", 2, "Int", 1, "Int", 6, "UPtr")

; Bind to Port
sockaddr := Buffer(16, 0)
NumPut("UShort", 2, sockaddr, 0)
NumPut("UShort", DllCall("Ws2_32\htons", "UShort", Port, "UShort"), sockaddr, 2)
DllCall("Ws2_32\bind", "UPtr", ListenSocket, "Ptr", sockaddr, "Int", 16)
DllCall("Ws2_32\listen", "UPtr", ListenSocket, "Int", 5)

; --- The "Magic" Bit: Register for Asynchronous Events ---
; FD_ACCEPT (1) = Notify when someone connects
; FD_READ (2)   = Notify when data arrives
; FD_CLOSE (32) = Notify when connection closes
OnMessage(WM_SOCKET, ReceiveMsg)
DllCall("Ws2_32\WSAAsyncSelect", "UPtr", ListenSocket, "Ptr", A_ScriptHwnd, "UInt", WM_SOCKET, "Int", 1 | 2 | 32)

MsgBox "Server is running in the background on port " Port ".`n`nYour script is still responsive!"

; --- Event Handler ---
ReceiveMsg(wParam, lParam, msg, hwnd) {
    Critical ; Prevent message overlap
    
    Socket := wParam
    Event  := lParam & 0xFFFF
    ErrorCode := lParam >> 16
    
    if (ErrorCode)
        return

    if (Event = 1) { ; FD_ACCEPT
        ClientSocket := DllCall("Ws2_32\accept", "UPtr", Socket, "Ptr", 0, "Int", 0, "UPtr")
        ; Register the NEW client socket for Read/Close events
        DllCall("Ws2_32\WSAAsyncSelect", "UPtr", ClientSocket, "Ptr", A_ScriptHwnd, "UInt", WM_SOCKET, "Int", 2 | 32)
    }
    
    else if (Event = 2) { ; FD_READ
        RecvBuf := Buffer(8192, 0)
        BytesReceived := DllCall("Ws2_32\recv", "UPtr", Socket, "Ptr", RecvBuf, "Int", 8192, "Int", 0)
        
        if (BytesReceived > 0) {
            Request := StrGet(RecvBuf, BytesReceived, "UTF-8")
            
            logger.Write("INCOMING: " Request)
            
            ; Simple Response Logic
            Html := "<html><body><h1>Async Server</h1><p>Time: " A_Now "</p></body></html>"
            Response := "HTTP/1.1 200 OK`r`nContent-Type: text/html`r`nContent-Length: " 
                      . StrLen(Html) . "`r`nConnection: close`r`n`r`n" . Html
            
            ResponseBuf := Buffer(StrPut(Response, "UTF-8"))
            StrPut(Response, ResponseBuf, "UTF-8")
            DllCall("Ws2_32\send", "UPtr", Socket, "Ptr", ResponseBuf, "Int", ResponseBuf.Size - 1, "Int", 0)
            
            ; Gracefully close after sending
            DllCall("Ws2_32\closesocket", "UPtr", Socket)
        }
    }
}

; --- Cleanup ---
OnExit((*) => (
    DllCall("Ws2_32\closesocket", "UPtr", ListenSocket),
    DllCall("Ws2_32\WSACleanup")
))

; Testing Hotkey to prove script isn't frozen
^j::MsgBox "See? I can still run hotkeys while the server waits!"