; TITLE:    Server v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include SharedFile.ahk

OnMsg(from, msg) {
    ToolTip "Got from " from ": " msg
}

OnStale(peer) {
    ToolTip "Stale peer detected: " peer
}

peer := SharedSyncPeer(
    A_Temp "\shared_sync.ini",
    "USER",
    Func("OnMsg"),
    Func("OnStale")
)

SetTimer(SendTick, 2000)

SendTick() {
    global peer
    peer.Send("Hello @ " A_TickCount)
}
