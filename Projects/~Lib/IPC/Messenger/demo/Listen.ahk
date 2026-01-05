; TITLE  :  Listen v0.0
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
; icon needed for TrayTip #NoTrayIcon

; ok #Include <RunAsAdmin>
#Include Messenger.ahk
#Include <CRC>

TrayTip "Listening...", "Listen.ahk"

SetTimer(HideTrayTip, -1000) 

HideTrayTip() {
    TrayTip() ; Calling with no arguments clears the current notification
}

; DetectHiddenWindows True

Persistent

ipc:= Messenger(CRC.Get64(A_ScriptName))

ipc.Listen(MyCallBackFunction)

MyCallBackFunction(Text, SenderHWND) {
    
    MsgBox("From Sender:`n`n" Text)

    ipc.Send(SenderHWND, "ACK: " Text)

    if (Text="IPC_EXIT")
        Persistent false
}