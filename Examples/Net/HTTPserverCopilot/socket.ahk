#Requires AutoHotkey v2.0

class Socket {

    static Init() {

        MsgBox "init"
        static WSAData := Buffer(400)
        if DllCall("Ws2_32\WSAStartup", "UShort", 0x202, "Ptr", WSAData)
            throw Error("WSAStartup failed")
    }

    ; __New(handle) {

    ;             MsgBox "new"

    ;     this.Handle := handle
    ; }

    static CreateTCP() {
        h := DllCall("Ws2_32\WSASocketW"
            , "Int", 2      ; AF_INET
            , "Int", 1      ; SOCK_STREAM
            , "Int", 6      ; IPPROTO_TCP
            , "Ptr", 0
            , "UInt", 0
            , "UInt", 0
            , "Ptr")

        if h = -1
            throw Error("WSASocketW failed: " . DllCall("Ws2_32\WSAGetLastError"))

        return Socket(h)
    }

    Bind(ip, port) {
        addr := Socket.MakeAddr(ip, port)
        if DllCall("Ws2_32\bind", "Ptr", this.Handle, "Ptr", addr, "Int", addr.Size)
            throw Error("bind failed: " . DllCall("Ws2_32\WSAGetLastError"))
    }

    Listen(backlog := 10) {
        if DllCall("Ws2_32\listen", "Ptr", this.Handle, "Int", backlog)
            throw Error("listen failed: " . DllCall("Ws2_32\WSAGetLastError"))
    }

    Accept() {
        h := DllCall("Ws2_32\accept", "Ptr", this.Handle, "Ptr", 0, "Ptr", 0, "Ptr")
        return (h = -1) ? 0 : Socket(h)
    }

    Connect(ip, port) {
        addr := Socket.MakeAddr(ip, port)
        if DllCall("Ws2_32\connect", "Ptr", this.Handle, "Ptr", addr, "Int", addr.Size)
            throw Error("connect failed: " . DllCall("Ws2_32\WSAGetLastError"))
    }

    Send(data) {
        return DllCall("Ws2_32\send"
            , "Ptr", this.Handle
            , "Ptr", StrPtr(data)
            , "Int", StrLen(data)
            , "Int", 0)
    }

    Recv(max := 4096) {
        buf := Buffer(max, 0)
        r := DllCall("Ws2_32\recv"
            , "Ptr", this.Handle
            , "Ptr", buf
            , "Int", max
            , "Int", 0)

        return (r <= 0) ? "" : StrGet(buf, r)
    }

    Close() {
        DllCall("Ws2_32\closesocket", "Ptr", this.Handle)
    }

    ; sockaddr_in builder
    static MakeAddr(ip, port) {
        addr := Buffer(16, 0)
        NumPut("UShort", 2, addr, 0) ; AF_INET
        NumPut("UShort", DllCall("Ws2_32\htons", "UShort", port), addr, 2)
        NumPut("UInt", Socket.IpToInt(ip), addr, 4)
        addr.Size := 16
        return addr
    }

    static IpToInt(ip) {
        p := StrSplit(ip, ".")
        return (p[1] << 24) | (p[2] << 16) | (p[3] << 8) | p[4]
    }
}