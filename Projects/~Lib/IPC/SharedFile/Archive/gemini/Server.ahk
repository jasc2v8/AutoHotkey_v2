#Requires AutoHotkey v2.0
#SingleInstance Force

#Include SharedSyncPeer.ahk

TrayTip "Watching..."


; ---------- Create server peer ----------
server := SharedSyncPeer("D:\Watcher", "SERVER")


; ---------- Timer to send messages ----------
;SetTimer(ServerSendTick, 2000)

ServerSendTick() {
    global server
    server.Send("Hello from SERVER @ " FormatTime(A_Now, "HH:mm:ss"))
}
