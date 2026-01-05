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
;#NoTrayIcon

; ok #Include <RunAsAdmin>
#Include Messenger.ahk

TrayTip "Listening...", "Listen.ahk"

SetTimer(HideTrayTip, -1000) 

HideTrayTip() {
    TrayTip() ; Calling with no arguments clears the current notification
}


DetectHiddenWindows True

Persistent

; Start listening and define what to do with the data
Messenger.Listen(MyCallBackFunction)

MyCallBackFunction(Text, Type, SenderHWND) {

    MsgBox("From: " SenderHWND "`n`nType: " Type "`n`nContent: " Text)

    Messenger.Send(SenderHWND, "ACK: " Text, 0)

    if (Text="IPC_EXIT")
        Persistent false
}