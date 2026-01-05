; TITLE  :  MyScript v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force

; Keep the script running to listen for connections
Persistent()

; ==============================================================================
; SIMPLE HTTP SERVER CLASS
; ==============================================================================

Class SimpleHttpServer {
    __New(Port := 8080, WebRoot := "www") {
        this.Port := Port
        this.WebRoot := WebRoot
        
        ; Resolve absolute path
        Loop Files, WebRoot, "D"
            this.WebRoot := A_LoopFileFullPath

        ; Bind events to this instance
        Callback := ObjBindMethod(this, "OnSocketEvent")
        
        Result := AHKsock_Listen(Port, Callback)
        if (Result)
            throw Error("AHKsock Error: " Result)
    }

    OnSocketEvent(sEvent, iSocket, *) {
        ; We only need RECEIVED for basic HTTP parsing
        if (sEvent == "RECEIVED") {
            ; Check if there is data to read
            arg := 0
            DllCall("Ws2_32\ioctlsocket", "Ptr", iSocket, "Int", 0x4004667E, "UInt*", &arg) ; FIONREAD
            
            if (arg > 0) {
                buf := Buffer(arg)
                received := DllCall("Ws2_32\recv", "Ptr", iSocket, "Ptr", buf, "Int", arg, "Int", 0)
                if (received > 0) {
                    RawData := StrGet(buf, received, "UTF-8")
                    this.ProcessRequest(iSocket, RawData)
                }
            }
        }
    }

    ProcessRequest(iSocket, RawData) {
        Sections := StrSplit(RawData, "`r`n`r`n", , 2)
        HeaderPart := Sections[1]
        
        Lines := StrSplit(HeaderPart, "`r`n")
        if (Lines.Length < 1) return
        
        ReqLine := StrSplit(Lines[1], " ")
        if (ReqLine.Length < 2) return
        
        Method := ReqLine[1]
        URLPath := ReqLine[2]

        ; Simple Routing
        FileName := StrReplace(URLPath, "/", "\")
        if (FileName == "\") FileName := "\index.html"
        
        FullPath := this.WebRoot . FileName

        if FileExist(FullPath) && !InStr(FullPath, "..") {
            this.ServeFile(iSocket, FullPath)
        } else {
            this.SendResponse(iSocket, 404, "Not Found", "<h1>404</h1><p>File not found.</p>")
        }
    }

    ServeFile(iSocket, FullPath) {
        SplitPath(FullPath, , , &Ext)
        Mime := (Ext = "js")  ? "application/javascript" :
                (Ext = "css") ? "text/css" :
                (Ext = "png") ? "image/png" : "text/html"

        try {
            FileBuf := FileRead(FullPath, "raw")
            
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
; AHKsock CORE (v2 CONVERTED)
; ==============================================================================

Class AHKsock_Global {
    Static Sockets := Map()
    Static IsStarted := False
    Static MessageID := 0x8000
}

AHKsock_Startup() {
    if AHKsock_Global.IsStarted
        return 0
    WSAData := Buffer(A_PtrSize == 8 ? 408 : 392, 0)
    if !DllCall("Ws2_32\WSAStartup", "UShort", 0x0202, "Ptr", WSAData, "Int") {
        AHKsock_Global.IsStarted := True
        OnMessage(AHKsock_Global.MessageID, AHKsock_OnMessage)
        return 0
    }
    return 1
}

AHKsock_Listen(sPort, sFunction) {
    if AHKsock_Startup()
        return 3
    
    aiHints := Buffer(16 + 4 * A_PtrSize, 0)
    NumPut("Int", 1, aiHints, 0), NumPut("Int", 2, aiHints, 4)
    NumPut("Int", 1, aiHints, 8), NumPut("Int", 6, aiHints, 12)
    
    aiResult := 0
    if DllCall("Ws2_32\getaddrinfo", "Ptr", 0, "Str", String(sPort), "Ptr", aiHints, "Ptr*", &aiResult)
        return 5

    skt := DllCall("Ws2_32\socket", "Int", 2, "Int", 1, "Int", 6, "Ptr")
    if (skt == -1) return 6

    if DllCall("Ws2_32\bind", "Ptr", skt, "Ptr", NumGet(aiResult, 16 + 2 * A_PtrSize, "Ptr"), "Int", NumGet(aiResult, 16, "Int"))
        return 7
    
    DllCall("Ws2_32\freeaddrinfo", "Ptr", aiResult)
    DllCall("Ws2_32\WSAAsyncSelect", "Ptr", skt, "Ptr", A_ScriptHwnd, "UInt", AHKsock_Global.MessageID, "Int", 8)
    DllCall("Ws2_32\listen", "Ptr", skt, "Int", 32)

    AHKsock_Global.Sockets[skt] := {Func: sFunction}
    return 0
}

AHKsock_Send(iSocket, pData, iLength) {
    return DllCall("Ws2_32\send", "Ptr", iSocket, "Ptr", pData, "Int", iLength, "Int", 0, "Int")
}

AHKsock_Close(iSocket) {
    DllCall("Ws2_32\closesocket", "Ptr", iSocket)
    if AHKsock_Global.Sockets.Has(iSocket)
        AHKsock_Global.Sockets.Delete(iSocket)
}

AHKsock_OnMessage(wParam, lParam, *) {
    Critical("On")
    iSocket := wParam, iEvent := lParam & 0xFFFF
    if !AHKsock_Global.Sockets.Has(iSocket)
        return

    SocketObj := AHKsock_Global.Sockets[iSocket]
    
    if (iEvent == 8) { ; FD_ACCEPT
        newSkt := DllCall("Ws2_32\accept", "Ptr", iSocket, "Ptr", 0, "Ptr", 0, "Ptr")
        if (newSkt != -1) {
            AHKsock_Global.Sockets[newSkt] := {Func: SocketObj.Func}
            DllCall("Ws2_32\WSAAsyncSelect", "Ptr", newSkt, "Ptr", A_ScriptHwnd, "UInt", AHKsock_Global.MessageID, "Int", 1 | 32)
            SocketObj.Func.Call("ACCEPTED", newSkt)
        }
    } else if (iEvent == 1) { ; FD_READ
        SocketObj.Func.Call("RECEIVED", iSocket)
    } else if (iEvent == 32) { ; FD_CLOSE
        SocketObj.Func.Call("DISCONNECTED", iSocket)
        AHKsock_Close(iSocket)
    }
}
