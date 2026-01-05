
; ==============================================================================
; SIMPLE HTTP SERVER CLASS
; ==============================================================================

Class SimpleHttpServer {
    __New(Port := 8080, WebRoot := "www") {
        this.Port := Port
        ; Ensure WebRoot is absolute
        Loop Files, WebRoot, "D"
            this.WebRoot := A_LoopFileFullPath

        Callback := ObjBindMethod(this, "OnSocketEvent")
        
        Result := AHKsock_Listen(Port, Callback)
        
        if (Result)
            throw Error("AHKsock_Listen failed with code: " Result)
    }

    OnSocketEvent(sEvent, iSocket, *) {
        switch sEvent {
            case "ACCEPTED":
                ; Handled inside AHKsock_OnMessage to capture IP
            case "RECEIVED":
                ; Check data size
                arg := 0
                DllCall("Ws2_32\ioctlsocket", "Ptr", iSocket, "Int", 0x4004667E, "UInt*", &arg) ; FIONREAD
                
                if (arg > 0) {
                    buf := Buffer(arg)
                    received := DllCall("Ws2_32\recv", "Ptr", iSocket, "Ptr", buf, "Int", arg, "Int", 0)
                    if (received > 0) {
                        RawRequest := StrGet(buf, received, "UTF-8")
                        this.ProcessRequest(iSocket, RawRequest)
                    }
                }
            case "DISCONNECTED":
                ServerLog("Client Disconnected (Socket " iSocket ")")
        }
    }

    ProcessRequest(iSocket, RawData) {
        ; Basic Parsing
        Lines := StrSplit(RawData, "`r`n")
        if (Lines.Length < 1)
            return
        
        ReqLine := StrSplit(Lines[1], " ")
        if (ReqLine.Length < 2)
            return
        
        Method := ReqLine[1]
        URLPath := ReqLine[2]

        ServerLog(Method " -> " URLPath)

        ; Route to File System
        FileName := StrReplace(URLPath, "/", "\")
        if (FileName == "\") FileName := "\index.html"
        FullPath := this.WebRoot . FileName

        ; Security Check & File Send
        if FileExist(FullPath) && !InStr(FullPath, "..") {
            this.ServeFile(iSocket, FullPath)
        } else {
            ServerLog("404 Error: " URLPath)
            this.SendResponse(iSocket, 404, "Not Found", "<h1>404 File Not Found</h1>")
        }
    }

    ServeFile(iSocket, FullPath) {
        try {
            FileBuf := FileRead(FullPath, "raw")
            
            ; Determine Mime
            SplitPath(FullPath, , , &Ext)
            Mime := (Ext = "js")  ? "application/javascript" :
                    (Ext = "css") ? "text/css" :
                    (Ext = "png") ? "image/png" : "text/html"

            Header := "HTTP/1.1 200 OK`r`n"
                    . "Content-Type: " Mime "`r`n"
                    . "Content-Length: " FileBuf.Size "`r`n"
                    . "Connection: close`r`n`r`n"
            
            HBuf := Buffer(StrPut(Header, "UTF-8") - 1)
            StrPut(Header, HBuf, "UTF-8")
            
            AHKsock_Send(iSocket, HBuf.Ptr, HBuf.Size)
            AHKsock_Send(iSocket, FileBuf.Ptr, FileBuf.Size)
        }
        AHKsock_Close(iSocket)
    }

    SendResponse(iSocket, Code, Status, Body) {
        Header := "HTTP/1.1 " Code " " Status "`r`n"
                . "Content-Type: text/html; charset=UTF-8`r`n"
                . "Content-Length: " . (StrPut(Body, "UTF-8") - 1) . "`r`n"
                . "Connection: close`r`n`r`n"
                . Body
        
        Buf := Buffer(StrPut(Header, "UTF-8") - 1)
        StrPut(Header, Buf, "UTF-8")
        AHKsock_Send(iSocket, Buf.Ptr, Buf.Size)
        AHKsock_Close(iSocket)
    }
}

; ==============================================================================
; AHKSOCK GLOBAL STORAGE & UTILITIES
; ==============================================================================

Class AHKsock_Global {
    Static Sockets := Map()
    static IsStarted := False
    static MessageID := 0x8000

    Static GetConnectionList() {
        Output := "List of Connected Clients:`n"
        Output .= "---------------------------`n"
        for skt, info in this.Sockets {
            if info.HasProp("Addr")
                Output .= "IP: " info.Addr " | Socket: " skt "`n"
        }
        return Output
    }
}

GetRemoteAddr(skt) {
    sockaddr := Buffer(16, 0)
    len := 16
    if !DllCall("Ws2_32\getpeername", "Ptr", skt, "Ptr", sockaddr, "Int*", &len) {
        pAddr := DllCall("Ws2_32\inet_ntoa", "UInt", NumGet(sockaddr, 4, "UInt"), "AStr")
        return pAddr
    }
    return "0.0.0.0"
}
