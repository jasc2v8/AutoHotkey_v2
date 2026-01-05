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
;#NoTrayIcon

#Include <RunAsAdmin>


Persistent

#Include <ConsoleWindow>
#Include <LogFile>
#Include <String>
#Include Socket.ahk

;global console := ConsoleWindow("Console Window")
global logger := LogFile("D:\server.log", "SERVER")
global _Str := StrFunctions

; Using a continuation section for the HTML
; Note: We use double quotes for the string, and the inner JS alerts/styles 
; work well with the single quotes or escaped double quotes.
Template := "
( Join`r`n
HTTP/1.0 200 OK
Content-Type: text/html
Access-Control-Allow-Origin: *
Cache-Control: no-cache
Connection: close

<!DOCTYPE html>
<html>
    <head>
        <title>Go AutoHotkey!</title>
        <style>
            table, td {
                border-collapse: collapse;
                border: 1px solid black;
                padding: 5px;
            }
        </style>
    </head>
    <body>
        <h2>AHK v2 Server</h2>
        <table>
            {}
            <tr><td>Visitor Count</td><td>{}</td></tr>
        </table>
    </body>
</html>
)"

    logger.Write("Starting Server...")

    ; Instantiate the TCP Socket
    Server := Socket(5800) ; default 8080

    Server.Listen()

    TrayTip("Serving on port " Server.Port "...")
    Sleep 1500
    TrayTip

    global Template
    Counter := 0
    Table := ""
    
Loop {

    ; Accept the incoming connection
    ; if !Server.Accept() {

    ;     MsgBox ("Error accepting connection")

    ;     Sleep 10
    ;     continue
    ; }
    
    Server.Accept()

    ; Receive the text
    Request := Server.Receive()

    ;MsgBox '[' Request ']', "REQUEST"

    logger.Write("Request: " Request)

    if (Request == "")
        continue

    ; Handle the Routes
    if !_Str.Contains(Request, "GET")
    {
        Server.Send("HTTP/1.0 501 Not Implemented`r`n`r`n")
    }
    else if _Str.Contains(Request, "/exit")
    {
        Server.Send("HTTP/1.0 200 OK`r`n`r`nEXIT")
        Sleep 500
        Server.Disconnect()
        ; Persistent false
        ; ExitApp()
        break

    }
    else if _Str.Contains(Request, "/favicon.ico")
    {
        Server.Send("HTTP/1.0 301 Moved Permanently`r`nLocation: https://autohotkey.com/favicon.ico`r`n")
    }
    else if _Str.Contains(Request, "/")
    {
        Counter++
        Server.Send(Format(Template, Table, Counter))
    }
    else
    {
        Server.Send("HTTP/1.0 404 Not Found`r`n`r`nHTTP/1.0 404 Not Found")
    }
    
    logger.Write("Disconnect")

    Server.Disconnect()

}

Persistent false
ExitApp()
