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
Persistent(true)

#Include AHKsock.ahk
#Include server.ahk

; ==============================================================================
; GUI & INTERFACE SETUP
; ==============================================================================

MyGui := Gui("+AlwaysOnTop", "AHK v2 HTTP Server Console")
MyGui.SetFont("s9", "Consolas")
MyGui.OnEvent("Close", (*) => ExitApp())
LogCtrl := MyGui.Add("Edit", "r15 w500 ReadOnly")
BtnList := MyGui.Add("Button", "w120", "List Connections")
BtnList.OnEvent("Click", (*) => MsgBox(AHKsock_Global.GetConnectionList(), "Active Clients"))
MyGui.Show()

ServerLog("Script Initializing...")

ServerLog(Text) {
    try LogCtrl.Value .= FormatTime(, "HH:mm:ss") " | " Text "`r`n"
    SendMessage(0x0115, 7, 0, LogCtrl.Hwnd, "User32.dll") ; Scroll to bottom
}

; Initialize Website Directory
WebDir := A_ScriptDir "\www"
if !DirExist(WebDir) {
    DirCreate(WebDir)
    FileAppend("<html><body><h1>AHK v2 Server</h1><p>Running on 0.0.0.0:8080</p></body></html>", WebDir "\index.html", "UTF-8")
}

; Start the Server
try {
    ; Test if we can even start Winsock
    if (AHKsock_Startup() != 0)
        throw Error("Winsock failed to initialize.")

    MainServer := SimpleHttpServer(8080, WebDir)
    ServerLog("SUCCESS: Server started on http://localhost:8080")
    TrayTip "AHK Server Online", "Listening on port 8080"
} catch Error as e {
    MsgBox("FAILED TO START:`n" e.Message "`n`nCheck if port 8080 is already in use.", "Error", 16)
    ExitApp()
}

ServerLog("Waiting for connections...")

; Ensure the script doesn't exit after the setup
return
