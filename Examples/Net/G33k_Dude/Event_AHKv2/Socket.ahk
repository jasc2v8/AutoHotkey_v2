; TITLE  :  MyScript v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

/*
    TODO:
*/

#Requires AutoHotkey v2.0

class Socket
{
    static WM_SOCKET := 0x9987, MSG_PEEK := 2
    static FD_READ := 1, FD_ACCEPT := 8, FD_CLOSE := 32
    static Blocking := True, BlockSleep := 50
    
    Socket := -1
    Bound := False
    ProtocolId := 0
    SocketType := 0

    __New(Socket := -1)
    {
        static Init := False
        if (!Init)
        {
            DllCall("LoadLibrary", "Str", "Ws2_32", "Ptr")
            WSAData := Buffer(394 + A_PtrSize)
            if (Err := DllCall("Ws2_32\WSAStartup", "UShort", 0x0202, "Ptr", WSAData))
                throw Error("Error starting Winsock", , Err)
            if (NumGet(WSAData, 2, "UShort") != 0x0202)
                throw Error("Winsock version 2.2 not available")
            Init := True
        }
        this.Socket := Socket
    }
    
    __Delete()
    {
        if (this.Socket != -1)
            this.Disconnect()
    }
    
    Connect(Address)
    {
        if (this.Socket != -1)
            throw Error("Socket already connected")
        
        pAddrInfo := this.GetAddrInfo(Address)
        Next := pAddrInfo
        
        while Next
        {
            ai_addrlen := NumGet(Next, 16, "UPtr")
            ai_addr    := NumGet(Next, 16 + (2 * A_PtrSize), "Ptr")
            
            this.Socket := DllCall("Ws2_32\socket", "Int", NumGet(Next, 4, "Int")
                , "Int", this.SocketType, "Int", this.ProtocolId, "UInt")
            
            if (this.Socket != -1)
            {
                if (DllCall("Ws2_32\WSAConnect", "UInt", this.Socket, "Ptr", ai_addr
                    , "UInt", ai_addrlen, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Int") == 0)
                {
                    DllCall("Ws2_32\freeaddrinfo", "Ptr", pAddrInfo)
                    return this.EventProcRegister(Socket.FD_READ | Socket.FD_CLOSE)
                }
                this.Disconnect()
            }
            Next := NumGet(Next, 16 + (3 * A_PtrSize), "Ptr")
        }
        throw Error("Error connecting")
    }
    
    Bind(Address)
    {
        if (this.Socket != -1)
            throw Error("Socket already connected")
            
        pAddrInfo := this.GetAddrInfo(Address)
        Next := pAddrInfo
        
        while Next
        {
            ai_addrlen := NumGet(Next, 16, "UPtr")
            ai_addr    := NumGet(Next, 16 + (2 * A_PtrSize), "Ptr")
            
            this.Socket := DllCall("Ws2_32\socket", "Int", NumGet(Next, 4, "Int")
                , "Int", this.SocketType, "Int", this.ProtocolId, "UInt")
            
            if (this.Socket != -1)
            {
                if (DllCall("Ws2_32\bind", "UInt", this.Socket, "Ptr", ai_addr
                    , "UInt", ai_addrlen, "Int") == 0)
                {
                    DllCall("Ws2_32\freeaddrinfo", "Ptr", pAddrInfo)
                    return this.EventProcRegister(Socket.FD_READ | Socket.FD_ACCEPT | Socket.FD_CLOSE)
                }
                this.Disconnect()
            }
            Next := NumGet(Next, 16 + (3 * A_PtrSize), "Ptr")
        }
        throw Error("Error binding")
    }
    
    Listen(backlog := 32)
    {
        return DllCall("Ws2_32\listen", "UInt", this.Socket, "Int", backlog) == 0
    }
    
    Accept()
    {
        if ((s := DllCall("Ws2_32\accept", "UInt", this.Socket, "Ptr", 0, "Ptr", 0, "Ptr")) == -1)
            throw Error("Error calling accept", , this.GetLastError())
            
        Sock := Socket(s)
        Sock.ProtocolId := this.ProtocolId
        Sock.SocketType := this.SocketType
        Sock.EventProcRegister(Socket.FD_READ | Socket.FD_CLOSE)
        return Sock
    }
    
    Disconnect()
    {
        if (this.Socket == -1)
            return 0
        
        this.EventProcUnregister()
        if (DllCall("Ws2_32\closesocket", "UInt", this.Socket, "Int") == -1)
            throw Error("Error closing socket", , this.GetLastError())
        this.Socket := -1
        return 1
    }
    
    MsgSize()
    {
        static FIONREAD := 0x4004667F
        argp := 0
        if (DllCall("Ws2_32\ioctlsocket", "UInt", this.Socket, "UInt", FIONREAD, "UInt*", &argp) == -1)
            throw Error("Error calling ioctlsocket", , this.GetLastError())
        return argp
    }
    
    Send(pBuffer, BufSize, Flags := 0)
    {
        if ((r := DllCall("Ws2_32\send", "UInt", this.Socket, "Ptr", pBuffer, "Int", BufSize, "Int", Flags)) == -1)
            throw Error("Error calling send", , this.GetLastError())
        return r
    }
    
    SendText(Text, Flags := 0, Encoding := "UTF-8")
    {
        BufSize := StrPut(Text, Encoding)
        Buf := Buffer(BufSize)
        StrPut(Text, Buf, Encoding)
        return this.Send(Buf, BufSize - (Encoding = "UTF-16" || Encoding = "cp1200" ? 2 : 1))
    }
    
    Recv(&BufferObj, BufSize := 0, Flags := 0)
    {
        while (!(Length := this.MsgSize()) && Socket.Blocking)
            Sleep(Socket.BlockSleep)
        
        if !Length
            return 0
        if !BufSize
            BufSize := Length
            
        BufferObj := Buffer(BufSize)
        if ((r := DllCall("Ws2_32\recv", "UInt", this.Socket, "Ptr", BufferObj, "Int", BufSize, "Int", Flags)) == -1)
            throw Error("Error calling recv", , this.GetLastError())
        return r
    }
    
    RecvText(BufSize := 0, Flags := 0, Encoding := "UTF-8")
    {
        if (Length := this.Recv(&Buf, BufSize, Flags))
            return StrGet(Buf, Length, Encoding)
        return ""
    }
    
    RecvLine(BufSize := 0, Flags := 0, Encoding := "UTF-8", KeepEnd := False)
    {
        while !(i := InStr(this.RecvText(BufSize, Flags | Socket.MSG_PEEK, Encoding), "`n"))
        {
            if !Socket.Blocking
                return ""
            Sleep(Socket.BlockSleep)
        }
        if KeepEnd
            return this.RecvText(i, Flags, Encoding)
        else
            return RTrim(this.RecvText(i, Flags, Encoding), "`r`n")
    }
    
    GetAddrInfo(Address)
    {
        Host := Address[1], Port := Address[2]
        Hints := Buffer(16 + (4 * A_PtrSize), 0)
        NumPut("Int", this.SocketType, Hints, 8)
        NumPut("Int", this.ProtocolId, Hints, 12)
        Result := 0
        if (Err := DllCall("Ws2_32\GetAddrInfoW", "Str", Host, "Str", Port, "Ptr", Hints, "Ptr*", &Result))
            throw Error("Error calling GetAddrInfo", , Err)
        return Result
    }
    
    ; --- CORRECTED MESSAGE HANDLER ---
    OnMessage(wParam, lParam, Msg, hWnd)
    {
        Critical()
        if (Msg != Socket.WM_SOCKET || wParam != this.Socket)
            return
        
        if (lParam & Socket.FD_READ)
            this.OnRecv.Call(this)
        else if (lParam & Socket.FD_ACCEPT)
            this.OnAccept.Call(this)
        else if (lParam & Socket.FD_CLOSE)
        {
            this.EventProcUnregister()
            this.OnDisconnect.Call(this)
        }
    }
    
    ; Placeholder methods (properly defined for v2)
    ; OnRecv() => ""
    ; OnAccept() => ""
    ; OnDisconnect() => ""

    OnRecv := Any
    OnAccept := Any
    OnDisconnect := Any

    EventProcRegister(lEvent)
    {
        this.AsyncSelect(lEvent)
        if !this.Bound
        {
            this.Bound := this.OnMessage.Bind(this)
            OnMessage(Socket.WM_SOCKET, this.Bound)
        }
    }
    
    EventProcUnregister()
    {
        this.AsyncSelect(0)
        if this.Bound
        {
            OnMessage(Socket.WM_SOCKET, this.Bound, 0)
            this.Bound := False
        }
    }
    
    AsyncSelect(lEvent)
    {
        if (DllCall("Ws2_32\WSAAsyncSelect"
            , "UInt", this.Socket
            , "Ptr", A_ScriptHwnd
            , "UInt", Socket.WM_SOCKET
            , "UInt", lEvent) == -1)
            throw Error("Error calling WSAAsyncSelect", , this.GetLastError())
    }
    
    GetLastError()
    {
        return DllCall("Ws2_32\WSAGetLastError")
    }
}

class SocketTCP extends Socket
{
    ProtocolId := 6 ; IPPROTO_TCP
    SocketType := 1 ; SOCK_STREAM
}

class SocketUDP extends Socket
{
    ProtocolId := 17 ; IPPROTO_UDP
    SocketType := 2  ; SOCK_DGRAM
    
    SetBroadcast(Enable)
    {
        static SOL_SOCKET := 0xFFFF, SO_BROADCAST := 0x20
        EnableVal := Integer(!!Enable)
        if (DllCall("Ws2_32\setsockopt"
            , "UInt", this.Socket
            , "Int", SOL_SOCKET
            , "Int", SO_BROADCAST
            , "UInt*", &EnableVal
            , "Int", 4) == -1)
            throw Error("Error calling setsockopt", , this.GetLastError())
    }
}