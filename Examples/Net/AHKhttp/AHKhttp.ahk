#Requires AutoHotkey v2.0

class Uri {
    static Decode(str) {
        while RegExMatch(str, "i)(?<=%)[\da-f]{1,2}", &hex)
            str := StrReplace(str, "%" hex[0], Chr("0x" hex[0]))
        return str
    }

    static Encode(str) {
        pr := ""
        if RegExMatch(str, "^\w+:/{0,2}", &match) {
            pr := match[0]
            str := SubStr(str, StrLen(pr) + 1)
        }
        str := StrReplace(str, "%", "%25")
        while RegExMatch(str, "i)[^\w\.~%]", &char)
            str := StrReplace(str, char[0], "%" . Format("{:X}", Ord(char[0])))
        return pr . str
    }
}

class HttpServer {
    static servers := Map()
    mimes := Map()
    paths := Map()

    LoadMimes(file) {
        if (!FileExist(file))
            return false
        
        data := FileRead(file)
        for line in StrSplit(data, "`n", "`r") {
            if (line = "")
                continue
            info := StrSplit(line, [A_Space, A_Tab])
            type := info.RemoveAt(1)
            for ext in info {
                if (ext != "")
                    this.mimes[ext] := type
            }
        }
        return true
    }

    GetMimeType(file) {
        SplitPath(file, , , &ext)
        return this.mimes.Has(ext) ? this.mimes[ext] : "text/plain"
    }

    ServeFile(response, file) {
        buf := FileRead(file, "RAW")
        response.SetBody(buf)
        response.headers["Content-Type"] := this.GetMimeType(file)
    }

    Handle(request) {
        res := HttpResponse()
        if (!this.paths.Has(request.path)) {
            res.status := 404
            if (this.paths.Has("404"))
                this.paths["404"](request, res, this)
        } else {
            this.paths[request.path](request, res, this)
        }
        return res
    }

    Serve(port) {
        this.port := port
        HttpServer.servers[port] := this
        ; Requires a v2 version of AHKsock
        return AHKsock_Listen(port, "HttpHandler")
    }
}

; Note: This function assumes your AHKsock v2 library uses this signature
HttpHandler(sEvent, iSocket := 0, sName := 0, sAddr := 0, sPort := 0, bData := 0, bDataLength := 0) {
    static sockets := Map()

    if (!sockets.Has(iSocket)) {
        sockets[iSocket] := SocketClass(iSocket) ; Renamed to avoid conflict with built-in names
        AHKsock_SockOpt(iSocket, "SO_KEEPALIVE", true)
    }
    socket := sockets[iSocket]

    if (sEvent == "DISCONNECTED") {
        sockets.Delete(iSocket)
    } else if (sEvent == "SEND") {
        if (socket.TrySend())
            socket.Close()
    } else if (sEvent == "RECEIVED") {
        server := HttpServer.servers[sPort]
        text := StrGet(bData, bDataLength, "UTF-8")

        if (socket.request) {
            socket.request.body .= text
            socket.request.bytesLeft -= bDataLength
            req := socket.request
        } else {
            req := HttpRequest(text)
            len := req.headers.Has("Content-Length") ? Number(req.headers["Content-Length"]) : 0
            req.bytesLeft := len - StrLen(req.body)
            socket.request := req
        }

        if (req.bytesLeft <= 0)
            req.done := true

        if (req.done || req.IsMultipart()) {
            response := server.Handle(req)
            if (response.status)
                socket.SetData(response.Generate())
        }

        if (socket.TrySend()) {
            if (!req.IsMultipart() || req.done)
                socket.Close()
        }
    }
}

class HttpRequest {
    headers := Map()
    queries := Map()
    body := ""
    done := false

    __New(data := "") {
        if (data)
            this.Parse(data)
    }

    Parse(data) {
        sections := StrSplit(data, "`r`n`r`n", , 2)
        headerLines := StrSplit(sections[1], "`r`n")
        this.body := (sections.Length > 1) ? sections[2] : ""

        ; Parse Request Line
        reqLine := StrSplit(headerLines.RemoveAt(1), " ")
        this.method := reqLine[1]
        fullPath := Uri.Decode(reqLine[2])
        this.protocol := reqLine[3]

        ; Parse Query String
        if InStr(fullPath, "?") {
            parts := StrSplit(fullPath, "?", , 2)
            this.path := parts[1]
            for pair in StrSplit(parts[2], "&") {
                kv := StrSplit(pair, "=", , 2)
                this.queries[kv[1]] := (kv.Length > 1) ? kv[2] : ""
            }
        } else {
            this.path := fullPath
        }

        for line in headerLines {
            if InStr(line, ":") {
                kv := StrSplit(line, ":", , 2)
                this.headers[Trim(kv[1])] := Trim(kv[2])
            }
        }
    }

    IsMultipart() => (this.headers.Has("Expect") && this.headers["Expect"] = "100-continue")
}

class HttpResponse {
    headers := Map()
    status := 200
    protocol := "HTTP/1.1"
    body := Buffer(0)

    SetBody(buf) {
        this.body := buf
        this.headers["Content-Length"] := buf.Size
    }

    SetBodyText(text) {
        buf := Buffer(StrPut(text, "UTF-8") - 1)
        StrPut(text, buf, "UTF-8")
        this.SetBody(buf)
    }

    Generate() {
        this.headers["Date"] := FormatTime(, "ddd, dd MMM yyyy HH:mm:ss 'GMT'")
        
        statusText := (this.status = 200) ? "OK" : (this.status = 404 ? "Not Found" : "Error")
        head := this.protocol " " this.status " " statusText "`r`n"
        for k, v in this.headers
            head .= k ": " v "`r`n"
        head .= "`r`n"

        headBuf := Buffer(StrPut(head, "UTF-8") - 1)
        StrPut(head, headBuf, "UTF-8")
        
        finalBuf := Buffer(headBuf.Size + this.body.Size)
        DllCall("RtlMoveMemory", "Ptr", finalBuf.Ptr, "Ptr", headBuf.Ptr, "UInt", headBuf.Size)
        DllCall("RtlMoveMemory", "Ptr", finalBuf.Ptr + headBuf.Size, "Ptr", this.body.Ptr, "UInt", this.body.Size)
        
        return finalBuf
    }
}

class SocketClass {
    request := ""
    data := ""
    
    __New(socket) => this.socket := socket
    Close() => AHKsock_Close(this.socket)
    SetData(data) => this.data := data

    TrySend() {
        if (!this.data) return false
        ; Note: AHKsock_Send usually takes (Socket, Pointer, Length)
        res := AHKsock_Send(this.socket, this.data.Ptr, this.data.Size)
        if (res >= 0) {
            this.data := ""
            return true
        }
        return false
    }
}