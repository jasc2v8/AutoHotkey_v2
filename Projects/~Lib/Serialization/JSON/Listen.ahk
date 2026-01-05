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
#Include <CRC>
#Include <Messenger>
#Include <ListObj>
#Include <JSON>

TrayTip "Listening...", "Listen.ahk"

SetTimer(HideTrayTip, -1500) 

HideTrayTip() {
    TrayTip() ; Calling with no arguments clears the current notification
}

Persistent

ipc:= Messenger(CRC.Get64(A_ScriptName))

ipc.Listen(MyCallBackFunction)

MyCallBackFunction(Text, SenderHWND) {
    
    ;MsgBox("From Sender:`n`n" Text)

    ListObj("Listen: Received Text", Text)

    if (Text="IPC_EXIT") {
        Persistent false
        ExitApp()
    }

    ReceivedObject:= JSON.ToObject(Text)
    
    if (Text!="IPC_EXIT") and (InStr(Text, "ACK")=0)
        ListObj("ReceivedObject", ReceivedObject)
        ;ListObj("ReceivedObject", ReceivedObject)


    ipc.Send(SenderHWND, "ACK: " Text)

}