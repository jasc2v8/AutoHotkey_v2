; TITLE  :  HttpServerExample v0.0
; SOURCE :  https://github.com/thqby/ahk2_lib
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
;TraySetIcon('imageres.dll', 328) ; Media server
TraySetIcon('D:\Software\DEV\Work\AHK2\Icons\media_server.ico') ; Media server

#Include  <RunAsAdmin>
#Include HttpServer.ahk

;@Ahk2Exe-SetMainIcon D:\Software\DEV\Work\AHK2\Icons\media_server.ico

SetScriptIcon('D:\Software\DEV\Work\AHK2\Icons\media_server.ico')

SetScriptIcon(IconPath) {
    if !FileExist(IconPath)
        return
    
    ; Load the icon from the file
    ; 0x1 is IMAGE_ICON, 0 and 0 for width/height uses the actual icon size
    hIcon := DllCall("LoadImage", "Ptr", 0, "Str", IconPath, "UInt", 1, "Int", 0, "Int", 0, "UInt", 0x10)
    
    if hIcon {
        ; 0x80 is WM_SETICON
        ; 0 = ICON_SMALL (Taskbar/Task Manager), 1 = ICON_BIG (Alt-Tab)
        SendMessage(0x80, 0, hIcon, A_ScriptHwnd) ; Small icon
        SendMessage(0x80, 1, hIcon, A_ScriptHwnd) ; Big icon
    }
}

Persistent()

myPID := ProcessExist()

TrayTip('Media Server Started PID: ' myPID)
; Sleep 2000
; TrayTip
SetTimer(HideTrayTip, -2000) 
HideTrayTip() {
	TrayTip()
}


;hs := HttpServer()
;hs.Add('http://127.0.0.1:1212/', handler)

; ok hs.Add('http://127.0.0.1:5800/', handler)

; Monitor all IPs on the current computer, requiring administrator privileges
;hs.Add('http://+:1212/', handler)
; hs.Add('http://+:5800/', handler)

; handler(req, rsp) {
; 	switch req.rawurl {
; 		case '/bye': ExitApp()
; 		case '/upload': rsp['Content-Type'] := 'application/json', rsp(req.Content)
; 		;case '/ws': WebSocketSession(req, rsp).OnMessage := (this, data) => this.Send(data)
; 		case '/': rsp('<body><form action="/upload" method="POST" enctype="multipart/form-data"><div>username<input type="text" name="username"></div><div>password<input type="text" name="password"></div><div><button type="submit">submit</button></div></form></body>')
; 		default: rsp(, 404)
; 	}
; }


server := HttpServer(8080)

; 1. Initialize the server and define the port immediately
server := HttpServer(8080)

; 2. Define your routes
server.OnGet("/", (req, res) => {
    res.SetStatus(200)
    res.SetBody("<h1>Server is Active</h1>")
})

; 3. Start the server
server.Serve()

MsgBox("Server is running on http://localhost:8080`nPress OK to exit.")