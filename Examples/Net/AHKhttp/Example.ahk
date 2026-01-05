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
#NoTrayIcon

#include AHKhttp.ahk
#include AHKsock.ahk


paths := {}
paths["/"] := HelloWorld
paths["404"] := NotFound
paths["/logo"] := Logo

server := HttpServer()
server.LoadMimes(A_ScriptDir . "/mime.types")
server.SetPaths(paths)
server.Serve(8000)
return

Logo(&req, &res, &server) {
    server.ServeFile(res, A_ScriptDir . "/logo.png")
    res.status := 200
}

NotFound(&req, &res) {
    res.SetBodyText("Page not found")
}

HelloWorld(&req, &res) {
    res.SetBodyText("Hello World")
    res.status := 200
}

