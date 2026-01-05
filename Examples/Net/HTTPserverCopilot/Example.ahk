
#Requires AutoHotkey v2.0
Persistent

#Include socket.ahk
#Include httpserver.ahk

server := HttpServer(8080)

server.AddRoute("/", (req, res) => (
    res.Body := "Welcome home!"
))

server.AddRoute("/time", (req, res) => (
    res.Body := "Server time: " A_Now
))

server.AddRoute("/json", (req, res) => (
    res.SetHeader("Content-Type", "application/json"),
    res.Body := '{"status":"ok"}'
))

; http://localhost:8080

server.Start()
