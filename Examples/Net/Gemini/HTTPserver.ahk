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

#Requires AutoHotkey v2.0

class HttpServer {
    __New(port := 8080) {
        this.port := port
        this.routes := Map()

        this.sock := this.SocketCreate(2, 1, 6)
        this.sock.Bind("0.0.0.0", port)
        this.sock.Listen()
    }

    AddRoute(path, callback) {
        this.routes[path] := callback
    }

    SocketCreate(af, type, protocol) {
        static WSAData := Buffer(400)

        ; Initialize Winsock (idempotent)
        if DllCall("Ws2_32\WSAStartup", "UShort", 0x202, "Ptr", WSAData) != 0
            throw Error("WSAStartup failed")

        ; Create socket
        s := DllCall("Ws2_32\WSASocketW"
            , "Int", af
            , "Int", type
            , "Int", protocol
            , "Ptr", 0
            , "UInt", 0
            , "UInt", 0
            , "Ptr")

        if s = -1
            throw Error("WSASocketW failed. WSAGetLastError=" . DllCall("Ws2_32\WSAGetLastError"))

        return this.SocketFromHandle(s)
    }

    ; Wrap raw socket handle into an AHK Socket object
    SocketFromHandle(handle) {
        sock := Socket()
        sock.Handle := handle
        return sock
    }

    Start() {
        MsgBox "HTTP server running on port " this.port

        while true {
            client := this.sock.Accept()
            if !client
                continue

            raw := client.RecvText()
            if raw = ""
                continue

            req := HttpRequest(raw)
            res := HttpResponse()

            ; Routing
            if this.routes.Has(req.Path) {
                this.routes[req.Path](req, res)
            } else {
                res.Status := "404 Not Found"
                res.Body := "404 Not Found"
            }

            client.SendText(res.Build())
            client.Close()
        }
    }
}

class HttpRequest {
    __New(raw) {
        this.Raw := raw

        msgbox raw, "RAW"

        lines := StrSplit(raw, "`n")
        first := StrSplit(lines[1], " ")

        this.Method := first[1]
        this.Path   := first[2]
        this.Headers := Map()

        ; Parse headers
        for i, line in lines {
            if (i = 1 || line = "`r")
                continue
            if InStr(line, ":") {
                parts := StrSplit(line, ":")
                this.Headers[Trim(parts[1])] := Trim(parts[2])
            }
        }

        ; Body (if any)
        this.Body := ""
        if InStr(raw, "`r`n`r`n") {
            this.Body := StrSplit(raw, "`r`n`r`n")[2]
        }
    }
}

class HttpResponse {
    __New() {
        this.Status := "200 OK"
        this.Headers := Map("Content-Type", "text/plain")
        this.Body := ""
    }

    SetHeader(name, value) {
        this.Headers[name] := value
    }

    Build() {
        body := this.Body
        headers := ""

        for name, value in this.Headers {
            headers .= name ": " value "`r`n"
        }

        return (
        "HTTP/1.1 " this.Status "`r`n"
        headers
        "Content-Length: " StrLen(body) "`r`n"
        "Connection: close`r`n"
        "`r`n"
        body
        )
    }
}

class Socket {
    Handle := 0

    Bind(ip, port) {
        addr := MakeSockAddr(ip, port)
        if DllCall("Ws2_32\bind", "Ptr", this.Handle, "Ptr", addr, "Int", addr.Size) != 0
            throw Error("bind failed. WSAGetLastError=" . DllCall("Ws2_32\WSAGetLastError"))
    }

    Listen(backlog := 10) {
        if DllCall("Ws2_32\listen", "Ptr", this.Handle, "Int", backlog) != 0
            throw Error("listen failed. WSAGetLastError=" . DllCall("Ws2_32\WSAGetLastError"))
    }

    Accept() {
        h := DllCall("Ws2_32\accept", "Ptr", this.Handle, "Ptr", 0, "Ptr", 0, "Ptr")
        if h = -1
            return 0
        return this.SocketFromHandle(h)
    }

    SendText(text) {
        return DllCall("Ws2_32\send", "Ptr", this.Handle, "Ptr", StrPtr(text), "Int", StrLen(text), "Int", 0)
    }

    RecvText(max := 4096) {
        buf := Buffer(max, 0)
        r := DllCall("Ws2_32\recv", "Ptr", this.Handle, "Ptr", buf, "Int", max, "Int", 0)
        if r <= 0
            return ""
        return StrGet(buf, r)
    }

    SocketFromHandle(handle) {
        sock := Socket()
        sock.Handle := handle
        return sock
    }
    Close() {
        DllCall("Ws2_32\closesocket", "Ptr", this.Handle)
    }
}

MakeSockAddr(ip, port) {
    addr := Buffer(16, 0)
    NumPut("UShort", 2, addr, 0)                ; AF_INET
    NumPut("UShort", SwapShort(port), addr, 2)  ; port (network byte order)
    NumPut("UInt",  IpToInt(ip), addr, 4)       ; IPv4
    addr.Size := 16
    return addr
}

SwapShort(n) => (n >> 8) | ((n & 0xFF) << 8)

IpToInt(ip) {
    parts := StrSplit(ip, ".")
    return (parts[1] << 24) | (parts[2] << 16) | (parts[3] << 8) | parts[4]
}
; -------------------------
; Example usage
; -------------------------

; http://127.0.0.1:8080/

server := HttpServer(8080)

server.AddRoute("/", (req, res) => (
    res.Body := "Welcome home!"
))

server.AddRoute("/time", (req, res) => (
    res.Body := "Server time: " A_Now
))

server.AddRoute("/json", (req, res) => (
    res.SetHeader("Content-Type", "application/json"),
    res.Body := '{"status":"ok","msg":"Hello JSON"}'
))

server.Start()