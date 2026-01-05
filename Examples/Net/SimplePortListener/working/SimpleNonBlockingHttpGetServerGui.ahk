; Copilot "ahk v2 example simple http non-blocking server with get and reply"

#Requires AutoHotkey v2.0+
#Include <RunAsAdmin>

Persistent

; -------------------- CONFIG --------------------
PORT := 8080
WM_SOCKET := 0x0400 + 1
FD_ACCEPT := 0x08
FD_READ   := 0x01
FD_CLOSE  := 0x20
; ------------------------------------------------

OnExit(Shutdown)
OnMessage(WM_SOCKET, SocketProc)

    ; --- Create GUI ---
    MyGui := Gui("+AlwaysOnTop", "AHK v2 HTTP Server")
    MyGui.SetFont("s9", "Consolas")
    LogCtrl := MyGui.Add("Edit", "r15 w500 ReadOnly vLog")
    Status := MyGui.Add("Text", "w500", "Status: Starting...")
    MyGui.OnEvent("Close", (*) => ExitApp())
    MyGui.Show()
    MyGui.Move(100, 100)


; WinSock startup
WSA := Buffer(32, 0)
DllCall("Ws2_32\WSAStartup", "UShort", 0x0202, "Ptr", WSA)

; Create socket
ListenSock := DllCall("Ws2_32\socket", "Int", 2, "Int", 1, "Int", 6)
addr := Buffer(16, 0)
NumPut("UShort", 2, addr)
NumPut("UShort", DllCall("Ws2_32\htons", "UShort", PORT), addr, 2)
NumPut("UInt", 0, addr, 4)

DllCall("Ws2_32\bind", "Ptr", ListenSock, "Ptr", addr, "Int", 16)
DllCall("Ws2_32\listen", "Ptr", ListenSock, "Int", 5)

; Async notification
DllCall("Ws2_32\WSAAsyncSelect"
    , "Ptr", ListenSock
    , "Ptr", MyGui.Hwnd ; A_ScriptHwnd
    , "UInt", WM_SOCKET
    , "UInt", FD_ACCEPT)

text := "Listening on http://127.0.0.1:" PORT
TrayTip "HTTP Server", text
UpdateGui(Text) 

return

; ================= SOCKET HANDLER =================
SocketProc(wParam, lParam, *) {
    global ListenSock, WM_SOCKET, FD_ACCEPT, FD_READ, FD_CLOSE

    event := lParam & 0xFFFF
    sock  := wParam

    if (event = FD_ACCEPT) {
        client := DllCall("Ws2_32\accept", "Ptr", sock, "Ptr", 0, "Ptr", 0)
        DllCall("Ws2_32\WSAAsyncSelect"
            , "Ptr", client
            , "Ptr", A_ScriptHwnd
            , "UInt", WM_SOCKET
            , "UInt", FD_READ | FD_CLOSE)
    }

    else if (event = FD_READ) {
        buf := Buffer(4096, 0)
        len := DllCall("Ws2_32\recv", "Ptr", sock, "Ptr", buf, "Int", 4096, "Int", 0)
        if (len <= 0)
            return

        req := StrGet(buf, len, "UTF-8")

        UpdateGui("Request: " req) 
    
        ; ---- Simple GET parsing ----
        if RegExMatch(req, "^GET\s+([^\s]+)", &m) {
            path := m[1]
        } else {
            path := "/"
        }

        body := "Hello from AutoHotkey v2!`nPath: " path

        resp :=
            "HTTP/1.1 200 OK`r`n" .
            "Content-Type: text/plain`r`n" .
            "Content-Length: " StrLen(body) "`r`n" .
            "Connection: close`r`n`r`n" .
            body

        DllCall("Ws2_32\send", "Ptr", sock, "AStr", resp, "Int", StrLen(resp), "Int", 0)
        DllCall("Ws2_32\closesocket", "Ptr", sock)
    }

    else if (event = FD_CLOSE) {
        DllCall("Ws2_32\closesocket", "Ptr", sock)
    }
}

UpdateGui(Text) {
    LogCtrl.Value .= "[" A_Hour ":" A_Min ":" A_Sec "] " Text "`r`n"
    SendMessage(0x0115, 7, 0, LogCtrl.Hwnd, "User32.dll") ; Scroll to bottom
}

Shutdown(*) {
    global ListenSock
    DllCall("Ws2_32\closesocket", "Ptr", ListenSock)
    DllCall("Ws2_32\WSACleanup")
}
