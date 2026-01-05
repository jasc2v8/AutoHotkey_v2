#Requires AutoHotkey v2.0
#SingleInstance Force

#Include SharedSyncPeer.ahk


; ---------- Create client peer ----------
client := SharedSyncPeer(A_Temp "\shared_sync.ini", "CLIENT")


; ---------- Timer to send messages ----------
SetTimer(ClientSendTick, 1000)

ClientSendTick() {
    global client
    client.Send("Hello from CLIENT @ " FormatTime(A_Now, "HH:mm:ss"))
}
