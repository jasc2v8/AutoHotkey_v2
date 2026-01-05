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
    
    Port := 0
    ListenSocket := -1
    ClientSocket := -1
    Bound := False
    ProtocolId := 0
    SocketType := 0

    __New(Port := 8080)
    {
        this.Port := Port
        
        ; Initialize Winsock
        WSAData := Buffer(394 + A_PtrSize)
        if (Err := DllCall("Ws2_32\WSAStartup", "UShort", 0x0202, "Ptr", WSAData))
            throw Error("Error starting Winsock", , Err)
        if (NumGet(WSAData, 2, "UShort") != 0x0202)
            throw Error("Winsock version 2.2 not available")

        ; Create Socket: 2=IPv4, 1=SOCK_STREAM, 6=IPPROTO_TCP
        ListenSocket := DllCall("Ws2_32\socket", "Int", 2, "Int", 1, "Int", 6, "UPtr")
        if (ListenSocket = -1)
            Throw Error("Socket creation failed.")

        ; Bind Socket
        sockaddr := Buffer(16, 0)
        NumPut("UShort", 2, sockaddr, 0) 
        NumPut("UShort", DllCall("Ws2_32\htons", "UShort", Port, "UShort"), sockaddr, 2) 

        if DllCall("Ws2_32\bind", "UPtr", ListenSocket, "Ptr", sockaddr, "Int", 16) {
            MsgBox "Bind failed. Is port " Port " already in use?"
            DllCall("Ws2_32\closesocket", "UPtr", ListenSocket)
            ExitApp()
        }

        this.ListenSocket := ListenSocket
    }
    
    __Delete()
    {
        if (this.ClientSocket != -1)
            this.Disconnect()
    }

    
    Listen(backlog := 5) ; 32?
    {
        return DllCall("Ws2_32\listen", "UPtr", this.ListenSocket, "Int", backlog) == 0
    }
    
    Accept()
    {
        ; This pauses here until someone connects
        this.ClientSocket := DllCall("Ws2_32\accept", "UPtr", this.ListenSocket, "Ptr", 0, "Int", 0, "UPtr")
    
        return (this.ClientSocket >0)

        ; MsgBox this.ClientSocket

        ; if (this.ClientSocket == -1 || this.ClientSocket == 0)
        ;     throw Error("Error calling accept", , this.GetLastError())


    }

    Receive()
    {

        RecvBuf := Buffer(4096, 0)
        BytesReceived := DllCall("Ws2_32\recv", "UPtr", this.ClientSocket, "Ptr", RecvBuf, "Int", 4096, "Int", 0)
        
        ReceivedText := ""
        if (BytesReceived > 0) {
            ReceivedText := StrGet(RecvBuf, BytesReceived, "UTF-8")
        }
        return ReceivedText
    }
    
    Send(Response) {
        ResponseBuf := Buffer(StrPut(Response, "UTF-8") - 1)
        StrPut(Response, ResponseBuf, "UTF-8")
        DllCall("Ws2_32\send", "UPtr", this.ClientSocket, "Ptr", ResponseBuf, "Int", ResponseBuf.Size, "Int", 0)
    }

    MsgSize()
    {
        static FIONREAD := 0x4004667F
        argp := 0
        if (DllCall("Ws2_32\ioctlsocket", "UInt", this.Socket, "UInt", FIONREAD, "UInt*", &argp) == -1)
            throw Error("Error calling ioctlsocket", , this.GetLastError())
        return argp
    }
    
    ; SendBuffer(pBuffer, BufSize, Flags := 0)
    ; {
    ;     if ((r := DllCall("Ws2_32\send", "UInt", this.Socket, "Ptr", pBuffer, "Int", BufSize, "Int", Flags)) == -1)
    ;         throw Error("Error calling send", , this.GetLastError())
    ;     return r
    ; }
    
    ; SendText(Text, Flags := 0, Encoding := "UTF-8")
    ; {
    ;     BufSize := StrPut(Text, Encoding)
    ;     Buf := Buffer(BufSize)
    ;     StrPut(Text, Buf, Encoding)
    ;     return this.Send(Buf, BufSize - (Encoding = "UTF-16" || Encoding = "cp1200" ? 2 : 1))
    ; }
    
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
    
    ReceiveText(BufSize := 0, Flags := 0, Encoding := "UTF-8")
    {
        if (Length := this.Recv(&Buf, BufSize, Flags))
            return StrGet(Buf, Length, Encoding)
        return ""
    }
    
    RecvLine(BufSize := 0, Flags := 0, Encoding := "UTF-8", KeepEnd := False)
    {
        while !(i := InStr(this.ReceiveText(BufSize, Flags | Socket.MSG_PEEK, Encoding), "`n"))
        {
            if !Socket.Blocking
                return ""
            Sleep(Socket.BlockSleep)
        }
        if KeepEnd
            return this.ReceiveText(i, Flags, Encoding)
        else
            return RTrim(this.ReceiveText(i, Flags, Encoding), "`r`n")
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
    
   
    GetLastError()
    {
        return DllCall("Ws2_32\WSAGetLastError")
    }

    Disconnect()
    {
        if (this.ClientSocket == -1)
            return 0
        
        if (DllCall("Ws2_32\closesocket", "UInt", this.ClientSocket, "Int") == -1)
            throw Error("Error closing socket", , this.GetLastError())
        this.ClientSocket := -1
        return 1
    }
    
}
