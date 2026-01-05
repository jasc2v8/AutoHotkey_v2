; TITLE  :  MyScript v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

#Requires AutoHotkey v2.0+
#SingleInstance Force

#Include <RunAsAdmin>
Persistent

#Include <LogFile>

global ClientSocket := 0

logger:=LogFile("D:\server.log", "SERVER")

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

    ; --- Create GUI ---
    MyGui := Gui("+AlwaysOnTop", "AHK v2 HTTP Server")
    MyGui.SetFont("s9", "Consolas")
    LogCtrl := MyGui.Add("Edit", "r15 w500 ReadOnly vLog")
    Status := MyGui.Add("Text", "w500", "Status: Starting...")
    MyGui.OnEvent("Close", (*) => ExitApp())
    MyGui.Show()
    MyGui.Move(100, 100)

    ; --- ASYNC CONFIGURATION ---
    WM_USER := 0x0400
    global ID_ASYNC := WM_USER + 1
    global FD_ACCEPT := 1
    global FD_READ := 2
    global FD_CLOSE := 32
    Global WM_SOCKET := 0x8000 + 1

    ; Start Listening
    if DllCall("Ws2_32\listen", "UPtr", ListenSocket, "Int", 5) {
        MsgBox "Listen failed."
        ExitApp()
    }

    TrayTip "Listening for connection on port " Port "..."
    Sleep 1500
    TrayTip

    logger.Write("Listening...")

    ; Register the ListenSocket for the ACCEPT event
    ;OnMessage(ID_ASYNC, ReceiveMessage)
    ;DllCall("Ws2_32\WSAAsyncSelect", "UPtr", ListenSocket, "Ptr", A_ScriptHwnd, "UInt", ID_ASYNC, "Int", FD_ACCEPT)

    OnMessage(WM_SOCKET, ReceiveMessage)
    DllCall("Ws2_32\WSAAsyncSelect", "UPtr", ListenSocket, "Ptr", MyGui.Hwnd, "UInt", WM_SOCKET, "Int", 1 | 2 | 32)

    Status.Value := "Status: Listening on http://localhost:" Port
    UpdateGui("Server started...")

    ; 2. Set the timer (calls 'UpdateEdit' every 1000ms)
    SetTimer(UpdateEdit, 1000)

    UpdateEdit() {
        Status.Value := "Current Time: " . A_Hour . ":" . A_Min . ":" . A_Sec
    }

return

    ReceiveMessage(wParam, lParam, msg, hwnd) {
        local Event := lParam & 0xFFFF
        local Error := lParam >> 16
        local Socket := wParam

        logger.Write("ReceiveMessage...")

        if (Error) {
            DllCall("Ws2_32\closesocket", "UPtr", Socket)
            return
        }

        if (Event == FD_ACCEPT) {

            ; 1. Accept the new client
            ClientSocket := DllCall("Ws2_32\accept", "UPtr", Socket, "Ptr", 0, "Int", 0, "UPtr")
            
            ; 2. IMPORTANT: Register this NEW socket for READ and CLOSE events
            ; Without this line, the script will never trigger the READ event below.
            DllCall("Ws2_32\WSAAsyncSelect", "UPtr", ClientSocket, "Ptr", A_ScriptHwnd, "UInt", ID_ASYNC, "Int", FD_READ | FD_CLOSE)
            
            logger.Write("New client connected!")

        } 
        
        else if (Event == FD_READ) {

            ; 2. RECEIVE DATA
            RecvBuf := Buffer(4096, 0)
            BytesReceived := DllCall("Ws2_32\recv", "UPtr", ClientSocket, "Ptr", RecvBuf, "Int", 4096, "Int", 0)
            
            ReceivedText := ""
            if (BytesReceived > 0) {
                ReceivedText := StrGet(RecvBuf, BytesReceived, "UTF-8")
                ;MsgBox "Received " BytesReceived " bytes:`n`n" ReceivedText, "Data Received"
                logger.Write("GET: " ReceivedText)
            }

            ; --- ROUTING ---
                    
            ; 1. Handle Favicon Request
            if InStr(ReceivedText, "GET /favicon.ico") {
                IconPath := "favicon.ico" ; Make sure this file exists in the script folder
                
                if FileExist(IconPath) {
                    FileData := FileRead(IconPath, "RAW")
                    FileLen := FileData.Size
                    
                    ; Send Binary Headers
                    Header := "HTTP/1.1 200 OK`r`nContent-Type: image/x-icon`r`nContent-Length: " FileLen "`r`nConnection: close`r`n`r`n"
                    HeaderBuf := Buffer(StrPut(Header, "UTF-8") - 1)
                    StrPut(Header, HeaderBuf, "UTF-8")
                    DllCall("Ws2_32\send", "UPtr", ClientSocket, "Ptr", HeaderBuf, "Int", HeaderBuf.Size, "Int", 0)
                    DllCall("Ws2_32\send", "UPtr", ClientSocket, "Ptr", FileData, "Int", FileLen, "Int", 0)

                } else {
                    ; Send 404 if file missing
                    Response := "HTTP/1.1 404 Not Found`r`nContent-Length: 0`r`nConnection: close`r`n`r`n"
                    ResponseBuf := Buffer(StrPut(Response, "UTF-8") - 1)
                    StrPut(Response, ResponseBuf, "UTF-8")
                    DllCall("Ws2_32\send", "UPtr", ClientSocket, "Ptr", ResponseBuf, "Int", ResponseBuf.Size, "Int", 0)
                }
            } else if InStr(ReceivedText, "GET /exit") {
                text := "Server EXIT!"
                len := StrLen(text)
                Response := "HTTP/1.1 200 OK`r`nContent-Type: text/plain`r`nContent-Length: " len "`r`n`r`n" text
                ; Convert string to UTF-8 buffer for sending
                ResponseBuf := Buffer(StrPut(Response, "UTF-8"), 0)
                StrPut(Response, ResponseBuf, "UTF-8")
                DllCall("Ws2_32\send", "UPtr", ClientSocket, "Ptr", ResponseBuf, "Int", ResponseBuf.Size - 1, "Int", 0)
                Sleep 500
                ExitApp()

            } else if InStr(ReceivedText, "GET ") {
                ; If it looks like a browser request (HTTP), we send a 200 OK header
                ;Response := "HTTP/1.1 200 OK`r`nContent-Type: text/plain`r`nContent-Length: 15`r`n`r`nHello from AHK!"

                ; 1. Define your HTML content
                htmlBody := "
                (
                <html><body style='font-family: sans-serif; background: #f0f0f0; text-align: center;'>
                <h1 style='color: red;'>Hello from AHK!</h1>
                <p>This is a <strong>real</strong> HTML page served by your script.</p>
                <button onclick='alert("AutoHotkey Rocks!")'>Click Me</button>
                <button onclick="showMessage()">Click me</button>
                <br><br>
                <a href='/exit'><button style='background: red; color: white; padding: 10px;'>Shutdown Server</button></a>
                <script>
                    function showMessage() {
                    alert("Hello, Jim! Your button works.");
                    }
                    // Add a live clock
                    const clockElement = document.createElement('div');
                    clockElement.id = 'clock';setInterval(() => {
                        document.getElementById('clock').innerText = new Date().toLocaleTimeString();
                    }, 1000);
                </script>
                <br><br>
                <div id="clock"></div>
                </body></html>
                )"

                ; 2. Calculate length (using StrPut to get actual byte count for UTF-8)
                bodyLength := StrPut(htmlBody, "UTF-8") - 1

                ; 3. Build the full response
                Response := "HTTP/1.1 200 OK`r`n"
                Response .= "Content-Type: text/html; charset=UTF-8`r`n"
                Response .= "Content-Length: " . bodyLength . "`r`n"
                Response .= "Connection: close`r`n"
                Response .= "`r`n" ; The mandatory double newline
                Response .= htmlBody

                ; Convert string to UTF-8 buffer for sending
                ResponseBuf := Buffer(StrPut(Response, "UTF-8"), 0)
                StrPut(Response, ResponseBuf, "UTF-8")
                DllCall("Ws2_32\send", "UPtr", ClientSocket, "Ptr", ResponseBuf, "Int", ResponseBuf.Size - 1, "Int", 0)

            }
            ; 3. CLOSE THE CLIENT SOCKET
            ; Crucial: You must close the specific client connection so the 
            ; ListenSocket can continue accepting new ones properly.
            DllCall("Ws2_32\closesocket", "UPtr", ClientSocket)

        }
        
        else if (Event == FD_CLOSE) {
            DllCall("Ws2_32\closesocket", "UPtr", Socket)
            TrayTip "Client disconnected."
        }
    }


; Loop {
;     ; 1. ACCEPT CONNECTION
;     ; This pauses here until someone connects
;     ClientSocket := DllCall("Ws2_32\accept", "UPtr", ListenSocket, "Ptr", 0, "Int", 0, "UPtr")
    
;     if (ClientSocket == -1 || ClientSocket == 0) {
;         Sleep(10) ; Small sleep to prevent CPU spiking if there's a constant error
;         continue
;     }

;     ;TrayTip "Connection received! Reading data..."
    
;     ; 2. RECEIVE DATA
;     RecvBuf := Buffer(4096, 0)
;     BytesReceived := DllCall("Ws2_32\recv", "UPtr", ClientSocket, "Ptr", RecvBuf, "Int", 4096, "Int", 0)
    
;     ReceivedText := ""
;     if (BytesReceived > 0) {
;         ReceivedText := StrGet(RecvBuf, BytesReceived, "UTF-8")
;         ;MsgBox "Received " BytesReceived " bytes:`n`n" ReceivedText, "Data Received"
;         logger.Write("GET: " ReceivedText)
;     }

; ; --- ROUTING ---
            
;         ; 1. Handle Favicon Request
;         if InStr(ReceivedText, "GET /favicon.ico") {
;             IconPath := "favicon.ico" ; Make sure this file exists in the script folder
            
;             if FileExist(IconPath) {
;                 FileData := FileRead(IconPath, "RAW")
;                 FileLen := FileData.Size
                
;                 ; Send Binary Headers
;                 Header := "HTTP/1.1 200 OK`r`nContent-Type: image/x-icon`r`nContent-Length: " FileLen "`r`nConnection: close`r`n`r`n"
;                 HeaderBuf := Buffer(StrPut(Header, "UTF-8") - 1)
;                 StrPut(Header, HeaderBuf, "UTF-8")
;                 DllCall("Ws2_32\send", "UPtr", ClientSocket, "Ptr", HeaderBuf, "Int", HeaderBuf.Size, "Int", 0)
;                 DllCall("Ws2_32\send", "UPtr", ClientSocket, "Ptr", FileData, "Int", FileLen, "Int", 0)

;             } else {
;                 ; Send 404 if file missing
;                 Response := "HTTP/1.1 404 Not Found`r`nContent-Length: 0`r`nConnection: close`r`n`r`n"
;                 ResponseBuf := Buffer(StrPut(Response, "UTF-8") - 1)
;                 StrPut(Response, ResponseBuf, "UTF-8")
;                 DllCall("Ws2_32\send", "UPtr", ClientSocket, "Ptr", ResponseBuf, "Int", ResponseBuf.Size, "Int", 0)
;             }
;         } else if InStr(ReceivedText, "GET /exit") {
;             text := "Server EXIT!"
;             len := StrLen(text)
;             Response := "HTTP/1.1 200 OK`r`nContent-Type: text/plain`r`nContent-Length: " len "`r`n`r`n" text
;             ; Convert string to UTF-8 buffer for sending
;             ResponseBuf := Buffer(StrPut(Response, "UTF-8"), 0)
;             StrPut(Response, ResponseBuf, "UTF-8")
;             DllCall("Ws2_32\send", "UPtr", ClientSocket, "Ptr", ResponseBuf, "Int", ResponseBuf.Size - 1, "Int", 0)
;             Sleep 500
;             ExitApp()

;         } else if InStr(ReceivedText, "GET ") {
;             ; If it looks like a browser request (HTTP), we send a 200 OK header
;             ;Response := "HTTP/1.1 200 OK`r`nContent-Type: text/plain`r`nContent-Length: 15`r`n`r`nHello from AHK!"

;             ; 1. Define your HTML content
;             htmlBody := "
;             (
;             <html><body style='font-family: sans-serif; background: #f0f0f0; text-align: center;'>
;             <h1 style='color: red;'>Hello from AHK!</h1>
;             <p>This is a <strong>real</strong> HTML page served by your script.</p>
;             <button onclick='alert("AutoHotkey Rocks!")'>Click Me</button>
;             <button onclick="showMessage()">Click me</button>
;             <br><br>
;             <a href='/exit'><button style='background: red; color: white; padding: 10px;'>Shutdown Server</button></a>
;             <script>
;                 function showMessage() {
;                 alert("Hello, Jim! Your button works.");
;                 }
;                 // Add a live clock
;                 const clockElement = document.createElement('div');
;                 clockElement.id = 'clock';setInterval(() => {
;                     document.getElementById('clock').innerText = new Date().toLocaleTimeString();
;                 }, 1000);
;             </script>
;             <br><br>
;             <div id="clock"></div>
;             </body></html>
;             )"

;             ; 2. Calculate length (using StrPut to get actual byte count for UTF-8)
;             bodyLength := StrPut(htmlBody, "UTF-8") - 1

;             ; 3. Build the full response
;             Response := "HTTP/1.1 200 OK`r`n"
;             Response .= "Content-Type: text/html; charset=UTF-8`r`n"
;             Response .= "Content-Length: " . bodyLength . "`r`n"
;             Response .= "Connection: close`r`n"
;             Response .= "`r`n" ; The mandatory double newline
;             Response .= htmlBody

;             ; Convert string to UTF-8 buffer for sending
;             ResponseBuf := Buffer(StrPut(Response, "UTF-8"), 0)
;             StrPut(Response, ResponseBuf, "UTF-8")
;             DllCall("Ws2_32\send", "UPtr", ClientSocket, "Ptr", ResponseBuf, "Int", ResponseBuf.Size - 1, "Int", 0)

;         }
;         ; 3. CLOSE THE CLIENT SOCKET
;         ; Crucial: You must close the specific client connection so the 
;         ; ListenSocket can continue accepting new ones properly.
;         DllCall("Ws2_32\closesocket", "UPtr", ClientSocket)

; }    

;ExitApp()
UpdateGui(Text) {
    LogCtrl.Value .= "[" A_Hour ":" A_Min ":" A_Sec "] " Text "`r`n"
    SendMessage(0x0115, 7, 0, LogCtrl.Hwnd, "User32.dll") ; Scroll to bottom
}

; Cleanup on Exit
OnExit((*) => (
    logger.Write("Cleanup...")
    DllCall("Ws2_32\closesocket", "UPtr", ClientSocket)
    DllCall("Ws2_32\WSACleanup")
))