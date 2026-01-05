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
Persistent

CoordMode "Mouse", "Screen"

; Ensure Socket.ahk (the v2 version we just converted) is in the same folder or library
#Include Socket.ahk

; Using a continuation section for the HTML
; Note: We use double quotes for the string, and the inner JS alerts/styles 
; work well with the single quotes or escaped double quotes.
Template := "
( Join`r`n
HTTP/1.0 200 OK
Content-Type: text/html

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
        <script>
            // Send requests sequentially so as to not overload the server
            var update = function(){
                var xhttp = new XMLHttpRequest();
                xhttp.onreadystatechange = function() {
                    if (xhttp.readyState == 4 && xhttp.status == 200) {
                        document.getElementById('mouse').innerHTML = xhttp.responseText;
                        setTimeout(update, 50);
                    }
                };
                xhttp.open('GET', 'mouse', true);
                xhttp.send();
            }
            setTimeout(update, 100);
        </script>
    </head>
    <body>
        <h2>AHK v2 Server</h2>
        <table>
            {}
            <tr><td>Visitor Count</td><td>{}</td></tr>
            <tr><td>Mouse Position</td><td id="mouse"></td></tr>
        </table>
    </body>
</html>
)"

; Instantiate the TCP Socket
Server := SocketTCP()
; In v2, you pass the function object directly
Server.OnAccept := OnAccept
Server.Bind(["0.0.0.0", 1337])
Server.Listen()

MsgBox("Serving on port 1337`nClose to ExitApp")
ExitApp()

OnAccept(ServerObj)
{
    global Template
    static Counter := 0
    Table := ""
    
    ; Accept the incoming connection
    Sock := ServerObj.Accept()
    
    ; Get the first line of the request (e.g., "GET / HTTP/1.1")
    FirstLine := Sock.RecvLine()
    if (FirstLine == "")
        return
        
    Request := StrSplit(FirstLine, " ")
    
    ; Empty the Recv buffer by reading headers
    while (Line := Sock.RecvLine())
    {
        Parts := StrSplit(Line, ": ", , 2)
        if (Parts.Length == 2)
            Table .= Format("<tr><td>{}</td><td>{}</td></tr>", Parts[1], Parts[2])
    }
    
    ; Handle the Routes
    if (Request[1] != "GET")
    {
        Sock.SendText("HTTP/1.0 501 Not Implemented`r`n`r`n")
    }
    else if (Request[2] == "/")
    {
        Counter++
        Sock.SendText(Format(Template, Table, Counter))
    }
    else if (Request[2] == "/mouse")
    {
        MouseGetPos(&x, &y)
        Sock.SendText("HTTP/1.0 200 OK`r`n`r`n" x "," y)
    }
    else if (Request[2] == "/favicon.ico")
    {
        Sock.SendText("HTTP/1.0 301 Moved Permanently`r`nLocation: https://autohotkey.com/favicon.ico`r`n")
    }
    else
    {
        Sock.SendText("HTTP/1.0 404 Not Found`r`n`r`nHTTP/1.0 404 Not Found")
    }
    
    Sock.Disconnect()
}
