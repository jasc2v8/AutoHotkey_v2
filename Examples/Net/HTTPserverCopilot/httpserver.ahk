class HttpServer {
    __New(port := 8080) {
        this.port := port
        this.routes := Map()
        this.sock := Socket.CreateTCP()
        this.sock.Bind("0.0.0.0", port)
        this.sock.Listen()
    }

    AddRoute(path, callback) {
        this.routes[path] := callback
    }

    Start() {
        MsgBox "HTTP server running on port " this.port

        while true {
            client := this.sock.Accept()
            if !client
                continue

            raw := client.Recv()
            if raw = ""
                continue

            req := HttpRequest(raw)
            res := HttpResponse()

            if this.routes.Has(req.Path)
                this.routes[req.Path](req, res)
            else {
                res.Status := "404 Not Found"
                res.Body := "404 Not Found"
            }

            client.Send(res.Build())
            client.Close()
        }
    }
}

class HttpRequest {
    __New(raw) {
        this.Raw := raw
        lines := StrSplit(raw, "`n")
        first := StrSplit(lines[1], " ")

        this.Method := first[1]
        this.Path   := first[2]
        this.Headers := Map()

        for i, line in lines {
            if (i = 1 || line = "`r")
                continue
            if InStr(line, ":") {
                p := StrSplit(line, ":")
                this.Headers[Trim(p[1])] := Trim(p[2])
            }
        }

        this.Body := ""
        if InStr(raw, "`r`n`r`n")
            this.Body := StrSplit(raw, "`r`n`r`n")[2]
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
        h := ""
        for k, v in this.Headers
            h .= k ": " v "`r`n"

        return (
        "HTTP/1.1 " this.Status "`r`n"
        h
        "Content-Length: " StrLen(this.Body) "`r`n"
        "Connection: close`r`n"
        "`r`n"
        this.Body
        )
    }
}