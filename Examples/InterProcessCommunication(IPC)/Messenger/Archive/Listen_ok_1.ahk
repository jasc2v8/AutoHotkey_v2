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
#Include <CRC>

TrayTip "Listening...", "Listen.ahk"

SetTimer(HideTrayTip, -1000) 

HideTrayTip() {
    TrayTip() ; Calling with no arguments clears the current notification
}

DetectHiddenWindows True

Persistent

; Start listening and define what to do with the data
ipc:= Messenger(A_ScriptName, CRC.Get64(A_ScriptName))

ipc.Listen(MyCallBackFunction)

MyCallBackFunction(Text, SenderHWND) {
    
    MsgBox("From Sender:`n`n" Text)

    ipc.Send(SenderHWND, "ACK: " Text)

    if (Text="IPC_EXIT")
        Persistent false
}